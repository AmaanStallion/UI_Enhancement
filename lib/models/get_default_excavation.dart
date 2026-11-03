// To parse this JSON data, do
//
//     final getDefaultExcavationList = getDefaultExcavationListFromJson(jsonString);

import 'dart:convert';

// import 'package:stallion/models/get_purchase_order_default_request.dart';

GetDefaultExcavationList getDefaultExcavationListFromJson(String str) =>
    GetDefaultExcavationList.fromJson(json.decode(str));

String getDefaultExcavationListToJson(GetDefaultExcavationList data) =>
    json.encode(data.toJson());

class GetDefaultExcavationList {
  GetDefaultExcavationListResponse? response;

  GetDefaultExcavationList({
    this.response,
  });

  factory GetDefaultExcavationList.fromJson(Map<String, dynamic> json) =>
      GetDefaultExcavationList(
        response: json["Response"] == null
            ? null
            : GetDefaultExcavationListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetDefaultExcavationListResponse {
  String? errorCode;
  String? msg;
  List<TruckSize>? vehicleType;
  List<TruckSize>? truckSize;
  List<TruckSize>? typeRoyality;
  List<SlabDetail>? slabDetails;

  GetDefaultExcavationListResponse({
    this.errorCode,
    this.msg,
    this.vehicleType,
    this.truckSize,
    this.typeRoyality,
    this.slabDetails,
  });

  factory GetDefaultExcavationListResponse.fromJson(
          Map<String, dynamic> json) =>
      GetDefaultExcavationListResponse(
        slabDetails: json["slab_details"] == null
            ? []
            : List<SlabDetail>.from(
                json["slab_details"]!.map((x) => SlabDetail.fromJson(x))),
        errorCode: json["error_code"],
        msg: json["msg"],
        vehicleType: json["vehicle_type"] == null
            ? []
            : List<TruckSize>.from(
                json["vehicle_type"]!.map((x) => TruckSize.fromJson(x))),
        truckSize: json["truck_size"] == null
            ? []
            : List<TruckSize>.from(
                json["truck_size"]!.map((x) => TruckSize.fromJson(x))),
        typeRoyality: json["type_royality"] == null
            ? []
            : List<TruckSize>.from(
                json["type_royality"]!.map((x) => TruckSize.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "slab_details": slabDetails == null
            ? []
            : List<dynamic>.from(slabDetails!.map((x) => x.toJson())),
        "error_code": errorCode,
        "msg": msg,
        "vehicle_type": vehicleType == null
            ? []
            : List<dynamic>.from(vehicleType!.map((x) => x.toJson())),
        "truck_size": truckSize == null
            ? []
            : List<dynamic>.from(truckSize!.map((x) => x.toJson())),
        "type_royality": typeRoyality == null
            ? []
            : List<dynamic>.from(typeRoyality!.map((x) => x.toJson())),
      };
}

class TruckSize {
  String? id;
  String? name;
  String? value;
  TruckSize({
    this.id,
    this.name,
    this.value,
  });

  factory TruckSize.fromJson(Map<String, dynamic> json) => TruckSize(
        id: json["id"],
        name: json["name"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
      };
}

class SlabDetail {
  String? id;
  String? name;
  String? selected;

  SlabDetail({
    this.id,
    this.name,
    this.selected,
  });

  factory SlabDetail.fromJson(Map<String, dynamic> json) => SlabDetail(
        id: json["id"],
        name: json["name"],
        selected: json["selected"] ?? '0',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "selected": selected,
      };
}
