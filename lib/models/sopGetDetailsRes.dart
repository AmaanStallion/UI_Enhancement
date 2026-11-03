// To parse this JSON data, do
//
//     final sopGetDetails = sopGetDetailsFromJson(jsonString);

import 'dart:convert';

SopGetDetails sopGetDetailsFromJson(String str) => SopGetDetails.fromJson(json.decode(str));

String sopGetDetailsToJson(SopGetDetails data) => json.encode(data.toJson());

class SopGetDetails {
    Response? response;

    SopGetDetails({
        this.response,
    });

    factory SopGetDetails.fromJson(Map<String, dynamic> json) => SopGetDetails(
        response: json["Response"] == null ? null : Response.fromJson(json["Response"]),
    );

    Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
    };
}

class Response {
    String? errorCode;
    String? msg;
    String? assignTrackFlag;
    List<AssingToList>? assingToList;
    List<dynamic>? sopDetailsStructure;

    Response({
        this.errorCode,
        this.msg,
        this.assignTrackFlag,
        this.assingToList,
        this.sopDetailsStructure,
    });

    factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        assignTrackFlag: json["assign_track_flag"],
        assingToList: json["assing_to_list"] == null ? [] : List<AssingToList>.from(json["assing_to_list"]!.map((x) => AssingToList.fromJson(x))),
        sopDetailsStructure: json["sop_details_structure"] == null ? [] : List<dynamic>.from(json["sop_details_structure"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "assign_track_flag": assignTrackFlag,
        "assing_to_list": assingToList == null ? [] : List<dynamic>.from(assingToList!.map((x) => x.toJson())),
        "sop_details_structure": sopDetailsStructure == null ? [] : List<dynamic>.from(sopDetailsStructure!.map((x) => x)),
    };
}

class AssingToList {
    String? transEmpProjectIdFk;
    String? transEmpDeveloperId;
    String? transEmpProjectStatus;
    String? transEmpProjectNumber;
    String? transEmpName;
    String? transEmpId;

    AssingToList({
        this.transEmpProjectIdFk,
        this.transEmpDeveloperId,
        this.transEmpProjectStatus,
        this.transEmpProjectNumber,
        this.transEmpName,
        this.transEmpId,
    });

    factory AssingToList.fromJson(Map<String, dynamic> json) => AssingToList(
        transEmpProjectIdFk: json["trans_emp_project_id_fk"],
        transEmpDeveloperId: json["trans_emp_developer_id"],
        transEmpProjectStatus: json["trans_emp_project_status"],
        transEmpProjectNumber: json["trans_emp_project_number"],
        transEmpName: json["trans_emp_name"],
        transEmpId: json["trans_emp_id"],
    );

    Map<String, dynamic> toJson() => {
        "trans_emp_project_id_fk": transEmpProjectIdFk,
        "trans_emp_developer_id": transEmpDeveloperId,
        "trans_emp_project_status": transEmpProjectStatus,
        "trans_emp_project_number": transEmpProjectNumber,
        "trans_emp_name": transEmpName,
        "trans_emp_id": transEmpId,
    };
}
