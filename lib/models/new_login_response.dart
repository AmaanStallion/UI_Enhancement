import 'dart:convert';

NewLoginResponse newLoginResponseFromJson(String str) =>
    NewLoginResponse.fromJson(json.decode(str));

String newLoginResponseToJson(NewLoginResponse data) =>
    json.encode(data.toJson());

class NewLoginResponse {
  bool? success;
  String? message;
  NewLoginData? data;

  NewLoginResponse({
    this.success,
    this.message,
    this.data,
  });

  factory NewLoginResponse.fromJson(Map<String, dynamic> json) =>
      NewLoginResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : NewLoginData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class NewLoginData {
  String? token;
  NewUser? user;

  NewLoginData({
    this.token,
    this.user,
  });

  factory NewLoginData.fromJson(Map<String, dynamic> json) => NewLoginData(
        token: json["token"],
        user: json["user"] == null ? null : NewUser.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "user": user?.toJson(),
      };
}

class NewUser {
  String? id;
  String? name;
  String? email;
  String? role;
  List<dynamic>? projectIds;

  NewUser({
    this.id,
    this.name,
    this.email,
    this.role,
    this.projectIds,
  });

  factory NewUser.fromJson(Map<String, dynamic> json) => NewUser(
        id: json["id"]?.toString(),
        name: json["name"],
        email: json["email"],
        role: json["role"],
        projectIds: json["project_ids"] == null
            ? []
            : List<dynamic>.from(json["project_ids"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "role": role,
        "project_ids": projectIds == null
            ? []
            : List<dynamic>.from(projectIds!.map((x) => x)),
      };
}
