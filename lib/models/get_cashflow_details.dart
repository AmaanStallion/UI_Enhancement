// To parse this JSON data, do
//
//     final getCashFlow = getCashFlowFromJson(jsonString);

import 'dart:convert';

GetCashFlow getCashFlowFromJson(String str) =>
    GetCashFlow.fromJson(json.decode(str));

String getCashFlowToJson(GetCashFlow data) => json.encode(data.toJson());

class GetCashFlow {
  ResponseGetCashFlow? response;

  GetCashFlow({
    this.response,
  });

  factory GetCashFlow.fromJson(Map<String, dynamic> json) => GetCashFlow(
        response: json["Response"] == null
            ? null
            : ResponseGetCashFlow.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetCashFlow {
  String? errorCode;
  String? msg;
  List<CashFlowList>? cashFlowList;
  SalesTotalBar? salesTotalBar;

  ResponseGetCashFlow({
    this.errorCode,
    this.msg,
    this.cashFlowList,
    this.salesTotalBar,
  });

  factory ResponseGetCashFlow.fromJson(Map<String, dynamic> json) =>
      ResponseGetCashFlow(
        errorCode: json["error_code"],
        msg: json["msg"],
        cashFlowList: json["cash_flow_list"] == null
            ? []
            : List<CashFlowList>.from(
                json["cash_flow_list"]!.map((x) => CashFlowList.fromJson(x))),
        salesTotalBar: json["sales_total_bar"] == null
            ? null
            : SalesTotalBar.fromJson(json["sales_total_bar"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "cash_flow_list": cashFlowList == null
            ? []
            : List<dynamic>.from(cashFlowList!.map((x) => x.toJson())),
        "sales_total_bar": salesTotalBar?.toJson(),
      };
}

class CashFlowList {
  String? id;
  String? name;
  String? selectTypeId;
  String? collectableBill;
  String? collected;
  String? balance;
  String? orderNo;
  String? cashFlowPaymentType;
  DateTime? startDate;
  DateTime? endDate;

  CashFlowList({
    this.id,
    this.name,
    this.selectTypeId,
    this.collectableBill,
    this.collected,
    this.balance,
    this.orderNo,
    this.cashFlowPaymentType,
    this.startDate,
    this.endDate,
  });

  factory CashFlowList.fromJson(Map<String, dynamic> json) {
    // DateTime? parseDate(String? dateString) {
    //   if (dateString == null || dateString.isEmpty) return null;
    //   try {
    //     final parts = dateString.split('-');
    //     return DateTime(
    //       int.parse(parts[2]), // Year
    //       int.parse(parts[1]), // Month
    //       int.parse(parts[0]), // Day
    //     );
    //   } catch (e) {
    //     throw FormatException('Invalid date format: $dateString');
    //   }
    // }
    DateTime? parseDate(String? dateString) {
      if (dateString == null ||
          dateString.isEmpty ||
          dateString == '0000-00-00') {
        return null;
      }
      return DateTime.tryParse(dateString);
    }

    return CashFlowList(
      id: json["id"],
      name: json["name"],
      selectTypeId: json["select_type_id"],
      collectableBill: json["collectable_bill"],
      collected: json["collected"],
      balance: json["balance"],
      orderNo: json["order_no"],
      cashFlowPaymentType: json["cash_flow_payment_type"],
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "select_type_id": selectTypeId,
        "collectable_bill": collectableBill,
        "collected": collected,
        "balance": balance,
        "order_no": orderNo,
        "cash_flow_payment_type": cashFlowPaymentType,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      };
}

class SalesTotalBar {
  String? totalCollectableBill;
  String? totalCollected;
  String? totalBalance;

  SalesTotalBar({
    this.totalCollectableBill,
    this.totalCollected,
    this.totalBalance,
  });

  factory SalesTotalBar.fromJson(Map<String, dynamic> json) => SalesTotalBar(
        totalCollectableBill: json["total_collectable_bill"],
        totalCollected: json["total_collected"],
        totalBalance: json["total_balance"],
      );

  Map<String, dynamic> toJson() => {
        "total_collectable_bill": totalCollectableBill,
        "total_collected": totalCollected,
        "total_balance": totalBalance,
      };
}
