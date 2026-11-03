// To parse this JSON data, do
//
//     final rccStructureData = rccStructureDataFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_project_masonry.dart';

RccStructureData rccStructureDataFromJson(String str) =>
    RccStructureData.fromJson(json.decode(str));

String rccStructureDataToJson(RccStructureData data) =>
    json.encode(data.toJson());

class RccStructureData {
  RccStructureData({
    required this.response,
  });

  final RccStructureDataResponse response;

  factory RccStructureData.fromJson(Map<String, dynamic> json) =>
      RccStructureData(
        response: RccStructureDataResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response.toJson(),
      };
}

class RccStructureDataResponse {
  RccStructureDataResponse({
    required this.errorCode,
    required this.msg,
    this.towarList,
    this.blockFlag,
    required this.slabDetails,
    required this.averagedata,
    this.offset,
  });

  final String errorCode;
  final String msg;
  List<TowarList>? towarList;
  final List<SlabDetail> slabDetails;
  final String averagedata;
  String? offset;

  String? blockFlag;

  factory RccStructureDataResponse.fromJson(Map<String, dynamic> json) =>
      RccStructureDataResponse(
        errorCode: json["error_code"],
        blockFlag: json["block_flag"],
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"]!.map((x) => TowarList.fromJson(x))),
        msg: json["msg"],
        slabDetails: List<SlabDetail>.from(
            json["slab_details"].map((x) => SlabDetail.fromJson(x))),
        averagedata: json["averagedata"],
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "block_flag": blockFlag,
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
        "slab_details": List<dynamic>.from(slabDetails.map((x) => x.toJson())),
        "averagedata": averagedata,
        "offset": offset,
      };
}

class SlabDetail {
  SlabDetail({
    required this.slabId,
    required this.slabNo,
    required this.estCompletDate,
    required this.completedDate,
    this.completTitile,
    required this.errorTitle,
    required this.completStatus,
    required this.issueReport,
    required this.issueSlabReport,
    required this.orderSupplies,
    required this.drawings,
    required this.slabCheck,
    this.checkListFlag,
  });
  String? checkListFlag;
  final String slabId;
  final String slabNo;
  final String estCompletDate;
  final String completedDate;
  final String? completTitile;
  final String errorTitle;
  final String completStatus;
  final String issueReport;
  final String issueSlabReport;
  final String orderSupplies;
  final List<Drawing> drawings;
  final List<SlabCheck> slabCheck;

  factory SlabDetail.fromJson(Map<String, dynamic> json) => SlabDetail(
        slabId: json["slab_id"],
        slabNo: json["slab_no"],
        estCompletDate: json["est_complet_date"],
        completedDate: json["completed_date"],
        completTitile: json["complet_titile"],
        errorTitle: json["error_title"],
        completStatus: json["complet_status"],
        issueReport: json["issue_report"],
        issueSlabReport: json["issue_slab_report"],
        orderSupplies: json["order_supplies"],
        drawings: List<Drawing>.from(
            json["drawings"].map((x) => Drawing.fromJson(x))),
        slabCheck: List<SlabCheck>.from(
            json["slab_check"].map((x) => SlabCheck.fromJson(x))),
        checkListFlag: json["check_list_flag"],
      );

  Map<String, dynamic> toJson() => {
        "slab_id": slabId,
        "slab_no": slabNo,
        "est_complet_date": estCompletDate,
        "completed_date": completedDate,
        "complet_titile": completTitile,
        "error_title": errorTitle,
        "complet_status": completStatus,
        "issue_report": issueReport,
        "issue_slab_report": issueSlabReport,
        "order_supplies": orderSupplies,
        "drawings": List<dynamic>.from(drawings.map((x) => x.toJson())),
        "slab_check": List<dynamic>.from(slabCheck.map((x) => x.toJson())),
        "check_list_flag": checkListFlag,
      };
}

class Drawing {
  Drawing({
    required this.drawingTitle,
    required this.drawingId,
    required this.pdf,
    required this.dwg,
    required this.drawingVersion,
    required this.slabCheckId,
    required this.submitReport,
    required this.issuse,
    required this.verify,
    this.isSelected = false,
    this.isDisabled = false,
  });

  final String drawingTitle;
  final String drawingId;
  final List<String> pdf;
  final List<String> dwg;
  final List<DrawingVersion> drawingVersion;
  final String slabCheckId;
  final String submitReport;
  final String issuse;
  final String verify;
  bool? isSelected = false;
  bool? isDisabled = false;

