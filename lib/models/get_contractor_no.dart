// To parse this JSON data, do
//
//     final getContractorNo = getContractorNoFromJson(jsonString);

import 'dart:convert';

GetContractorNo getContractorNoFromJson(String str) => GetContractorNo.fromJson(json.decode(str));

String getContractorNoToJson(GetContractorNo data) => json.encode(data.toJson());

class GetContractorNo {
  ResponseGetContractorNo? response;

  GetContractorNo({
    this.response,
  });

  factory GetContractorNo.fromJson(Map<String, dynamic> json) => GetContractorNo(
    response: json["Response"] == null ? null : ResponseGetContractorNo.fromJson(json["Response"]),
  );

  Map<String, dynamic> toJson() => {
    "Response": response?.toJson(),
  };
}

class ResponseGetContractorNo {
  String? errorCode;
  String? msg;
  List<WoList>? woList;

  ResponseGetContractorNo({
    this.errorCode,
    this.msg,
    this.woList,
  });

  factory ResponseGetContractorNo.fromJson(Map<String, dynamic> json) => ResponseGetContractorNo(
    errorCode: json["error_code"],
    msg: json["msg"],
    woList: json["wo_list"] == null ? [] : List<WoList>.from(json["wo_list"]!.map((x) => WoList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error_code": errorCode,
    "msg": msg,
    "wo_list": woList == null ? [] : List<dynamic>.from(woList!.map((x) => x.toJson())),
  };
}

class WoList {
  String? workOrderNumber;
  String? workOrderId;

  WoList({
    this.workOrderNumber,
    this.workOrderId,
  });

  factory WoList.fromJson(Map<String, dynamic> json) => WoList(
    workOrderNumber: json["work_order_number"],
    workOrderId: json["work_order_id"],
  );

  Map<String, dynamic> toJson() => {
    "work_order_number": workOrderNumber,
    "work_order_id": workOrderId,
  };
}
