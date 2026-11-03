// To parse this JSON data, do
//
//     final getPoRequistionForm = getPoRequistionFormFromJson(jsonString);

import 'dart:convert';

GetPoRequistionForm getPoRequistionFormFromJson(String str) =>
    GetPoRequistionForm.fromJson(json.decode(str));

String getPoRequistionFormToJson(GetPoRequistionForm data) =>
    json.encode(data.toJson());

class GetPoRequistionForm {
  GetPoRequistionForm({
    this.response,
  });

  ResponseGetPoRequistionForm? response;

  factory GetPoRequistionForm.fromJson(Map<String, dynamic> json) =>
      GetPoRequistionForm(
        response: ResponseGetPoRequistionForm.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPoRequistionForm {
  ResponseGetPoRequistionForm({
    this.errorCode,
    this.msg,
    this.venderList,
    this.assingToList,
    this.purchaseUserTrack,
  });

  String? errorCode;
  String? msg;
  List<VenderList>? venderList;
  List<AssingToList>? assingToList;
  String? purchaseUserTrack;

  factory ResponseGetPoRequistionForm.fromJson(Map<String, dynamic> json) =>
      ResponseGetPoRequistionForm(
        errorCode: json["error_code"],
        msg: json["msg"],
        venderList: List<VenderList>.from(
            json["vender_list"].map((x) => VenderList.fromJson(x))),
        assingToList: json["assing_to_list"] == null
            ? []
            : List<AssingToList>.from(
                json["assing_to_list"]!.map((x) => AssingToList.fromJson(x))),
        purchaseUserTrack: json["purchase_user_track"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "vender_list": List<dynamic>.from(venderList!.map((x) => x.toJson())),
        "assing_to_list": assingToList == null
            ? []
            : List<dynamic>.from(assingToList!.map((x) => x.toJson())),
        "purchase_user_track": purchaseUserTrack,
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

class VenderList {
  VenderList({
    this.selectId,
    this.selectName,
    this.sendStatus,
  });

  String? selectId;
  String? selectName;
  String? sendStatus;

  factory VenderList.fromJson(Map<String, dynamic> json) => VenderList(
        selectId: json["select_id"],
        selectName: json["select_name"],
        sendStatus: json["send_status"],
      );

  Map<String, dynamic> toJson() => {
        "select_id": selectId,
        "select_name": selectName,
        "send_status": sendStatus,
      };
}
