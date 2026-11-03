// To parse this JSON data, do
//
//     final getSaleBuyerRequest = getSaleBuyerRequestFromJson(jsonString);

import 'dart:convert';
import 'package:stallion/models/get_broker_details.dart';

GetSaleBuyerRequest getSaleBuyerRequestFromJson(String str) =>
    GetSaleBuyerRequest.fromJson(json.decode(str));

String getSaleBuyerRequestToJson(GetSaleBuyerRequest data) =>
    json.encode(data.toJson());

class GetSaleBuyerRequest {
  ResponseGetSaleBuyerRequest? response;

  GetSaleBuyerRequest({
    this.response,
  });

  factory GetSaleBuyerRequest.fromJson(Map<String, dynamic> json) =>
      GetSaleBuyerRequest(
        response: json["Response"] == null
            ? null
            : ResponseGetSaleBuyerRequest.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetSaleBuyerRequest {
  String? errorCode;
  String? msg;
  List<OrderShort>? orderShort;
  List<FlatBuyerInfo>? buyerContactDetails;

  String? totalSold;
  String? totalRegistered;
  String? totalUnregistered;
  List<FlatBuyerRequest>? flatBuyerRequest;
  String? offset;

  ResponseGetSaleBuyerRequest({
    this.errorCode,
    this.msg,
    this.totalSold,
    this.orderShort,
    this.totalRegistered,
    this.totalUnregistered,
    this.flatBuyerRequest,
    this.offset,
    this.buyerContactDetails,
  });

  factory ResponseGetSaleBuyerRequest.fromJson(Map<String, dynamic> json) =>
      ResponseGetSaleBuyerRequest(
        buyerContactDetails: json["buyer_contact_details"] == null
            ? []
            : List<FlatBuyerInfo>.from(json["buyer_contact_details"]!
                .map((x) => FlatBuyerInfo.fromJson(x))),
        errorCode: json["error_code"],
        orderShort: json["order_short"] == null
            ? []
            : List<OrderShort>.from(
                json["order_short"]!.map((x) => OrderShort.fromJson(x))),
        msg: json["msg"],
        totalSold: json["total_sold"],
        totalRegistered: json["total_registered"],
        totalUnregistered: json["total_unregistered"],
        flatBuyerRequest: json["flat_buyer_request"] == null
            ? []
            : List<FlatBuyerRequest>.from(json["flat_buyer_request"]!
                .map((x) => FlatBuyerRequest.fromJson(x))),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "order_short": orderShort == null
            ? []
            : List<dynamic>.from(orderShort!.map((x) => x.toJson())),
        "total_sold": totalSold,
        "total_registered": totalRegistered,
        "total_unregistered": totalUnregistered,
        "flat_buyer_request": flatBuyerRequest == null
            ? []
            : List<dynamic>.from(flatBuyerRequest!.map((x) => x.toJson())),
        "offset": offset,
        "buyer_contact_details":
            buyerContactDetails?.map((e) => e.toJson()).toList(),
      };
}

class OrderShort {
  String? id;
  String? name;

  OrderShort({
    this.id,
    this.name,
  });

  factory OrderShort.fromJson(Map<String, dynamic> json) => OrderShort(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
/*class SelectedFlat {
  String? flatName;
  String? flatId;
  String? inventryFlatName;
  String? flatArea;
  String? masonryIdFk;
  String? masnoryName;
  String? floorNumber;

  SelectedFlat({
    this.flatName,
    this.flatId,
    this.inventryFlatName,
    this.flatArea,
    this.masonryIdFk,
    this.masnoryName,
    this.floorNumber,
  });

  factory SelectedFlat.fromJson(Map<String, dynamic> json) => SelectedFlat(
    flatName: json["flat_name"],
    flatId: json["flat_id"],
    inventryFlatName: json["inventry_flat_name"],
    flatArea: json["flat_area"],
    masonryIdFk: json["masonry_id_fk"],
    masnoryName: json["masnory_name"],
    floorNumber: json["floor_number"],
  );

  Map<String, dynamic> toJson() => {
    "flat_name": flatName,
    "flat_id": flatId,
    "inventry_flat_name": inventryFlatName,
    "flat_area": flatArea,
    "masonry_id_fk": masonryIdFk,
    "masnory_name": masnoryName,
    "floor_number": floorNumber,
  };
}*/
