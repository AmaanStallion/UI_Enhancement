// To parse this JSON data, do
//
//     final getOverBugetView = getOverBugetViewFromJson(jsonString);

import 'dart:convert';

GetOverBugetView getOverBugetViewFromJson(String str) =>
    GetOverBugetView.fromJson(json.decode(str));

String getOverBugetViewToJson(GetOverBugetView data) =>
    json.encode(data.toJson());

class GetOverBugetView {
  GetOverBugetViewResponse? response;

  GetOverBugetView({
    this.response,
  });

  factory GetOverBugetView.fromJson(Map<String, dynamic> json) =>
      GetOverBugetView(
        response: json["Response"] == null
            ? null
            : GetOverBugetViewResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetOverBugetViewResponse {
  String? errorCode;
  String? msg;
  List<PoBudgetList>? poBudgetList;
  List<WoBudgetList>? woBudgetList;

  GetOverBugetViewResponse({
    this.errorCode,
    this.msg,
    this.poBudgetList,
    this.woBudgetList,
  });

  factory GetOverBugetViewResponse.fromJson(Map<String, dynamic> json) =>
      GetOverBugetViewResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        poBudgetList: json["po_budget_list"] == null
            ? []
            : List<PoBudgetList>.from(
                json["po_budget_list"]!.map((x) => PoBudgetList.fromJson(x))),
        woBudgetList: json["wo_budget_list"] == null
            ? []
            : List<WoBudgetList>.from(
                json["wo_budget_list"]!.map((x) => WoBudgetList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "po_budget_list": poBudgetList == null
            ? []
            : List<dynamic>.from(poBudgetList!.map((x) => x.toJson())),
        "wo_budget_list": woBudgetList == null
            ? []
            : List<dynamic>.from(woBudgetList!.map((x) => x.toJson())),
      };
}

class PoBudgetList {
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

  PoBudgetList({
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

  factory PoBudgetList.fromJson(Map<String, dynamic> json) => PoBudgetList(
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

class WoBudgetList {
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

  WoBudgetList({
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

  factory WoBudgetList.fromJson(Map<String, dynamic> json) => WoBudgetList(
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
