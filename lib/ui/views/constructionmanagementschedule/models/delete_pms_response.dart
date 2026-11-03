// To parse this JSON data, do
//
//     final deletePmsResponse = deletePmsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/ui/views/constructionmanagementschedule/models/ws_get_pms_structure.dart';

DeletePmsResponse deletePmsResponseFromJson(String str) =>
    DeletePmsResponse.fromJson(json.decode(str));

String deletePmsResponseToJson(DeletePmsResponse data) =>
    json.encode(data.toJson());

class DeletePmsResponse {
  ResponseDeletePmsResponse? response;

  DeletePmsResponse({
    this.response,
  });

  factory DeletePmsResponse.fromJson(Map<String, dynamic> json) =>
      DeletePmsResponse(
        response: json["Response"] == null
            ? null
            : ResponseDeletePmsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseDeletePmsResponse {
  String? errorCode;
  String? msg;
  List<PmsStructure>? changeData;

  ResponseDeletePmsResponse({
    this.errorCode,
    this.msg,
    this.changeData,
  });

  factory ResponseDeletePmsResponse.fromJson(Map<String, dynamic> json) =>
      ResponseDeletePmsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        changeData: json["change_data"] == null
            ? []
            : List<PmsStructure>.from(
                json["change_data"]!.map((x) => PmsStructure.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "change_data": changeData == null
            ? []
            : List<dynamic>.from(changeData!.map((x) => x.toJson())),
      };
}

// class ChangeDatum {
//   String? mstPmsId;
//   String? parentIdFk;
//   String? pmsCategoryName;
//   String? pmsOrderNo;
//   String? pmsColorCode;
//   DateTime? pmsStartDate;
//   DateTime? pmsEndDate;
//   String? workIdFk;
//   String? projectPmsIdFk;
//   String? progressPercentage;
//   String? totolPercentage;
//   String? consumePercentage;
//   String? checkStatus;
//   DateTime? minDate;
//   DateTime? maxDate;
//   String? parentStartDate;
//   String? parentEndDate;
//   List<dynamic>? workOrderDetails;
//   String? pmsTotalDays;
//   List<dynamic>? remarkList;
//   List<dynamic>? details;

//   ChangeDatum({
//     this.mstPmsId,
//     this.parentIdFk,
//     this.pmsCategoryName,
//     this.pmsOrderNo,
//     this.pmsColorCode,
//     this.pmsStartDate,
//     this.pmsEndDate,
//     this.workIdFk,
//     this.projectPmsIdFk,
//     this.progressPercentage,
//     this.totolPercentage,
//     this.consumePercentage,
//     this.checkStatus,
//     this.minDate,
//     this.maxDate,
//     this.parentStartDate,
//     this.parentEndDate,
//     this.workOrderDetails,
//     this.pmsTotalDays,
//     this.remarkList,
//     this.details,
//   });

//   factory ChangeDatum.fromJson(Map<String, dynamic> json) => ChangeDatum(
//         mstPmsId: json["mst_pms_id"],
//         parentIdFk: json["parent_id_fk"],
//         pmsCategoryName: json["pms_category_name"],
//         pmsOrderNo: json["pms_order_no"],
//         pmsColorCode: json["pms_color_code"],
//         pmsStartDate: json["pms_start_date"] == null
//             ? null
//             : DateTime.parse(json["pms_start_date"]),
//         pmsEndDate: json["pms_end_date"] == null
//             ? null
//             : DateTime.parse(json["pms_end_date"]),
//         workIdFk: json["work_id_fk"],
//         projectPmsIdFk: json["project_pms_id_fk"],
//         progressPercentage: json["progress_percentage"],
//         totolPercentage: json["totol_percentage"],
//         consumePercentage: json["consume_percentage"],
//         checkStatus: json["check_status"],
//         minDate:
//             json["min_date"] == null ? null : DateTime.parse(json["min_date"]),
//         maxDate:
//             json["max_date"] == null ? null : DateTime.parse(json["max_date"]),
//         parentStartDate: json["parent_start_date"],
//         parentEndDate: json["parent_end_date"],
//         workOrderDetails: json["work_order_details"] == null
//             ? []
//             : List<dynamic>.from(json["work_order_details"]!.map((x) => x)),
//         pmsTotalDays: json["pms_total_days"],
//         remarkList: json["remark_list"] == null
//             ? []
//             : List<dynamic>.from(json["remark_list"]!.map((x) => x)),
//         details: json["details"] == null
//             ? []
//             : List<dynamic>.from(json["details"]!.map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "mst_pms_id": mstPmsId,
//         "parent_id_fk": parentIdFk,
//         "pms_category_name": pmsCategoryName,
//         "pms_order_no": pmsOrderNo,
//         "pms_color_code": pmsColorCode,
//         "pms_start_date":
//             "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
//         "pms_end_date":
//             "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
//         "work_id_fk": workIdFk,
//         "project_pms_id_fk": projectPmsIdFk,
//         "progress_percentage": progressPercentage,
//         "totol_percentage": totolPercentage,
//         "consume_percentage": consumePercentage,
//         "check_status": checkStatus,
//         "min_date":
//             "${minDate!.year.toString().padLeft(4, '0')}-${minDate!.month.toString().padLeft(2, '0')}-${minDate!.day.toString().padLeft(2, '0')}",
//         "max_date":
//             "${maxDate!.year.toString().padLeft(4, '0')}-${maxDate!.month.toString().padLeft(2, '0')}-${maxDate!.day.toString().padLeft(2, '0')}",
//         "parent_start_date": parentStartDate,
//         "parent_end_date": parentEndDate,
//         "work_order_details": workOrderDetails == null
//             ? []
//             : List<dynamic>.from(workOrderDetails!.map((x) => x)),
//         "pms_total_days": pmsTotalDays,
//         "remark_list": remarkList == null
//             ? []
//             : List<dynamic>.from(remarkList!.map((x) => x)),
//         "details":
//             details == null ? [] : List<dynamic>.from(details!.map((x) => x)),
//       };
// }
