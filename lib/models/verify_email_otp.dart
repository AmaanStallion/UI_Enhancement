// To parse this JSON data, do
//
//     final verifyEmailOtp = verifyEmailOtpFromJson(jsonString);

import 'dart:convert';

VerifyEmailOtp verifyEmailOtpFromJson(String str) =>
    VerifyEmailOtp.fromJson(json.decode(str));

String verifyEmailOtpToJson(VerifyEmailOtp data) => json.encode(data.toJson());

class VerifyEmailOtp {
  VerifyEmailOtpResponse? response;

  VerifyEmailOtp({
    this.response,
  });

  factory VerifyEmailOtp.fromJson(Map<String, dynamic> json) => VerifyEmailOtp(
        response: json["Response"] == null
            ? null
            : VerifyEmailOtpResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class VerifyEmailOtpResponse {
  String? errorCode;
  String? msg;

  VerifyEmailOtpResponse({
    this.errorCode,
    this.msg,
  });

  factory VerifyEmailOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyEmailOtpResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
