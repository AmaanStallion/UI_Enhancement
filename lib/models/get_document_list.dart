// To parse this JSON data, do
//
//     final getDocumentList = getDocumentListFromJson(jsonString);

import 'dart:convert';

GetDocumentList getDocumentListFromJson(String str) =>
    GetDocumentList.fromJson(json.decode(str));

String getDocumentListToJson(GetDocumentList data) =>
    json.encode(data.toJson());

class GetDocumentList {
  ResponseGetDocumentList? response;

  GetDocumentList({
    this.response,
  });

  factory GetDocumentList.fromJson(Map<String, dynamic> json) =>
      GetDocumentList(
        response: json["Response"] == null
            ? null
            : ResponseGetDocumentList.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetDocumentList {
  String? errorCode;
  String? msg;
  String? bankLetter;
  String? flatAllotLetter;
  List<FlatBuyer>? flatBuyerDemandNote;
  List<FlatBuyer>? flatBuyerInvoiceData;
  String? costomCharesLetter;
  List<ArchCertificate>? archCertificate;
  String? possessionLetter;

  ResponseGetDocumentList({
    this.errorCode,
    this.msg,
    this.bankLetter,
    this.flatAllotLetter,
    this.flatBuyerDemandNote,
    this.flatBuyerInvoiceData,
    this.costomCharesLetter,
    this.archCertificate,
    this.possessionLetter,
  });

  factory ResponseGetDocumentList.fromJson(Map<String, dynamic> json) =>
      ResponseGetDocumentList(
        errorCode: json["error_code"],
        msg: json["msg"],
        bankLetter: json["bank_letter"],
        flatAllotLetter: json["flat_allot_letter"],
        flatBuyerDemandNote: json["flat_buyer_demand_note"] == null
            ? []
            : List<FlatBuyer>.from(json["flat_buyer_demand_note"]!
                .map((x) => FlatBuyer.fromJson(x))),
        flatBuyerInvoiceData: json["flat_buyer_invoice_data"] == null
            ? []
            : List<FlatBuyer>.from(json["flat_buyer_invoice_data"]!
                .map((x) => FlatBuyer.fromJson(x))),
        costomCharesLetter: json["costom_chares_letter"],
        archCertificate: json["arch_certificate"] == null
            ? []
            : List<ArchCertificate>.from(json["arch_certificate"]!
                .map((x) => ArchCertificate.fromJson(x))),
        possessionLetter: json["possession_letter"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "bank_letter": bankLetter,
        "flat_allot_letter": flatAllotLetter,
        "flat_buyer_demand_note": flatBuyerDemandNote == null
            ? []
            : List<dynamic>.from(flatBuyerDemandNote!.map((x) => x.toJson())),
        "flat_buyer_invoice_data": flatBuyerInvoiceData == null
            ? []
            : List<dynamic>.from(flatBuyerInvoiceData!.map((x) => x.toJson())),
        "costom_chares_letter": costomCharesLetter,
        "arch_certificate": archCertificate == null
            ? []
            : List<dynamic>.from(archCertificate!.map((x) => x.toJson())),
        "possession_letter": possessionLetter,
      };
}

class ArchCertificate {
  String? slabName;
  List<Detail>? details;

  ArchCertificate({
    this.slabName,
    this.details,
  });

  factory ArchCertificate.fromJson(Map<String, dynamic> json) =>
      ArchCertificate(
        slabName: json["slab_name"],
        details: json["details"] == null
            ? []
            : List<Detail>.from(
                json["details"]!.map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "slab_name": slabName,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class Detail {
  String? title;
  String? slabName;
  String? certificateRemark;
  String? createdAt;
  String? viewPdf;

  Detail({
    this.title,
    this.slabName,
    this.certificateRemark,
    this.createdAt,
    this.viewPdf,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        title: json["title"],
        slabName: json["slab_name"],
        certificateRemark: json["certificate_remark"],
        createdAt: json["created_at"],
        viewPdf: json["view_pdf"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "slab_name": slabName,
        "certificate_remark": certificateRemark,
        "created_at": createdAt,
        "view_pdf": viewPdf,
      };
}

class FlatBuyer {
  String? title;
  String? amountDue;
  String? dueDate;
  String? viewPdf;

  FlatBuyer({
    this.title,
    this.amountDue,
    this.dueDate,
    this.viewPdf,
  });

  factory FlatBuyer.fromJson(Map<String, dynamic> json) => FlatBuyer(
        title: json["title"],
        amountDue: json["amount_due"],
        dueDate: json["due_date"],
        viewPdf: json["view_pdf"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "amount_due": amountDue,
        "due_date": dueDate,
        "view_pdf": viewPdf,
      };
}
