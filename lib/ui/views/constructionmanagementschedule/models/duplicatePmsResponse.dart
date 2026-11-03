// To parse this JSON data, do
//
//     final duplicatePmsResponse = duplicatePmsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/ui/views/constructionmanagementschedule/models/ws_get_pms_structure.dart';

DuplicatePmsResponse duplicatePmsResponseFromJson(String str) =>
    DuplicatePmsResponse.fromJson(json.decode(str));

String duplicatePmsResponseToJson(DuplicatePmsResponse data) =>
    json.encode(data.toJson());

class DuplicatePmsResponse {
  ResponseDuplicatePmsResponse? response;

  DuplicatePmsResponse({
    this.response,
  });

  factory DuplicatePmsResponse.fromJson(Map<String, dynamic> json) =>
      DuplicatePmsResponse(
        response: json["Response"] == null
            ? null
            : ResponseDuplicatePmsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseDuplicatePmsResponse {
  String? errorCode;
  String? msg;
  List<PmsStructure>? finalData;

  ResponseDuplicatePmsResponse({
    this.errorCode,
    this.msg,
    this.finalData,
  });

  factory ResponseDuplicatePmsResponse.fromJson(Map<String, dynamic> json) =>
      ResponseDuplicatePmsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        finalData: json["final_data"] == null
            ? []
            : List<PmsStructure>.from(
                json["final_data"]?.map((x) => PmsStructure.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "final_data": finalData == null
            ? []
            : List<dynamic>.from(finalData!.map((x) => x.toJson())),
      };
}

// class FinalDatum {
//     String? projectIdFk;
//     String? towarIdFk;
//     String? pmsCategoryName;
//     String? pmsType;
//     String? parentIdFk;
//     String? pmsOrderNo;
//     String? pmsColorCode;
//     String? pmsStartDate;
//     String? pmsEndDate;
//     String? workIdFk;
//     String? progressPercentage;
//     String? pmsStatus;
//     String? mstPmsId;
//     List<FinalDatum>? details;

//     FinalDatum({
//         this.projectIdFk,
//         this.towarIdFk,
//         this.pmsCategoryName,
//         this.pmsType,
//         this.parentIdFk,
//         this.pmsOrderNo,
//         this.pmsColorCode,
//         this.pmsStartDate,
//         this.pmsEndDate,
//         this.workIdFk,
//         this.progressPercentage,
//         this.pmsStatus,
//         this.mstPmsId,
//         this.details,
//     });

//     factory FinalDatum.fromJson(Map<String, dynamic> json) => FinalDatum(
//         projectIdFk: json["project_id_fk"],
//         towarIdFk: json["towar_id_fk"],
//         pmsCategoryName: json["pms_category_name"],
//         pmsType: json["pms_type"],
//         parentIdFk: json["parent_id_fk"],
//         pmsOrderNo: json["pms_order_no"],
//         pmsColorCode: json["pms_color_code"],
//         pmsStartDate: json["pms_start_date"],
//         pmsEndDate: json["pms_end_date"],
//         workIdFk: json["work_id_fk"],
//         progressPercentage: json["progress_percentage"],
//         pmsStatus: json["pms_status"],
//         mstPmsId: json["mst_pms_id"],
//         details: json["details"] == null ? [] : List<FinalDatum>.from(json["details"]!.map((x) => FinalDatum.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "project_id_fk": projectIdFk,
//         "towar_id_fk": towarIdFk,
//         "pms_category_name": pmsCategoryName,
//         "pms_type": pmsType,
//         "parent_id_fk": parentIdFk,
//         "pms_order_no": pmsOrderNo,
//         "pms_color_code": pmsColorCode,
//         "pms_start_date": pmsStartDate,
//         "pms_end_date": pmsEndDate,
//         "work_id_fk": workIdFk,
//         "progress_percentage": progressPercentage,
//         "pms_status": pmsStatus,
//         "mst_pms_id": mstPmsId,
//         "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
//     };
// }
