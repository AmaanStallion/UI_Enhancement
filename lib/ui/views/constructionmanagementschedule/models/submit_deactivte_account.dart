// To parse this JSON data, do
//
//     final submitDeactivateAccount = submitDeactivateAccountFromJson(jsonString);

import 'dart:convert';

SubmitDeactivateAccount submitDeactivateAccountFromJson(String str) =>
    SubmitDeactivateAccount.fromJson(json.decode(str));

String submitDeactivateAccountToJson(SubmitDeactivateAccount data) =>
    json.encode(data.toJson());

class SubmitDeactivateAccount {
  SubmitDeactivateAccount({
    this.response,
  });

  ResponseSubmitDeactivateAccount? response;

  factory SubmitDeactivateAccount.fromJson(Map<String, dynamic> json) =>
      SubmitDeactivateAccount(
        response: ResponseSubmitDeactivateAccount.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseSubmitDeactivateAccount {
  ResponseSubmitDeactivateAccount({
    this.errorCode,
    this.status,
    this.msg,
    this.requestId,
    this.userType,
  });

  String? errorCode;
  String? status;
  String? msg;
  String? requestId;
  String? userType;

  factory ResponseSubmitDeactivateAccount.fromJson(Map<String, dynamic> json) =>
      ResponseSubmitDeactivateAccount(
        errorCode: json["error_code"],
        status: json["status"],
        msg: json["msg"],
        requestId: json["request_id"],
        userType: json["user_type"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "status": status,
        "msg": msg,
        "request_id": requestId,
        "user_type": userType,
      };
}
