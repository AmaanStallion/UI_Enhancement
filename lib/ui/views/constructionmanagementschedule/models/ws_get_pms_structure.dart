// To parse this JSON data, do
//
//     final projectSchedule = projectScheduleFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/getPmsWorkList.dart';

ProjectSchedule projectScheduleFromJson(String str) =>
    ProjectSchedule.fromJson(json.decode(str));

String projectScheduleToJson(ProjectSchedule data) =>
    json.encode(data.toJson());

class ProjectSchedule {
  ResponseProjectSchedule? response;

  ProjectSchedule({
    this.response,
  });

  factory ProjectSchedule.fromJson(Map<String, dynamic> json) =>
      ProjectSchedule(
        response: json["Response"] == null
            ? null
            : ResponseProjectSchedule.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseProjectSchedule {
  String? errorCode;
  String? msg;
  DateTime? pmsStartDate;
  List<ProjectPmsInfo>? projectPmsInfo;
  String? defaultFlag;
  DateTime? pmsEndDate;
  List<PmsStructure>? pmsStructure;

  ResponseProjectSchedule({
    this.errorCode,
    this.msg,
    this.pmsStartDate,
    this.projectPmsInfo,
    this.pmsEndDate,
    this.pmsStructure,
    this.defaultFlag,
  });

  factory ResponseProjectSchedule.fromJson(Map<String, dynamic> json) =>
      ResponseProjectSchedule(
        errorCode: json["error_code"],
        msg: json["msg"],
        defaultFlag: json["default_flag"],
        projectPmsInfo: json["project_pms_info"] == null
            ? []
            : List<ProjectPmsInfo>.from(json["project_pms_info"]!
                .map((x) => ProjectPmsInfo.fromJson(x))),
        pmsStartDate: json["pms_start_date"] == null
            ? null
            : DateTime.parse(json["pms_start_date"]),
        pmsEndDate: json["pms_end_date"] == null
            ? null
            : DateTime.parse(json["pms_end_date"]),
        pmsStructure: json["pms_structure"] == null
            ? []
            : List<PmsStructure>.from(
                json["pms_structure"]!.map((x) => PmsStructure.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "default_flag": defaultFlag,
        "project_pms_info": projectPmsInfo == null
            ? []
            : List<dynamic>.from(projectPmsInfo!.map((x) => x.toJson())),
        "pms_start_date":
            "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
        "pms_end_date":
            "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
        "pms_structure": pmsStructure == null
            ? []
            : List<dynamic>.from(pmsStructure!.map((x) => x.toJson())),
      };
}

class ProjectPmsInfo {
  String? mstProjectPmsId;
  String? projectIdFk;
  String? towarIdFk;
  String? developerIdFk;
  String? projectPmsName;
  DateTime? projectPmsStartDate;
  DateTime? projectPmsEndDate;
  String? projectPmsStatus;
  DateTime? projectPmsUpdatedAt;
  DateTime? projectPmsCreatedAt;

  ProjectPmsInfo({
    this.mstProjectPmsId,
    this.projectIdFk,
    this.towarIdFk,
    this.developerIdFk,
    this.projectPmsName,
    this.projectPmsStartDate,
    this.projectPmsEndDate,
    this.projectPmsStatus,
    this.projectPmsUpdatedAt,
    this.projectPmsCreatedAt,
  });

  factory ProjectPmsInfo.fromJson(Map<String, dynamic> json) => ProjectPmsInfo(
        mstProjectPmsId: json["mst_project_pms_id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        developerIdFk: json["developer_id_fk"],
        projectPmsName: json["project_pms_name"],
        projectPmsStartDate: json["project_pms_start_date"] == null
            ? null
            : DateTime.parse(json["project_pms_start_date"]),
        projectPmsEndDate: json["project_pms_end_date"] == null
            ? null
            : DateTime.parse(json["project_pms_end_date"]),
        projectPmsStatus: json["project_pms_status"],
        projectPmsUpdatedAt: json["project_pms_updated_at"] == null
            ? null
            : DateTime.parse(json["project_pms_updated_at"]),
        projectPmsCreatedAt: json["project_pms_created_at"] == null
            ? null
            : DateTime.parse(json["project_pms_created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "mst_project_pms_id": mstProjectPmsId,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "developer_id_fk": developerIdFk,
        "project_pms_name": projectPmsName,
        "project_pms_start_date":
            "${projectPmsStartDate!.year.toString().padLeft(4, '0')}-${projectPmsStartDate!.month.toString().padLeft(2, '0')}-${projectPmsStartDate!.day.toString().padLeft(2, '0')}",
        "project_pms_end_date":
            "${projectPmsEndDate!.year.toString().padLeft(4, '0')}-${projectPmsEndDate!.month.toString().padLeft(2, '0')}-${projectPmsEndDate!.day.toString().padLeft(2, '0')}",
        "project_pms_status": projectPmsStatus,
        "project_pms_updated_at": projectPmsUpdatedAt?.toIso8601String(),
        "project_pms_created_at": projectPmsCreatedAt?.toIso8601String(),
      };
}

class PmsStructure {
  String? mstPmsId;
  String? parentIdFk;
  String? pmsCategoryName;
  String? pmsOrderNo;
  String? pmsColorCode;
  DateTime? pmsStartDate;
  DateTime? pmsEndDate;
  DateTime? parentStartDate;
  DateTime? parent_end_date;
  String? totolPercentage;
  String? consumePercentage;
  List<PmsStructure>? details;
  String? checkStatus;
  String? projectPmsIdFk;
  DateTime? minDate;
  DateTime? maxDate;
  String? pmsTotalDays;
  bool? expand;
  String? pms_color_code;
  List<RemarkList>? remarkList;
  List<WorkOrderList>? workOrderDetails;
  DateTime? cmsOriginalStartDate;
  DateTime? cmsOriginalEndDate;
  String? rccSlabSync;
  String? projectSlabMasnoryType;

  // String? parentStartDate;

  PmsStructure({
    this.mstPmsId,
    this.parentIdFk,
    this.expand = false,
    this.pmsCategoryName,
    this.pmsOrderNo,
    this.pmsColorCode,
    this.pmsStartDate,
    this.pmsEndDate,
    this.totolPercentage,
    this.consumePercentage,
    this.pmsTotalDays,
    this.details,
    this.pms_color_code,
    this.remarkList,
    this.parentStartDate,
    this.parent_end_date,
    this.workOrderDetails,
    this.minDate,
    this.checkStatus,
    this.maxDate,
    this.projectPmsIdFk,
    this.cmsOriginalStartDate,
    this.cmsOriginalEndDate,
    this.rccSlabSync,
    this.projectSlabMasnoryType,

    // this.parentStartDate,
  });

  factory PmsStructure.fromJson(Map<String, dynamic> json) => PmsStructure(
        mstPmsId: json["mst_pms_id"],
        parentIdFk: json["parent_id_fk"],
        pmsCategoryName: json["pms_category_name"],
        pmsOrderNo: json["pms_order_no"],
        expand: json["expand"],
        checkStatus: json["check_status"],
        pms_color_code: json["pms_color_code"],
        pmsStartDate: json["pms_start_date"] == ''
            ? DateTime(2000)
            : DateTime.parse(json["pms_start_date"]),
        pmsEndDate: json["pms_end_date"] == ''
            ? DateTime(2101)
            : DateTime.parse(json["pms_end_date"]),
        parentStartDate:
            json["parent_start_date"] == "" || json["parent_start_date"] == null
                ? null
                : DateTime.parse(json["parent_start_date"]),
        parent_end_date:
            json["parent_end_date"] == "" || json["parent_end_date"] == null
                ? null
                : DateTime.parse(json["parent_end_date"]),
        totolPercentage: json["totol_percentage"],
        consumePercentage: json["consume_percentage"],
        minDate: json["min_date"] == '' || json["min_date"] == null
            ? DateTime(2101) //DateTime(2000)
            : DateTime.parse(json["min_date"]),
        maxDate: json["max_date"] == '' || json["max_date"] == null
            ? DateTime(2000) //DateTime(2101)
            : DateTime.parse(json["max_date"]),
        pmsTotalDays: json["pms_total_days"],
        details: json["details"] == null
            ? []
            : List<PmsStructure>.from(
                json["details"]!.map((x) => PmsStructure.fromJson(x))),
        remarkList: json["remark_list"] == null
            ? []
            : List<RemarkList>.from(
                json["remark_list"]!.map((x) => RemarkList.fromJson(x))),
        workOrderDetails: json["work_order_details"] == null
            ? null
            : List<WorkOrderList>.from(json["work_order_details"]!
                .map((x) => WorkOrderList.fromJson(x))),
        projectPmsIdFk: json["project_pms_id_fk"],
        // parentStartDate: json["parent_start_date"],
        cmsOriginalStartDate: json["cms_original_start_date"] == null ||
                json["cms_original_start_date"] == ''
            ? null
            : DateTime.parse(json["cms_original_start_date"]),
        cmsOriginalEndDate: json["cms_original_end_date"] == null ||
                json["cms_original_end_date"] == ''
            ? null
            : DateTime.parse(json["cms_original_end_date"]),
        rccSlabSync: json["rcc_slab_sync"],
        projectSlabMasnoryType: json["project_slab_masnory_type"],
      );

  Map<String, dynamic> toJson() => {
        "mst_pms_id": mstPmsId,
        "parent_id_fk": parentIdFk,
        "pms_category_name": pmsCategoryName,
        "pms_order_no": pmsOrderNo,
        "pms_color_code": pms_color_code,
        "check_status": checkStatus,
        "pms_start_date":
            "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
        "pms_end_date":
            "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
        "parentStartDate":
            "${parentStartDate!.year.toString().padLeft(4, '0')}-${parentStartDate!.month.toString().padLeft(2, '0')}-${parentStartDate!.day.toString().padLeft(2, '0')}",
        "parent_end_date":
            "${parent_end_date!.year.toString().padLeft(4, '0')}-${parent_end_date!.month.toString().padLeft(2, '0')}-${parent_end_date!.day.toString().padLeft(2, '0')}",
        "totol_percentage": totolPercentage,
        "consume_percentage": consumePercentage,
        "pms_total_days": pmsTotalDays,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
        "remark_list": remarkList == null
            ? []
            : List<dynamic>.from(remarkList!.map((x) => x.toJson())),
        "min_date":
            "${minDate!.year.toString().padLeft(4, '0')}-${minDate!.month.toString().padLeft(2, '0')}-${minDate!.day.toString().padLeft(2, '0')}",
        "max_date":
            "${maxDate!.year.toString().padLeft(4, '0')}-${maxDate!.month.toString().padLeft(2, '0')}-${maxDate!.day.toString().padLeft(2, '0')}",
        "work_order_details": workOrderDetails == null
            ? []
            : List<dynamic>.from(workOrderDetails!.map((x) => x.toJson())),
        "project_pms_id_fk": projectPmsIdFk,
        // "parent_start_date": parentStartDate,
        "cms_original_start_date":
            "${cmsOriginalStartDate!.year.toString().padLeft(4, '0')}-${cmsOriginalStartDate!.month.toString().padLeft(2, '0')}-${cmsOriginalStartDate!.day.toString().padLeft(2, '0')}",
        "cms_original_end_date":
            "${cmsOriginalEndDate!.year.toString().padLeft(4, '0')}-${cmsOriginalEndDate!.month.toString().padLeft(2, '0')}-${cmsOriginalEndDate!.day.toString().padLeft(2, '0')}",
        "rcc_slab_sync": rccSlabSync,
        "project_slab_masnory_type": projectSlabMasnoryType,
      };
}

class RemarkList {
  String? transPmsRemark;
  String? userName;
  DateTime? createdAt;

  RemarkList({
    this.transPmsRemark,
    this.userName,
    this.createdAt,
  });

  factory RemarkList.fromJson(Map<String, dynamic> json) => RemarkList(
        transPmsRemark: json["trans_pms_remark"],
        userName: json["user_name"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "trans_pms_remark": transPmsRemark,
        "user_name": userName,
        "created_at": createdAt?.toIso8601String(),
      };
}
