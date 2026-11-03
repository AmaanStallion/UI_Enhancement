// To parse this JSON data, do
//
//     final woBudgetList = woBudgetListFromJson(jsonString);

import 'dart:convert';

WoBudgetList woBudgetListFromJson(String str) =>
    WoBudgetList.fromJson(json.decode(str));

String woBudgetListToJson(WoBudgetList data) => json.encode(data.toJson());

class WoBudgetList {
  WoBudgetListResponse? response;

  WoBudgetList({
    this.response,
  });

  factory WoBudgetList.fromJson(Map<String, dynamic> json) => WoBudgetList(
        response: json["Response"] == null
            ? null
            : WoBudgetListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class WoBudgetListResponse {
  String? errorCode;
  String? msg;
  List<OrderList>? orderList;
  List<BudgetWoList>? budgetWoList;
  String? totalContractCost;
  String? totalAmountPaid;
  String? totalCost;
  String? overBudgetAmount;

  WoBudgetListResponse({
    this.errorCode,
    this.msg,
    this.orderList,
    this.budgetWoList,
    this.totalContractCost,
    this.totalAmountPaid,
    this.totalCost,
    this.overBudgetAmount,
  });

  factory WoBudgetListResponse.fromJson(Map<String, dynamic> json) =>
      WoBudgetListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        orderList: json["order_list"] == null
            ? []
            : List<OrderList>.from(
                json["order_list"]!.map((x) => OrderList.fromJson(x))),
        budgetWoList: json["budget_wo_list"] == null
            ? []
            : List<BudgetWoList>.from(
                json["budget_wo_list"]!.map((x) => BudgetWoList.fromJson(x))),
        totalContractCost: json["total_contract_cost"],
        totalAmountPaid: json["total_amount_paid"],
        totalCost: json["total_cost"],
        overBudgetAmount: json["over_budget_amount"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "order_list": orderList == null
            ? []
            : List<dynamic>.from(orderList!.map((x) => x.toJson())),
        "budget_wo_list": budgetWoList == null
            ? []
            : List<dynamic>.from(budgetWoList!.map((x) => x.toJson())),
        "total_contract_cost": totalContractCost,
        "total_amount_paid": totalAmountPaid,
        "total_cost": totalCost,
        "over_budget_amount": overBudgetAmount,
      };
}

class BudgetWoList {
  String? budgetWoId;
  String? budgetWoName;
  String? budgetWoType;
  String? budgetWoEstContractArea;
  String? budgetWoEstContractRate;
  String? budgetWoEstContractValue;
  String? overBudgetFlag;
  String? budgetOverBudgetAmount;
  String? budgetWoContractPercentage;
  String? budgetWoContractAvoided;
  String? budgetWoContractPaid;
  String? budgetTypeId;
  String? budgetTypeName;
  String? budgetWoGstContractValue;

  BudgetWoList({
    this.budgetWoId,
    this.budgetWoName,
    this.budgetWoType,
    this.budgetWoEstContractArea,
    this.budgetWoEstContractRate,
    this.budgetWoEstContractValue,
    this.overBudgetFlag,
    this.budgetOverBudgetAmount,
    this.budgetWoContractPercentage,
    this.budgetWoContractAvoided,
    this.budgetWoContractPaid,
    this.budgetTypeId,
    this.budgetTypeName,
    this.budgetWoGstContractValue,
  });

  factory BudgetWoList.fromJson(Map<String, dynamic> json) => BudgetWoList(
        budgetWoId: json["budget_wo_id"],
        budgetWoName: json["budget_wo_name"],
        budgetWoType: json["budget_wo_type"],
        budgetWoEstContractArea: json["budget_wo_est_contract_area"],
        budgetWoEstContractRate: json["budget_wo_est_contract_rate"],
        budgetWoEstContractValue: json["budget_wo_est_contract_value"],
        overBudgetFlag: json["over_budget_flag"],
        budgetOverBudgetAmount: json["budget_over_budget_amount"],
        budgetWoContractPercentage: json["budget_wo_contract_percentage"],
        budgetWoContractAvoided: json["budget_wo_contract_avoided"],
        budgetWoContractPaid: json["budget_wo_contract_paid"],
        budgetTypeId: json["budget_type_id"],
        budgetTypeName: json["budget_type_name"],
        budgetWoGstContractValue: json["budget_wo_gst_contract_value"],
      );

  Map<String, dynamic> toJson() => {
        "budget_wo_id": budgetWoId,
        "budget_wo_name": budgetWoName,
        "budget_wo_type": budgetWoType,
        "budget_wo_est_contract_area": budgetWoEstContractArea,
        "budget_wo_est_contract_rate": budgetWoEstContractRate,
        "budget_wo_est_contract_value": budgetWoEstContractValue,
        "over_budget_flag": overBudgetFlag,
        "budget_over_budget_amount": budgetOverBudgetAmount,
        "budget_wo_contract_percentage": budgetWoContractPercentage,
        "budget_wo_contract_avoided": budgetWoContractAvoided,
        "budget_wo_contract_paid": budgetWoContractPaid,
        "budget_type_id": budgetTypeId,
        "budget_type_name": budgetTypeName,
        "budget_wo_gst_contract_value": budgetWoGstContractValue,
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
