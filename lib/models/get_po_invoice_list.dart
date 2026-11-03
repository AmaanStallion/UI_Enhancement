// To parse this JSON data, do
//
//     final getInvoiceList = getInvoiceListFromJson(jsonString);

import 'dart:convert';

GetInvoiceList getInvoiceListFromJson(String str) =>
    GetInvoiceList.fromJson(json.decode(str));

String getInvoiceListToJson(GetInvoiceList data) => json.encode(data.toJson());

class GetInvoiceList {
  GetInvoiceList({
    this.response,
  });

  ResponseGetInvoiceList? response;

  factory GetInvoiceList.fromJson(Map<String, dynamic> json) => GetInvoiceList(
        response: ResponseGetInvoiceList.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetInvoiceList {
  ResponseGetInvoiceList({
    this.errorCode,
    this.msg,
    this.invoiceData,
    this.invoicePath,
  });

  String? errorCode;
  String? msg;
  List<InvoiceDatum>? invoiceData;
  String? invoicePath;

  factory ResponseGetInvoiceList.fromJson(Map<String, dynamic> json) =>
      ResponseGetInvoiceList(
        errorCode: json["error_code"],
        msg: json["msg"],
        invoiceData: List<InvoiceDatum>.from(
            json["invoice_data"].map((x) => InvoiceDatum.fromJson(x))),
        invoicePath: json["invoice_path"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "invoice_data": List<dynamic>.from(invoiceData!.map((x) => x.toJson())),
        "invoice_path": invoicePath,
      };
}

class InvoiceDatum {
  InvoiceDatum({
    this.invoiceId,
    this.invoiceNo,
    this.invoiceImage,
    this.invoiceDate,
    this.totalPaid,
    this.totalAmount,
    this.status,
  });

  String? invoiceId;
  String? invoiceNo;
  String? invoiceImage;
  String? invoiceDate;
  String? totalPaid;
  String? totalAmount;
  String? status;

  factory InvoiceDatum.fromJson(Map<String, dynamic> json) => InvoiceDatum(
        invoiceId: json["invoice_id"],
        invoiceNo: json["invoice_no"],
        invoiceImage: json["invoice_image"],
        invoiceDate: json["invoice_date"],
        totalPaid: json["total_paid"],
        totalAmount: json["total_amount"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "invoice_id": invoiceId,
        "invoice_no": invoiceNo,
        "invoice_image": invoiceImage,
        "invoice_date": invoiceDate,
        "total_paid": totalPaid,
        "total_amount": totalAmount,
        "status": status,
      };
}
