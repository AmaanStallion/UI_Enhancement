// To parse this JSON data, do
//
//     final messageSuccess = messageSuccessFromJson(jsonString);

import 'dart:convert';

MessageSuccess messageSuccessFromJson(String str) =>
    MessageSuccess.fromJson(json.decode(str));

String messageSuccessToJson(MessageSuccess data) => json.encode(data.toJson());

class MessageSuccess {
  MessageSuccess({
    this.response,
  });

  ResponseMessageSuccess? response;

  factory MessageSuccess.fromJson(Map<String, dynamic> json) => MessageSuccess(
        response: ResponseMessageSuccess.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response!.toJson(),
      };
}

class ResponseMessageSuccess {
  ResponseMessageSuccess({
    this.errorCode,
    this.msg,
  });

  String? errorCode;
  String? msg;

  factory ResponseMessageSuccess.fromJson(Map<String, dynamic> json) =>
      ResponseMessageSuccess(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
