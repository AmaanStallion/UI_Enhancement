// To parse this JSON data, do
//
//     final flatStatus = flatStatusFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/models/get_flat_list_by_project.dart';

FlatStatus flatStatusFromJson(String str) =>
    FlatStatus.fromJson(json.decode(str));

String flatStatusToJson(FlatStatus data) => json.encode(data.toJson());

class FlatStatus {
  FlatStatusResponse? response;

  FlatStatus({
    this.response,
  });

  factory FlatStatus.fromJson(Map<String, dynamic> json) => FlatStatus(
        response: json["Response"] == null
            ? null
            : FlatStatusResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class FlatStatusResponse {
  String? errorCode;
  String? msg;
  List<FlatAvailableList>? flatAvailableList;
  String? userId;
  List<TenentList>? tenentList;
  List<PodiumList>? podiumList;

  FlatStatusResponse({
    this.errorCode,
    this.msg,
    this.flatAvailableList,
    this.userId,
    this.tenentList,
    this.podiumList,
  });

  factory FlatStatusResponse.fromJson(Map<String, dynamic> json) =>
      FlatStatusResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        flatAvailableList: json["flat_available_list"] == null
            ? []
            : List<FlatAvailableList>.from(json["flat_available_list"]
                .map((x) => FlatAvailableList.fromJson(x))),
        userId: json["user_id"],
        tenentList: json["tenent_list"] == null
            ? []
            : List<TenentList>.from(
                json["tenent_list"]!.map((x) => TenentList.fromJson(x))),
        podiumList: json["podium_list"] == null
            ? []
            : List<PodiumList>.from(
                json["podium_list"]!.map((x) => PodiumList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "flat_available_list": flatAvailableList == null
            ? []
            : List<dynamic>.from(flatAvailableList!.map((x) => x.toJson())),
        "user_id": userId,
        "tenent_list": tenentList == null
            ? []
            : List<dynamic>.from(tenentList!.map((x) => x.toJson())),
        "podium_list": podiumList == null
            ? []
            : List<dynamic>.from(podiumList!.map((x) => x.toJson())),
      };
}

class FlatAvailableList {
  FloorDetails? floorDetails;

  FlatAvailableList({
    this.floorDetails,
  });

  factory FlatAvailableList.fromJson(Map<String, dynamic> json) =>
      FlatAvailableList(
        floorDetails: json["floor_details"] == null
            ? null
            : FloorDetails.fromJson(json["floor_details"]),
      );

  Map<String, dynamic> toJson() => {
        "floor_details": floorDetails?.toJson(),
      };
}

class FloorDetails {
  String? mstInventryFloorId;
  String? floorName;
  String? masonryIdFk;
  List<FlatDetail>? flatDetails;

  FloorDetails({
    this.mstInventryFloorId,
    this.floorName,
    this.masonryIdFk,
    this.flatDetails,
  });

  factory FloorDetails.fromJson(Map<String, dynamic> json) => FloorDetails(
        mstInventryFloorId: json["mst_inventry_floor_id"],
        floorName: json["floor_name"],
        masonryIdFk: json["masonry_id_fk"],
        flatDetails: json["flat_details"] == null
            ? []
            : List<FlatDetail>.from(
                json["flat_details"]!.map((x) => FlatDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "mst_inventry_floor_id": mstInventryFloorId,
        "floor_name": floorName,
        "masonry_id_fk": masonryIdFk,
        "flat_details": flatDetails == null
            ? []
            : List<dynamic>.from(flatDetails!.map((x) => x.toJson())),
      };
}

class FlatDetail {
  bool? isSelected;
  String? floorTypeId;
  String? inventyParkingNumber;
  String? flatName;
  String? flatId;
  String? inventryFlatName;
  String? flatArea;
  String? inventryFlatType;
  String? floorNumber;
  String? masnoryName;
  String? availablePark;
  String? isParking;
  String? registrationDoc;
  String? flatType;
  String? tenentId;
  String? tenentPaymentFlag;
  String? flatBuyerId;

  String? availableStatus;
  List<FlatBuyerRequest>? flatBuyerDetails;
  List<List<CustomCharge>>? customCharges;

  FlatDetail({
    this.floorTypeId,
    this.inventyParkingNumber,
    this.flatName,
    this.flatId,
    this.inventryFlatName,
    this.flatArea,
    this.inventryFlatType,
    this.floorNumber,
    this.masnoryName,
    this.availablePark,
    this.isParking,
    this.registrationDoc,
    this.flatType,
    this.tenentId,
    this.availableStatus,
    this.flatBuyerDetails,
    this.customCharges,
    this.isSelected = false,
    this.tenentPaymentFlag,
    this.flatBuyerId,
  });

  factory FlatDetail.fromJson(Map<String, dynamic> json) => FlatDetail(
        floorTypeId: json["floor_type_id"],
        inventyParkingNumber: json["inventy_parking_number"],
        flatName: json["flat_name"],
        flatId: json["flat_id"],
        inventryFlatName: json["inventry_flat_name"],
        flatArea: json["flat_area"],
        inventryFlatType: json["inventry_flat_type"],
        floorNumber: json["floor_number"],
        masnoryName: json["masnory_name"],
        availablePark: json["available_park"],
        isParking: json["is_parking"],
        registrationDoc: json["registration_doc"],
        flatType: json["flat_type"],
        tenentId: json["tenent_id"],
        availableStatus: json["available_status"],
        flatBuyerDetails: json["flat_buyer_details"] == null
            ? []
            : List<FlatBuyerRequest>.from(json["flat_buyer_details"]
                .map((x) => FlatBuyerRequest.fromJson(x))),
        customCharges: json["custom_charges"] == null
            ? []
            : List<List<CustomCharge>>.from(json["custom_charges"]!.map((x) =>
                List<CustomCharge>.from(
                    x.map((x) => CustomCharge.fromJson(x))))),
        tenentPaymentFlag: json["tenent_payment_flag"],
        flatBuyerId: json["flat_buyer_id"],
      );

  Map<String, dynamic> toJson() => {
        "floor_type_id": floorTypeId,
        "inventy_parking_number": inventyParkingNumber,
        "flat_name": flatName,
        "flat_id": flatId,
        "inventry_flat_name": inventryFlatName,
        "flat_area": flatArea,
        "inventry_flat_type": inventryFlatType,
        "floor_number": floorNumber,
        "masnory_name": masnoryName,
        "available_park": availablePark,
        "is_parking": isParking,
        "registration_doc": registrationDoc,
        "flat_type": flatType,
        "tenent_id": tenentId,
        "available_status": availableStatus,
        "flat_buyer_details": flatBuyerDetails == null
            ? []
            : List<dynamic>.from(flatBuyerDetails!.map((x) => x.toJson())),
        "custom_charges": customCharges == null
            ? []
            : List<dynamic>.from(customCharges!
                .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        "tenent_payment_flag": tenentPaymentFlag,
        "flat_buyer_id": flatBuyerId,
      };
}

// class CustomCharge {
//   String? calculated;
//   String? chargesId;
//   String? collected;
//   String? id;
//   String? value;
//   String? totalValue;
//   Name? name;
//   String? chargesGst;
//   String? status;
//   Unit? unit;

//   CustomCharge({
//     this.calculated,
//     this.chargesId,
//     this.collected,
//     this.id,
//     this.value,
//     this.totalValue,
//     this.name,
//     this.chargesGst,
//     this.status,
//     this.unit,
//   });

//   factory CustomCharge.fromJson(Map<String, dynamic> json) => CustomCharge(
//         calculated: json["calculated"],
//         chargesId: json["charges_id"],
//         collected: json["collected"],
//         id: json["id"],
//         value: json["value"],
//         totalValue: json["total_value"],
//         name: nameValues.map[json["name"]],
//         chargesGst: json["charges_gst"],
//         status: json["status"],
//         unit: unitValues.map[json["unit"]],
//       );

//   Map<String, dynamic> toJson() => {
//         "calculated": calculated,
//         "charges_id": chargesId,
//         "collected": collected,
//         "id": id,
//         "value": value,
//         "total_value": totalValue,
//         "name": nameValues.reverse[name],
//         "charges_gst": chargesGst,
//         "status": status,
//         "unit": unitValues.reverse[unit],
//       };
// }

enum Name {
  ADVANCE_MAINTENANCE,
  ADVANCE_PAYMENT,
  DEVELOPMENT_CHARGES,
  LEGAL,
  SECURITY,
  STAMP_DUTY
}

final nameValues = EnumValues({
  "Advance Maintenance": Name.ADVANCE_MAINTENANCE,
  "Advance payment": Name.ADVANCE_PAYMENT,
  "Development Charges": Name.DEVELOPMENT_CHARGES,
  "Legal": Name.LEGAL,
  "Security": Name.SECURITY,
  "Stamp Duty": Name.STAMP_DUTY
});

// enum Unit { LUMSUM }

// final unitValues = EnumValues({"Lumsum": Unit.LUMSUM});

enum AadharNo { ADHARCARD123, EMPTY, THE_637809039567 }

final aadharNoValues = EnumValues({
  "ADHARCARD123": AadharNo.ADHARCARD123,
  "": AadharNo.EMPTY,
  "637809039567": AadharNo.THE_637809039567
});

enum FlatAadharDoc { EMPTY, THE_16857082566969_PNG }

final flatAadharDocValues = EnumValues({
  "": FlatAadharDoc.EMPTY,
  "16857082566969.png": FlatAadharDoc.THE_16857082566969_PNG
});

enum FlatBuyerAddress1 {
  BHOIR_WADA_DOMBIVALI_EAST,
  EMPTY,
  TEST_ADDRESS_1_MUMBAI
}

final flatBuyerAddress1Values = EnumValues({
  "Bhoir wada, Dombivali - East": FlatBuyerAddress1.BHOIR_WADA_DOMBIVALI_EAST,
  "": FlatBuyerAddress1.EMPTY,
  "Test Address 1 Mumbai": FlatBuyerAddress1.TEST_ADDRESS_1_MUMBAI
});

enum FlatBuyerName1 { EMPTY, VAIBHAV_S_BROTHER }

final flatBuyerName1Values = EnumValues({
  " ": FlatBuyerName1.EMPTY,
  " Vaibhav's Brother": FlatBuyerName1.VAIBHAV_S_BROTHER
});

enum FlatPanDoc { EMPTY, THE_16857082564395_PNG }

final flatPanDocValues = EnumValues({
  "": FlatPanDoc.EMPTY,
  "16857082564395.png": FlatPanDoc.THE_16857082564395_PNG
});

enum PanNo { AAS81_KHA78, EMPTY, PANCARD123 }

final panNoValues = EnumValues({
  "AAS81KHA78": PanNo.AAS81_KHA78,
  "": PanNo.EMPTY,
  "PANCARD123": PanNo.PANCARD123
});

enum RequestCancelationRes { EMPTY, HGHGHGG, TEST }

final requestCancelationResValues = EnumValues({
  "": RequestCancelationRes.EMPTY,
  "hghghgg": RequestCancelationRes.HGHGHGG,
  "test": RequestCancelationRes.TEST
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

class TenentList {
  String? name;
  String? id;
  bool? isSelected = false;
  String? viewFlag;

  TenentList({
    this.name,
    this.id,
    this.isSelected = false,
    this.viewFlag,
  });

  factory TenentList.fromJson(Map<String, dynamic> json) => TenentList(
        name: json["name"],
        id: json["id"],
        isSelected: false,
        viewFlag: json["view_flag"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "view_flag": viewFlag,
      };
}
