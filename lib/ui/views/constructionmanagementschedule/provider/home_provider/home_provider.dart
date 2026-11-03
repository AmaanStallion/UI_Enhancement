import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/getPmsWorkList.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/nodee.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/provider/home_provider/fetch_api_provider.dart';
import 'package:stallion/ui/views/salesmanagement/salesleads/salesleadPage.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/custom_date_picker.dart';

import '../../models/ws_get_pms_structure.dart';
import '../provider_registration.dart';

class HomeProvider extends ChangeNotifier {
  late ChangeNotifierProviderRef<HomeProvider> ref;
  HomeProvider(this.ref);
  TextEditingController controllerWorkOrderPercentageDrawer =
      TextEditingController();
  DateTime? isClickedStartDate;
  String? drawerTitle;
  String selectedWorkOrder = "";
  String isSelectedFilterView = "DAYS"; // DAYS  WEEK  MONTH  YEAR
  DateTime? isClickedEndDate;
  PmsStructure? dictDrawerData;
  Node? curNodeDrawerData;
  TextEditingController startDateControlerDrawer = TextEditingController();
  TextEditingController endDateControlerDrawer = TextEditingController();
  double workCompletePercentageValue = 0.0;

  DateTime? selectedStartDateDrawer;
  DateTime? selectedEndDateDrawer;

  TextEditingController workOrderControlerDrawer = TextEditingController();
  WorkOrderList? workOrderListSelected;
  int checkboxValue = 1;
  void updateCheckboxValue(int value) {
    // setState(() {
    checkboxValue = value;
    // });
    notifyListeners();
  }

  setWorkOrderListSelected(WorkOrderList? data) {
    workOrderListSelected = data;
    notifyListeners();
  }

  setWorkCompletePercentageValue(double vall) {
    workCompletePercentageValue = vall;
    notifyListeners();
  }

  setIsSelectedFilterView(String data) {
    isSelectedFilterView = data;
    notifyListeners();
  }

