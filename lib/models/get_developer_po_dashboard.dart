// To parse this JSON data, do
//
//     final getDeveloperPoDashboard = getDeveloperPoDashboardFromJson(jsonString);

import 'dart:convert';

GetDeveloperPoDashboard getDeveloperPoDashboardFromJson(String str) =>
    GetDeveloperPoDashboard.fromJson(json.decode(str));

String getDeveloperPoDashboardToJson(GetDeveloperPoDashboard data) =>
    json.encode(data.toJson());

class GetDeveloperPoDashboard {
  GetDeveloperPoDashboardResponse? response;

  GetDeveloperPoDashboard({
    this.response,
  });

  factory GetDeveloperPoDashboard.fromJson(Map<String, dynamic> json) =>
      GetDeveloperPoDashboard(
        response: json["Response"] == null
            ? null
            : GetDeveloperPoDashboardResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetDeveloperPoDashboardResponse {
  String? errorCode;
  String? msg;
  Data? data;

  GetDeveloperPoDashboardResponse({
    this.errorCode,
    this.msg,
    this.data,
  });

  factory GetDeveloperPoDashboardResponse.fromJson(Map<String, dynamic> json) =>
      GetDeveloperPoDashboardResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "data": data?.toJson(),
      };
}

class Data {
  List<Approval>? approvals;
  List<Approval>? invoices;
  List<Approval>? delivery;
  List<Approval>? vendor;
  List<Approval>? dueover;
  List<Approval>? payments;

  Data({
    this.approvals,
    this.invoices,
    this.delivery,
    this.vendor,
    this.dueover,
    this.payments,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        approvals: json["approvals"] == null
            ? []
            : List<Approval>.from(
                json["approvals"]!.map((x) => Approval.fromJson(x))),
        invoices: json["invoices"] == null
            ? []
            : List<Approval>.from(
                json["invoices"]!.map((x) => Approval.fromJson(x))),
        delivery: json["delivery"] == null
            ? []
            : List<Approval>.from(
                json["delivery"]!.map((x) => Approval.fromJson(x))),
        vendor: json["vendor"] == null
            ? []
            : List<Approval>.from(
                json["vendor"]!.map((x) => Approval.fromJson(x))),
        dueover: json["dueover"] == null
            ? []
            : List<Approval>.from(
                json["dueover"]!.map((x) => Approval.fromJson(x))),
        payments: json["payments"] == null
            ? []
            : List<Approval>.from(
                json["payments"]!.map((x) => Approval.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "approvals": approvals == null
            ? []
            : List<dynamic>.from(approvals!.map((x) => x.toJson())),
        "invoices": invoices == null
            ? []
            : List<dynamic>.from(invoices!.map((x) => x.toJson())),
        "delivery": delivery == null
            ? []
            : List<dynamic>.from(delivery!.map((x) => x.toJson())),
        "vendor": vendor == null
            ? []
            : List<dynamic>.from(vendor!.map((x) => x.toJson())),
        "dueover": dueover == null
            ? []
            : List<dynamic>.from(dueover!.map((x) => x.toJson())),
        "payments": payments == null
            ? []
            : List<dynamic>.from(payments!.map((x) => x.toJson())),
      };
}

class Approval {
  String? status;
  String? count;

  Approval({
    this.status,
    this.count,
  });

  factory Approval.fromJson(Map<String, dynamic> json) => Approval(
        status: json["status"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "count": count,
      };
}
