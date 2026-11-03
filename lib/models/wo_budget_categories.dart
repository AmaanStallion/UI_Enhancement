// To parse this JSON data, do
//
//     final woBudgetCategories = woBudgetCategoriesFromJson(jsonString);

import 'dart:convert';

WoBudgetCategories woBudgetCategoriesFromJson(String str) =>
    WoBudgetCategories.fromJson(json.decode(str));

String woBudgetCategoriesToJson(WoBudgetCategories data) =>
    json.encode(data.toJson());

class WoBudgetCategories {
  WoBudgetCategoriesResponse? response;

  WoBudgetCategories({
    this.response,
  });

  factory WoBudgetCategories.fromJson(Map<String, dynamic> json) =>
      WoBudgetCategories(
        response: json["Response"] == null
            ? null
            : WoBudgetCategoriesResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class WoBudgetCategoriesResponse {
  String? errorCode;
  String? msg;
  List<BudgetWoGroupDatum>? budgetWoGroupData;

  WoBudgetCategoriesResponse({
    this.errorCode,
    this.msg,
    this.budgetWoGroupData,
  });

  factory WoBudgetCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      WoBudgetCategoriesResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        budgetWoGroupData: json["budget_wo_group_data"] == null
            ? []
            : List<BudgetWoGroupDatum>.from(json["budget_wo_group_data"]!
                .map((x) => BudgetWoGroupDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "budget_wo_group_data": budgetWoGroupData == null
            ? []
            : List<dynamic>.from(budgetWoGroupData!.map((x) => x.toJson())),
      };
}

class BudgetWoGroupDatum {
  String? budgetTypeId;
  String? budgetTypeName;
  dynamic budgetWoContractAvoided;
  dynamic budgetWoEstContractValue;
  dynamic budgetWoContractPaid;

  BudgetWoGroupDatum({
    this.budgetTypeId,
    this.budgetTypeName,
    this.budgetWoContractAvoided,
    this.budgetWoEstContractValue,
    this.budgetWoContractPaid,
  });

  factory BudgetWoGroupDatum.fromJson(Map<String, dynamic> json) =>
      BudgetWoGroupDatum(
        budgetTypeId: json["budget_type_id"],
        budgetTypeName: json["budget_type_name"],
        budgetWoContractAvoided: json["budget_wo_contract_avoided"],
        budgetWoEstContractValue: json["budget_wo_est_contract_value"],
        budgetWoContractPaid: json["budget_wo_contract_paid"],
      );

  Map<String, dynamic> toJson() => {
        "budget_type_id": budgetTypeId,
        "budget_type_name": budgetTypeName,
        "budget_wo_contract_avoided": budgetWoContractAvoided,
        "budget_wo_est_contract_value": budgetWoEstContractValue,
        "budget_wo_contract_paid": budgetWoContractPaid,
      };
}
