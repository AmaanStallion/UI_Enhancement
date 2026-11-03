// To parse this JSON data, do
//
//     final budgetStatutoryResponse = budgetStatutoryResponseFromJson(jsonString);

import 'dart:convert';

BudgetStatutoryResponse budgetStatutoryResponseFromJson(String str) =>
    BudgetStatutoryResponse.fromJson(json.decode(str));

String budgetStatutoryResponseToJson(BudgetStatutoryResponse data) =>
    json.encode(data.toJson());

class BudgetStatutoryResponse {
  ResponseBudgetStatutoryResponse? response;

  BudgetStatutoryResponse({
    this.response,
  });

  factory BudgetStatutoryResponse.fromJson(Map<String, dynamic> json) =>
      BudgetStatutoryResponse(
        response: json["Response"] == null
            ? null
            : ResponseBudgetStatutoryResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseBudgetStatutoryResponse {
  String? errorCode;
  String? msg;
  List<OrderList>? orderList;
  String? totalStatutory;
  String? totalAmountPaid;
  String? totalAmountIncur;
  String? overBudgetAmount;
  List<StatutoryList>? statutoryList;

  ResponseBudgetStatutoryResponse({
    this.errorCode,
    this.msg,
    this.orderList,
    this.totalStatutory,
    this.totalAmountPaid,
    this.totalAmountIncur,
    this.overBudgetAmount,
    this.statutoryList,
  });

  factory ResponseBudgetStatutoryResponse.fromJson(Map<String, dynamic> json) =>
      ResponseBudgetStatutoryResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        orderList: json["order_list"] == null
            ? []
            : List<OrderList>.from(
                json["order_list"]!.map((x) => OrderList.fromJson(x))),
        totalStatutory: json["total_statutory"],
        totalAmountPaid: json["total_amount_paid"],
        totalAmountIncur: json["total_amount_incur"],
        overBudgetAmount: json["over_budget_amount"],
        statutoryList: json["statutory_list"] == null
            ? []
            : List<StatutoryList>.from(
                json["statutory_list"]!.map((x) => StatutoryList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "order_list": orderList == null
            ? []
            : List<dynamic>.from(orderList!.map((x) => x.toJson())),
        "total_statutory": totalStatutory,
        "total_amount_paid": totalAmountPaid,
        "total_amount_incur": totalAmountIncur,
        "over_budget_amount": overBudgetAmount,
        "statutory_list": statutoryList == null
            ? []
            : List<dynamic>.from(statutoryList!.map((x) => x.toJson())),
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

class StatutoryList {
  String? mstStatutoryId;
  String? mstStatutoryName;
  String? mstStatutoryValue;
  String? statutoryAmountPaid;
  String? statutoryAmountIncur;
  String? statutoryOverBudgetAmount;
  String? statutoryPercentage;
  String? transStatutoryId;
  String? overBudgetFlag;

  StatutoryList({
    this.mstStatutoryId,
    this.mstStatutoryName,
    this.mstStatutoryValue,
    this.statutoryAmountPaid,
    this.statutoryAmountIncur,
    this.statutoryOverBudgetAmount,
    this.statutoryPercentage,
    this.transStatutoryId,
    this.overBudgetFlag,
  });

  factory StatutoryList.fromJson(Map<String, dynamic> json) => StatutoryList(
        mstStatutoryId: json["mst_statutory_id"],
        mstStatutoryName: json["mst_statutory_name"],
        mstStatutoryValue: json["mst_statutory_value"],
        statutoryAmountPaid: json["statutory_amount_paid"],
        statutoryAmountIncur: json["statutory_amount_incur"],
        statutoryOverBudgetAmount: json["statutory_over_budget_amount"],
        statutoryPercentage: json["statutory_percentage"],
        transStatutoryId: json["trans_statutory_id"],
        overBudgetFlag: json["over_budget_flag"],
      );

  Map<String, dynamic> toJson() => {
        "mst_statutory_id": mstStatutoryId,
        "mst_statutory_name": mstStatutoryName,
        "mst_statutory_value": mstStatutoryValue,
        "statutory_amount_paid": statutoryAmountPaid,
        "statutory_amount_incur": statutoryAmountIncur,
        "statutory_over_budget_amount": statutoryOverBudgetAmount,
        "statutory_percentage": statutoryPercentage,
        "trans_statutory_id": transStatutoryId,
        "over_budget_flag": overBudgetFlag,
      };
}
