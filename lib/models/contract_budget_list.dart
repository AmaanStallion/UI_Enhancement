// To parse this JSON data, do
//
//     final contractBudgetList = contractBudgetListFromJson(jsonString);

import 'dart:convert';

ContractBudgetList contractBudgetListFromJson(String str) =>
    ContractBudgetList.fromJson(json.decode(str));

String contractBudgetListToJson(ContractBudgetList data) =>
    json.encode(data.toJson());

class ContractBudgetList {
  ContractBudgetListResponse? response;

  ContractBudgetList({
    this.response,
  });

  factory ContractBudgetList.fromJson(Map<String, dynamic> json) =>
      ContractBudgetList(
        response: json["Response"] == null
            ? null
            : ContractBudgetListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ContractBudgetListResponse {
  String? errorCode;
  String? msg;
  List<BudgetCompanyList>? budgetCompanyList;
  String? totalContractCost;
  String? totalAmountPaid;
  String? costToIncur;

  ContractBudgetListResponse({
    this.errorCode,
    this.msg,
    this.budgetCompanyList,
    this.totalContractCost,
    this.totalAmountPaid,
    this.costToIncur,
  });

  factory ContractBudgetListResponse.fromJson(Map<String, dynamic> json) =>
      ContractBudgetListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        budgetCompanyList: json["budget_company_list"] == null
            ? []
            : List<BudgetCompanyList>.from(json["budget_company_list"]!
                .map((x) => BudgetCompanyList.fromJson(x))),
        totalContractCost: json["total_contract_cost"],
        totalAmountPaid: json["total_amount_paid"],
        costToIncur: json["cost_to_incur"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "budget_company_list": budgetCompanyList == null
            ? []
            : List<dynamic>.from(budgetCompanyList!.map((x) => x.toJson())),
        "total_contract_cost": totalContractCost,
        "total_amount_paid": totalAmountPaid,
        "cost_to_incur": costToIncur,
      };
}

class BudgetCompanyList {
  String? mstCompanyId;
  String? mstCompanyName;
  String? contractAvoided;
  String? contractPaid;
  String? workOrderId;
  String? woTypeOrder;
  String? gradeIdFk;

  BudgetCompanyList({
    this.mstCompanyId,
    this.mstCompanyName,
    this.contractAvoided,
    this.contractPaid,
    this.workOrderId,
    this.woTypeOrder,
    this.gradeIdFk,
  });

  factory BudgetCompanyList.fromJson(Map<String, dynamic> json) =>
      BudgetCompanyList(
        mstCompanyId: json["mst_company_id"],
        mstCompanyName: json["mst_company_name"],
        contractAvoided: json["contract_avoided"],
        contractPaid: json["contract_paid"],
        workOrderId: json["work_order_id"],
        woTypeOrder: json["wo_type_order"],
        gradeIdFk: json["grade_id_fk"],
      );

  Map<String, dynamic> toJson() => {
        "mst_company_id": mstCompanyId,
        "mst_company_name": mstCompanyName,
        "contract_avoided": contractAvoided,
        "contract_paid": contractPaid,
        "work_order_id": workOrderId,
        "wo_type_order": woTypeOrder,
        "grade_id_fk": gradeIdFk,
      };
}
