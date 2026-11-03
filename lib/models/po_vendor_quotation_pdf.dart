// To parse this JSON data, do
//
//     final poVendorQuotationPdf = poVendorQuotationPdfFromJson(jsonString);

import 'dart:convert';

PoVendorQuotationPdf poVendorQuotationPdfFromJson(String str) =>
    PoVendorQuotationPdf.fromJson(json.decode(str));

String poVendorQuotationPdfToJson(PoVendorQuotationPdf data) =>
    json.encode(data.toJson());

class PoVendorQuotationPdf {
  PoVendorQuotationPdfResponse? response;

  PoVendorQuotationPdf({
    this.response,
  });

  factory PoVendorQuotationPdf.fromJson(Map<String, dynamic> json) =>
      PoVendorQuotationPdf(
        response: json["Response"] == null
            ? null
            : PoVendorQuotationPdfResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class PoVendorQuotationPdfResponse {
  String? errorCode;
  String? msg;
  String? quoteFileName;
  String? quoteFilePath;

  PoVendorQuotationPdfResponse({
    this.errorCode,
    this.msg,
    this.quoteFileName,
    this.quoteFilePath,
  });

  factory PoVendorQuotationPdfResponse.fromJson(Map<String, dynamic> json) =>
      PoVendorQuotationPdfResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        quoteFileName: json["quote_file_name"],
        quoteFilePath: json["quote_file_path"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "quote_file_name": quoteFileName,
        "quote_file_path": quoteFilePath,
      };
}
