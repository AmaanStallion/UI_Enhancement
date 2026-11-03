// To parse this JSON data, do
//
//     final acquisitionList = acquisitionListFromJson(jsonString);

import 'dart:convert';

AcquisitionList acquisitionListFromJson(String str) =>
    AcquisitionList.fromJson(json.decode(str));

String acquisitionListToJson(AcquisitionList data) =>
    json.encode(data.toJson());

class AcquisitionList {
  Response? response;

  AcquisitionList({
    this.response,
  });

  factory AcquisitionList.fromJson(Map<String, dynamic> json) =>
      AcquisitionList(
        response: json["Response"] == null
            ? null
            : Response.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class Response {
  String? errorCode;
  String? msg;
  List<AcquisitionListElement>? acquisitionList;

  Response({
    this.errorCode,
    this.msg,
    this.acquisitionList,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        acquisitionList: json["acquisitionList"] == null
            ? []
            : List<AcquisitionListElement>.from(json["acquisitionList"]!
                .map((x) => AcquisitionListElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "acquisitionList": acquisitionList == null
            ? []
            : List<dynamic>.from(acquisitionList!.map((x) => x.toJson())),
      };
}

class AcquisitionListElement {
  String? acquisitionId;
  String? acquisition;
  String? address;
  String? developerIdFk;
  String? developerName;

  AcquisitionListElement({
    this.acquisitionId,
    this.acquisition,
    this.address,
    this.developerIdFk,
    this.developerName,
  });

  factory AcquisitionListElement.fromJson(Map<String, dynamic> json) =>
      AcquisitionListElement(
        acquisitionId: json["acquisition_id"],
        acquisition: json["acquisition"],
        address: json["address"],
        developerIdFk: json["developer_id_fk"],
        developerName: json["developer_name"],
      );

  Map<String, dynamic> toJson() => {
        "acquisition_id": acquisitionId,
        "acquisition": acquisition,
        "address": address,
        "developer_id_fk": developerIdFk,
        "developer_name": developerName,
      };
}
