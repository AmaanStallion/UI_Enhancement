// To parse this JSON data, do
//
//     final trackAssign = trackAssignFromJson(jsonString);

import 'dart:convert';

TrackAssign trackAssignFromJson(String str) =>
    TrackAssign.fromJson(json.decode(str));

String trackAssignToJson(TrackAssign data) => json.encode(data.toJson());

class TrackAssign {
  TrackAssignResponse? response;

  TrackAssign({
    this.response,
  });

  factory TrackAssign.fromJson(Map<String, dynamic> json) => TrackAssign(
        response: json["Response"] == null
            ? null
            : TrackAssignResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class TrackAssignResponse {
  String? errorCode;
  String? msg;
  List<TrackList>? trackList;

  TrackAssignResponse({
    this.errorCode,
    this.msg,
    this.trackList,
  });

  factory TrackAssignResponse.fromJson(Map<String, dynamic> json) =>
      TrackAssignResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        trackList: json["track_list"] == null
            ? []
            : List<TrackList>.from(
                json["track_list"]!.map((x) => TrackList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "track_list": trackList == null
            ? []
            : List<dynamic>.from(trackList!.map((x) => x.toJson())),
      };
}

class TrackList {
  String? transEmpName;
  String? transEmpId;
  String? totalCount;
  String? pendingCount;

  TrackList({
    this.transEmpName,
    this.transEmpId,
    this.totalCount,
    this.pendingCount,
  });

  factory TrackList.fromJson(Map<String, dynamic> json) => TrackList(
        transEmpName: json["trans_emp_name"],
        transEmpId: json["trans_emp_id"],
        totalCount: json["total_count"],
        pendingCount: json["pending_count"],
      );

  Map<String, dynamic> toJson() => {
        "trans_emp_name": transEmpName,
        "trans_emp_id": transEmpId,
        "total_count": totalCount,
        "pending_count": pendingCount,
      };
}
