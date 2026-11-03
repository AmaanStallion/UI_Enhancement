// To parse this JSON data, do
//
//     final sopUserListModal = sopUserListModalFromJson(jsonString);

import 'dart:convert';

SopUserListModal sopUserListModalFromJson(String str) =>
    SopUserListModal.fromJson(json.decode(str));

String sopUserListModalToJson(SopUserListModal data) =>
    json.encode(data.toJson());

class SopUserListModal {
  SopUserListModalResponse? response;

  SopUserListModal({
    this.response,
  });

  factory SopUserListModal.fromJson(Map<String, dynamic> json) =>
      SopUserListModal(
        response: json["Response"] == null
            ? null
            : SopUserListModalResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class SopUserListModalResponse {
  String? errorCode;
  String? msg;
  List<SopListDetail>? sopListDetails;

  SopUserListModalResponse({
    this.errorCode,
    this.msg,
    this.sopListDetails,
  });

  factory SopUserListModalResponse.fromJson(Map<String, dynamic> json) =>
      SopUserListModalResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        sopListDetails: json["sop_list_details"] == null
            ? []
            : List<SopListDetail>.from(json["sop_list_details"]!
                .map((x) => SopListDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "sop_list_details": sopListDetails == null
            ? []
            : List<dynamic>.from(sopListDetails!.map((x) => x.toJson())),
      };
}

class SopListDetail {
  String? id;
  String? sopId;
  String? userIdFk;
  String? userName;
  String? sopFileName;
  String? filePath;
  String? createdAt;

  SopListDetail({
    this.id,
    this.sopId,
    this.userIdFk,
    this.userName,
    this.sopFileName,
    this.filePath,
    this.createdAt,
  });

  factory SopListDetail.fromJson(Map<String, dynamic> json) => SopListDetail(
        id: json["id"],
        sopId: json["sop_id"],
        userIdFk: json["user_id_fk"],
        userName: json["user_name"],
        sopFileName: json["sop_file_name"],
        filePath: json["file_path"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sop_id": sopId,
        "user_id_fk": userIdFk,
        "user_name": userName,
        "sop_file_name": sopFileName,
        "file_path": filePath,
        "created_at": createdAt,
      };
}