  factory Drawing.fromJson(Map<String, dynamic> json) => Drawing(
        drawingTitle: json["drawing_title"],
        drawingId: json["drawing_id"],
        pdf: List<String>.from(json["pdf"].map((x) => x)),
        dwg: List<String>.from(json["dwg"].map((x) => x)),
        drawingVersion: List<DrawingVersion>.from(
            json["drawing_version"].map((x) => DrawingVersion.fromJson(x))),
        slabCheckId: json["slab_check_id"],
        submitReport: json["submit_report"],
        issuse: json["issuse"],
        verify: json["verify"],
        isSelected: false,
        isDisabled: json["is_disabled"] == true,
      );

  Map<String, dynamic> toJson() => {
        "drawing_title": drawingTitle,
        "drawing_id": drawingId,
        "pdf": List<dynamic>.from(pdf.map((x) => x)),
        "dwg": List<dynamic>.from(dwg.map((x) => x)),
        "drawing_version":
            List<dynamic>.from(drawingVersion.map((x) => x.toJson())),
        "slab_check_id": slabCheckId,
        "submit_report": submitReport,
        "issuse": issuse,
        "verify": verify,
        "is_disabled": isDisabled,
      };
}

// class DrawingVersion {
//   String? pdfRemark;
//   String? name;
//   String? dwgRemark;
//   List<Dwg>? pdf;
//   List<Dwg>? dwg;

//   DrawingVersion({
//     this.pdfRemark,
//     this.name,
//     this.dwgRemark,
//     this.pdf,
//     this.dwg,
//   });

//   factory DrawingVersion.fromJson(Map<String, dynamic> json) => DrawingVersion(
//         pdfRemark: json["pdf_remark"],
//         name: json["name"],
//         dwgRemark: json["dwg_remark"],
//         pdf: json["pdf"] == null
//             ? []
//             : List<Dwg>.from(json["pdf"]!.map((x) => Dwg.fromJson(x))),
//         dwg: json["dwg"] == null
//             ? []
//             : List<Dwg>.from(json["dwg"]!.map((x) => Dwg.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "pdf_remark": pdfRemark,
//         "name": name,
//         "dwg_remark": dwgRemark,
//         "pdf":
//             pdf == null ? [] : List<dynamic>.from(pdf!.map((x) => x.toJson())),
//         "dwg":
//             dwg == null ? [] : List<dynamic>.from(dwg!.map((x) => x.toJson())),
//       };
// }

// class Dwg {
//   Dwg({
//     required this.slabDrawingImgName,
//     required this.drawingDate,
//   });

//   final String slabDrawingImgName;
//   final String drawingDate;

//   factory Dwg.fromJson(Map<String, dynamic> json) => Dwg(
//         slabDrawingImgName: json["slab_drawing_img_name"],
//         drawingDate: json["drawing_date"],
//       );

//   Map<String, dynamic> toJson() => {
//         "slab_drawing_img_name": slabDrawingImgName,
//         "drawing_date": drawingDate,
//       };
// }

class SlabCheck {
  SlabCheck({
    required this.slabCheckTitle,
    required this.slabCheckId,
    required this.isSetupDone,
    required this.slabCheckStatusOk,
    required this.slabCheckStatusIssue,
    required this.clickActive,
    this.towerAuthorityId,
    this.remarks,
    this.completedOn,
    this.documents,
    this.createdByName,
  });

  final String slabCheckTitle;
  final String slabCheckId;
  final String isSetupDone;
  final String slabCheckStatusOk;
  final String slabCheckStatusIssue;
  final String clickActive;
  final String? towerAuthorityId;
  final String? remarks;
  final String? completedOn;
  final List<dynamic>? documents;
  final String? createdByName;

  factory SlabCheck.fromJson(Map<String, dynamic> json) => SlabCheck(
        slabCheckTitle: json["slab_check_title"] ?? '',
        slabCheckId: json["slab_check_id"] ?? '',
        isSetupDone: json["is_setup_done"] ?? '0',
        slabCheckStatusOk: json["slab_check_status_ok"] ?? '0',
        slabCheckStatusIssue: json["slab_check_status_issue"] ?? '0',
        clickActive: json["click_active"] ?? '0',
        towerAuthorityId: json["tower_authority_id"],
        remarks: json["remarks"],
        completedOn: json["completed_on"],
        documents: json["documents"],
        createdByName: json["created_by_name"],
      );

  Map<String, dynamic> toJson() => {
        "slab_check_title": slabCheckTitle,
        "slab_check_id": slabCheckId,
        "is_setup_done": isSetupDone,
        "slab_check_status_ok": slabCheckStatusOk,
        "slab_check_status_issue": slabCheckStatusIssue,
        "click_active": clickActive,
        "tower_authority_id": towerAuthorityId,
        "remarks": remarks,
        "completed_on": completedOn,
        "documents": documents,
        "created_by_name": createdByName,
      };
}
