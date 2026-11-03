// To parse this JSON data, do
//
//     final getCmsDetails = getCmsDetailsFromJson(jsonString);

import 'dart:convert';

GetCmsDetails getCmsDetailsFromJson(String str) => GetCmsDetails.fromJson(json.decode(str));

String getCmsDetailsToJson(GetCmsDetails data) => json.encode(data.toJson());

class GetCmsDetails {
  GetCmsDetails({
    this.response,
  });

  ResponseGetCmsDetails? response;

  factory GetCmsDetails.fromJson(Map<String, dynamic> json) => GetCmsDetails(
    response: ResponseGetCmsDetails.fromJson(json["Response"]),
  );

  Map<String, dynamic> toJson() => {
    "Response": response?.toJson(),
  };
}

class ResponseGetCmsDetails {
  ResponseGetCmsDetails({
    this.errorCode,
    this.msg,
    this.cmsDetails,
  });

  String? errorCode;
  String? msg;
  List<CmsDetail>? cmsDetails;

  factory ResponseGetCmsDetails.fromJson(Map<String, dynamic> json) => ResponseGetCmsDetails(
    errorCode: json["error_code"],
    msg: json["msg"],
    cmsDetails: List<CmsDetail>.from(json["cms_details"].map((x) => CmsDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error_code": errorCode,
    "msg": msg,
    "cms_details": List<dynamic>.from(cmsDetails!.map((x) => x.toJson())),
  };
}

class CmsDetail {
  CmsDetail({
    this.cmsValId,
    this.cmsId,
    this.pageTitle,
    this.pageContent,
    this.pageSeoTitleLang,
    this.pageMetaKeyword,
    this.pageMetaDescription,
    this.langId,
  });

  String? cmsValId;
  String? cmsId;
  String? pageTitle;
  String? pageContent;
  String? pageSeoTitleLang;
  String? pageMetaKeyword;
  String? pageMetaDescription;
  String? langId;

  factory CmsDetail.fromJson(Map<String, dynamic> json) => CmsDetail(
    cmsValId: json["cms_val_id"],
    cmsId: json["cms_id"],
    pageTitle: json["page_title"],
    pageContent: json["page_content"],
    pageSeoTitleLang: json["page_seo_title_lang"],
    pageMetaKeyword: json["page_meta_keyword"],
    pageMetaDescription: json["page_meta_description"],
    langId: json["lang_id"],
  );

  Map<String, dynamic> toJson() => {
    "cms_val_id": cmsValId,
    "cms_id": cmsId,
    "page_title": pageTitle,
    "page_content": pageContent,
    "page_seo_title_lang": pageSeoTitleLang,
    "page_meta_keyword": pageMetaKeyword,
    "page_meta_description": pageMetaDescription,
    "lang_id": langId,
  };
}
