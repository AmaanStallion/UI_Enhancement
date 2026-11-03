import 'dart:convert';

verifyotp verifyotpFromJson(String str) => verifyotp.fromJson(json.decode(str));

String verifyotpToJson(verifyotp data) => json.encode(data.toJson());

class verifyotp {
  verifyotpResponse? response;

  verifyotp({this.response});

  verifyotp.fromJson(Map<String, dynamic> json) {
    response = json['Response'] != null
        ? verifyotpResponse.fromJson(json['Response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (response != null) {
      data['Response'] = response?.toJson();
    }
    return data;
  }
}

class verifyotpResponse {
  String? errorCode;
  String? msg;
  List<UserDetails>? userDetails;
  String? userType;
  List<UserDetails>? developerDetails;

  verifyotpResponse({
    this.errorCode,
    this.msg,
    this.userDetails,
    this.userType,
    this.developerDetails,
  });

  factory verifyotpResponse.fromJson(Map<String, dynamic> json) =>
      verifyotpResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        userDetails: json["user_details"] == null
            ? []
            : List<UserDetails>.from(
                json["user_details"].map((x) => UserDetails.fromJson(x))),
        userType: json["user_type"],
        developerDetails: json["developer_details"] == null
            ? []
            : List<UserDetails>.from(
                json["developer_details"].map((x) => UserDetails.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "user_details": userDetails == null
            ? []
            : List<dynamic>.from(userDetails!.map((x) => x.toJson())),
        "user_type": userType,
        "developer_details": developerDetails == null
            ? []
            : List<dynamic>.from(developerDetails!.map((x) => x.toJson())),
      };
}

class UserDetails {
  String? userId;
  String? userName;
  String? companyId;
  String? companyName;
  String? mobileNo;
  String? userProfile;
  String? desingnation;
  String? profileImg;
  String? userType;

  UserDetails({
    this.userId,
    this.userName,
    this.companyId,
    this.companyName,
    this.mobileNo,
    this.userProfile,
    this.desingnation,
    this.profileImg,
    this.userType,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        userId: json["user_id"],
        userName: json["user_name"],
        companyId: json["company_id"],
        companyName: json["company_name"],
        mobileNo: json["mobile_no"],
        userProfile: json["user_profile"],
        desingnation: json["desingnation"],
        profileImg: json["profile_img"],
        userType: json["user_type"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_name": userName,
        "company_id": companyId,
        "company_name": companyName,
        "mobile_no": mobileNo,
        "user_profile": userProfile,
        "desingnation": desingnation,
        "profile_img": profileImg,
        "user_type": userType,
      };
}
