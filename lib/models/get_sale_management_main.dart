// To parse this JSON data, do
//
//     final getProjectBuyerInventory = getProjectBuyerInventoryFromJson(jsonString);

import 'dart:convert';

GetProjectBuyerInventory getProjectBuyerInventoryFromJson(String str) =>
    GetProjectBuyerInventory.fromJson(json.decode(str));

String getProjectBuyerInventoryToJson(GetProjectBuyerInventory data) =>
    json.encode(data.toJson());

class GetProjectBuyerInventory {
  ResponseGetProjectBuyerInventory? response;

  GetProjectBuyerInventory({
    this.response,
  });

  factory GetProjectBuyerInventory.fromJson(Map<String, dynamic> json) =>
      GetProjectBuyerInventory(
        response: json["Response"] == null
            ? null
            : ResponseGetProjectBuyerInventory.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetProjectBuyerInventory {
  String? errorCode;
  String? msg;
  List<OrderList>? orderList;
  ProjectBuyerList? projectBuyerList;
  List<dynamic>? flatBuyerRequest;
  String? saleAccTab;
  String? showLeads;
  List<dynamic>? brokerList;
  List<TowarList>? towarList;
  String? member_ship_form;
  String? sales_plot_flag;
  String? downloadLink;

  ResponseGetProjectBuyerInventory({
    this.errorCode,
    this.msg,
    this.orderList,
    this.projectBuyerList,
    this.flatBuyerRequest,
    this.saleAccTab,
    this.showLeads,
    this.brokerList,
    this.towarList,
    this.member_ship_form,
    this.sales_plot_flag,
    this.downloadLink,
  });

  factory ResponseGetProjectBuyerInventory.fromJson(
          Map<String, dynamic> json) =>
      ResponseGetProjectBuyerInventory(
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
        saleAccTab: json["sale_acc_tab"],
        showLeads: json["show_leads"],
        sales_plot_flag: json["sales_plot_flag"],
        brokerList: json["broker_list"] == null
            ? []
            : List<dynamic>.from(json["broker_list"]!.map((x) => x)),
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"]!.map((x) => TowarList.fromJson(x))),
        member_ship_form: json["member_ship_form"],
        downloadLink: json["download_link"],
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
        "sale_acc_tab": saleAccTab,
        "show_leads": showLeads,
        "sales_plot_flag": sales_plot_flag,
        "broker_list": brokerList == null
            ? []
            : List<dynamic>.from(brokerList!.map((x) => x)),
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
        "member_ship_form": member_ship_form,
        "download_link": downloadLink,
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
  List<FlatConfigurationAvg>? flatConfigurationAvg;

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
    this.flatConfigurationAvg,
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
        flatConfigurationAvg: json["flat_configuration_avg"] == null
            ? []
            : List<FlatConfigurationAvg>.from(json["flat_configuration_avg"]!
                .map((x) => FlatConfigurationAvg.fromJson(x))),
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
        "flat_configuration_avg": flatConfigurationAvg == null
            ? []
            : List<dynamic>.from(flatConfigurationAvg!.map((x) => x.toJson())),
      };
}

class FlatConfigurationAvg {
  String? id;
  String? name;
  String? avgFlatRate;
  String? newAvgFlatRate;

  FlatConfigurationAvg({
    this.id,
    this.name,
    this.avgFlatRate,
    this.newAvgFlatRate,
  });

  factory FlatConfigurationAvg.fromJson(Map<String, dynamic> json) =>
      FlatConfigurationAvg(
        id: json["id"],
        name: json["name"],
        avgFlatRate: json["avg_flat_rate"],
        newAvgFlatRate: json["new_avg_flat_rate"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "avg_flat_rate": avgFlatRate,
        "new_avg_flat_rate": newAvgFlatRate,
      };
}
