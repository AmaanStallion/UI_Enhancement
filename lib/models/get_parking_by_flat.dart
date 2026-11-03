// To parse this JSON data, do
//
//     final getParkingByFlat = getParkingByFlatFromJson(jsonString);

import 'dart:convert';

GetParkingByFlat getParkingByFlatFromJson(String str) =>
    GetParkingByFlat.fromJson(json.decode(str));

String getParkingByFlatToJson(GetParkingByFlat data) =>
    json.encode(data.toJson());

class GetParkingByFlat {
  GetParkingByFlatResponse? response;

  GetParkingByFlat({
    this.response,
  });

  factory GetParkingByFlat.fromJson(Map<String, dynamic> json) =>
      GetParkingByFlat(
        response: json["Response"] == null
            ? null
            : GetParkingByFlatResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetParkingByFlatResponse {
  String? errorCode;
  String? msg;
  List<FlatParking>? flatParking;

  GetParkingByFlatResponse({
    this.errorCode,
    this.msg,
    this.flatParking,
  });

  factory GetParkingByFlatResponse.fromJson(Map<String, dynamic> json) =>
      GetParkingByFlatResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        flatParking: json["flat_parking"] == null
            ? []
            : List<FlatParking>.from(
                json["flat_parking"]!.map((x) => FlatParking.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "flat_parking": flatParking == null
            ? []
            : List<dynamic>.from(flatParking!.map((x) => x.toJson())),
      };
}

class FlatParking {
  String? parkingSerialNo;
  String? mstParkingId;
  String? inventryAllocatedId;
  String? parkingAllowcated;
  String? availableStatus;
  String? flatName;
  String? buyerTenantId;
  String? availableType;

  FlatParking({
    this.parkingSerialNo,
    this.mstParkingId,
    this.inventryAllocatedId,
    this.parkingAllowcated,
    this.availableStatus,
    this.flatName,
    this.buyerTenantId,
    this.availableType,
  });

  factory FlatParking.fromJson(Map<String, dynamic> json) => FlatParking(
        parkingSerialNo: json["parking_serial_no"],
        mstParkingId: json["mst_parking_id"],
        inventryAllocatedId: json["inventry_allocated_id"],
        parkingAllowcated: json["parking_allowcated"],
        availableStatus: json["available_status"],
        flatName: json["flat_name"],
        buyerTenantId: json["buyer_tenant_id"],
        availableType: json["available_type"],
      );

  Map<String, dynamic> toJson() => {
        "parking_serial_no": parkingSerialNo,
        "mst_parking_id": mstParkingId,
        "inventry_allocated_id": inventryAllocatedId,
        "parking_allowcated": parkingAllowcated,
        "available_status": availableStatus,
        "flat_name": flatName,
        "buyer_tenant_id": buyerTenantId,
        "available_type": availableType,
      };
}
