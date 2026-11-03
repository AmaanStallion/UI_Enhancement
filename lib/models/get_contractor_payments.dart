// To parse this JSON data, do
//
//     final getContractorPayments = getContractorPaymentsFromJson(jsonString);

import 'dart:convert';

GetContractorPayments getContractorPaymentsFromJson(String str) =>
    GetContractorPayments.fromJson(json.decode(str));

String getContractorPaymentsToJson(GetContractorPayments data) =>
    json.encode(data.toJson());

class GetContractorPayments {
  GetContractorPayments({
    this.response,
  });

  ResponseGetContractorPayments? response;

  factory GetContractorPayments.fromJson(Map<String, dynamic> json) =>
      GetContractorPayments(
        response: ResponseGetContractorPayments.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetContractorPayments {
  ResponseGetContractorPayments({
    this.errorCode,
    this.msg,
    this.paymentDetails,
    this.totalPaid,
  });

  String? errorCode;
  String? msg;
  List<PaymentDetail>? paymentDetails;
  String? totalPaid;

  factory ResponseGetContractorPayments.fromJson(Map<String, dynamic> json) =>
      ResponseGetContractorPayments(
        errorCode: json["error_code"],
        msg: json["msg"],
        paymentDetails: List<PaymentDetail>.from(
            json["payment_details"].map((x) => PaymentDetail.fromJson(x))),
        totalPaid: json["total_paid"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "payment_details":
            List<dynamic>.from(paymentDetails!.map((x) => x.toJson())),
        "total_paid": totalPaid,
      };
}

class PaymentDetail {
  PaymentDetail({
    this.transactionNo,
    this.paymentAmount,
    this.paymentMode,
    this.paymentDate,
  });

  String? transactionNo;
  String? paymentAmount;
  String? paymentMode;
  String? paymentDate;

  factory PaymentDetail.fromJson(Map<String, dynamic> json) => PaymentDetail(
        transactionNo: json["transaction_no"],
        paymentAmount: json["payment_amount"],
        paymentMode: json["payment_mode"],
        paymentDate: json["payment_date"],
      );

  Map<String, dynamic> toJson() => {
        "transaction_no": transactionNo,
        "payment_amount": paymentAmount,
        "payment_mode": paymentMode,
        "payment_date": paymentDate,
      };
}
