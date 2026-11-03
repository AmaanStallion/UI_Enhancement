// To parse this JSON data, do
//
//     final getGrnList = getGrnListFromJson(jsonString);

import 'dart:convert';

GetGrnList getGrnListFromJson(String str) =>
    GetGrnList.fromJson(json.decode(str));

String getGrnListToJson(GetGrnList data) => json.encode(data.toJson());

class GetGrnList {
  GetGrnList({
    this.response,
  });

  ResponseGetGrnList? response;

  factory GetGrnList.fromJson(Map<String, dynamic> json) => GetGrnList(
        response: json["Response"] == null
            ? null
            : ResponseGetGrnList.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetGrnList {
  ResponseGetGrnList({
    this.errorCode,
    this.msg,
    this.grnDetails,
  });

  String? errorCode;
  String? msg;
  List<GrnDetail>? grnDetails;

  factory ResponseGetGrnList.fromJson(Map<String, dynamic> json) =>
      ResponseGetGrnList(
        errorCode: json["error_code"],
        msg: json["msg"],
        grnDetails: json["grn_details"] == null
            ? []
            : List<GrnDetail>.from(
                json["grn_details"]!.map((x) => GrnDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "grn_details": grnDetails == null
            ? []
            : List<dynamic>.from(grnDetails!.map((x) => x.toJson())),
      };
}

class GrnDetail {
  GrnDetail({
    this.grnFileName,
    this.grnSrNo,
    this.grnCreatedDate,
    this.grnId,
    this.gradeIdFk,
    this.bookingType,
    this.gradeName,
    this.challan_no,
  });

  String? grnFileName;
  String? grnSrNo;
  DateTime? grnCreatedDate;
  String? grnId;
  String? gradeIdFk;
  String? bookingType;
  String? gradeName;
  String? challan_no;

  factory GrnDetail.fromJson(Map<String, dynamic> json) => GrnDetail(
        grnFileName: json["grn_file_name"],
    challan_no: json["challan_no"] ?? "",
        grnSrNo: json["grn_sr_no"],
        grnCreatedDate: json["grn_created_date"] == null
            ? null
            : DateTime.parse(json["grn_created_date"]),
        grnId: json["grn_id"],
        gradeIdFk: json["grade_id_fk"],
        bookingType: json["booking_type"],
        gradeName: json["grade_name"],
      );

  Map<String, dynamic> toJson() => {
        "grn_file_name": grnFileName,
        "grn_sr_no": grnSrNo,
    "challan_no": challan_no,
        "grn_created_date": grnCreatedDate?.toIso8601String(),
        "grn_id": grnId,
        "grade_id_fk": gradeIdFk,
        "booking_type": bookingType,
        "grade_name": gradeName,
      };
}
