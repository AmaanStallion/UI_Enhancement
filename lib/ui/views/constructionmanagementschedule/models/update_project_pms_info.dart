// To parse this JSON data, do
//
//     final updateProjectPmsInfo = updateProjectPmsInfoFromJson(jsonString);

import 'dart:convert';

UpdateProjectPmsInfo updateProjectPmsInfoFromJson(String str) =>
    UpdateProjectPmsInfo.fromJson(json.decode(str));

String updateProjectPmsInfoToJson(UpdateProjectPmsInfo data) =>
    json.encode(data.toJson());

class UpdateProjectPmsInfo {
  UpdateProjectPmsInfoResponse? response;

  UpdateProjectPmsInfo({
    this.response,
  });

  factory UpdateProjectPmsInfo.fromJson(Map<String, dynamic> json) =>
      UpdateProjectPmsInfo(
        response: json["Response"] == null
            ? null
            : UpdateProjectPmsInfoResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class UpdateProjectPmsInfoResponse {
  String? errorCode;
  String? msg;
  DateTime? pmsStartDate;
  DateTime? pmsEndDate;

  UpdateProjectPmsInfoResponse({
    this.errorCode,
    this.msg,
    this.pmsStartDate,
    this.pmsEndDate,
  });

  factory UpdateProjectPmsInfoResponse.fromJson(Map<String, dynamic> json) =>
      UpdateProjectPmsInfoResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        pmsStartDate: json["pms_start_date"] == null
            ? null
            : DateTime.parse(json["pms_start_date"]),
        pmsEndDate: json["pms_end_date"] == null
            ? null
            : DateTime.parse(json["pms_end_date"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "pms_start_date":
            "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
        "pms_end_date":
            "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
      };
}
