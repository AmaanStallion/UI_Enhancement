// To parse this JSON data, do
//
//     final getPlotListing = getPlotListingFromJson(jsonString);

import 'dart:convert';

import 'get_broker_details.dart';

GetPlotListing getPlotListingFromJson(String str) => GetPlotListing.fromJson(json.decode(str));

String getPlotListingToJson(GetPlotListing data) => json.encode(data.toJson());

class GetPlotListing {
  ResponseGetPlotListing? response;

  GetPlotListing({
    this.response,
  });

  factory GetPlotListing.fromJson(Map<String, dynamic> json) => GetPlotListing(
    response: ResponseGetPlotListing.fromJson(json["Response"]),
  );

  Map<String, dynamic> toJson() => {
    "Response": response?.toJson(),
  };
}

class ResponseGetPlotListing {
  String? errorCode;
  String? msg;
  String? plotDrawing;
  List<PlotDetail>? plotDetails;
  List<FloorDetail>? floorDetails;

  ResponseGetPlotListing({
    this.errorCode,
    this.msg,
    this.plotDrawing,
    this.plotDetails,
    this.floorDetails,
  });

  factory ResponseGetPlotListing.fromJson(Map<String, dynamic> json) => ResponseGetPlotListing(
    errorCode: json["error_code"],
    msg: json["msg"],
    plotDrawing: json["plot_drawing"],
    plotDetails: List<PlotDetail>.from(json["plot_details"].map((x) => PlotDetail.fromJson(x))),
    floorDetails: List<FloorDetail>.from(json["floor_details"].map((x) => FloorDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error_code": errorCode,
    "msg": msg,
    "plot_drawing": plotDrawing,
    "plot_details": List<dynamic>.from(plotDetails!.map((x) => x.toJson())),
    "floor_details": List<dynamic>.from(floorDetails!.map((x) => x.toJson())),
  };
}

class FloorDetail {
  String? flatName;
  String? inventryFlatId;

  FloorDetail({
    this.flatName,
    this.inventryFlatId,
  });

  factory FloorDetail.fromJson(Map<String, dynamic> json) => FloorDetail(
    flatName: json["flat_name"],
    inventryFlatId: json["inventry_flat_id"],
  );

  Map<String, dynamic> toJson() => {
    "flat_name": flatName,
    "inventry_flat_id": inventryFlatId,
  };
}

class PlotDetail {
  String? plotNo;
  String? flatId;
  Move? move;
  List<Move>? plotPoints;
  String? availableStatus;
  String? flatName;
  String? inventryFlatType;
  String? inventryFlatName;
  String? flatArea;
  String? masonryIdFk;
  String? masnoryName;
  String? floorNumber;
  List<FlatDetail>? flatDetails;
  String? selected;

  PlotDetail({
    this.plotNo,
    this.flatId,
    this.move,
    this.plotPoints,
    this.availableStatus,
    this.flatName,
    this.inventryFlatType,
    this.inventryFlatName,
    this.flatArea,
    this.masonryIdFk,
    this.masnoryName,
    this.floorNumber,
    this.flatDetails,
    this.selected,
  });

  factory PlotDetail.fromJson(Map<String, dynamic> json) => PlotDetail(
    plotNo: json["plot_no"],
    flatId: json["flat_id"],
    move: Move.fromJson(json["move"]),
    plotPoints: List<Move>.from(json["plot_points"].map((x) => Move.fromJson(x))),
    availableStatus: json["available_status"],
    flatName: json["flat_name"],
    inventryFlatType: json["inventry_flat_type"],
    inventryFlatName: json["inventry_flat_name"],
    flatArea: json["flat_area"],
    masonryIdFk: json["masonry_id_fk"],
    masnoryName: json["masnory_name"],
    floorNumber: json["floor_number"],
    selected: json["selected"] ?? "",
    flatDetails: List<FlatDetail>.from(json["flat_details"].map((x) => FlatDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "plot_no": plotNo,
    "flat_id": flatId,
    "move": move!.toJson(),
    "plot_points": List<dynamic>.from(plotPoints!.map((x) => x.toJson())),
    "available_status": availableStatus,
    "flat_name": flatName,
    "inventry_flat_type": inventryFlatType,
    "inventry_flat_name": inventryFlatName,
    "flat_area": flatArea,
    "masonry_id_fk": masonryIdFk,
    "masnory_name": masnoryName,
    "selected": selected,
    "floor_number": floorNumber,
    "flat_details": List<dynamic>.from(flatDetails!.map((x) => x.toJson())),
  };
}

class FlatDetail {
  String? floorTypeId;
  String? flatName;
  String? flatId;
  String? inventryFlatName;
  String? flatArea;
  String? inventryFlatType;
  String? floorNumber;
  String? masnoryName;
  String? availablePark;
  String? isParking;
  String? flatType;
  String? availableStatus;
  List<FlatBuyerRequest>? flatBuyerDetails;
  List<List<dynamic>>? customCharges;

  FlatDetail({
    this.floorTypeId,
    this.flatName,
    this.flatId,
    this.inventryFlatName,
    this.flatArea,
    this.inventryFlatType,
    this.floorNumber,
    this.masnoryName,
    this.availablePark,
    this.isParking,
    this.flatType,
    this.availableStatus,
    this.flatBuyerDetails,
    this.customCharges,
  });

  factory FlatDetail.fromJson(Map<String, dynamic> json) => FlatDetail(
    floorTypeId: json["floor_type_id"],
    flatName: json["flat_name"],
    flatId: json["flat_id"],
    inventryFlatName: json["inventry_flat_name"],
    flatArea: json["flat_area"],
    inventryFlatType: json["inventry_flat_type"],
    floorNumber: json["floor_number"],
    masnoryName: json["masnory_name"],
    availablePark: json["available_park"],
    isParking: json["is_parking"],
    flatType: json["flat_type"],
    availableStatus: json["available_status"],
    flatBuyerDetails: List<FlatBuyerRequest>.from(json["flat_buyer_details"].map((x) => FlatBuyerRequest.fromJson(x))),
    customCharges: List<List<dynamic>>.from(json["custom_charges"].map((x) => List<dynamic>.from(x.map((x) => x)))),
  );

  Map<String, dynamic> toJson() => {
    "floor_type_id": floorTypeId,
    "flat_name": flatName,
    "flat_id": flatId,
    "inventry_flat_name": inventryFlatName,
    "flat_area": flatArea,
    "inventry_flat_type": inventryFlatType,
    "floor_number": floorNumber,
    "masnory_name": masnoryName,
    "available_park": availablePark,
    "is_parking": isParking,
    "flat_type": flatType,
    "available_status": availableStatus,
    "flat_buyer_details": List<dynamic>.from(flatBuyerDetails!.map((x) => x.toJson())),
    "custom_charges": List<dynamic>.from(customCharges!.map((x) => List<dynamic>.from(x.map((x) => x)))),
  };
}


class SelectedFlat {
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
}

class Move {
  String? x;
  String? y;

  Move({
    this.x,
    this.y,
  });

  factory Move.fromJson(Map<String, dynamic> json) => Move(
    x: json["x"],
    y: json["y"],
  );

  Map<String, dynamic> toJson() => {
    "x": x,
    "y": y,
  };
}
