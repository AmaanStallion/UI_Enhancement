// To parse this JSON data, do
//
//     final tenantDocuments = tenantDocumentsFromJson(jsonString);

import 'dart:convert';

TenantDocuments tenantDocumentsFromJson(String str) =>
    TenantDocuments.fromJson(json.decode(str));

String tenantDocumentsToJson(TenantDocuments data) =>
    json.encode(data.toJson());

class TenantDocuments {
  TenantDocumentsResponse? response;

  TenantDocuments({
    this.response,
  });

  factory TenantDocuments.fromJson(Map<String, dynamic> json) =>
      TenantDocuments(
        response: json["Response"] == null
            ? null
            : TenantDocumentsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class TenantDocumentsResponse {
  String? errorCode;
  String? msg;
  TenantDoc? tenantDoc;

  TenantDocumentsResponse({
    this.errorCode,
    this.msg,
    this.tenantDoc,
  });

  factory TenantDocumentsResponse.fromJson(Map<String, dynamic> json) =>
      TenantDocumentsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        tenantDoc: json["tenant_doc"] == null
            ? null
            : TenantDoc.fromJson(json["tenant_doc"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "tenant_doc": tenantDoc?.toJson(),
      };
}

class TenantDoc {
  List<Consent>? consent;
  List<Consent>? paaa;
  List<Consent>? personal;
  List<Consent>? tot;
  String? flatAllotLetter;
  String? flatAllotPath;

  TenantDoc({
    this.consent,
    this.paaa,
    this.personal,
    this.tot,
    this.flatAllotLetter,
    this.flatAllotPath,
  });

  factory TenantDoc.fromJson(Map<String, dynamic> json) => TenantDoc(
        consent: json["consent"] == null
            ? []
            : List<Consent>.from(
                json["consent"]!.map((x) => Consent.fromJson(x))),
        paaa: json["paaa"] == null
            ? []
            : List<Consent>.from(json["paaa"]!.map((x) => Consent.fromJson(x))),
        personal: json["personal"] == null
            ? []
            : List<Consent>.from(
                json["personal"]!.map((x) => Consent.fromJson(x))),
        tot: json["tot"] == null
            ? []
            : List<Consent>.from(json["tot"]!.map((x) => Consent.fromJson(x))),
        flatAllotLetter: json["flat_allot_letter"],
        flatAllotPath: json["flat_allot_path"],
      );

  Map<String, dynamic> toJson() => {
        "consent": consent == null
            ? []
            : List<dynamic>.from(consent!.map((x) => x.toJson())),
        "paaa": paaa == null
            ? []
            : List<dynamic>.from(paaa!.map((x) => x.toJson())),
        "personal": personal == null
            ? []
            : List<dynamic>.from(personal!.map((x) => x.toJson())),
        "tot":
            tot == null ? [] : List<dynamic>.from(tot!.map((x) => x.toJson())),
        "flat_allot_letter": flatAllotLetter,
        "flat_allot_path": flatAllotPath,
      };
}

class Consent {
  String? documentType;
  String? documentName;

  Consent({
    this.documentType,
    this.documentName,
  });

  factory Consent.fromJson(Map<String, dynamic> json) => Consent(
        documentType: json["document_type"],
        documentName: json["document_name"],
      );

  Map<String, dynamic> toJson() => {
        "document_type": documentType,
        "document_name": documentName,
      };
}
