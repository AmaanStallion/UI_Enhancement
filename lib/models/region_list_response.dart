// To parse this JSON data, do
//
//     final regionListResponse = regionListResponseFromJson(jsonString);

import 'dart:convert';

RegionListResponse regionListResponseFromJson(String str) =>
    RegionListResponse.fromJson(json.decode(str));

String regionListResponseToJson(RegionListResponse data) =>
    json.encode(data.toJson());

class RegionListResponse {
  ResponseRegionListResponse? response;

  RegionListResponse({
    this.response,
  });

  factory RegionListResponse.fromJson(Map<String, dynamic> json) =>
      RegionListResponse(
        response: json["Response"] == null
            ? null
            : ResponseRegionListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseRegionListResponse {
  String? errorCode;
  String? msg;
  List<RegionList>? regionList;

  ResponseRegionListResponse({
    this.errorCode,
    this.msg,
    this.regionList,
  });

  factory ResponseRegionListResponse.fromJson(Map<String, dynamic> json) =>
      ResponseRegionListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        regionList: json["region_list"] == null
            ? []
            : List<RegionList>.from(
                json["region_list"]!.map((x) => RegionList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "region_list": regionList == null
            ? []
            : List<dynamic>.from(regionList!.map((x) => x.toJson())),
      };
}

class RegionList {
  String? id;
  String? name;

  RegionList({
    this.id,
    this.name,
  });

  factory RegionList.fromJson(Map<String, dynamic> json) => RegionList(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