  Future<void> selectStartDateDrawer({
    required BuildContext context,
    required DateTime startDateRes,
    required DateTime endDateRes,
    required TextEditingController control,
    required TextEditingController controlday,
    required DateTime endDateResponse,
    required DupliacateDataPms currData,
    required int inndex,
  }) async {
    DateTime? selectedStartDateDrawerDrawer;
    print(
        '${currData.pmsStartDate} ------- ${currData.minDate} ==== ${startDateRes} ${DateTime.now().isBefore(currData.minDate!)}');

    print(
        '${currData.parentStartDate} ==== parentStartDate ${currData.pmsCategoryName}');
    DateTime initialDateCalender(DupliacateDataPms currData) {
      if (currData.pmsStartDate == DateTime(2000) ||
          currData.pmsStartDate == null) {
        if (DateTime.now().isBefore(currData.minDate!) == false) {
          return currData.minDate!;
        } else {
          return DateTime.now();
        }
      } else {
        return currData.pmsStartDate!;
        // return currData.parentStartDate!;
      }
    }

    print(
        'initialDateCalender ->${initialDateCalender(currData)} firstDate ->${startDateRes} lastDate ->${currData.minDate == DateTime(2101) || currData.minDate == DateTime(1970) ? DateTime(2101) : currData.minDate!}');

    final DateTime firstDate = startDateRes;
    final DateTime lastDate =
        currData.minDate == DateTime(2101) || currData.minDate == DateTime(2000)
            ? DateTime(2101)
            : currData.minDate!;

    DateTime initialDate = initialDateCalender(currData);

// Ensure initialDate is within bounds
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    } else if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final DateTime? picked = await showAutoFormatDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    // final DateTime? picked = await showDatePicker(
    //   context: context,
    //   initialDate: initialDateCalender(currData),
    //   // currData.pmsStartDate == DateTime(2000) ||
    //   //         currData.pmsStartDate == null
    //   //     ? DateTime.now()
    //   //     : currData.pmsStartDate!, //?? startDateRes,
    //   firstDate: startDateRes, //DateTime(2000),
    //   lastDate: currData.minDate == DateTime(2101) ||
    //           currData.minDate == DateTime(1970)
    //       ? DateTime(2101)
    //       : currData.minDate!,
    //   // currData.pmsEndDate == DateTime(2101) || currData.pmsEndDate == null
    //   //     ? DateTime(2101)
    //   //     : currData.pmsEndDate!, //endDateRes, //DateTime(2101),
    // );
    if (picked != null && picked != selectedStartDateDrawerDrawer) {
      if (currData.pmsEndDate != null) {
        if (picked.isAfter(currData.pmsEndDate!)) {
          currData.pmsEndDate = null;
        }
      }

      selectedStartDateDrawerDrawer = picked;
      currData.pmsStartDate = picked;

      control.text = DateFormat('dd/MM/yyyy').format(picked);
      notifyListeners();
      if (endDateResponse != DateTime(2101)) {
        // controlday.text =
        //     (((endDateResponse.difference(picked)).inDays)).toString();
        // currData.totalDays =
        //     (((endDateResponse.difference(picked)).inDays)).toString();
        currData.pmsEndDate = currData.pmsStartDate!
            .add(Duration(days: int.parse(currData.totalDays ?? '0')));
        notifyListeners();
      }

      String parentIdd = currData.parentIdFk ?? '';

      for (int k = inndex; k >= 0; k--) {
        for (int l = k; l >= 0; l--) {
          if (parentIdd ==
              ref
                  .read(fetchApiProvider)
                  .pmsStructureForDuplicating?[l]
                  .mstPmsId) {
            print(ref
                .read(fetchApiProvider)
                .pmsStructureForDuplicating?[l]
                .pmsCategoryName);
            if (ref
                        .read(fetchApiProvider)
                        .pmsStructureForDuplicating?[l]
                        .pmsStartDate ==
                    DateTime(2000) ||
                ref
                        .read(fetchApiProvider)
                        .pmsStructureForDuplicating?[l]
                        .pmsStartDate ==
                    null) {
              print(
                  '${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsCategoryName} -----==   ${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsStartDate == DateTime(2000)}');

              ref
                  .read(fetchApiProvider)
                  .pmsStructureForDuplicating?[l]
                  .pmsStartDate = picked;
              // print(ref
              //     .read(fetchApiProvider)
              //     .pmsStructureForDuplicating?[l]
              //     .pmsStartDate);
              // notifyListeners();
            }
            parentIdd = ref
                    .read(fetchApiProvider)
                    .pmsStructureForDuplicating?[l]
                    .parentIdFk ??
                '';
            Duration difference = Duration.zero;
            if (ref
                    .read(fetchApiProvider)
                    .pmsStructureForDuplicating?[l]
                    .pmsStartDate !=
                null) {
              difference = ref
                      .read(fetchApiProvider)
                      .pmsStructureForDuplicating?[l]
                      .pmsStartDate!
                      .difference(picked) ??
                  Duration.zero;
            }

            if (difference.inDays > 0) {
              ref
                      .read(fetchApiProvider)
                      .pmsStructureForDuplicating?[l]
                      .minDate =
                  ref
                      .read(fetchApiProvider)
                      .pmsStructureForDuplicating?[l]
                      .pmsStartDate!
                      .subtract(Duration(days: difference.inDays));
              ref
                      .read(fetchApiProvider)
                      .pmsStructureForDuplicating?[l]
                      .pmsStartDate =
                  ref
                      .read(fetchApiProvider)
                      .pmsStructureForDuplicating?[l]
                      .pmsStartDate!
                      .subtract(Duration(days: difference.inDays));

              ref
                      .read(fetchApiProvider)
                      .pmsStructureForDuplicating?[l]
                      .totalDays =
                  ref
                      .read(fetchApiProvider)
                      .pmsStructureForDuplicating![l]
                      .pmsEndDate!
                      .difference(ref
                              .read(fetchApiProvider)
                              .pmsStructureForDuplicating?[l]
                              .pmsStartDate ??
                          DateTime.now())
                      .inDays
                      .toString();
              notifyListeners();
            }
          }
        }
      }
      // (((picked.difference(endDateResponse)).inDays)).toString();

      // startDateControlerDrawer.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> selectEndDateDrawer({
    required BuildContext context,
    required DateTime startDateRes,
    required DateTime endDateRes,
    required TextEditingController control,
    required TextEditingController controlday,
    required DateTime startDateResponse,
    required DupliacateDataPms currData,
    required int inndex,
  }) async {
    DateTime? selectedEndDateDrawerDrawer;

    DateTime selectEndStartDateCalender() {
      if (currData.maxDate == DateTime(2000)) {
        return startDateResponse;
      } else {
        return currData.maxDate!;
      }
    }

    DateTime selectStartInitialDateCalender() {
      if (currData.pmsEndDate == DateTime(2101) ||
          currData.pmsEndDate == null) {
        if (DateTime.now().isAfter(selectEndStartDateCalender())) {
          return DateTime.now();
        } else {
          return selectEndStartDateCalender();
        }
      } else {
        return currData.pmsEndDate!;
      }
    }

    final DateTime? picked = await showAutoFormatDatePicker(
      context: context,
      initialDate: selectStartInitialDateCalender(),
      firstDate: selectEndStartDateCalender(),
      lastDate: endDateRes,
    );
    // final DateTime? picked = await showDatePicker(
    //   context: context,
    //   initialDate: selectStartInitialDateCalender(),
    //   // currData.pmsEndDate == DateTime(2101) || currData.pmsEndDate == null
    //   //     ? DateTime.now()
    //   //     : currData.pmsEndDate!, //?? endDateRes,
    //   firstDate: selectEndStartDateCalender(),
    //  currData.maxDate == DateTime(2000)
    //     ? DateTime(2000)
    //     : currData.maxDate!,
    // currData.pmsStartDate == DateTime(2000) ||
    //         currData.pmsStartDate == null
    //     ? DateTime(2000)
    //     : currData.pmsStartDate!, //startDateRes, //DateTime(2000),
    // lastDate: endDateRes, //DateTime(2101),
    // );
    if (picked != null && picked != selectedEndDateDrawerDrawer) {
      selectedEndDateDrawerDrawer = picked;
      currData.pmsEndDate = picked;
      control.text = DateFormat('dd/MM/yyyy').format(picked);
      // controlday.text = startDateResponse.difference(picked).inDays.toString();
      if (startDateResponse != DateTime(2000)) {
        // controlday.text =
        //     (((picked.difference(startDateResponse)).inDays)).toString();
        currData.totalDays =
            (((picked.difference(startDateResponse)).inDays)).toString();
        notifyListeners();
      }

      // String parentIdd = currData.parentIdFk ?? '';
      // for (int k = inndex; k >= 0; k--) {
      //   for (int l = k; l >= 0; l--) {
      //     if (parentIdd ==
      //         ref
      //             .read(fetchApiProvider)
      //             .pmsStructureForDuplicating?[l]
      //             .mstPmsId) {
      //       print(
      //           '${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsCategoryName} -----==   ${ref.read(fetchApiProvider).pmsStructureForDuplicating?[l].pmsEndDate == DateTime(2101)}');

      //       if (ref
      //               .read(fetchApiProvider)
      //               .pmsStructureForDuplicating?[l]
      //               .pmsEndDate ==
      //           DateTime(2101)) {
      //         ref
      //             .read(fetchApiProvider)
      //             .pmsStructureForDuplicating?[l]
      //             .pmsEndDate = picked;
      //       }
      //       parentIdd = ref
      //               .read(fetchApiProvider)
      //               .pmsStructureForDuplicating?[l]
      //               .parentIdFk ??
      //           '';

      //       Duration difference = picked.difference(ref
      //               .read(fetchApiProvider)
      //               .pmsStructureForDuplicating?[l]
      //               .pmsEndDate ??
      //           DateTime.now());

      //       if (difference.inDays > 0) {
      //         ref
      //                 .read(fetchApiProvider)
      //                 .pmsStructureForDuplicating?[l]
      //                 .maxDate =
      //             ref
      //                 .read(fetchApiProvider)
      //                 .pmsStructureForDuplicating?[l]
      //                 .pmsEndDate!
      //                 .add(Duration(days: difference.inDays));
      //         ref
      //                 .read(fetchApiProvider)
      //                 .pmsStructureForDuplicating?[l]
      //                 .pmsEndDate =
      //             ref
      //                 .read(fetchApiProvider)
      //                 .pmsStructureForDuplicating?[l]
      //                 .pmsEndDate!
      //                 .add(Duration(days: difference.inDays));

      //         ref
      //                 .read(fetchApiProvider)
      //                 .pmsStructureForDuplicating?[l]
      //                 .totalDays =
      //             ref
      //                 .read(fetchApiProvider)
      //                 .pmsStructureForDuplicating![l]
      //                 .pmsEndDate!
      //                 .difference(ref
      //                         .read(fetchApiProvider)
      //                         .pmsStructureForDuplicating?[l]
      //                         .pmsStartDate ??
      //                     DateTime.now())
      //                 .inDays
      //                 .toString();
      //         notifyListeners();
      //       }
      //     }
      //   }
      // }
    }
  }

  clearData() {
    dictDrawerData = null;
    isSelectedFilterView = "DAYS";
    notifyListeners();
  }

  setSelectedStartDateDrawer(
      {required DateTime startdata,
      required DateTime enddata,
      required PmsStructure data,
      required String drawerTitle1,
      required DateTime isClickedStartDate,
      required DateTime isClickedEndDate,
      required Node curNode,
      required}) {
    // ref.read(homeProvider).updateCheckboxValue(data.checkStatus == '1' ? 1 : 0);
    controllerWorkOrderPercentageDrawer.text =
        '${double.parse(data.consumePercentage ?? '0')}';
    checkboxValue = data.checkStatus == "1" ? 1 : 0;
    selectedStartDateDrawer = startdata;
    startDateControlerDrawer.text = DateFormat('dd/MM/yyyy').format(startdata);
    selectedEndDateDrawer = enddata;
    endDateControlerDrawer.text = DateFormat('dd/MM/yyyy').format(enddata);
    dictDrawerData = data;
    curNodeDrawerData = curNode;
    drawerTitle = drawerTitle1;
    isClickedStartDate = isClickedStartDate;
    isClickedEndDate = isClickedEndDate;
    workCompletePercentageValue =
        double.parse(data.consumePercentage ?? '0') / 100;
    ref.read(fetchApiProvider).arrWidget.clear();
    workOrderControlerDrawer.clear();
    workOrderListSelected =
        data.workOrderDetails?.length == 0 ? null : data.workOrderDetails?[0];
    if (data.workOrderDetails?.length != 0 && data.workOrderDetails != null) {
      workOrderControlerDrawer.text =
          '${data.workOrderDetails?[0].workOrderNumber}';
      // \n ${data.workOrderDetails?[0].mstCompanyName}  |  ${data.workOrderDetails?[0].skillType}';
    } else {
      workOrderControlerDrawer.clear();
    }
    notifyListeners();
  }
}
