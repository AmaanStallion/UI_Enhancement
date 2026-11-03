// To parse this JSON data, do
//
//     final budgetStatutoryDetailsResponse = budgetStatutoryDetailsResponseFromJson(jsonString);

import 'dart:convert';

BudgetStatutoryDetailsResponse budgetStatutoryDetailsResponseFromJson(
        String str) =>
    BudgetStatutoryDetailsResponse.fromJson(json.decode(str));

String budgetStatutoryDetailsResponseToJson(
        BudgetStatutoryDetailsResponse data) =>
    json.encode(data.toJson());

class BudgetStatutoryDetailsResponse {
  ResponseBudgetStatutoryDetailsResponse? response;

  BudgetStatutoryDetailsResponse({
    this.response,
  });

  factory BudgetStatutoryDetailsResponse.fromJson(Map<String, dynamic> json) =>
      BudgetStatutoryDetailsResponse(
        response: json["Response"] == null
            ? null
            : ResponseBudgetStatutoryDetailsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseBudgetStatutoryDetailsResponse {
  String? errorCode;
  String? msg;
  String? totalStatutory;
  String? totalAmountPaid;
  String? totalAmountIncur;
  String? overBudgetAmount;
  List<StatutoryDetailsList>? statutoryDetailsList;

  ResponseBudgetStatutoryDetailsResponse({
    this.errorCode,
    this.msg,
    this.totalStatutory,
    this.totalAmountPaid,
    this.totalAmountIncur,
    this.overBudgetAmount,
    this.statutoryDetailsList,
  });

  factory ResponseBudgetStatutoryDetailsResponse.fromJson(
          Map<String, dynamic> json) =>
      ResponseBudgetStatutoryDetailsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        totalStatutory: json["total_statutory"],
        totalAmountPaid: json["total_amount_paid"],
        totalAmountIncur: json["total_amount_incur"],
        overBudgetAmount: json["over_budget_amount"],
        statutoryDetailsList: json["statutory_details_list"] == null
            ? []
            : List<StatutoryDetailsList>.from(json["statutory_details_list"]!
                .map((x) => StatutoryDetailsList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "total_statutory": totalStatutory,
        "total_amount_paid": totalAmountPaid,
        "total_amount_incur": totalAmountIncur,
        "over_budget_amount": overBudgetAmount,
        "statutory_details_list": statutoryDetailsList == null
            ? []
            : List<dynamic>.from(statutoryDetailsList!.map((x) => x.toJson())),
      };
}

class StatutoryDetailsList {
  String? transStatutoryId;
  String? statutoryIdFk;
  String? transStatutoryNote;
  String? transStatutoryAmount;
  DateTime? transStatutoryDate;

  StatutoryDetailsList({
    this.transStatutoryId,
    this.statutoryIdFk,
    this.transStatutoryNote,
    this.transStatutoryAmount,
    this.transStatutoryDate,
  });

  factory StatutoryDetailsList.fromJson(Map<String, dynamic> json) =>
      StatutoryDetailsList(
        transStatutoryId: json["trans_statutory_id"],
        statutoryIdFk: json["statutory_id_fk"],
        transStatutoryNote: json["trans_statutory_note"],
        transStatutoryAmount: json["trans_statutory_amount"],
        transStatutoryDate: json["trans_statutory_date"] == null
            ? null
            : DateTime.parse(json["trans_statutory_date"]),
      );

  Map<String, dynamic> toJson() => {
        "trans_statutory_id": transStatutoryId,
        "statutory_id_fk": statutoryIdFk,
        "trans_statutory_note": transStatutoryNote,
        "trans_statutory_amount": transStatutoryAmount,
        "trans_statutory_date":
            "${transStatutoryDate!.year.toString().padLeft(4, '0')}-${transStatutoryDate!.month.toString().padLeft(2, '0')}-${transStatutoryDate!.day.toString().padLeft(2, '0')}",
      };
}
