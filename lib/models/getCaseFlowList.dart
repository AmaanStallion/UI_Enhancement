// To parse this JSON data, do
//
//     final getCaseFlowList = getCaseFlowListFromJson(jsonString);

import 'dart:convert';

GetCaseFlowList getCaseFlowListFromJson(String str) =>
    GetCaseFlowList.fromJson(json.decode(str));

String getCaseFlowListToJson(GetCaseFlowList data) =>
    json.encode(data.toJson());

class GetCaseFlowList {
  GetCaseFlowListResponse? response;

  GetCaseFlowList({
    this.response,
  });

  factory GetCaseFlowList.fromJson(Map<String, dynamic> json) =>
      GetCaseFlowList(
        response: json["Response"] == null
            ? null
            : GetCaseFlowListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetCaseFlowListResponse {
  String? errorCode;
  String? msg;
  List<BankDetail>? bankDetails;
  List<CaseflowList>? caseflowList;
  String? totalCredit;
  String? totalDebit;
  String? totalCount;

  GetCaseFlowListResponse({
    this.errorCode,
    this.msg,
    this.bankDetails,
    this.caseflowList,
    this.totalCredit,
    this.totalDebit,
    this.totalCount,
  });

  factory GetCaseFlowListResponse.fromJson(Map<String, dynamic> json) =>
      GetCaseFlowListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        bankDetails: json["bank_details"] == null
            ? []
            : List<BankDetail>.from(
                json["bank_details"]!.map((x) => BankDetail.fromJson(x))),
        caseflowList: json["caseflow_list"] == null
            ? []
            : List<CaseflowList>.from(
                json["caseflow_list"]!.map((x) => CaseflowList.fromJson(x))),
        totalCredit: json["total_credit"],
        totalDebit: json["total_debit"],
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "bank_details": bankDetails == null
            ? []
            : List<dynamic>.from(bankDetails!.map((x) => x.toJson())),
        "caseflow_list": caseflowList == null
            ? []
            : List<dynamic>.from(caseflowList!.map((x) => x.toJson())),
        "total_credit": totalCredit,
        "total_debit": totalDebit,
        "total_count": totalCount,
      };
}

class BankDetail {
  String? projectBankId;
  String? projectIdFk;
  String? bankName;
  String? accountHolderName;
  String? accountNumber;
  String? bankIfscCode;
  String? projectBankStatus;
  DateTime? projectBankUpdateAt;
  DateTime? projectBankCreateAt;
  String? address;
  String? address2;
  String? address3;
  String? branch;
  String? bankDtFor;
  String? bankTowerIdFk;

  BankDetail({
    this.projectBankId,
    this.projectIdFk,
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.bankIfscCode,
    this.projectBankStatus,
    this.projectBankUpdateAt,
    this.projectBankCreateAt,
    this.address,
    this.address2,
    this.address3,
    this.branch,
    this.bankDtFor,
    this.bankTowerIdFk,
  });

  factory BankDetail.fromJson(Map<String, dynamic> json) => BankDetail(
        projectBankId: json["project_bank_id"],
        projectIdFk: json["project_id_fk"],
        bankName: json["bank_name"],
        accountHolderName: json["account_holder_name"],
        accountNumber: json["account_number"],
        bankIfscCode: json["bank_ifsc_code"],
        projectBankStatus: json["project_bank_status"],
        projectBankUpdateAt: json["project_bank_update_at"] == null
            ? null
            : DateTime.parse(json["project_bank_update_at"]),
        projectBankCreateAt: json["project_bank_create_at"] == null
            ? null
            : DateTime.parse(json["project_bank_create_at"]),
        address: json["address"],
        address2: json["address2"],
        address3: json["address3"],
        branch: json["branch"],
        bankDtFor: json["bank_dt_for"],
        bankTowerIdFk: json["bank_tower_id_fk"],
      );

  Map<String, dynamic> toJson() => {
        "project_bank_id": projectBankId,
        "project_id_fk": projectIdFk,
        "bank_name": bankName,
        "account_holder_name": accountHolderName,
        "account_number": accountNumber,
        "bank_ifsc_code": bankIfscCode,
        "project_bank_status": projectBankStatus,
        "project_bank_update_at": projectBankUpdateAt?.toIso8601String(),
        "project_bank_create_at": projectBankCreateAt?.toIso8601String(),
        "address": address,
        "address2": address2,
        "address3": address3,
        "branch": branch,
        "bank_dt_for": bankDtFor,
        "bank_tower_id_fk": bankTowerIdFk,
      };
}

class CaseflowList {
  String? id;
  String? transationName;
  String? instument;
  DateTime? bankDate;
  String? creditAmount;
  String? debitAmount;
  String? creditType;
  String? paymentType;
  DateTime? createdAt;

  CaseflowList({
    this.id,
    this.transationName,
    this.instument,
    this.bankDate,
    this.creditAmount,
    this.debitAmount,
    this.creditType,
    this.paymentType,
    this.createdAt,
  });

  factory CaseflowList.fromJson(Map<String, dynamic> json) => CaseflowList(
        id: json["id"],
        transationName: json["transation_name"],
        instument: json["instument"],
        bankDate: json["bank_date"] == null
            ? null
            : DateTime.parse(json["bank_date"]),
        creditAmount: json["credit_amount"],
        debitAmount: json["debit_amount"],
        creditType: json["credit_type"],
        paymentType: json["payment_type"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "transation_name": transationName,
        "instument": instument,
        "bank_date":
            "${bankDate!.year.toString().padLeft(4, '0')}-${bankDate!.month.toString().padLeft(2, '0')}-${bankDate!.day.toString().padLeft(2, '0')}",
        "credit_amount": creditAmount,
        "debit_amount": debitAmount,
        "credit_type": creditType,
        "payment_type": paymentType,
        "created_at":
            "${createdAt!.year.toString().padLeft(4, '0')}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}",
      };
}
