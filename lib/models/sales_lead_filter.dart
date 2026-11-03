// To parse this JSON data, do
//
//     final salesLeadFilter = salesLeadFilterFromJson(jsonString);

import 'dart:convert';

SalesLeadFilter salesLeadFilterFromJson(String str) =>
    SalesLeadFilter.fromJson(json.decode(str));

String salesLeadFilterToJson(SalesLeadFilter data) =>
    json.encode(data.toJson());

class SalesLeadFilter {
  SalesLeadFilterResponse? response;

  SalesLeadFilter({
    this.response,
  });

  factory SalesLeadFilter.fromJson(Map<String, dynamic> json) =>
      SalesLeadFilter(
        response: json["Response"] == null
            ? null
            : SalesLeadFilterResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class SalesLeadFilterResponse {
  String? errorCode;
  String? msg;
  List<FilterList>? filterList;

  SalesLeadFilterResponse({
    this.errorCode,
    this.msg,
    this.filterList,
  });

  factory SalesLeadFilterResponse.fromJson(Map<String, dynamic> json) =>
      SalesLeadFilterResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        filterList: json["filter_list"] == null
            ? []
            : List<FilterList>.from(
                json["filter_list"]!.map((x) => FilterList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "filter_list": filterList == null
            ? []
            : List<dynamic>.from(filterList!.map((x) => x.toJson())),
      };
}

class FilterList {
  String? name;
  String? id;
  int ct = 0;
  List<Detail>? details;

  FilterList({this.name, this.id, this.details, this.ct = 0});

  factory FilterList.fromJson(Map<String, dynamic> json) => FilterList(
        name: json["name"],
        id: json["id"],
        ct: 0,
        details: json["details"] == null
            ? []
            : List<Detail>.from(
                json["details"]!.map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class Detail {
  String? id;
  String? name;
  bool? isSelected = false;

  Detail({
    this.id,
    this.name,
    this.isSelected,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        name: json["name"],
        isSelected: false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
