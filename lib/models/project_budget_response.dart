// To parse this JSON data, do
//
//     final projectBudget = projectBudgetFromJson(jsonString);

import 'dart:convert';

ProjectBudget projectBudgetFromJson(String str) =>
    ProjectBudget.fromJson(json.decode(str));

String projectBudgetToJson(ProjectBudget data) => json.encode(data.toJson());

class ProjectBudget {
  ProjectBudgetResponse? response;

  ProjectBudget({
    this.response,
  });

  factory ProjectBudget.fromJson(Map<String, dynamic> json) => ProjectBudget(
        response: json["Response"] == null
            ? null
            : ProjectBudgetResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectBudgetResponse {
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
  List<FinalBudgetResult>? finalBudgetResult;
  List<TowarList>? towarList;

  ProjectBudgetResponse({
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
    this.towarList,
  });

  factory ProjectBudgetResponse.fromJson(Map<String, dynamic> json) =>
      ProjectBudgetResponse(
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
            : List<FinalBudgetResult>.from(json["final_budget_result"]!
                .map((x) => FinalBudgetResult.fromJson(x))),
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"]!.map((x) => TowarList.fromJson(x))),
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
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
      };
}

class FinalBudgetResult {
  String? id;
  String? title;
  String? subtitle;
  String? totalcost;
  List<ArrBudgetCost>? arrBudgetCost;

  FinalBudgetResult({
    this.id,
    this.title,
    this.subtitle,
    this.totalcost,
    this.arrBudgetCost,
  });

  factory FinalBudgetResult.fromJson(Map<String, dynamic> json) =>
      FinalBudgetResult(
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

class TowarList {
  String? towarId;
  String? towarName;

  TowarList({
    this.towarId,
    this.towarName,
  });

  factory TowarList.fromJson(Map<String, dynamic> json) => TowarList(
        towarId: json["towar_id"],
        towarName: json["towar_name"],
      );

  Map<String, dynamic> toJson() => {
        "towar_id": towarId,
        "towar_name": towarName,
      };
}
