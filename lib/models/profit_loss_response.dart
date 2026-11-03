// To parse this JSON data, do
//
//     final profitLossResponse = profitLossResponseFromJson(jsonString);

import 'dart:convert';

ProfitLossResponse profitLossResponseFromJson(String str) =>
    ProfitLossResponse.fromJson(json.decode(str));

String profitLossResponseToJson(ProfitLossResponse data) =>
    json.encode(data.toJson());

class ProfitLossResponse {
  ResponseProfitLossResponse? response;

  ProfitLossResponse({
    this.response,
  });

  factory ProfitLossResponse.fromJson(Map<String, dynamic> json) =>
      ProfitLossResponse(
        response: json["Response"] == null
            ? null
            : ResponseProfitLossResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseProfitLossResponse {
  String? errorCode;
  String? msg;
  List<dynamic>? towarList;
  BudgetDetails? budgetDetails;
  List<InventryCostly>? projectCostly;
  List<InventryCostly>? inventryCostly;
  List<InventryCostly>? resultCostly;

  ResponseProfitLossResponse({
    this.errorCode,
    this.msg,
    this.towarList,
    this.budgetDetails,
    this.projectCostly,
    this.inventryCostly,
    this.resultCostly,
  });

  factory ResponseProfitLossResponse.fromJson(Map<String, dynamic> json) =>
      ResponseProfitLossResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        towarList: json["towar_list"] == null
            ? []
            : List<dynamic>.from(json["towar_list"]!.map((x) => x)),
        budgetDetails: json["budget_details"] == null
            ? null
            : BudgetDetails.fromJson(json["budget_details"]),
        projectCostly: json["project_costly"] == null
            ? []
            : List<InventryCostly>.from(
                json["project_costly"]!.map((x) => InventryCostly.fromJson(x))),
        inventryCostly: json["inventry_costly"] == null
            ? []
            : List<InventryCostly>.from(json["inventry_costly"]!
                .map((x) => InventryCostly.fromJson(x))),
        resultCostly: json["result_costly"] == null
            ? []
            : List<InventryCostly>.from(
                json["result_costly"]!.map((x) => InventryCostly.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x)),
        "budget_details": budgetDetails?.toJson(),
        "project_costly": projectCostly == null
            ? []
            : List<dynamic>.from(projectCostly!.map((x) => x.toJson())),
        "inventry_costly": inventryCostly == null
            ? []
            : List<dynamic>.from(inventryCostly!.map((x) => x.toJson())),
        "result_costly": resultCostly == null
            ? []
            : List<dynamic>.from(resultCostly!.map((x) => x.toJson())),
      };
}

class BudgetDetails {
  String? errorCode;
  String? msg;
  String? budgetStatus;
  String? contractStatus;
  String? statutoryStatus;
  String? costPerSqft;
  String? rearAreaCost;
  String? totalCost;
  String? totalStatutory;
  String? totalContractCost;
  String? totalMaterialCost;
  String? overBudgetWoAmount;
  String? overBudgetPoAmount;
  String? totalPaid;
  String? totalCostToIncur;
  String? totalOverBudgetCost;
  List<InventryCostly>? finalBudgetResult;

  BudgetDetails({
    this.errorCode,
    this.msg,
    this.budgetStatus,
    this.contractStatus,
    this.statutoryStatus,
    this.costPerSqft,
    this.rearAreaCost,
    this.totalCost,
    this.totalStatutory,
    this.totalContractCost,
    this.totalMaterialCost,
    this.overBudgetWoAmount,
    this.overBudgetPoAmount,
    this.totalPaid,
    this.totalCostToIncur,
    this.totalOverBudgetCost,
    this.finalBudgetResult,
  });

  factory BudgetDetails.fromJson(Map<String, dynamic> json) => BudgetDetails(
        errorCode: json["error_code"],
        msg: json["msg"],
        budgetStatus: json["budget_status"],
        contractStatus: json["contract_status"],
        statutoryStatus: json["statutory_status"],
        costPerSqft: json["cost_per_sqft"],
        rearAreaCost: json["rear_area_cost"],
        totalCost: json["total_cost"],
        totalStatutory: json["total_statutory"],
        totalContractCost: json["total_contract_cost"],
        totalMaterialCost: json["total_material_cost"],
        overBudgetWoAmount: json["over_budget_wo_amount"],
        overBudgetPoAmount: json["over_budget_po_amount"],
        totalPaid: json["total_paid"],
        totalCostToIncur: json["total_cost_to_incur"],
        totalOverBudgetCost: json["total_over_budget_cost"],
        finalBudgetResult: json["final_budget_result"] == null
            ? []
            : List<InventryCostly>.from(json["final_budget_result"]!
                .map((x) => InventryCostly.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "budget_status": budgetStatus,
        "contract_status": contractStatus,
        "statutory_status": statutoryStatus,
        "cost_per_sqft": costPerSqft,
        "rear_area_cost": rearAreaCost,
        "total_cost": totalCost,
        "total_statutory": totalStatutory,
        "total_contract_cost": totalContractCost,
        "total_material_cost": totalMaterialCost,
        "over_budget_wo_amount": overBudgetWoAmount,
        "over_budget_po_amount": overBudgetPoAmount,
        "total_paid": totalPaid,
        "total_cost_to_incur": totalCostToIncur,
        "total_over_budget_cost": totalOverBudgetCost,
        "final_budget_result": finalBudgetResult == null
            ? []
            : List<dynamic>.from(finalBudgetResult!.map((x) => x.toJson())),
      };
}

class InventryCostly {
  String? id;
  String? title;
  String? subtitle;
  String? totalcost;
  List<ArrBudgetCost>? arrBudgetCost;

  InventryCostly({
    this.id,
    this.title,
    this.subtitle,
    this.totalcost,
    this.arrBudgetCost,
  });

  factory InventryCostly.fromJson(Map<String, dynamic> json) => InventryCostly(
        id: json["id"],
        title: json["title"],
        subtitle: json["subtitle"],
        totalcost: json["totalcost"],
        arrBudgetCost: json["arr_budget_cost"] == null
            ? []
            : List<ArrBudgetCost>.from(
                json["arr_budget_cost"]!.map((x) => ArrBudgetCost.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "subtitle": subtitle,
        "totalcost": totalcost,
        "arr_budget_cost": arrBudgetCost == null
            ? []
            : List<dynamic>.from(arrBudgetCost!.map((x) => x.toJson())),
      };
}

class ArrBudgetCost {
  String? id;
  String? title;
  String? amount;

  ArrBudgetCost({
    this.id,
    this.title,
    this.amount,
  });

  factory ArrBudgetCost.fromJson(Map<String, dynamic> json) => ArrBudgetCost(
        id: json["id"],
        title: json["title"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "amount": amount,
      };
}
