// To parse this JSON data, do
//
//     final getAllMembersByProject = getAllMembersByProjectFromJson(jsonString);

import 'dart:convert';

GetAllMembersByProject getAllMembersByProjectFromJson(String str) =>
    GetAllMembersByProject.fromJson(json.decode(str));

String getAllMembersByProjectToJson(GetAllMembersByProject data) =>
    json.encode(data.toJson());

class GetAllMembersByProject {
  GetAllMembersByProjectResponse? response;

  GetAllMembersByProject({
    this.response,
  });

  factory GetAllMembersByProject.fromJson(Map<String, dynamic> json) =>
      GetAllMembersByProject(
        response: json["Response"] == null
            ? null
            : GetAllMembersByProjectResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetAllMembersByProjectResponse {
  String? errorCode;
  String? msg;
  List<MemberDetail>? memberDetails;

  GetAllMembersByProjectResponse({
    this.errorCode,
    this.msg,
    this.memberDetails,
  });

  factory GetAllMembersByProjectResponse.fromJson(Map<String, dynamic> json) =>
      GetAllMembersByProjectResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        memberDetails: json["member_details"] == null
            ? []
            : List<MemberDetail>.from(
                json["member_details"]!.map((x) => MemberDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "member_details": memberDetails == null
            ? []
            : List<dynamic>.from(memberDetails!.map((x) => x.toJson())),
      };
}

// class MemberDetail {
//   String? memberName;
//   String? contactNubmer;
//   String? memberId;
//   String? designation;
//   String? profileImg;
//   String? companyId;
//   String? compayName;
//   String? typeName;
//   bool? isSelected;

//   MemberDetail({
//     this.memberName,
//     this.contactNubmer,
//     this.memberId,
//     this.designation,
//     this.profileImg,
//     this.companyId,
//     this.compayName,
//     this.typeName,
//     this.isSelected,
//   });

//   factory MemberDetail.fromJson(Map<String, dynamic> json) => MemberDetail(
//         memberName: json["member_name"],
//         contactNubmer: json["contact_nubmer"],
//         memberId: json["member_id"],
//         designation: json["Designation"],
//         profileImg: json["profile_img"],
//         companyId: json["company_id"],
//         compayName: json["compay_name"],
//         typeName: json["type_name"],
//       );

//   Map<String, dynamic> toJson() => {
//         "member_name": memberName,
//         "contact_nubmer": contactNubmer,
//         "member_id": memberId,
//         "Designation": designation,
//         "profile_img": profileImg,
//         "company_id": companyId,
//         "compay_name": compayName,
//         "type_name": typeName,
//         "isSelected": false,
//       };
// }

class MemberDetail {
  String? memberName;
  String? contactNubmer;
  String? memberId;
  String? designation;
  String? profileImg;
  String? companyId;
  String? compayName;
  String? typeName;
  bool? isSelected;

  MemberDetail({
    this.memberName,
    this.contactNubmer,
    this.memberId,
    this.designation,
    this.profileImg,
    this.companyId,
    this.compayName,
    this.typeName,
    this.isSelected,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json) {
    return MemberDetail(
      memberName: json["name"]?.toString() ?? json["member_name"]?.toString(),
      contactNubmer: json["mobile_no"]?.toString() ?? json["contact_number"]?.toString() ?? json["contact_nubmer"]?.toString() ?? json["email"]?.toString(),
      memberId: json["id"]?.toString() ?? json["member_id"]?.toString(),
      designation: json["role"]?.toString() ?? json["Designation"]?.toString(),
      profileImg: json["profile_img"]?.toString(),
      companyId: json["company_id"]?.toString(),
      compayName: json["compay_name"]?.toString(),
      typeName: json["type_name"]?.toString(),
      isSelected: false,
    );
  }

  factory MemberDetail.from(MemberDetail other) {
    return MemberDetail(
      memberName: other.memberName,
      contactNubmer: other.contactNubmer,
      memberId: other.memberId,
      designation: other.designation,
      profileImg: other.profileImg,
      companyId: other.companyId,
      compayName: other.compayName,
      typeName: other.typeName,
      isSelected: other.isSelected ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "member_name": memberName,
        "contact_nubmer": contactNubmer,
        "member_id": memberId,
        "Designation": designation,
        "profile_img": profileImg,
        "company_id": companyId,
        "compay_name": compayName,
        "type_name": typeName,
        "isSelected": isSelected ?? false,
      };
}
