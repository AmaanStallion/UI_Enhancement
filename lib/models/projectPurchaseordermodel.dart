// To parse this JSON data, do
//
//     final projectPurchaseordermodel = projectPurchaseordermodelFromJson(jsonString);

import 'dart:convert';

ProjectPurchaseordermodel projectPurchaseordermodelFromJson(String str) =>
    ProjectPurchaseordermodel.fromJson(json.decode(str));

String projectPurchaseordermodelToJson(ProjectPurchaseordermodel data) =>
    json.encode(data.toJson());

class ProjectPurchaseordermodel {
  Response? response;

  ProjectPurchaseordermodel({
    this.response,
  });

  factory ProjectPurchaseordermodel.fromJson(Map<String, dynamic> json) =>
      ProjectPurchaseordermodel(
        response: json["Response"] == null
            ? null
            : Response.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class Response {
  String? errorCode;
  String? msg;
  PoModule? poModule;

  Response({
    this.errorCode,
    this.msg,
    this.poModule,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        poModule: json["po_module"] == null
            ? null
            : PoModule.fromJson(json["po_module"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "po_module": poModule?.toJson(),
      };
}

class PoModule {
  String? totalOpenPo;
  String? totalIssuedPo;
  String? totalDue;
  String? totalPaid;
  List<LastUpdate>? lastUpdate;
  String? isActive;

  PoModule({
    this.totalOpenPo,
    this.totalIssuedPo,
    this.totalDue,
    this.totalPaid,
    this.lastUpdate,
    this.isActive,
  });

  factory PoModule.fromJson(Map<String, dynamic> json) => PoModule(
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

class LastUpdate {
  String? name;
  String? type;

  LastUpdate({
    this.name,
    this.type,
  });

  factory LastUpdate.fromJson(Map<String, dynamic> json) => LastUpdate(
        name: json["name"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
      };
}
