// To parse this JSON data, do
//
//     final getBrokerList = getBrokerListFromJson(jsonString);

import 'dart:convert';

GetBrokerList getBrokerListFromJson(String str) =>
    GetBrokerList.fromJson(json.decode(str));

String getBrokerListToJson(GetBrokerList data) => json.encode(data.toJson());

class GetBrokerList {
  GetBrokerListResponse? response;

  GetBrokerList({
    this.response,
  });

  factory GetBrokerList.fromJson(Map<String, dynamic> json) => GetBrokerList(
        response: json["Response"] == null
            ? null
            : GetBrokerListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetBrokerListResponse {
  String? errorCode;
  String? msg;
  List<BrokerList>? brokerList;
  TotalBar? totalBar;
  String? offset;
  String? brokerLink;
  GetBrokerListResponse({
    this.errorCode,
    this.msg,
    this.brokerList,
    this.totalBar,
    this.offset,
    this.brokerLink,
  });

  factory GetBrokerListResponse.fromJson(Map<String, dynamic> json) =>
      GetBrokerListResponse(
        errorCode: json["error_code"],
        brokerLink: json["broker_link"],
        msg: json["msg"],
        brokerList: json["broker_list"] == null
            ? []
            : List<BrokerList>.from(
                json["broker_list"]!.map((x) => BrokerList.fromJson(x))),
        totalBar: json["total_bar"] == null
            ? null
            : TotalBar.fromJson(json["total_bar"]),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "broker_link": brokerLink,
        "error_code": errorCode,
        "msg": msg,
        "broker_list": brokerList == null
            ? []
            : List<dynamic>.from(brokerList!.map((x) => x.toJson())),
        "total_bar": totalBar?.toJson(),
        "offset": offset,
      };
}

class BrokerList {
  String? brokerId;
  String? brokerTotal;
  String? companyName;
  String? totalFlat;
  String? totalFlatValue;
  String? totalPaid;
  String? totalBalance;

  BrokerList({
    this.brokerId,
    this.brokerTotal,
    this.companyName,
    this.totalFlat,
    this.totalFlatValue,
    this.totalPaid,
    this.totalBalance,
  });

  factory BrokerList.fromJson(Map<String, dynamic> json) => BrokerList(
        brokerId: json["broker_id"],
        brokerTotal: json["broker_total"],
        companyName: json["company_name"],
        totalFlat: json["total_flat"],
        totalFlatValue: json["total_flat_value"],
        totalPaid: json["total_paid"],
        totalBalance: json["total_balance"],
      );

  Map<String, dynamic> toJson() => {
        "broker_id": brokerId,
        "broker_total": brokerTotal,
        "company_name": companyName,
        "total_flat": totalFlat,
        "total_flat_value": totalFlatValue,
        "total_paid": totalPaid,
        "total_balance": totalBalance,
      };
}

class TotalBar {
  String? totalAmount;
  String? totalPaid;
  String? totalBalance;

  TotalBar({
    this.totalAmount,
    this.totalPaid,
    this.totalBalance,
  });

  factory TotalBar.fromJson(Map<String, dynamic> json) => TotalBar(
        totalAmount: json["total_amount"],
        totalPaid: json["total_paid"],
        totalBalance: json["total_balance"],
      );

  Map<String, dynamic> toJson() => {
        "total_amount": totalAmount,
        "total_paid": totalPaid,
        "total_balance": totalBalance,
      };
}
