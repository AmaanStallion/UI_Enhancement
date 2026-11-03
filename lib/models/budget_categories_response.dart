// To parse this JSON data, do
//
//     final projectBudgetCategories = projectBudgetCategoriesFromJson(jsonString);

import 'dart:convert';

ProjectBudgetCategories projectBudgetCategoriesFromJson(String str) =>
    ProjectBudgetCategories.fromJson(json.decode(str));

String projectBudgetCategoriesToJson(ProjectBudgetCategories data) =>
    json.encode(data.toJson());

class ProjectBudgetCategories {
  ProjectBudgetCategoriesResponse? response;

  ProjectBudgetCategories({
    this.response,
  });

  factory ProjectBudgetCategories.fromJson(Map<String, dynamic> json) =>
      ProjectBudgetCategories(
        response: json["Response"] == null
            ? null
            : ProjectBudgetCategoriesResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectBudgetCategoriesResponse {
  String? errorCode;
  String? msg;
  List<BudgetGroupDatum>? budgetGroupData;

  ProjectBudgetCategoriesResponse({
    this.errorCode,
    this.msg,
    this.budgetGroupData,
  });

  factory ProjectBudgetCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      ProjectBudgetCategoriesResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        budgetGroupData: json["budget_group_data"] == null
            ? []
            : List<BudgetGroupDatum>.from(json["budget_group_data"]!
                .map((x) => BudgetGroupDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "budget_group_data": budgetGroupData == null
            ? []
            : List<dynamic>.from(budgetGroupData!.map((x) => x.toJson())),
      };
}

class BudgetGroupDatum {
  String? budgetTypeId;
  String? budgetTypeName;
  dynamic estTotal;
  dynamic purchaseAmount;
  dynamic budgetEstQuantity;
  dynamic purchaseTotalQuantity;

  BudgetGroupDatum({
    this.budgetTypeId,
    this.budgetTypeName,
    this.estTotal,
    this.purchaseAmount,
    this.budgetEstQuantity,
    this.purchaseTotalQuantity,
  });

  factory BudgetGroupDatum.fromJson(Map<String, dynamic> json) =>
      BudgetGroupDatum(
        budgetTypeId: json["budget_type_id"],
        budgetTypeName: json["budget_type_name"],
        estTotal: json["est_total"],
        purchaseAmount: json["purchase_amount"],
        budgetEstQuantity: json["budget_est_quantity"],
        purchaseTotalQuantity: json["purchase_total_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "budget_type_id": budgetTypeId,
        "budget_type_name": budgetTypeName,
        "est_total": estTotal,
        "purchase_amount": purchaseAmount,
        "budget_est_quantity": budgetEstQuantity,
        "purchase_total_quantity": purchaseTotalQuantity,
      };
}
