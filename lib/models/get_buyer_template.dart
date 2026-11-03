// To parse this JSON data, do
//
//     final webgetbuyertemplate = webgetbuyertemplateFromJson(jsonString);

import 'dart:convert';

Webgetbuyertemplate webgetbuyertemplateFromJson(String str) =>
    Webgetbuyertemplate.fromJson(json.decode(str));

String webgetbuyertemplateToJson(Webgetbuyertemplate data) =>
    json.encode(data.toJson());

class Webgetbuyertemplate {
  ResponseWebgetbuyertemplate? response;

  Webgetbuyertemplate({
    this.response,
  });

  factory Webgetbuyertemplate.fromJson(Map<String, dynamic> json) =>
      Webgetbuyertemplate(
        response: json["Response"] == null
            ? null
            : ResponseWebgetbuyertemplate.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseWebgetbuyertemplate {
  String? errorCode;
  String? msg;
  List<MasoryList>? masoryList;
  List<DefaultMasonryList>? defaultMasonryList;
  List<SalesType>? salesType;
  List<FinishingTypeList>? finishingTypeList;

  ResponseWebgetbuyertemplate({
    this.errorCode,
    this.msg,
    this.masoryList,
    this.defaultMasonryList,
    this.salesType,
    this.finishingTypeList,
  });

  factory ResponseWebgetbuyertemplate.fromJson(Map<String, dynamic> json) =>
      ResponseWebgetbuyertemplate(
        errorCode: json["error_code"],
        msg: json["msg"],
        masoryList: json["masory_list"] == null
            ? []
            : List<MasoryList>.from(
                json["masory_list"]!.map((x) => MasoryList.fromJson(x))),
        defaultMasonryList: json["default_masonry_list"] == null
            ? []
            : List<DefaultMasonryList>.from(json["default_masonry_list"]!
                .map((x) => DefaultMasonryList.fromJson(x))),
        salesType: json["sales_type"] == null
            ? []
            : List<SalesType>.from(
                json["sales_type"]!.map((x) => SalesType.fromJson(x))),
        finishingTypeList: json["finishing_type_list"] == null
            ? []
            : List<FinishingTypeList>.from(json["finishing_type_list"]!
                .map((x) => FinishingTypeList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "masory_list": masoryList == null
            ? []
            : List<dynamic>.from(masoryList!.map((x) => x.toJson())),
        "default_masonry_list": defaultMasonryList == null
            ? []
            : List<dynamic>.from(defaultMasonryList!.map((x) => x.toJson())),
        "sales_type": salesType == null
            ? []
            : List<dynamic>.from(salesType!.map((x) => x.toJson())),
        "finishing_type_list": finishingTypeList == null
            ? []
            : List<dynamic>.from(finishingTypeList!.map((x) => x.toJson())),
      };
}

class DefaultMasonryList {
  String? name;
  List<MasoryList>? details;

  DefaultMasonryList({
    this.name,
    this.details,
  });

  factory DefaultMasonryList.fromJson(Map<String, dynamic> json) =>
      DefaultMasonryList(
        name: json["name"],
        details: json["details"] == null
            ? []
            : List<MasoryList>.from(
                json["details"]!.map((x) => MasoryList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class MasoryList {
  String? date_show;
  String? payment_date;
  String? masonry_id;
  String? flat_id;
  String? masonry_name;
  String? payment_name;
  String? payment_amount;
  String? masonry_percentage;
  String? payment_percentage;
  String? masnory_date;
  String? advanceFlag;
  String? select_type_id;
  String? template_remark;
  String? payment_id;
  String? trans_project_slab_end_date;

  MasoryList({
    this.date_show,
    this.payment_date,
    this.masonry_id,
    this.payment_id,
    this.flat_id,
    this.advanceFlag,
    this.payment_name,
    this.masonry_name,
    this.payment_amount,
    this.masonry_percentage,
    this.payment_percentage,
    this.masnory_date,
    this.select_type_id,
    this.template_remark,
    this.trans_project_slab_end_date,
  });

  factory MasoryList.fromJson(Map<String, dynamic> json) => MasoryList(
        date_show: json["date_show"],
        flat_id: json["flat_id"],
        payment_id: json["payment_id"],
        advanceFlag: json["advanceFlag"],
        payment_date: json["payment_date"],
        payment_name: json["payment_name"],
        masonry_id: json["masonry_id"],
        payment_amount: json["payment_amount"],
        masonry_name: json["masonry_name"],
        masonry_percentage: json["masonry_percentage"],
        payment_percentage: json["payment_percentage"],
        masnory_date: json["masnory_date"],
        select_type_id: json["select_type_id"],
        template_remark: json["template_remark"],
        trans_project_slab_end_date: json["trans_project_slab_end_date"],
      );

  Map<String, dynamic> toJson() => {
        "date_show": date_show,
        "flat_id": flat_id,
        "advanceFlag": advanceFlag,
        "masonry_id": masonry_id,
        "payment_id": payment_id,
        "payment_date": payment_date,
        "masonry_name": masonry_name,
        "payment_name": payment_name,
        "payment_amount": payment_amount,
        "masonry_percentage": masonry_percentage,
        "payment_percentage": payment_percentage,
        "masnory_date": masnory_date,
        "select_type_id": select_type_id,
        "template_remark": template_remark,
        "trans_project_slab_end_date": trans_project_slab_end_date,
      };
}

class FinishingTypeList {
  String? mstFinishingId;
  String? mstFinishingName;
  String? mstFinishingStatus;
  DateTime? mstFinishingUpdateAt;
  DateTime? mstFinishingCreatedAt;

  FinishingTypeList({
    this.mstFinishingId,
    this.mstFinishingName,
    this.mstFinishingStatus,
    this.mstFinishingUpdateAt,
    this.mstFinishingCreatedAt,
  });

  factory FinishingTypeList.fromJson(Map<String, dynamic> json) =>
      FinishingTypeList(
        mstFinishingId: json["mst_finishing_id"],
        mstFinishingName: json["mst_finishing_name"],
        mstFinishingStatus: json["mst_finishing_status"],
        mstFinishingUpdateAt: json["mst_finishing_update_at"] == null
            ? null
            : DateTime.parse(json["mst_finishing_update_at"]),
        mstFinishingCreatedAt: json["mst_finishing_created_at"] == null
            ? null
            : DateTime.parse(json["mst_finishing_created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "mst_finishing_id": mstFinishingId,
        "mst_finishing_name": mstFinishingName,
        "mst_finishing_status": mstFinishingStatus,
        "mst_finishing_update_at": mstFinishingUpdateAt?.toIso8601String(),
        "mst_finishing_created_at": mstFinishingCreatedAt?.toIso8601String(),
      };
}

class SalesType {
  String? id;
  String? name;
  String? selectType;
  String? templateRemark;
  String? dateShow;
  int? key;

  SalesType({
    this.id,
    this.name,
    this.selectType,
    this.templateRemark,
    this.dateShow,
    this.key,
  });

  factory SalesType.fromJson(Map<String, dynamic> json) => SalesType(
        id: json["id"],
        name: json["name"],
        selectType: json["select_type"],
        templateRemark: json["template_remark"],
        dateShow: json["date_show"],
        key: json["key"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "select_type": selectType,
        "template_remark": templateRemark,
        "date_show": dateShow,
        "key": key,
      };
}
