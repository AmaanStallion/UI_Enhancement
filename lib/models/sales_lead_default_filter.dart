// To parse this JSON data, do
//
//     final salesLeadDefaultFilter = salesLeadDefaultFilterFromJson(jsonString);

import 'dart:convert';

SalesLeadDefaultFilter salesLeadDefaultFilterFromJson(String str) =>
    SalesLeadDefaultFilter.fromJson(json.decode(str));

String salesLeadDefaultFilterToJson(SalesLeadDefaultFilter data) =>
    json.encode(data.toJson());

class SalesLeadDefaultFilter {
  ResponseSalesLeadDefaultFilter? response;

  SalesLeadDefaultFilter({
    this.response,
  });

  factory SalesLeadDefaultFilter.fromJson(Map<String, dynamic> json) =>
      SalesLeadDefaultFilter(
        response: json["Response"] == null
            ? null
            : ResponseSalesLeadDefaultFilter.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseSalesLeadDefaultFilter {
  String? errorCode;
  String? msg;
  List<FlatDetail>? flatDetails;
  List<AreaRangeList>? rangeList;
  List<AreaRangeList>? sourceList;
  List<AreaRangeList>? subSources;
  List<AreaRangeList>? ethnicity;
  List<AreaRangeList>? location;
  List<AreaRangeList>? leadStage;
  List<AreaRangeList>? lostReason;
  List<BrokerList>? brokerList;
  List<String>? requirement;
  List<AreaRangeList>? brokerLocation;
  List<AreaRangeList>? areaRangeList;
  List<AssingUserList>? assingUserList;
  List<AreaRangeList>? invenster;
  List<AreaRangeList>? campaign;
  List<AreaRangeList>? currentOwner;
  List<AreaRangeList>? nationality;
  List<AreaRangeList>? currentConfiguration;
  List<AreaRangeList>? buyerType;
  List<AreaRangeList>? fundingType;

  ResponseSalesLeadDefaultFilter({
    this.errorCode,
    this.msg,
    this.flatDetails,
    this.rangeList,
    this.sourceList,
    this.subSources,
    this.ethnicity,
    this.location,
    this.leadStage,
    this.lostReason,
    this.brokerList,
    this.requirement,
    this.brokerLocation,
    this.areaRangeList,
    this.assingUserList,
    this.invenster,
    this.campaign,
    this.currentOwner,
    this.nationality,
    this.currentConfiguration,
    this.buyerType,
    this.fundingType,
  });

  factory ResponseSalesLeadDefaultFilter.fromJson(Map<String, dynamic> json) =>
      ResponseSalesLeadDefaultFilter(
        errorCode: json["error_code"],
        msg: json["msg"],
        flatDetails: json["flat_details"] == null
            ? []
            : List<FlatDetail>.from(
                json["flat_details"]!.map((x) => FlatDetail.fromJson(x))),
        rangeList: json["range_list"] == null
            ? []
            : List<AreaRangeList>.from(
                json["range_list"]!.map((x) => AreaRangeList.fromJson(x))),
        sourceList: json["source_list"] == null
            ? []
            : List<AreaRangeList>.from(
                json["source_list"]!.map((x) => AreaRangeList.fromJson(x))),
        subSources: json["sub_sources"] == null
            ? []
            : List<AreaRangeList>.from(
                json["sub_sources"]!.map((x) => AreaRangeList.fromJson(x))),
        ethnicity: json["ethnicity"] == null
            ? []
            : List<AreaRangeList>.from(
                json["ethnicity"]!.map((x) => AreaRangeList.fromJson(x))),
        location: json["location"] == null
            ? []
            : List<AreaRangeList>.from(
                json["location"]!.map((x) => AreaRangeList.fromJson(x))),
        leadStage: json["lead_stage"] == null
            ? []
            : List<AreaRangeList>.from(
                json["lead_stage"]!.map((x) => AreaRangeList.fromJson(x))),
        lostReason: json["lost_reason"] == null
            ? []
            : List<AreaRangeList>.from(
                json["lost_reason"]!.map((x) => AreaRangeList.fromJson(x))),
        brokerList: json["broker_list"] == null
            ? []
            : List<BrokerList>.from(
                json["broker_list"]!.map((x) => BrokerList.fromJson(x))),
        requirement: json["requirement"] == null
            ? []
            : List<String>.from(json["requirement"]!.map((x) => x)),
        brokerLocation: json["broker_location"] == null
            ? []
            : List<AreaRangeList>.from(
                json["broker_location"]!.map((x) => AreaRangeList.fromJson(x))),
        areaRangeList: json["area_range_list"] == null
            ? []
            : List<AreaRangeList>.from(
                json["area_range_list"]!.map((x) => AreaRangeList.fromJson(x))),
        assingUserList: json["assing_user_list"] == null
            ? []
            : List<AssingUserList>.from(json["assing_user_list"]!
                .map((x) => AssingUserList.fromJson(x))),
        invenster: json["invenster"] == null
            ? []
            : List<AreaRangeList>.from(
                json["invenster"]!.map((x) => AreaRangeList.fromJson(x))),
        campaign: json["campaign"] == null
            ? []
            : List<AreaRangeList>.from(
                json["campaign"]!.map((x) => AreaRangeList.fromJson(x))),
        currentOwner: json["current_owner"] == null
            ? []
            : List<AreaRangeList>.from(
                json["current_owner"]!.map((x) => AreaRangeList.fromJson(x))),
        nationality: json["nationality"] == null
            ? []
            : List<AreaRangeList>.from(
                json["nationality"]!.map((x) => AreaRangeList.fromJson(x))),
        currentConfiguration: json["current_configuration"] == null
            ? []
            : List<AreaRangeList>.from(json["current_configuration"]!
                .map((x) => AreaRangeList.fromJson(x))),
        buyerType: json["buyer_type"] == null
            ? []
            : List<AreaRangeList>.from(
                json["buyer_type"]!.map((x) => AreaRangeList.fromJson(x))),
        fundingType: json["funding_type"] == null
            ? []
            : List<AreaRangeList>.from(
                json["funding_type"]!.map((x) => AreaRangeList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "flat_details": flatDetails == null
            ? []
            : List<dynamic>.from(flatDetails!.map((x) => x.toJson())),
        "range_list": rangeList == null
            ? []
            : List<dynamic>.from(rangeList!.map((x) => x.toJson())),
        "source_list": sourceList == null
            ? []
            : List<dynamic>.from(sourceList!.map((x) => x.toJson())),
        "sub_sources": subSources == null
            ? []
            : List<dynamic>.from(subSources!.map((x) => x.toJson())),
        "ethnicity": ethnicity == null
            ? []
            : List<dynamic>.from(ethnicity!.map((x) => x.toJson())),
        "location": location == null
            ? []
            : List<dynamic>.from(location!.map((x) => x.toJson())),
        "lead_stage": leadStage == null
            ? []
            : List<dynamic>.from(leadStage!.map((x) => x.toJson())),
        "lost_reason": lostReason == null
            ? []
            : List<dynamic>.from(lostReason!.map((x) => x.toJson())),
        "broker_list": brokerList == null
            ? []
            : List<dynamic>.from(brokerList!.map((x) => x.toJson())),
        "requirement": requirement == null
            ? []
            : List<dynamic>.from(requirement!.map((x) => x)),
        "broker_location": brokerLocation == null
            ? []
            : List<dynamic>.from(brokerLocation!.map((x) => x.toJson())),
        "area_range_list": areaRangeList == null
            ? []
            : List<dynamic>.from(areaRangeList!.map((x) => x.toJson())),
        "assing_user_list": assingUserList == null
            ? []
            : List<dynamic>.from(assingUserList!.map((x) => x.toJson())),
        "invenster": invenster == null
            ? []
            : List<dynamic>.from(invenster!.map((x) => x.toJson())),
        "campaign": campaign == null
            ? []
            : List<dynamic>.from(campaign!.map((x) => x.toJson())),
        "current_owner": currentOwner == null
            ? []
            : List<dynamic>.from(currentOwner!.map((x) => x.toJson())),
        "nationality": nationality == null
            ? []
            : List<dynamic>.from(nationality!.map((x) => x.toJson())),
        "current_configuration": currentConfiguration == null
            ? []
            : List<dynamic>.from(currentConfiguration!.map((x) => x.toJson())),
        "buyer_type": buyerType == null
            ? []
            : List<dynamic>.from(buyerType!.map((x) => x.toJson())),
        "funding_type": fundingType == null
            ? []
            : List<dynamic>.from(fundingType!.map((x) => x.toJson())),
      };
}

class AreaRangeList {
  String? id;
  String? name;

  AreaRangeList({
    this.id,
    this.name,
  });

  factory AreaRangeList.fromJson(Map<String, dynamic> json) => AreaRangeList(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class AssingUserList {
  String? transEmpId;
  String? transEmpName;

  AssingUserList({
    this.transEmpId,
    this.transEmpName,
  });

  factory AssingUserList.fromJson(Map<String, dynamic> json) => AssingUserList(
        transEmpId: json["trans_emp_id"],
        transEmpName: json["trans_emp_name"],
      );

  Map<String, dynamic> toJson() => {
        "trans_emp_id": transEmpId,
        "trans_emp_name": transEmpName,
      };
}

class BrokerList {
  String? brokerId;
  String? companyName;

  BrokerList({
    this.brokerId,
    this.companyName,
  });

  factory BrokerList.fromJson(Map<String, dynamic> json) => BrokerList(
        brokerId: json["broker_id"],
        companyName: json["company_name"],
      );

  Map<String, dynamic> toJson() => {
        "broker_id": brokerId,
        "company_name": companyName,
      };
}

class FlatDetail {
  String? flatName;
  InventryFlatType? inventryFlatType;
  String? flatId;
  String? inventryFlatName;
  String? flatArea;
  String? masonryIdFk;

  FlatDetail({
    this.flatName,
    this.inventryFlatType,
    this.flatId,
    this.inventryFlatName,
    this.flatArea,
    this.masonryIdFk,
  });

  factory FlatDetail.fromJson(Map<String, dynamic> json) => FlatDetail(
        flatName: json["flat_name"],
        inventryFlatType:
            inventryFlatTypeValues.map[json["inventry_flat_type"]],
        flatId: json["flat_id"],
        inventryFlatName: json["inventry_flat_name"],
        flatArea: json["flat_area"],
        masonryIdFk: json["masonry_id_fk"],
      );

  Map<String, dynamic> toJson() => {
        "flat_name": flatName,
        "inventry_flat_type": inventryFlatTypeValues.reverse[inventryFlatType],
        "flat_id": flatId,
        "inventry_flat_name": inventryFlatName,
        "flat_area": flatArea,
        "masonry_id_fk": masonryIdFk,
      };
}

enum InventryFlatType { THE_2_BHK, THE_3_BHK }

final inventryFlatTypeValues = EnumValues(
    {"2 BHK": InventryFlatType.THE_2_BHK, "3 BHK": InventryFlatType.THE_3_BHK});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
