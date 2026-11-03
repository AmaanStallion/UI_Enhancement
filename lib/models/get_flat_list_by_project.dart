// To parse this JSON data, do
//
//     final getFlatListByProject = getFlatListByProjectFromJson(jsonString);

import 'dart:convert';

GetFlatListByProject getFlatListByProjectFromJson(String str) =>
    GetFlatListByProject.fromJson(json.decode(str));

String getFlatListByProjectToJson(GetFlatListByProject data) =>
    json.encode(data.toJson());

class GetFlatListByProject {
  ResponseGetFlatListByProject? response;

  GetFlatListByProject({
    this.response,
  });

  factory GetFlatListByProject.fromJson(Map<String, dynamic> json) =>
      GetFlatListByProject(
        response: json["Response"] == null
            ? null
            : ResponseGetFlatListByProject.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetFlatListByProject {
  String? errorCode;
  String? msg;
  List<FinishingBookList>? finishingBookList;
  List<PodiumList>? podiumList;
  Percentagate? percentagate;
  List<FlatList>? flatList;
  List<List<CustomCharge>>? customCharges;
  List<BorkerList>? borkerList;
  String? averagePrice;
  String? bookingType;

  ResponseGetFlatListByProject({
    this.errorCode,
    this.msg,
    this.finishingBookList,
    this.podiumList,
    this.percentagate,
    this.flatList,
    this.customCharges,
    this.borkerList,
    this.averagePrice,
    this.bookingType,
  });

  factory ResponseGetFlatListByProject.fromJson(Map<String, dynamic> json) =>
      ResponseGetFlatListByProject(
        errorCode: json["error_code"],
        msg: json["msg"],
        finishingBookList: json["finishing_book_list"] == null
            ? []
            : List<FinishingBookList>.from(json["finishing_book_list"]
                .map((x) => FinishingBookList.fromJson(x))),
        podiumList: json["podium_list"] == null
            ? []
            : List<PodiumList>.from(
                json["podium_list"].map((x) => PodiumList.fromJson(x))),
        percentagate: json["percentagate"] == null
            ? null
            : Percentagate.fromJson(json["percentagate"]),
        flatList: json["flat_list"] == null
            ? []
            : List<FlatList>.from(
                json["flat_list"]!.map((x) => FlatList.fromJson(x))),
        customCharges: json["custom_charges"] == null
            ? []
            : List<List<CustomCharge>>.from(json["custom_charges"]!.map((x) =>
                List<CustomCharge>.from(
                    x.map((x) => CustomCharge.fromJson(x))))),
        borkerList: json["borker_list"] == null
            ? []
            : List<BorkerList>.from(
                json["borker_list"]!.map((x) => BorkerList.fromJson(x))),
        averagePrice: json["average_price"],
        bookingType: json["booking_type"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "finishing_book_list": finishingBookList == null
            ? []
            : List<dynamic>.from(finishingBookList!.map((x) => x.toJson())),
        "podium_list": podiumList == null
            ? []
            : List<dynamic>.from(podiumList!.map((x) => x.toJson())),
        "percentagate": percentagate?.toJson(),
        "flat_list": flatList == null
            ? []
            : List<dynamic>.from(flatList!.map((x) => x.toJson())),
        "custom_charges": customCharges == null
            ? []
            : List<dynamic>.from(customCharges!
                .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        "borker_list": borkerList == null
            ? []
            : List<dynamic>.from(borkerList!.map((x) => x.toJson())),
        "average_price": averagePrice,
        "booking_type": bookingType,
      };
}

class BorkerList {
  String? companyName;
  String? brokerId;
  String? brokeragePercent;

  BorkerList({
    this.companyName,
    this.brokerId,
    this.brokeragePercent,
  });

  factory BorkerList.fromJson(Map<String, dynamic> json) => BorkerList(
        companyName: json["company_name"],
        brokerId: json["broker_id"],
        brokeragePercent: json["brokerage_percent"],
      );

  Map<String, dynamic> toJson() => {
        "company_name": companyName,
        "broker_id": brokerId,
        "brokerage_percent": brokeragePercent,
      };
}

class CustomCharge {
  String? id;
  String? chargesId;
  String? name;
  String? value;
  String? calculated;
  String? collected;
  String? chargesGst;
  String? totalValue;
  String? unit;
  String? selected;

  CustomCharge({
    this.id,
    this.chargesId,
    this.name,
    this.value,
    this.calculated,
    this.collected,
    this.chargesGst,
    this.totalValue,
    this.unit,
    this.selected,
  });

  factory CustomCharge.fromJson(Map<String, dynamic> json) => CustomCharge(
        id: json["id"],
        chargesId: json["charges_id"],
        name: json["name"],
        value: json["value"],
        calculated: json["calculated"],
        collected: json["collected"],
        chargesGst: json["charges_gst"],
        totalValue: json["total_value"],
        unit: json["unit"],
        selected: json["selected"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "charges_id": chargesId,
        "name": name,
        "value": value,
        "calculated": calculated,
        "collected": collected,
        "charges_gst": chargesGst,
        "selected": selected,
        "total_value": totalValue,
        "unit": unit,
      };
}

class FinishingBookList {
  String? mstFinishingId;
  String? mstFinishingName;
  String? mstFinishingStatus;
  DateTime? mstFinishingUpdateAt;
  DateTime? mstFinishingCreatedAt;

  FinishingBookList({
    this.mstFinishingId,
    this.mstFinishingName,
    this.mstFinishingStatus,
    this.mstFinishingUpdateAt,
    this.mstFinishingCreatedAt,
  });

  factory FinishingBookList.fromJson(Map<String, dynamic> json) =>
      FinishingBookList(
        mstFinishingId: json["mst_finishing_id"],
        mstFinishingName: json["mst_finishing_name"],
        mstFinishingStatus: json["mst_finishing_status"],
        mstFinishingUpdateAt: json["mst_finishing_update_at"] == null
            ? null
            : DateTime.parse(json["mst_finishing_update_at"]),
        mstFinishingCreatedAt: json["mst_finishing_created_at"] == null
            ? null
            : DateTime.parse(json["mst_finishing_created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "mst_finishing_id": mstFinishingId,
        "mst_finishing_name": mstFinishingName,
        "mst_finishing_status": mstFinishingStatus,
        "mst_finishing_update_at": mstFinishingUpdateAt?.toIso8601String(),
        "mst_finishing_created_at": mstFinishingCreatedAt?.toIso8601String(),
      };
}

class FlatList {
  String? flatName;
  String? flatId;
  String? inventryFlatName;
  String? flatArea;
  String? masonryIdFk;
  String? masnoryName;
  String? floorNumber;
  String? buyer_name;
  String? mobile_number;
  String? emailid;
  String? address;
  String? pan;
  String? aadhar;
  bool? isSelected = false;
  String? inventyParkingNumber;
  List<FlatListParkingList>? parkingList;
  String? flatIdFk;
  String? floorTypeId;

  FlatList({
    this.flatIdFk,
    this.flatName,
    this.flatId,
    this.inventryFlatName,
    this.flatArea,
    this.masonryIdFk,
    this.masnoryName,
    this.floorNumber,
    this.buyer_name,
    this.mobile_number,
    this.emailid,
    this.address,
    this.pan,
    this.aadhar,
    this.isSelected = false,
    this.inventyParkingNumber,
    this.parkingList,
    this.floorTypeId,
  });

  factory FlatList.fromJson(Map<String, dynamic> json) => FlatList(
        flatName: json["flat_name"],
        flatIdFk: json["flat_id_fk"],
        flatId: json["flat_id"],
        inventryFlatName: json["inventry_flat_name"],
        flatArea: json["flat_area"],
        masonryIdFk: json["masonry_id_fk"],
        masnoryName: json["masnory_name"],
        floorNumber: json["floor_number"],
        buyer_name: json["buyer_name"],
        mobile_number: json["mobile_number"],
        emailid: json["emailid"],
        address: json["address"],
        pan: json["pan"],
        aadhar: json["aadhar"],
        isSelected: json['isSelected'],
        inventyParkingNumber: json["inventy_parking_number"],
        parkingList: json["parking_list"] == null
            ? []
            : List<FlatListParkingList>.from(json["parking_list"]!
                .map((x) => FlatListParkingList.fromJson(x))),
        floorTypeId: json["floor_type_id"],
      );

  Map<String, dynamic> toJson() => {
        "flat_name": flatName,
        "flat_id_fk": flatIdFk,
        "flat_id": flatId,
        "inventry_flat_name": inventryFlatName,
        "flat_area": flatArea,
        "masonry_id_fk": masonryIdFk,
        "masnory_name": masnoryName,
        "floor_number": floorNumber,
        "buyer_name": buyer_name,
        "mobile_number": mobile_number,
        "emailid": emailid,
        "address": address,
        "pan": pan,
        "aadhar": aadhar,
        "isSelected": isSelected,
        "inventy_parking_number": inventyParkingNumber,
        "parking_list": parkingList == null
            ? []
            : List<dynamic>.from(parkingList!.map((x) => x.toJson())),
        "floor_type_id": floorTypeId,
      };
}

class FlatListParkingList {
  String? parkingSerialNo;
  String? mstParkingId;

  FlatListParkingList({
    this.parkingSerialNo,
    this.mstParkingId,
  });

  factory FlatListParkingList.fromJson(Map<String, dynamic> json) =>
      FlatListParkingList(
        parkingSerialNo: json["parking_serial_no"],
        mstParkingId: json["mst_parking_id"],
      );

  Map<String, dynamic> toJson() => {
        "parking_serial_no": parkingSerialNo,
        "mst_parking_id": mstParkingId,
      };
}

class Percentagate {
  String? stampDurty;
  String? gstPer;
  String? tdsPercentage;
  String? residentialPercentage;
  String? commertialPercentage;

  Percentagate({
    this.stampDurty,
    this.gstPer,
    this.tdsPercentage,
    this.residentialPercentage,
    this.commertialPercentage,
  });

  factory Percentagate.fromJson(Map<String, dynamic> json) => Percentagate(
        stampDurty: json["stamp_durty"],
        gstPer: json["gst_per"],
        tdsPercentage: json["tds_percentage"],
        residentialPercentage: json["residential_percentage"],
        commertialPercentage: json["commertial_percentage"],
      );

  Map<String, dynamic> toJson() => {
        "stamp_durty": stampDurty,
        "gst_per": gstPer,
        "tds_percentage": tdsPercentage,
        "residential_percentage": residentialPercentage,
        "commertial_percentage": commertialPercentage,
      };
}

class PodiumList {
  String? flatName;
  String? flatId;
  String? inventryFlatName;
  String? flatArea;
  String? available;
  List<ParkingList>? parkingList;

  PodiumList({
    this.flatName,
    this.flatId,
    this.inventryFlatName,
    this.flatArea,
    this.available,
    this.parkingList,
  });

  factory PodiumList.fromJson(Map<String, dynamic> json) => PodiumList(
        flatName: json["flat_name"],
        flatId: json["flat_id"],
        inventryFlatName: json["inventry_flat_name"],
        flatArea: json["flat_area"],
        available: json["available"] ?? '0',
        parkingList: json["parking_list"] == null
            ? []
            : List<ParkingList>.from(
                json["parking_list"]!.map((x) => ParkingList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "flat_name": flatName,
        "flat_id": flatId,
        "inventry_flat_name": inventryFlatName,
        "flat_area": flatArea,
        "available": available,
        "parking_list": parkingList == null
            ? []
            : List<dynamic>.from(parkingList!.map((x) => x)),
      };
}

class ParkingList {
  String? parkingSerialNo;
  String? mstParkingId;
  String? selected;
  String? inventryAllocatedId;
  String? parkingIsAllocated;

  ParkingList({
    this.parkingSerialNo,
    this.mstParkingId,
    this.selected,
    this.inventryAllocatedId,
    this.parkingIsAllocated,
  });

  factory ParkingList.fromJson(Map<String, dynamic> json) => ParkingList(
        parkingSerialNo: json["parking_serial_no"],
        mstParkingId: json["mst_parking_id"],
        selected: json["selected"] ?? '',
        inventryAllocatedId: json["inventry_allocated_id"],
        parkingIsAllocated: json["parking_is_allocated"],
      );

  Map<String, dynamic> toJson() => {
        "parking_serial_no": parkingSerialNo,
        "mst_parking_id": mstParkingId,
        "selected": selected,
        "inventry_allocated_id": inventryAllocatedId,
        "parking_is_allocated": parkingIsAllocated,
      };
}
