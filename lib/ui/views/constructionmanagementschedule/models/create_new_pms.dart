// To parse this JSON data, do
//
//     final createNewPms = createNewPmsFromJson(jsonString);

import 'dart:convert';

CreateNewPms createNewPmsFromJson(String str) =>
    CreateNewPms.fromJson(json.decode(str));

String createNewPmsToJson(CreateNewPms data) => json.encode(data.toJson());

class CreateNewPms {
  CreateNewPmsResponse? response;

  CreateNewPms({
    this.response,
  });

  factory CreateNewPms.fromJson(Map<String, dynamic> json) => CreateNewPms(
        response: json["Response"] == null
            ? null
            : CreateNewPmsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class CreateNewPmsResponse {
  String? errorCode;
  String? msg;

  CreateNewPmsResponse({
    this.errorCode,
    this.msg,
  });

  factory CreateNewPmsResponse.fromJson(Map<String, dynamic> json) =>
      CreateNewPmsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
