// To parse this JSON data, do
//
//     final rccBookingDetails = rccBookingDetailsFromJson(jsonString);

import 'dart:convert';

RccBookingDetails rccBookingDetailsFromJson(String str) =>
    RccBookingDetails.fromJson(json.decode(str));

String rccBookingDetailsToJson(RccBookingDetails data) =>
    json.encode(data.toJson());

class RccBookingDetails {
  ResponseRccBookingDetails? response;

  RccBookingDetails({
    this.response,
  });

  factory RccBookingDetails.fromJson(Map<String, dynamic> json) =>
      RccBookingDetails(
        response: json["Response"] == null
            ? null
            : ResponseRccBookingDetails.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseRccBookingDetails {
  String? errorCode;
  String? msg;
  List<BookingDetail>? bookingDetails;

  ResponseRccBookingDetails({
    this.errorCode,
    this.msg,
    this.bookingDetails,
  });

  factory ResponseRccBookingDetails.fromJson(Map<String, dynamic> json) =>
      ResponseRccBookingDetails(
        errorCode: json["error_code"],
        msg: json["msg"],
        bookingDetails: json["booking_details"] == null
            ? []
            : List<BookingDetail>.from(
                json["booking_details"]!.map((x) => BookingDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "booking_details": bookingDetails == null
            ? []
            : List<dynamic>.from(bookingDetails!.map((x) => x.toJson())),
      };
}

class BookingDetail {
  String? gradeId;
  String? name;
  String? unit;
  String? estQunatity;
  String? amount;
  String? orderQuantity;
  String? orderAmount;
  String? gradePercentage;
  List<GradeType>? gradeType;

  BookingDetail({
    this.gradeId,
    this.name,
    this.unit,
    this.estQunatity,
    this.amount,
    this.orderQuantity,
    this.orderAmount,
    this.gradePercentage,
    this.gradeType,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) => BookingDetail(
        gradeId: json["grade_id"],
        name: json["name"],
        unit: json["unit"],
        estQunatity: json["est_qunatity"],
        amount: json["amount"],
        orderQuantity: json["order_quantity"],
        orderAmount: json["order_amount"],
        gradePercentage: json["grade_percentage"],
        gradeType: json["grade_type"] == null
            ? []
            : List<GradeType>.from(
                json["grade_type"]!.map((x) => GradeType.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "grade_id": gradeId,
        "name": name,
        "unit": unit,
        "est_qunatity": estQunatity,
        "amount": amount,
        "order_quantity": orderQuantity,
        "order_amount": orderAmount,
        "grade_percentage": gradePercentage,
        "grade_type": gradeType == null
            ? []
            : List<dynamic>.from(gradeType!.map((x) => x.toJson())),
      };
}

class GradeType {
  String? gradeTypeId;
  String? gradeTypeName;

  GradeType({
    this.gradeTypeId,
    this.gradeTypeName,
  });

  factory GradeType.fromJson(Map<String, dynamic> json) => GradeType(
        gradeTypeId: json["grade_type_id"],
        gradeTypeName: json["grade_type_name"],
      );

  Map<String, dynamic> toJson() => {
        "grade_type_id": gradeTypeId,
        "grade_type_name": gradeTypeName,
      };
}
