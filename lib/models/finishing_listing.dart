// To parse this JSON data, do
//
//     final finishingListing = finishingListingFromJson(jsonString);

import 'dart:convert';

FinishingListing finishingListingFromJson(String str) =>
    FinishingListing.fromJson(json.decode(str));

String finishingListingToJson(FinishingListing data) =>
    json.encode(data.toJson());

class FinishingListing {
  FinishingListingResponse? response;

  FinishingListing({
    this.response,
  });

  factory FinishingListing.fromJson(Map<String, dynamic> json) =>
      FinishingListing(
        response: json["Response"] == null
            ? null
            : FinishingListingResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class FinishingListingResponse {
  String? errorCode;
  String? msg;
  List<FlatDetailsList>? flatDetailsList;

  FinishingListingResponse({
    this.errorCode,
    this.msg,
    this.flatDetailsList,
  });

  factory FinishingListingResponse.fromJson(Map<String, dynamic> json) =>
      FinishingListingResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        flatDetailsList: json["flat_details_list"] == null
            ? []
            : List<FlatDetailsList>.from(json["flat_details_list"]!
                .map((x) => FlatDetailsList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "flat_details_list": flatDetailsList == null
            ? []
            : List<dynamic>.from(flatDetailsList!.map((x) => x.toJson())),
      };
}

class FlatDetailsList {
  String? floorName;
  List<FlatDetail>? flatDetails;

  FlatDetailsList({
    this.floorName,
    this.flatDetails,
  });

  factory FlatDetailsList.fromJson(Map<String, dynamic> json) =>
      FlatDetailsList(
        floorName: json["floor_name"],
        flatDetails: json["flat_details"] == null
            ? []
            : List<FlatDetail>.from(
                json["flat_details"]!.map((x) => FlatDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "floor_name": floorName,
        "flat_details": flatDetails == null
            ? []
            : List<dynamic>.from(flatDetails!.map((x) => x.toJson())),
      };
}

class FlatDetail {
  String? flatName;
  String? floorId;

  FlatDetail({
    this.flatName,
    this.floorId,
  });

  factory FlatDetail.fromJson(Map<String, dynamic> json) => FlatDetail(
        flatName: json["flat_name"],
        floorId: json["floor_id"],
      );

  Map<String, dynamic> toJson() => {
        "flat_name": flatName,
        "floor_id": floorId,
      };
}
