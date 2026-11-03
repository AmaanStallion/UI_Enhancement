// To parse this JSON data, do
//
//     final groupContractorCategoryList = groupContractorCategoryListFromJson(jsonString);

import 'dart:convert';

GroupContractorCategoryList groupContractorCategoryListFromJson(String str) =>
    GroupContractorCategoryList.fromJson(json.decode(str));

String groupContractorCategoryListToJson(GroupContractorCategoryList data) =>
    json.encode(data.toJson());

class GroupContractorCategoryList {
  GroupContractorCategoryListResponse? response;

  GroupContractorCategoryList({
    this.response,
  });

  factory GroupContractorCategoryList.fromJson(Map<String, dynamic> json) =>
      GroupContractorCategoryList(
        response: json["Response"] == null
            ? null
            : GroupContractorCategoryListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GroupContractorCategoryListResponse {
  String? errorCode;
  String? msg;
  String? woMaskFlag;
  TotalBBar? totalBtmBar;
  List<FianlResult>? fianlResult;
  List<OrderList>? orderList;
  String? accountFlag;

  GroupContractorCategoryListResponse({
    this.errorCode,
    this.msg,
    this.woMaskFlag,
    this.totalBtmBar,
    this.fianlResult,
    this.orderList,
    this.accountFlag,
  });

  factory GroupContractorCategoryListResponse.fromJson(
          Map<String, dynamic> json) =>
      GroupContractorCategoryListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        woMaskFlag: json["wo_mask_flag"],
        totalBtmBar: json["total_btm_bar"] == null
            ? null
            : TotalBBar.fromJson(json["total_btm_bar"]),
        fianlResult: json["fianl_result"] == null
            ? []
            : List<FianlResult>.from(
                json["fianl_result"]!.map((x) => FianlResult.fromJson(x))),
        orderList: json["order_list"] == null
            ? []
            : List<OrderList>.from(
                json["order_list"]!.map((x) => OrderList.fromJson(x))),
        accountFlag: json["account_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "wo_mask_flag": woMaskFlag,
        "total_btm_bar": totalBtmBar?.toJson(),
        "fianl_result": fianlResult == null
            ? []
            : List<dynamic>.from(fianlResult!.map((x) => x.toJson())),
        "order_list": orderList == null
            ? []
            : List<dynamic>.from(orderList!.map((x) => x.toJson())),
        "account_flag": accountFlag,
      };
}

class FianlResult {
  String? id;
  String? name;
  String? developerId;
  List<TotalBBar>? totalBar;
  dynamic count;

  FianlResult({
    this.id,
    this.name,
    this.developerId,
    this.totalBar,
    this.count,
  });

  factory FianlResult.fromJson(Map<String, dynamic> json) => FianlResult(
        id: json["id"],
        name: json["name"],
        developerId: json["developer_id"],
        totalBar: json["total_bar"] == null
            ? []
            : List<TotalBBar>.from(
                json["total_bar"]!.map((x) => TotalBBar.fromJson(x))),
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "developer_id": developerId,
        "total_bar": totalBar == null
            ? []
            : List<dynamic>.from(totalBar!.map((x) => x.toJson())),
        "count": count,
      };
}

class TotalBBar {
  dynamic? totalPayment;
  dynamic? dueAmount;
  dynamic? paidAmount;
  dynamic? overDueAmount;
  dynamic? discountAmount;

  TotalBBar({
    this.totalPayment,
    this.dueAmount,
    this.paidAmount,
    this.overDueAmount,
    this.discountAmount,
  });

  factory TotalBBar.fromJson(Map<String, dynamic> json) => TotalBBar(
        totalPayment: json["total_payment"],
        dueAmount: json["due_amount"]?.toDouble(),
        paidAmount: json["paid_amount"],
        overDueAmount: json["over_due_amount"]?.toDouble(),
        discountAmount: json["discount_amount"],
      );

  Map<String, dynamic> toJson() => {
        "total_payment": totalPayment,
        "due_amount": dueAmount,
        "paid_amount": paidAmount,
        "over_due_amount": overDueAmount,
        "discount_amount": discountAmount,
      };
}

class OrderList {
  String? id;
  String? name;
  List<TowarList>? towarList;

  OrderList({
    this.id,
    this.name,
    this.towarList,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"],
        name: json["name"],
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"]!.map((x) => TowarList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
      };
}

class TowarList {
  String? towarId;
  String? towarName;

  TowarList({
    this.towarId,
    this.towarName,
  });

  factory TowarList.fromJson(Map<String, dynamic> json) => TowarList(
        towarId: json["towar_id"],
        towarName: json["towar_name"],
      );

  Map<String, dynamic> toJson() => {
        "towar_id": towarId,
        "towar_name": towarName,
      };
}
