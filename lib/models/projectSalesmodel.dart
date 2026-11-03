// To parse this JSON data, do
//
//     final projectSalesmodel = projectSalesmodelFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_overview.dart';

ProjectSalesmodel projectSalesmodelFromJson(String str) =>
    ProjectSalesmodel.fromJson(json.decode(str));

String projectSalesmodelToJson(ProjectSalesmodel data) =>
    json.encode(data.toJson());

class ProjectSalesmodel {
  ProjectSalesmodelResponse? response;

  ProjectSalesmodel({
    this.response,
  });

  factory ProjectSalesmodel.fromJson(Map<String, dynamic> json) =>
      ProjectSalesmodel(
        response: json["Response"] == null
            ? null
            : ProjectSalesmodelResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectSalesmodelResponse {
  String? errorCode;
  String? msg;
  SalesModule? salesModule;
  SalesAll? salesAll;

  ProjectSalesmodelResponse({
    this.errorCode,
    this.msg,
    this.salesModule,
    this.salesAll,
  });

  factory ProjectSalesmodelResponse.fromJson(Map<String, dynamic> json) =>
      ProjectSalesmodelResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        salesModule: json["sales_module"] == null
            ? null
            : SalesModule.fromJson(json["sales_module"]),
        salesAll: json["sales_all"] == null
            ? null
            : SalesAll.fromJson(json["sales_all"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "sales_module": salesModule?.toJson(),
        "sales_all": salesAll?.toJson(),
      };
}

class SalesAll {
  String? errorCode;
  String? msg;
  List<OrderList>? orderList;
  ProjectBuyerList? projectBuyerList;
  List<dynamic>? flatBuyerRequest;

  SalesAll({
    this.errorCode,
    this.msg,
    this.orderList,
    this.projectBuyerList,
    this.flatBuyerRequest,
  });

  factory SalesAll.fromJson(Map<String, dynamic> json) => SalesAll(
        errorCode: json["error_code"],
        msg: json["msg"],
        orderList: json["order_list"] == null
            ? []
            : List<OrderList>.from(
                json["order_list"]!.map((x) => OrderList.fromJson(x))),
        projectBuyerList: json["project_buyer_list"] == null
            ? null
            : ProjectBuyerList.fromJson(json["project_buyer_list"]),
        flatBuyerRequest: json["flat_buyer_request"] == null
            ? []
            : List<dynamic>.from(json["flat_buyer_request"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "order_list": orderList == null
            ? []
            : List<dynamic>.from(orderList!.map((x) => x.toJson())),
        "project_buyer_list": projectBuyerList?.toJson(),
        "flat_buyer_request": flatBuyerRequest == null
            ? []
            : List<dynamic>.from(flatBuyerRequest!.map((x) => x)),
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

class ProjectBuyerList {
  String? flatRequest;
  String? flatApproved;
  String? totalFlatArea;
  String? totalSoldFlatArea;
  String? totalAviFlatArea;
  String? avaliableInventory;
  String? inventrySold;
  String? totalRecord;
  String? paymentToCollect;
  String? totalSold;
  String? totalReceive;
  String? unsoldInventory;
  String? flatReserved;
  String? totalPodiumCount;
  String? totalPodiumSoldCount;
  String? podiumAreaCost;
  String? totalRemainingPodiumCost;
  String? totalCollect;
  String? avgFlatRate;
  String? newAvgFlatRate;

  ProjectBuyerList({
    this.flatRequest,
    this.flatApproved,
    this.totalFlatArea,
    this.totalSoldFlatArea,
    this.totalAviFlatArea,
    this.avaliableInventory,
    this.inventrySold,
    this.totalRecord,
    this.paymentToCollect,
    this.totalSold,
    this.totalReceive,
    this.unsoldInventory,
    this.flatReserved,
    this.totalPodiumCount,
    this.totalPodiumSoldCount,
    this.podiumAreaCost,
    this.totalRemainingPodiumCost,
    this.totalCollect,
    this.avgFlatRate,
    this.newAvgFlatRate,
  });

  factory ProjectBuyerList.fromJson(Map<String, dynamic> json) =>
      ProjectBuyerList(
        flatRequest: json["flat_request"],
        flatApproved: json["flat_approved"],
        totalFlatArea: json["total_flat_area"],
        totalSoldFlatArea: json["total_sold_flat_area"],
        totalAviFlatArea: json["total_avi_flat_area"],
        avaliableInventory: json["avaliable_inventory"],
        inventrySold: json["inventry_sold"],
        totalRecord: json["total_record"],
        paymentToCollect: json["payment_to_collect"],
        totalSold: json["total_sold"],
        totalReceive: json["total_receive"],
        unsoldInventory: json["unsold_inventory"],
        flatReserved: json["flat_reserved"],
        totalPodiumCount: json["total_podium_count"],
        totalPodiumSoldCount: json["total_podium_sold_count"],
        podiumAreaCost: json["podium_area_cost"],
        totalRemainingPodiumCost: json["total_remaining_podium_cost"],
        totalCollect: json["total_collect"],
        avgFlatRate: json["avg_flat_rate"],
        newAvgFlatRate: json["new_avg_flat_rate"],
      );

  Map<String, dynamic> toJson() => {
        "flat_request": flatRequest,
        "flat_approved": flatApproved,
        "total_flat_area": totalFlatArea,
        "total_sold_flat_area": totalSoldFlatArea,
        "total_avi_flat_area": totalAviFlatArea,
        "avaliable_inventory": avaliableInventory,
        "inventry_sold": inventrySold,
        "total_record": totalRecord,
        "payment_to_collect": paymentToCollect,
        "total_sold": totalSold,
        "total_receive": totalReceive,
        "unsold_inventory": unsoldInventory,
        "flat_reserved": flatReserved,
        "total_podium_count": totalPodiumCount,
        "total_podium_sold_count": totalPodiumSoldCount,
        "podium_area_cost": podiumAreaCost,
        "total_remaining_podium_cost": totalRemainingPodiumCost,
        "total_collect": totalCollect,
        "avg_flat_rate": avgFlatRate,
        "new_avg_flat_rate": newAvgFlatRate,
      };
}

// class SalesModule {
//   String? paymentStatusReceive;
//   String? paymentStatusOver;
//   String? paymentCollectable;
//   List<AvailableValue>? availableValue;
//   List<AvailableValue>? successLead;
//   String? pendingRequest;
//   String? nextTargetPrice;
//   String? unsoldInventry;
//   String? flatReserved;
//   String? flatReservedPencentage;
//   String? totalSoldSqft;
//   String? totalSoldAvg;
//   String? totalUnsoldAvg;
//   String? isActive;
//   List<BrokerDetail>? brokerDetail;

//   SalesModule({
//     this.paymentStatusReceive,
//     this.paymentStatusOver,
//     this.paymentCollectable,
//     this.availableValue,
//     this.successLead,
//     this.pendingRequest,
//     this.nextTargetPrice,
//     this.unsoldInventry,
//     this.flatReserved,
//     this.flatReservedPencentage,
//     this.totalSoldSqft,
//     this.totalSoldAvg,
//     this.totalUnsoldAvg,
//     this.isActive,
//     this.brokerDetail,
//   });

//   factory SalesModule.fromJson(Map<String, dynamic> json) => SalesModule(
//         paymentStatusReceive: json["payment_status_receive"],
//         paymentStatusOver: json["payment_status_over"],
//         paymentCollectable: json["payment_collectable"],
//         availableValue: json["available_value"] == null
//             ? []
//             : List<AvailableValue>.from(json["available_value"]!
//                 .map((x) => AvailableValue.fromJson(x))),
//         successLead: json["success_lead"] == null
//             ? []
//             : List<AvailableValue>.from(
//                 json["success_lead"]!.map((x) => AvailableValue.fromJson(x))),
//         pendingRequest: json["pending_request"],
//         nextTargetPrice: json["next_target_price"],
//         unsoldInventry: json["unsold_inventry"],
//         flatReserved: json["flat_reserved"],
//         flatReservedPencentage: json["flat_reserved_pencentage"],
//         totalSoldSqft: json["total_sold_sqft"],
//         totalSoldAvg: json["total_sold_avg"],
//         totalUnsoldAvg: json["total_unsold_avg"],
//         isActive: json["is_active"],
//         brokerDetail: json["broker_detail"] == null
//             ? []
//             : List<BrokerDetail>.from(
//                 json["broker_detail"]!.map((x) => BrokerDetail.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "payment_status_receive": paymentStatusReceive,
//         "payment_status_over": paymentStatusOver,
//         "payment_collectable": paymentCollectable,
//         "available_value": availableValue == null
//             ? []
//             : List<dynamic>.from(availableValue!.map((x) => x.toJson())),
//         "success_lead": successLead == null
//             ? []
//             : List<dynamic>.from(successLead!.map((x) => x.toJson())),
//         "pending_request": pendingRequest,
//         "next_target_price": nextTargetPrice,
//         "unsold_inventry": unsoldInventry,
//         "flat_reserved": flatReserved,
//         "flat_reserved_pencentage": flatReservedPencentage,
//         "total_sold_sqft": totalSoldSqft,
//         "total_sold_avg": totalSoldAvg,
//         "total_unsold_avg": totalUnsoldAvg,
//         "is_active": isActive,
//         "broker_detail": brokerDetail == null
//             ? []
//             : List<dynamic>.from(brokerDetail!.map((x) => x.toJson())),
//       };
// }

class AvailableValue {
  String? percentage;
  String? value;

  AvailableValue({
    this.percentage,
    this.value,
  });

  factory AvailableValue.fromJson(Map<String, dynamic> json) => AvailableValue(
        percentage: json["percentage"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "percentage": percentage,
        "value": value,
      };
}

// class BrokerDetail {
//   String? brokerTotal;
//   String? companyName;
//   String? totalSold;
//   String? totPaid;

//   BrokerDetail({
//     this.brokerTotal,
//     this.companyName,
//     this.totalSold,
//     this.totPaid,
//   });

//   factory BrokerDetail.fromJson(Map<String, dynamic> json) => BrokerDetail(
//         brokerTotal: json["broker_total"],
//         companyName: json["company_name"],
//         totalSold: json["total_sold"],
//         totPaid: json["tot_paid"],
//       );

//   Map<String, dynamic> toJson() => {
//         "broker_total": brokerTotal,
//         "company_name": companyName,
//         "total_sold": totalSold,
//         "tot_paid": totPaid,
//       };
// }
