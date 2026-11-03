// To parse this JSON data, do
//
//     final projectWorkordermodel = projectWorkordermodelFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/projectPurchaseordermodel.dart';

ProjectWorkordermodel projectWorkordermodelFromJson(String str) =>
    ProjectWorkordermodel.fromJson(json.decode(str));

String projectWorkordermodelToJson(ProjectWorkordermodel data) =>
    json.encode(data.toJson());

class ProjectWorkordermodel {
  ProjectWorkordermodelResponse? response;

  ProjectWorkordermodel({
    this.response,
  });

  factory ProjectWorkordermodel.fromJson(Map<String, dynamic> json) =>
      ProjectWorkordermodel(
        response: json["Response"] == null
            ? null
            : ProjectWorkordermodelResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectWorkordermodelResponse {
  String? errorCode;
  String? msg;
  WoModule? woModule;

  ProjectWorkordermodelResponse({
    this.errorCode,
    this.msg,
    this.woModule,
  });

  factory ProjectWorkordermodelResponse.fromJson(Map<String, dynamic> json) =>
      ProjectWorkordermodelResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        woModule: json["wo_module"] == null
            ? null
            : WoModule.fromJson(json["wo_module"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "wo_module": woModule?.toJson(),
      };
}

class WoModule {
  String? totalOpenPo;
  String? totalIssuedPo;
  String? totalDue;
  String? totalPaid;
  List<LastUpdate>? lastUpdate;
  String? isActive;

  WoModule({
    this.totalOpenPo,
    this.totalIssuedPo,
    this.totalDue,
    this.totalPaid,
    this.lastUpdate,
    this.isActive,
  });

  factory WoModule.fromJson(Map<String, dynamic> json) => WoModule(
        totalOpenPo: json["total_open_po"],
        totalIssuedPo: json["total_issued_po"],
        totalDue: json["total_due"],
        totalPaid: json["total_paid"],
        lastUpdate: json["last_update"] == null
            ? []
            : List<LastUpdate>.from(
                json["last_update"]!.map((x) => LastUpdate.fromJson(x))),
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "total_open_po": totalOpenPo,
        "total_issued_po": totalIssuedPo,
        "total_due": totalDue,
        "total_paid": totalPaid,
        "last_update": lastUpdate == null
            ? []
            : List<dynamic>.from(lastUpdate!.map((x) => x.toJson())),
        "is_active": isActive,
      };
}

// class LastUpdate {
//   String? name;
//   String? type;

//   LastUpdate({
//     this.name,
//     this.type,
//   });

//   factory LastUpdate.fromJson(Map<String, dynamic> json) => LastUpdate(
//         name: json["name"],
//         type: json["type"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "type": type,
//       };
// }
