// To parse this JSON data, do
//
//     final caseFlowBuyerList = caseFlowBuyerListFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_broker_details.dart';

CaseFlowBuyerList caseFlowBuyerListFromJson(String str) =>
    CaseFlowBuyerList.fromJson(json.decode(str));

String caseFlowBuyerListToJson(CaseFlowBuyerList data) =>
    json.encode(data.toJson());

class CaseFlowBuyerList {
  CaseFlowBuyerListResponse? response;

  CaseFlowBuyerList({
    this.response,
  });

  factory CaseFlowBuyerList.fromJson(Map<String, dynamic> json) =>
      CaseFlowBuyerList(
        response: json["Response"] == null
            ? null
            : CaseFlowBuyerListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class CaseFlowBuyerListResponse {
  String? errorCode;
  String? msg;
  List<FlatBuyerRequest>? projectBuyerDetailsList;
  String? offset;

  CaseFlowBuyerListResponse({
    this.errorCode,
    this.msg,
    this.projectBuyerDetailsList,
    this.offset,
  });

  factory CaseFlowBuyerListResponse.fromJson(Map<String, dynamic> json) =>
      CaseFlowBuyerListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        projectBuyerDetailsList: json["project_buyer_details_list"] == null
            ? []
            : List<FlatBuyerRequest>.from(json["project_buyer_details_list"]!
                .map((x) => FlatBuyerRequest.fromJson(x))),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "project_buyer_details_list": projectBuyerDetailsList == null
            ? []
            : List<dynamic>.from(
                projectBuyerDetailsList!.map((x) => x.toJson())),
        "offset": offset,
      };
}
