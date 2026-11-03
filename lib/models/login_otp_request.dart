
import 'dart:convert';

LoginOtpRequest loginModelFromJson(String str) => LoginOtpRequest.fromJson(json.decode(str));

String loginModelToJson(LoginOtpRequest data) => json.encode(data.toJson());


class LoginOtpRequest {
  Response? response;

  LoginOtpRequest({this.response});

  LoginOtpRequest.fromJson(Map<String, dynamic> json) {
    response = json['Response'] != null
        ? new Response.fromJson(json['Response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.response != null) {
      data['Response'] = this.response?.toJson();
    }
    return data;
  }
}

class Response {
  String? errorCode;
  String? status;
  String? msg;
  String? requestId;
  String? userType;

  Response(
      {this.errorCode, this.status, this.msg, this.requestId, this.userType});

  Response.fromJson(Map<String, dynamic> json) {
    errorCode = json['error_code'];
    status = json['status'];
    msg = json['msg'];
    requestId = json['request_id'];
    userType = json['user_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error_code'] = this.errorCode;
    data['status'] = this.status;
    data['msg'] = this.msg;
    data['request_id'] = this.requestId;
    data['user_type'] = this.userType;
    return data;
  }
}