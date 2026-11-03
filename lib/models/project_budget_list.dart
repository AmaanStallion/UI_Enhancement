// To parse this JSON data, do
//
//     final projectBudgetList = projectBudgetListFromJson(jsonString);

import 'dart:convert';

ProjectBudgetList projectBudgetListFromJson(String str) =>
    ProjectBudgetList.fromJson(json.decode(str));

String projectBudgetListToJson(ProjectBudgetList data) =>
    json.encode(data.toJson());

class ProjectBudgetList {
  ProjectBudgetListResponse? response;

  ProjectBudgetList({
    this.response,
  });

  factory ProjectBudgetList.fromJson(Map<String, dynamic> json) =>
      ProjectBudgetList(
        response: json["Response"] == null
            ? null
            : ProjectBudgetListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectBudgetListResponse {
  String? errorCode;
  String? msg;
  List<OrderList>? orderList;
  List<BudgetList>? budgetList;
  String? totalEstmateCost;
  String? totalProcuiteCost;
  String? totalCost;
  String? overBudgetAmount;

  ProjectBudgetListResponse({
    this.errorCode,
    this.msg,
    this.orderList,
    this.budgetList,
    this.totalEstmateCost,
    this.totalProcuiteCost,
    this.totalCost,
    this.overBudgetAmount,
  });

  factory ProjectBudgetListResponse.fromJson(Map<String, dynamic> json) =>
      ProjectBudgetListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        orderList: json["order_list"] == null
            ? []
            : List<OrderList>.from(
                json["order_list"]!.map((x) => OrderList.fromJson(x))),
        budgetList: json["budget_list"] == null
            ? []
            : List<BudgetList>.from(
                json["budget_list"]!.map((x) => BudgetList.fromJson(x))),
        totalEstmateCost: json["total_estmate_cost"],
        totalProcuiteCost: json["total_procuite_cost"],
        totalCost: json["total_cost"],
        overBudgetAmount: json["over_budget_amount"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "order_list": orderList == null
            ? []
            : List<dynamic>.from(orderList!.map((x) => x.toJson())),
        "budget_list": budgetList == null
            ? []
            : List<dynamic>.from(budgetList!.map((x) => x.toJson())),
        "total_estmate_cost": totalEstmateCost,
        "total_procuite_cost": totalProcuiteCost,
        "total_cost": totalCost,
        "over_budget_amount": overBudgetAmount,
      };
}

class BudgetList {
  String? budgetTypeId;
  String? budgetTypeName;
  String? gradeId;
  String? gradeName;
  String? budgetEstRate;
  String? budgetEstQuantity;
  String? budgetEstUnit;
  String? estTotal;
  String? overBudgetFlag;
  String? purchaseTotalQuantity;
  String? purchaseAmount;
  String? budgetOverBudgetAmount;
  String? budgetPercentage;
  String? budgetLastPrice;
  String? budgetPurchaseAmount;
  String? gradeGstValue;

  BudgetList({
    this.budgetTypeId,
    this.budgetTypeName,
    this.gradeId,
    this.gradeName,
    this.budgetEstRate,
    this.budgetEstQuantity,
    this.budgetEstUnit,
    this.estTotal,
    this.overBudgetFlag,
    this.purchaseTotalQuantity,
    this.purchaseAmount,
    this.budgetOverBudgetAmount,
    this.budgetPercentage,
    this.budgetLastPrice,
    this.budgetPurchaseAmount,
    this.gradeGstValue,
  });

  factory BudgetList.fromJson(Map<String, dynamic> json) => BudgetList(
        budgetTypeId: json["budget_type_id"],
        budgetTypeName: json["budget_type_name"],
        gradeId: json["grade_id"],
        gradeName: json["grade_name"],
        budgetEstRate: json["budget_est_rate"],
        budgetEstQuantity: json["budget_est_quantity"],
        budgetEstUnit: json["budget_est_unit"],
        estTotal: json["est_total"],
        overBudgetFlag: json["over_budget_flag"],
        purchaseTotalQuantity: json["purchase_total_quantity"],
        purchaseAmount: json["purchase_amount"],
        budgetOverBudgetAmount: json["budget_over_budget_amount"],
        budgetPercentage: json["budget_percentage"],
        budgetLastPrice: json["budget_last_price"],
        budgetPurchaseAmount: json["budget_purchase_amount"],
        gradeGstValue: json["grade_gst_value"],
      );

  Map<String, dynamic> toJson() => {
        "budget_type_id": budgetTypeId,
        "budget_type_name": budgetTypeName,
        "grade_id": gradeId,
        "grade_name": gradeName,
        "budget_est_rate": budgetEstRate,
        "budget_est_quantity": budgetEstQuantity,
        "budget_est_unit": budgetEstUnit,
        "est_total": estTotal,
        "over_budget_flag": overBudgetFlag,
        "purchase_total_quantity": purchaseTotalQuantity,
        "purchase_amount": purchaseAmount,
        "budget_over_budget_amount": budgetOverBudgetAmount,
        "budget_percentage": budgetPercentage,
        "budget_last_price": budgetLastPrice,
        "budget_purchase_amount": budgetPurchaseAmount,
        "grade_gst_value": gradeGstValue,
      };
}

class OrderList {
  String? id;
  String? name;
  List<dynamic>? towarList;

  OrderList({
    this.id,
    this.name,
    this.towarList,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"],
        name: json["name"],
        towarList: json["towar_list"] == null
            ? []
            : List<dynamic>.from(json["towar_list"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x)),
      };
}
