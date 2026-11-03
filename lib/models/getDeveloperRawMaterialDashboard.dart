// To parse this JSON data, do
//
//     final getDeveloperRawMaterialDashboard = getDeveloperRawMaterialDashboardFromJson(jsonString);

import 'dart:convert';

GetDeveloperRawMaterialDashboard getDeveloperRawMaterialDashboardFromJson(
        String str) =>
    GetDeveloperRawMaterialDashboard.fromJson(json.decode(str));

String getDeveloperRawMaterialDashboardToJson(
        GetDeveloperRawMaterialDashboard data) =>
    json.encode(data.toJson());

class GetDeveloperRawMaterialDashboard {
  GetDeveloperRawMaterialDashboardResponse? response;

  GetDeveloperRawMaterialDashboard({
    this.response,
  });

  factory GetDeveloperRawMaterialDashboard.fromJson(
          Map<String, dynamic> json) =>
      GetDeveloperRawMaterialDashboard(
        response: json["Response"] == null
            ? null
            : GetDeveloperRawMaterialDashboardResponse.fromJson(
                json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetDeveloperRawMaterialDashboardResponse {
  String? errorCode;
  String? msg;
  List<DatumDeveloperRawMaterialDashboard>? data;

  GetDeveloperRawMaterialDashboardResponse({
    this.errorCode,
    this.msg,
    this.data,
  });

  factory GetDeveloperRawMaterialDashboardResponse.fromJson(
          Map<String, dynamic> json) =>
      GetDeveloperRawMaterialDashboardResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        data: json["data"] == null
            ? []
            : List<DatumDeveloperRawMaterialDashboard>.from(json["data"]!
                .map((x) => DatumDeveloperRawMaterialDashboard.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class DatumDeveloperRawMaterialDashboard {
  String? gradeName;
  String? gradeId;
  List<Detail>? details;

  DatumDeveloperRawMaterialDashboard({
    this.gradeName,
    this.gradeId,
    this.details,
  });

  factory DatumDeveloperRawMaterialDashboard.fromJson(
          Map<String, dynamic> json) =>
      DatumDeveloperRawMaterialDashboard(
        gradeName: json["grade_name"],
        gradeId: json["grade_id"],
        details: json["details"] == null
            ? []
            : List<Detail>.from(
                json["details"]!.map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "grade_name": gradeName,
        "grade_id": gradeId,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class Detail {
  String? stockIn;
  String? stockOut;
  String? month;
  String? monthName;

  Detail({
    this.stockIn,
    this.stockOut,
    this.month,
    this.monthName,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        stockIn: json["stock_in"],
        stockOut: json["stock_out"],
        month: json["month"],
        monthName: json["month_name"],
      );

  Map<String, dynamic> toJson() => {
        "stock_in": stockIn,
        "stock_out": stockOut,
        "month": month,
        "month_name": monthName,
      };
}
