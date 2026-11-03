// To parse this JSON data, do
//
//     final companyPaymentDue = companyPaymentDueFromJson(jsonString);

import 'dart:convert';

CompanyPaymentDue companyPaymentDueFromJson(String str) =>
    CompanyPaymentDue.fromJson(json.decode(str));

String companyPaymentDueToJson(CompanyPaymentDue data) =>
    json.encode(data.toJson());

class CompanyPaymentDue {
  CompanyPaymentDueResponse? response;

  CompanyPaymentDue({
    this.response,
  });

  factory CompanyPaymentDue.fromJson(Map<String, dynamic> json) =>
      CompanyPaymentDue(
        response: json["Response"] == null
            ? null
            : CompanyPaymentDueResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class CompanyPaymentDueResponse {
  String? errorCode;
  String? msg;
  String? paymentDue;
  String? paymentOverdue;
  String? totalPaidAmount;
  String? paymentBalance;

  CompanyPaymentDueResponse({
    this.errorCode,
    this.msg,
    this.paymentDue,
    this.paymentOverdue,
    this.totalPaidAmount,
    this.paymentBalance,
  });

  factory CompanyPaymentDueResponse.fromJson(Map<String, dynamic> json) =>
      CompanyPaymentDueResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        paymentDue: json["payment_due"],
        paymentOverdue: json["payment_overdue"],
        totalPaidAmount: json["total_paid_amount"],
        paymentBalance: json["payment_balance"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "payment_due": paymentDue,
        "payment_overdue": paymentOverdue,
        "total_paid_amount": totalPaidAmount,
        "payment_balance": paymentBalance,
      };
}
