// To parse this JSON data, do
//
//     final brochurePlan = brochurePlanFromJson(jsonString);

import 'dart:convert';

BrochurePlan brochurePlanFromJson(String str) =>
    BrochurePlan.fromJson(json.decode(str));

String brochurePlanToJson(BrochurePlan data) => json.encode(data.toJson());

class BrochurePlan {
  BrochurePlanResponse? response;

  BrochurePlan({
    this.response,
  });

  factory BrochurePlan.fromJson(Map<String, dynamic> json) => BrochurePlan(
        response: json["Response"] == null
            ? null
            : BrochurePlanResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class BrochurePlanResponse {
  String? errorCode;
  String? msg;
  List<SellBrochurePlan>? sellBrochurePlan;

  BrochurePlanResponse({
    this.errorCode,
    this.msg,
    this.sellBrochurePlan,
  });

  factory BrochurePlanResponse.fromJson(Map<String, dynamic> json) =>
      BrochurePlanResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        sellBrochurePlan: json["sell_brochure_plan"] == null
            ? []
            : List<SellBrochurePlan>.from(json["sell_brochure_plan"]!
                .map((x) => SellBrochurePlan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "sell_brochure_plan": sellBrochurePlan == null
            ? []
            : List<dynamic>.from(sellBrochurePlan!.map((x) => x.toJson())),
      };
}

class SellBrochurePlan {
  String? brochurePlanId;
  String? projectId;
  String? brochurePlanImage;
  DateTime? createdAt;
  String? planName;
  String? brochureTowerIdFk;

  SellBrochurePlan({
    this.brochurePlanId,
    this.projectId,
    this.brochurePlanImage,
    this.createdAt,
    this.planName,
    this.brochureTowerIdFk,
  });

  factory SellBrochurePlan.fromJson(Map<String, dynamic> json) =>
      SellBrochurePlan(
        brochurePlanId: json["brochure_plan_id"],
        projectId: json["project_id"],
        brochurePlanImage: json["brochure_plan_image"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        planName: json["plan_name"],
        brochureTowerIdFk: json["brochure_tower_id_fk"],
      );

  Map<String, dynamic> toJson() => {
        "brochure_plan_id": brochurePlanId,
        "project_id": projectId,
        "brochure_plan_image": brochurePlanImage,
        "created_at": createdAt?.toIso8601String(),
        "plan_name": planName,
        "brochure_tower_id_fk": brochureTowerIdFk,
      };
}
