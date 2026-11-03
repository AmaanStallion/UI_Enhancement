// To parse this JSON data, do
//
//     final getProjectDprContractor = getProjectDprContractorFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

GetProjectDprContractor getProjectDprContractorFromJson(String str) =>
    GetProjectDprContractor.fromJson(json.decode(str));

String getProjectDprContractorToJson(GetProjectDprContractor data) =>
    json.encode(data.toJson());

class GetProjectDprContractor {
  ResponseGetProjectDprContractor? response;

  GetProjectDprContractor({
    this.response,
  });

  factory GetProjectDprContractor.fromJson(Map<String, dynamic> json) =>
      GetProjectDprContractor(
        response: json["Response"] == null
            ? null
            : ResponseGetProjectDprContractor.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetProjectDprContractor {
  String? errorCode;
  String? msg;
  List<DprYesterdayActivity>? dprYesterdayActivity;
  List<ContractProgress>? contractProgress;

  List<ContrctorList>? contrctorList;
  List<CustomType>? customType;
  List<OrderDeliveredList>? orderDeliveredList;
  List<WorkProgress>? workProgress;

  List<MasnoryList>? masnoryList;
  List<DprYesterdayActivity>? dprFinishingYesterdayActivity;
  List<DprStockList>? dprStockList;

  ResponseGetProjectDprContractor({
    this.errorCode,
    this.msg,
    this.contrctorList,
    this.customType,
    this.dprYesterdayActivity,
    this.orderDeliveredList,
    this.contractProgress,
    this.workProgress,
    this.masnoryList,
    this.dprFinishingYesterdayActivity,
    this.dprStockList,
  });

  factory ResponseGetProjectDprContractor.fromJson(Map<String, dynamic> json) =>
      ResponseGetProjectDprContractor(
        errorCode: json["error_code"],
        msg: json["msg"],
        dprYesterdayActivity: json["dpr_yesterday_activity"] == null
            ? []
            : List<DprYesterdayActivity>.from(json["dpr_yesterday_activity"]!
                .map((x) => DprYesterdayActivity.fromJson(x))),
        contrctorList: json["contrctor_list"] == null
            ? []
            : List<ContrctorList>.from(
                json["contrctor_list"]!.map((x) => ContrctorList.fromJson(x))),
        customType: json["custom_type"] == null
            ? []
            : List<CustomType>.from(
                json["custom_type"]!.map((x) => CustomType.fromJson(x))),
        orderDeliveredList: json["order_delivered_list"] == null
            ? []
            : List<OrderDeliveredList>.from(json["order_delivered_list"]!
                .map((x) => OrderDeliveredList.fromJson(x))),
        contractProgress: json["contract_progress"] == null
            ? []
            : List<ContractProgress>.from(json["contract_progress"]!
                .map((x) => ContractProgress.fromJson(x))),
        workProgress: json["work_progress"] == null
            ? []
            : List<WorkProgress>.from(
                json["work_progress"]!.map((x) => WorkProgress.fromJson(x))),
        masnoryList: json["masnory_list"] == null
            ? []
            : List<MasnoryList>.from(
                json["masnory_list"]!.map((x) => MasnoryList.fromJson(x))),
        dprFinishingYesterdayActivity:
            json["dpr_finishing_yesterday_activity"] == null
                ? []
                : List<DprYesterdayActivity>.from(
                    json["dpr_finishing_yesterday_activity"]!
                        .map((x) => DprYesterdayActivity.fromJson(x))),
        dprStockList: json["dpr_stock_list"] == null
            ? []
            : List<DprStockList>.from(
                json["dpr_stock_list"]!.map((x) => DprStockList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "dpr_yesterday_activity": dprYesterdayActivity == null
            ? []
            : List<dynamic>.from(dprYesterdayActivity!.map((x) => x.toJson())),
        "contrctor_list": contrctorList == null
            ? []
            : List<dynamic>.from(contrctorList!.map((x) => x.toJson())),
        "custom_type": customType == null
            ? []
            : List<dynamic>.from(customType!.map((x) => x.toJson())),
        "order_delivered_list": orderDeliveredList == null
            ? []
            : List<dynamic>.from(orderDeliveredList!.map((x) => x.toJson())),
        "contract_progress": contractProgress == null
            ? []
            : List<dynamic>.from(contractProgress!.map((x) => x.toJson())),
        "work_progress": workProgress == null
            ? []
            : List<dynamic>.from(workProgress!.map((x) => x.toJson())),
        "masnory_list": masnoryList == null
            ? []
            : List<dynamic>.from(masnoryList!.map((x) => x.toJson())),
        "dpr_finishing_yesterday_activity":
            dprFinishingYesterdayActivity == null
                ? []
                : List<dynamic>.from(
                    dprFinishingYesterdayActivity!.map((x) => x.toJson())),
        "dpr_stock_list": dprStockList == null
            ? []
            : List<dynamic>.from(dprStockList!.map((x) => x.toJson())),
      };
}

class ContrctorList {
  String? companyId;
  String? companyName;
  List<Skill>? skill;
  bool? isSelected;
  String? count;
  TextEditingController? isTextEditingController;

  ContrctorList({
    this.companyId,
    this.companyName,
    this.skill,
    this.isSelected = true,
    this.isTextEditingController,
    this.count,
  });

  factory ContrctorList.fromJson(Map<String, dynamic> json) => ContrctorList(
        companyId: json["company_id"],
        count: json["count"] ?? '',
        companyName: json["company_name"],
        skill: json["skill"] == null
            ? []
            : List<Skill>.from(json["skill"]!.map((x) => Skill.fromJson(x))),
        isSelected: false,
        isTextEditingController: TextEditingController(),
      );

  Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "company_name": companyName,
        "skill": skill == null
            ? []
            : List<dynamic>.from(skill!.map((x) => x.toJson())),
        "isSelected": isSelected,
        "count": count,
      };
}

class Skill {
  String? mstWorkName;
  String? mstWorkId;
  bool? isSelected;

  Skill({
    this.mstWorkName,
    this.mstWorkId,
    this.isSelected = true,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        mstWorkName: json["mst_work_name"],
        mstWorkId: json["mst_work_id"],
        isSelected: false,
      );

  Map<String, dynamic> toJson() => {
        "mst_work_name": mstWorkName,
        "mst_work_id": mstWorkId,
        "isSelected": isSelected,
      };
}

// class CustomType {
//   String? name;
//   String? id;
//   String? value;
//   TextEditingController? editingTextController;
//   String flag;
//   String? description;

//   CustomType({
//     this.name,
//     this.id,
//     this.value,
//     this.editingTextController,
//     this.flag = "", // Set default value to an empty string
//     this.description,
//   });

//   factory CustomType.fromJson(Map<String, dynamic> json) => CustomType(
//         name: json["name"],
//         id: json["id"],
//         value: json["value"],
//         editingTextController: TextEditingController(),
//         flag: json["flag"] ?? "", // Ensure flag is never null
//         description: json["description"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "id": id,
//         "value": value,
//         // "editingTextController": editingTextController,
//         "flag": flag,
//         "description": description,
//       };
// }

class CustomType {
  String name;
  String id;
  String value;
  TextEditingController editingTextController;
  String flag;
  String description;

  CustomType({
    this.name = "",
    this.id = "",
    this.value = "",
    TextEditingController? editingTextController,
    this.flag = "",
    this.description = "",
  }) : editingTextController = editingTextController ?? TextEditingController();

  factory CustomType.fromJson(Map<String, dynamic> json) => CustomType(
        name: json["name"] ?? "",
        id: json["id"] ?? "",
        value: json["value"] ?? "",
        editingTextController: TextEditingController(),
        flag: json["flag"] ?? "",
        description: json["description"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "value": value,
        "flag": flag,
        "description": description,
      };
}

class WorkProgress {
  String? id;
  String? title;

  WorkProgress({
    this.id,
    this.title,
  });

  factory WorkProgress.fromJson(Map<String, dynamic> json) => WorkProgress(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}

class OrderDeliveredList {
  String? name;
  String? totalQuantity;
  String? consumeQuantity;
  String? unit;

  OrderDeliveredList({
    this.name,
    this.totalQuantity,
    this.consumeQuantity,
    this.unit,
  });

  factory OrderDeliveredList.fromJson(Map<String, dynamic> json) =>
      OrderDeliveredList(
        name: json["name"],
        totalQuantity: json["total_quantity"],
        consumeQuantity: json["consume_quantity"],
        unit: json["unit"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "total_quantity": totalQuantity,
        "consume_quantity": consumeQuantity,
        "unit": unit,
      };
}

class DprYesterdayActivity {
  String? id;
  String? targetdate;
  String? description;
  bool isSelected;
  String descriptionVal;
  TextEditingController dprActivityController;
  TextEditingController dprActivityDateController;
  String? dprFlag;

  DprYesterdayActivity({
    this.id,
    this.targetdate,
    this.description,
    this.dprFlag,
    required this.isSelected,
    required this.descriptionVal,
    required this.dprActivityController,
    required this.dprActivityDateController,
  });

  factory DprYesterdayActivity.fromJson(Map<String, dynamic> json) =>
      DprYesterdayActivity(
        id: json["id"],
        targetdate: json["targetdate"],
        description: json["description"],
        dprFlag: json["dpr_flag"],
        isSelected: false,
        descriptionVal: '',
        dprActivityController: TextEditingController(),
        dprActivityDateController: TextEditingController(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "targetdate": targetdate,
        "description": description,
        "dpr_flag": dprFlag,
      };
}

class DprStaffList {
  String? id;
  String? inTime;
  String? outTime;
  String? staffName;

  DprStaffList({
    this.id,
    this.inTime,
    this.outTime,
    this.staffName,
  });

  factory DprStaffList.fromJson(Map<String, dynamic> json) => DprStaffList(
        id: json["id"],
        inTime: json["in_time"],
        outTime: json["out_time"],
        staffName: json["staff_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "in_time": inTime,
        "out_time": outTime,
        "staff_name": staffName,
      };
}

class ContractProgress {
  String? transWorkId;
  String? mstCompanyName;
  String? totalPercentage;
  String? quantification;
  String? woTotalPercentage;
  String? woTotalQuantification;
  String? skillName;

  ContractProgress({
    this.transWorkId,
    this.mstCompanyName,
    this.totalPercentage,
    this.quantification,
    this.woTotalPercentage,
    this.woTotalQuantification,
    this.skillName,
  });

  factory ContractProgress.fromJson(Map<String, dynamic> json) =>
      ContractProgress(
        transWorkId: json["trans_work_id"],
        mstCompanyName: json["mst_company_name"],
        totalPercentage: json["total_percentage"],
        quantification: json["quantification"],
        woTotalPercentage: json["wo_total_percentage"],
        woTotalQuantification: json["wo_total_quantification"],
        skillName: json["skill_name"],
      );

  Map<String, dynamic> toJson() => {
        "trans_work_id": transWorkId,
        "mst_company_name": mstCompanyName,
        "total_percentage": totalPercentage,
        "quantification": quantification,
        "wo_total_percentage": woTotalPercentage,
        "wo_total_quantification": woTotalQuantification,
        "skill_name": skillName,
      };
}

class MasnoryList {
  bool? isSelected;

  String? id;
  String? name;

  MasnoryList({
    this.id,
    this.name,
    this.isSelected = false,
  });

  factory MasnoryList.fromJson(Map<String, dynamic> json) => MasnoryList(
        id: json["id"],
        name: json["name"],
        isSelected: false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "isSelected": isSelected,
      };
}

class DprStockList {
  String? id;
  String? name;
  String? stockIn;
  String? stockConsume;
  String? stockRemain;

  DprStockList({
    this.id,
    this.name,
    this.stockIn,
    this.stockConsume,
    this.stockRemain,
  });

  factory DprStockList.fromJson(Map<String, dynamic> json) => DprStockList(
        id: json["id"],
        name: json["name"],
        stockIn: json["stock_in"],
        stockConsume: json["stock_consume"],
        stockRemain: json["stock_remain"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "stock_in": stockIn,
        "stock_consume": stockConsume,
        "stock_remain": stockRemain,
      };
}
