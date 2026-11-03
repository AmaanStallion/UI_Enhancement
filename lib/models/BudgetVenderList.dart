// To parse this JSON data, do
//
//     final budgetVenderList = budgetVenderListFromJson(jsonString);

import 'dart:convert';

BudgetVenderList budgetVenderListFromJson(String str) =>
    BudgetVenderList.fromJson(json.decode(str));

String budgetVenderListToJson(BudgetVenderList data) =>
    json.encode(data.toJson());

class BudgetVenderList {
  BudgetVenderListResponse? response;

  BudgetVenderList({
    this.response,
  });

  factory BudgetVenderList.fromJson(Map<String, dynamic> json) =>
      BudgetVenderList(
        response: json["Response"] == null
            ? null
            : BudgetVenderListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class BudgetVenderListResponse {
  String? errorCode;
  String? msg;
  List<BudgetVenderListElement>? budgetVenderList;

  BudgetVenderListResponse({
    this.errorCode,
    this.msg,
    this.budgetVenderList,
  });

  factory BudgetVenderListResponse.fromJson(Map<String, dynamic> json) =>
      BudgetVenderListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        budgetVenderList: json["budget_vender_list"] == null
            ? []
            : List<BudgetVenderListElement>.from(json["budget_vender_list"]!
                .map((x) => BudgetVenderListElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "budget_vender_list": budgetVenderList == null
            ? []
            : List<dynamic>.from(budgetVenderList!.map((x) => x.toJson())),
      };
}

class BudgetVenderListElement {
  String? venderName;
  String? venderId;
  String? procuredQuantity;
  String? procuredValue;
  String? gradeId;

  BudgetVenderListElement({
    this.venderName,
    this.venderId,
    this.procuredQuantity,
    this.procuredValue,
    this.gradeId,
  });

  factory BudgetVenderListElement.fromJson(Map<String, dynamic> json) =>
      BudgetVenderListElement(
        venderName: json["vender_name"],
        venderId: json["vender_id"],
        procuredQuantity: json["procured_quantity"],
        procuredValue: json["procured_value"],
        gradeId: json["grade_id"],
      );

  Map<String, dynamic> toJson() => {
        "vender_name": venderName,
        "vender_id": venderId,
        "procured_quantity": procuredQuantity,
        "procured_value": procuredValue,
        "grade_id": gradeId,
      };
}
