// To parse this JSON data, do
//
//     final updateExistingDrawer = updateExistingDrawerFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/getPmsWorkList.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/models/ws_get_pms_structure.dart';

UpdateExistingDrawer updateExistingDrawerFromJson(String str) =>
    UpdateExistingDrawer.fromJson(json.decode(str));

String updateExistingDrawerToJson(UpdateExistingDrawer data) =>
    json.encode(data.toJson());

class UpdateExistingDrawer {
  UpdateExistingDrawerResponse? response;

  UpdateExistingDrawer({
    this.response,
  });

  factory UpdateExistingDrawer.fromJson(Map<String, dynamic> json) =>
      UpdateExistingDrawer(
        response: json["Response"] == null
            ? null
            : UpdateExistingDrawerResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class UpdateExistingDrawerResponse {
  String? errorCode;
  String? msg;
  DateTime? pmsStartDate;
  DateTime? pmsEndDate;
  List<AddedPmsList>? changeData;
  List<AddedPmsList>? addedPmsList;

  UpdateExistingDrawerResponse({
    this.errorCode,
    this.msg,
    this.pmsStartDate,
    this.pmsEndDate,
    this.changeData,
    this.addedPmsList,
  });

  factory UpdateExistingDrawerResponse.fromJson(Map<String, dynamic> json) =>
      UpdateExistingDrawerResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        pmsStartDate: json["pms_start_date"] == null
            ? null
            : DateTime.parse(json["pms_start_date"]),
        pmsEndDate: json["pms_end_date"] == null
            ? null
            : DateTime.parse(json["pms_end_date"]),
        changeData: json["change_data"] == null
            ? []
            : List<AddedPmsList>.from(
                json["change_data"]!.map((x) => AddedPmsList.fromJson(x))),
        addedPmsList: json["added_pms_list"] == null
            ? []
            : List<AddedPmsList>.from(
                json["added_pms_list"]!.map((x) => AddedPmsList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "pms_start_date":
            "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
        "pms_end_date":
            "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
        "change_data": changeData == null
            ? []
            : List<dynamic>.from(changeData!.map((x) => x.toJson())),
        "added_pms_list": addedPmsList == null
            ? []
            : List<dynamic>.from(addedPmsList!.map((x) => x.toJson())),
      };
}

class AddedPmsList {
  String? mstPmsId;
  String? parentIdFk;
  String? pmsCategoryName;
  String? pmsOrderNo;
  String? pmsColorCode;
  DateTime? pmsStartDate;
  DateTime? pmsEndDate;
  String? workIdFk;
  String? progressPercentage;
  String? totolPercentage;
  String? consumePercentage;
  String? checkStatus;
  String? parentStartDate;
  String? parentEndDate;
  List<WorkOrderList>? workOrderDetails;
  String? pmsTotalDays;
  List<RemarkList>? remarkList;
  List<dynamic>? details;
  DateTime? cmsOriginalStartDate;
  DateTime? cmsOriginalEndDate;

  DateTime? minDate;
  DateTime? maxDate;

  AddedPmsList({
    this.mstPmsId,
    this.parentIdFk,
    this.pmsCategoryName,
    this.pmsOrderNo,
    this.pmsColorCode,
    this.pmsStartDate,
    this.pmsEndDate,
    this.workIdFk,
    this.progressPercentage,
    this.totolPercentage,
    this.consumePercentage,
    this.checkStatus,
    this.parentStartDate,
    this.parentEndDate,
    this.workOrderDetails,
    this.pmsTotalDays,
    this.remarkList,
    this.details,
    this.minDate,
    this.maxDate,
    this.cmsOriginalStartDate,
    this.cmsOriginalEndDate,
  });

  factory AddedPmsList.fromJson(Map<String, dynamic> json) => AddedPmsList(
        mstPmsId: json["mst_pms_id"],
        parentIdFk: json["parent_id_fk"],
        pmsCategoryName: json["pms_category_name"],
        pmsOrderNo: json["pms_order_no"],
        pmsColorCode: json["pms_color_code"],
        pmsStartDate:
            json["pms_start_date"] == null || json["pms_start_date"] == ""
                ? DateTime(2000)
                : DateTime.parse(json["pms_start_date"]),
        pmsEndDate: json["pms_end_date"] == null || json["pms_end_date"] == ""
            ? DateTime(2101)
            : DateTime.parse(json["pms_end_date"]),
        workIdFk: json["work_id_fk"],
        progressPercentage: json["progress_percentage"],
        totolPercentage: json["totol_percentage"],
        consumePercentage: json["consume_percentage"],
        checkStatus: json["check_status"],
        parentStartDate: json["parent_start_date"],
        parentEndDate: json["parent_end_date"],
        pmsTotalDays: json["pms_total_days"],
        minDate: json["min_date"] == ''
            ? DateTime(2101) //DateTime(2000)
            : DateTime.parse(json["min_date"]),
        maxDate: json["max_date"] == ''
            ? DateTime(2000) //DateTime(2101)
            : DateTime.parse(json["max_date"]),
        remarkList: json["remark_list"] == null
            ? []
            : List<RemarkList>.from(
                json["remark_list"]!.map((x) => RemarkList.fromJson(x))),
        workOrderDetails: json["work_order_details"] == null
            ? null
            : List<WorkOrderList>.from(json["work_order_details"]!
                .map((x) => WorkOrderList.fromJson(x))),
        details: json["details"] == null
            ? []
            : List<dynamic>.from(json["details"]!.map((x) => x)),
        cmsOriginalStartDate: json["cms_original_start_date"] == null ||
                json["cms_original_start_date"] == ""
            ? null
            : DateTime.parse(json["cms_original_start_date"]),
        cmsOriginalEndDate: json["cms_original_end_date"] == null ||
                json["cms_original_end_date"] == ""
            ? null
            : DateTime.parse(json["cms_original_end_date"]),
      );

  Map<String, dynamic> toJson() => {
        "mst_pms_id": mstPmsId,
        "parent_id_fk": parentIdFk,
        "pms_category_name": pmsCategoryName,
        "pms_order_no": pmsOrderNo,
        "pms_color_code": pmsColorCode,
        "pms_start_date":
            "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
        "pms_end_date":
            "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
        "work_id_fk": workIdFk,
        "progress_percentage": progressPercentage,
        "totol_percentage": totolPercentage,
        "consume_percentage": consumePercentage,
        "check_status": checkStatus,
        "parent_start_date": parentStartDate,
        "parent_end_date": parentEndDate,
        "work_order_details": workOrderDetails == null
            ? []
            : List<dynamic>.from(workOrderDetails!.map((x) => x.toJson())),
        "pms_total_days": pmsTotalDays,
        "remark_list": remarkList == null
            ? []
            : List<dynamic>.from(remarkList!.map((x) => x.toJson())),
        "min_date":
            "${minDate!.year.toString().padLeft(4, '0')}-${minDate!.month.toString().padLeft(2, '0')}-${minDate!.day.toString().padLeft(2, '0')}",
        "max_date":
            "${maxDate!.year.toString().padLeft(4, '0')}-${maxDate!.month.toString().padLeft(2, '0')}-${maxDate!.day.toString().padLeft(2, '0')}",
        "details":
            details == null ? [] : List<dynamic>.from(details!.map((x) => x)),
        "cms_original_start_date":
            "${cmsOriginalStartDate!.year.toString().padLeft(4, '0')}-${cmsOriginalStartDate!.month.toString().padLeft(2, '0')}-${cmsOriginalStartDate!.day.toString().padLeft(2, '0')}",
        "cms_original_end_date":
            "${cmsOriginalEndDate!.year.toString().padLeft(4, '0')}-${cmsOriginalEndDate!.month.toString().padLeft(2, '0')}-${cmsOriginalEndDate!.day.toString().padLeft(2, '0')}",
      };
}
