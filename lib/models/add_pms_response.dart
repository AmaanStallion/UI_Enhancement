// To parse this JSON data, do
//
//     final addPmsResponse = addPmsResponseFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/ui/views/constructionmanagementschedule/models/ws_get_pms_structure.dart';

AddPmsResponse addPmsResponseFromJson(String str) =>
    AddPmsResponse.fromJson(json.decode(str));

String addPmsResponseToJson(AddPmsResponse data) => json.encode(data.toJson());

class AddPmsResponse {
  ResponseAddPmsResponse? response;

  AddPmsResponse({
    this.response,
  });

  factory AddPmsResponse.fromJson(Map<String, dynamic> json) => AddPmsResponse(
        response: json["Response"] == null
            ? null
            : ResponseAddPmsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseAddPmsResponse {
  String? errorCode;
  DateTime? pmsStartDate;
  DateTime? pmsEndDate;
  String? msg;
  List<PmsStructure>? changeData;
  List<PmsStructure>? addedPmsList;

  ResponseAddPmsResponse({
    this.errorCode,
    this.msg,
    this.changeData,
    this.addedPmsList,
    this.pmsStartDate,
    this.pmsEndDate,
  });

  factory ResponseAddPmsResponse.fromJson(Map<String, dynamic> json) =>
      ResponseAddPmsResponse(
        errorCode: json["error_code"],
        pmsStartDate: json["pms_start_date"] == null
            ? null
            : DateTime.parse(json["pms_start_date"]),
        pmsEndDate: json["pms_end_date"] == null
            ? null
            : DateTime.parse(json["pms_end_date"]),
        msg: json["msg"],
        changeData: json["change_data"] == null
            ? []
            : List<PmsStructure>.from(
                json["change_data"]!.map((x) => PmsStructure.fromJson(x))),
        addedPmsList: json["added_pms_list"] == null
            ? []
            : List<PmsStructure>.from(
                json["added_pms_list"]!.map((x) => PmsStructure.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "pms_start_date":
            "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
        "pms_end_date":
            "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
        "msg": msg,
        "change_data": changeData == null
            ? []
            : List<dynamic>.from(changeData!.map((x) => x.toJson())),
        "added_pms_list": addedPmsList == null
            ? []
            : List<dynamic>.from(addedPmsList!.map((x) => x.toJson())),
      };
}
