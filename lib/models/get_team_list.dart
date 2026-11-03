// To parse this JSON data, do
//
//     final getTeamList = getTeamListFromJson(jsonString);

import 'dart:convert';

GetTeamList? getTeamListFromJson(String str) =>
    GetTeamList.fromJson(json.decode(str));

String getTeamListToJson(GetTeamList? data) => json.encode(data!.toJson());

class GetTeamList {
  GetTeamList({
    this.response,
  });

  ResponseGetTeamList? response;

  factory GetTeamList.fromJson(Map<String, dynamic> json) => GetTeamList(
        response: ResponseGetTeamList.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response!.toJson(),
      };
}

class ResponseGetTeamList {
  ResponseGetTeamList({
    this.errorCode,
    this.msg,
    this.temaDetails,
  });

  String? errorCode;
  String? msg;
  List<TemaDetail?>? temaDetails;

  factory ResponseGetTeamList.fromJson(Map<String, dynamic> json) =>
      ResponseGetTeamList(
        errorCode: json["error_code"],
        msg: json["msg"],
        temaDetails: List<TemaDetail?>.from(
            json["Tema_Details"]!.map((x) => TemaDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "Tema_Details":
            List<dynamic>.from(temaDetails!.map((x) => x!.toJson())),
      };
}

class TemaDetail {
  TemaDetail({
    this.companyId,
    this.compayName,
    this.typeName,
    this.memberDetails,
  });

  String? companyId;
  String? compayName;
  String? typeName;
  List<MemberDetail?>? memberDetails;

  factory TemaDetail.fromJson(Map<String, dynamic> json) => TemaDetail(
        companyId: json["company_id"],
        compayName: json["compay_name"],
        typeName: json["type_name"],
        memberDetails: List<MemberDetail?>.from(
            json["member_details"]!.map((x) => MemberDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "compay_name": compayName,
        "type_name": typeName,
        "member_details":
            List<dynamic>.from(memberDetails!.map((x) => x!.toJson())),
      };
}

class MemberDetail {
  MemberDetail({
    this.memberName,
    this.contactNubmer,
    this.memberId,
    this.designation,
    this.profileImg,
  });

  String? memberName;
  String? contactNubmer;
  String? memberId;
  String? designation;
  String? profileImg;

  factory MemberDetail.fromJson(Map<String, dynamic> json) => MemberDetail(
        memberName: json["member_name"],
        contactNubmer: json["contact_nubmer"],
        memberId: json["member_id"],
        designation: json["Designation"],
        profileImg: json["profile_img"],
      );

  Map<String, dynamic> toJson() => {
        "member_name": memberName,
        "contact_nubmer": contactNubmer,
        "member_id": memberId,
        "Designation": designation,
        "profile_img": profileImg,
      };
}
