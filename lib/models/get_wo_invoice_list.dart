// To parse this JSON data, do
//
//     final getWoInvoiceList = getWoInvoiceListFromJson(jsonString);

import 'dart:convert';

GetWoInvoiceList getWoInvoiceListFromJson(String str) => GetWoInvoiceList.fromJson(json.decode(str));

String getWoInvoiceListToJson(GetWoInvoiceList data) => json.encode(data.toJson());

class GetWoInvoiceList {
  GetWoInvoiceList({
    this.response,
  });

  ResponseGetWoInvoiceList? response;

  factory GetWoInvoiceList.fromJson(Map<String, dynamic> json) => GetWoInvoiceList(
    response: ResponseGetWoInvoiceList.fromJson(json["Response"]),
  );

  Map<String, dynamic> toJson() => {
    "Response": response?.toJson(),
  };
}

class ResponseGetWoInvoiceList {
  ResponseGetWoInvoiceList({
    this.errorCode,
    this.msg,
    this.invoiceData,
    this.invoicePath,
  });

  String? errorCode;
  String? msg;
  List<InvoiceDatum>? invoiceData;
  String? invoicePath;

  factory ResponseGetWoInvoiceList.fromJson(Map<String, dynamic> json) => ResponseGetWoInvoiceList(
    errorCode: json["error_code"],
    msg: json["msg"],
    invoiceData: List<InvoiceDatum>.from(json["invoice_data"].map((x) => InvoiceDatum.fromJson(x))),
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
