// To parse this JSON data, do
//
//     final sopDetailsModal = sopDetailsModalFromJson(jsonString);

import 'dart:convert';

SopDetailsModal sopDetailsModalFromJson(String str) =>
    SopDetailsModal.fromJson(json.decode(str));

String sopDetailsModalToJson(SopDetailsModal data) =>
    json.encode(data.toJson());

class SopDetailsModal {
  Response? response;

  SopDetailsModal({
    this.response,
  });

  factory SopDetailsModal.fromJson(Map<String, dynamic> json) =>
      SopDetailsModal(
        response: json["Response"] == null
            ? null
            : Response.fromJson(json["Response"]),
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
  List<SopDetailsStructure>? sopDetailsStructure;
  String? sopHideShowFlag;

  Response({
    this.errorCode,
    this.msg,
    this.assignTrackFlag,
    this.assingToList,
    this.sopDetailsStructure,
    this.sopHideShowFlag,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        assignTrackFlag: json["assign_track_flag"],
        assingToList: json["assing_to_list"] == null
            ? []
            : List<AssingToList>.from(
                json["assing_to_list"]!.map((x) => AssingToList.fromJson(x))),
        sopDetailsStructure: json["sop_details_structure"] == null
            ? []
            : List<SopDetailsStructure>.from(json["sop_details_structure"]!
                .map((x) => SopDetailsStructure.fromJson(x))),
        sopHideShowFlag: json["sop_hide_show_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "assign_track_flag": assignTrackFlag,
        "assing_to_list": assingToList == null
            ? []
            : List<dynamic>.from(assingToList!.map((x) => x.toJson())),
        "sop_details_structure": sopDetailsStructure == null
            ? []
            : List<dynamic>.from(sopDetailsStructure!.map((x) => x.toJson())),
        "sop_hide_show_flag": sopHideShowFlag,
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

class SopDetailsStructure {
  String? id;
  String? categoryId;
  String? name;
  List<Detail>? details;
  bool? isOpen = false;
  String? tickFlag;
  bool isLoadingSubHeadings;
  bool isSubHeadingsLoaded;

  SopDetailsStructure({
    this.id,
    this.categoryId,
    this.name,
    this.details,
    this.isOpen = false,
    this.tickFlag,
    this.isLoadingSubHeadings = false,
    this.isSubHeadingsLoaded = false,
  });

  factory SopDetailsStructure.fromJson(Map<String, dynamic> json) =>
      SopDetailsStructure(
        id: json["id"],
        categoryId: json["category_id"],
        name: json["name"],
        details: json["details"] == null
            ? []
            : List<Detail>.from(
                json["details"]!.map((x) => Detail.fromJson(x))),
        tickFlag: json["tick_flag"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "name": name,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
        "tick_flag": tickFlag,
      };
}

class Detail {
  String? id;
  String? subCatId;
  String? name;
  String? checkFlag;
  String? remark;
  String? assingToId;
  String? assingName;
  String? userIdFk;
  String? userName;
  List<UploadImg>? uploadImg;
  String? tickFlag;
  // String? startDate;
  // String? endDate;
  DateTime? startDate;
  DateTime? endDate;

  Detail({
    this.id,
    this.subCatId,
    this.name,
    this.checkFlag,
    this.remark,
    this.assingToId,
    this.assingName,
    this.userIdFk,
    this.userName,
    this.uploadImg,
    this.tickFlag,
    this.startDate,
    this.endDate,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        final parts = dateString.split('-');
        return DateTime(
          int.parse(parts[2]), // Year
          int.parse(parts[1]), // Month
          int.parse(parts[0]), // Day
        );
      } catch (e) {
        throw FormatException('Invalid date format: $dateString');
      }
    }

    return Detail(
      id: json["id"],
      subCatId: json["sub_cat_id"],
      name: json["name"],
      checkFlag: json["check_flag"],
      remark: json["remark"],
      assingToId: json["assing_to_id"],
      assingName: json["assing_name"],
      userIdFk: json["user_id_fk"],
      userName: json["user_name"],
      uploadImg: json["upload_img"] == null
          ? []
          : List<UploadImg>.from(
              json["upload_img"]!.map((x) => UploadImg.fromJson(x))),
      tickFlag: json["tick_flag"],
      // startDate: json["start_date"],
      // endDate: json["end_date"],
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "sub_cat_id": subCatId,
        "name": name,
        "check_flag": checkFlag,
        "remark": remark,
        "assing_to_id": assingToId,
        "assing_name": assingName,
        "user_id_fk": userIdFk,
        "user_name": userName,
        "upload_img": uploadImg == null
            ? []
            : List<dynamic>.from(uploadImg!.map((x) => x.toJson())),
        "tick_flag": tickFlag,
        // "start_date": startDate,
        // "end_date": endDate,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      };
}

class UploadImg {
  String? docId;
  String? docName;
  String? fileUrl;

  UploadImg({
    this.docId,
    this.docName,
    this.fileUrl,
  });

  factory UploadImg.fromJson(Map<String, dynamic> json) => UploadImg(
        docId: json["doc_id"]?.toString(),
        docName: json["doc_name"],
        fileUrl: json["file_url"],
      );

  Map<String, dynamic> toJson() => {
        "doc_id": docId,
        "doc_name": docName,
        "file_url": fileUrl,
      };
}
