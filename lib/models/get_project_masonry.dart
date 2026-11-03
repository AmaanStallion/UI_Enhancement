// To parse this JSON data, do
//
//     final getProjectMasonry = getProjectMasonryFromJson(jsonString);

import 'dart:convert';

GetProjectMasonry getProjectMasonryFromJson(String str) =>
    GetProjectMasonry.fromJson(json.decode(str));

String getProjectMasonryToJson(GetProjectMasonry data) =>
    json.encode(data.toJson());

class GetProjectMasonry {
  GetProjectMasonryResponse? response;

  GetProjectMasonry({
    this.response,
  });

  factory GetProjectMasonry.fromJson(Map<String, dynamic> json) =>
      GetProjectMasonry(
        response: json["Response"] == null
            ? null
            : GetProjectMasonryResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetProjectMasonryResponse {
  String? errorCode;
  String? msg;
  List<TowarList>? towarList;
  List<MasonryDetail>? masonryDetails;
  String? averagedata;
  String? documentPath;
  String? offset;

  GetProjectMasonryResponse({
    this.errorCode,
    this.msg,
    this.towarList,
    this.masonryDetails,
    this.averagedata,
    this.documentPath,
    this.offset,
  });

  factory GetProjectMasonryResponse.fromJson(Map<String, dynamic> json) =>
      GetProjectMasonryResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"]!.map((x) => TowarList.fromJson(x))),
        masonryDetails: json["masonry_details"] == null
            ? []
            : List<MasonryDetail>.from(
                json["masonry_details"]!.map((x) => MasonryDetail.fromJson(x))),
        averagedata: json["averagedata"],
        documentPath: json["document_path"],
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
        "masonry_details": masonryDetails == null
            ? []
            : List<dynamic>.from(masonryDetails!.map((x) => x.toJson())),
        "averagedata": averagedata,
        "document_path": documentPath,
        "offset": offset,
      };
}

class MasonryDetail {
  String? masonryId;
  String? masonryNo;
  String? estCompletDate;
  String? completedDate;
  String? completTitile;
  String? errorTitle;
  String? completStatus;
  String? issueReport;
  String? issueMasnoryReport;
  List<Drawing>? drawings;
  List<MasonryCheck>? masonryCheck;
  String? checkListFlag;

  MasonryDetail({
    this.masonryId,
    this.masonryNo,
    this.estCompletDate,
    this.completedDate,
    this.completTitile,
    this.errorTitle,
    this.completStatus,
    this.issueReport,
    this.issueMasnoryReport,
    this.drawings,
    this.masonryCheck,
    this.checkListFlag,
  });

  factory MasonryDetail.fromJson(Map<String, dynamic> json) => MasonryDetail(
        masonryId: json["masonry_id"],
        masonryNo: json["masonry_no"],
        estCompletDate: json["est_complet_date"],
        completedDate: json["completed_date"],
        completTitile: json["complet_titile"],
        errorTitle: json["error_title"],
        completStatus: json["complet_status"],
        issueReport: json["issue_report"],
        issueMasnoryReport: json["issue_masnory_report"],
        drawings: json["drawings"] == null
            ? []
            : List<Drawing>.from(
                json["drawings"].map((x) => Drawing.fromJson(x))),
        masonryCheck: json["masonry_check"] == null
            ? []
            : List<MasonryCheck>.from(
                json["masonry_check"].map((x) => MasonryCheck.fromJson(x))),
        checkListFlag: json["check_list_flag"],
      );

  Map<String, dynamic> toJson() => {
        "masonry_id": masonryId,
        "masonry_no": masonryNo,
        "est_complet_date": estCompletDate,
        "completed_date": completedDate,
        "complet_titile": completTitile,
        "error_title": errorTitle,
        "complet_status": completStatus,
        "issue_report": issueReport,
        "issue_masnory_report": issueMasnoryReport,
        "drawings": drawings == null
            ? []
            : List<dynamic>.from(drawings!.map((x) => x.toJson())),
        "masonry_check": masonryCheck == null
            ? []
            : List<dynamic>.from(masonryCheck!.map((x) => x.toJson())),
        "check_list_flag": checkListFlag,
      };
}

// enum CompletTitile { ALL_DRAWINGS_ISSUED, EMPTY }

// final completTitileValues = EnumValues({
//   "All Drawings Issued": CompletTitile.ALL_DRAWINGS_ISSUED,
//   "": CompletTitile.EMPTY
// });

class Drawing {
  String? drawingTitle;
  String? drawingId;
  List<String>? pdf;
  List<String>? dwg;
  String? masonryCheckId;
  String? submitReport;
  String? issuse;
  String? verify;
  List<DrawingVersion>? drawingVersion;

  Drawing({
    this.drawingTitle,
    this.drawingId,
    this.pdf,
    this.dwg,
    this.masonryCheckId,
    this.submitReport,
    this.issuse,
    this.verify,
    this.drawingVersion,
  });

  factory Drawing.fromJson(Map<String, dynamic> json) => Drawing(
        drawingTitle: json["drawing_title"],
        drawingId: json["drawing_id"],
        pdf: json["pdf"] == null
            ? []
            : List<String>.from(json["pdf"].map((x) => x)),
        dwg: json["dwg"] == null
            ? []
            : List<String>.from(json["dwg"].map((x) => x.toString())),
        masonryCheckId: json["masonry_check_id"],
        submitReport: json["submit_report"],
        issuse: json["issuse"],
        verify: json["verify"],
        drawingVersion: json["drawing_version"] == null
            ? []
            : List<DrawingVersion>.from(
                json["drawing_version"].map((x) => DrawingVersion.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "drawing_title": drawingTitle,
        "drawing_id": drawingId,
        "pdf": pdf == null ? [] : List<String>.from(pdf!.map((x) => x)),
        "dwg": dwg == null
            ? []
            : List<dynamic>.from(dwg!.map((x) => x.toString())),
        "masonry_check_id": masonryCheckId,
        "submit_report": submitReport,
        "issuse": issuse,
        "verify": verify,
        "drawing_version": drawingVersion == null
            ? []
            : List<dynamic>.from(drawingVersion!.map((x) => x.toJson())),
      };
}

// enum DrawingTitle { ELEVATION_DRAWING, WINDOW_DRAWING, WORKING_DRAWING }

// final drawingTitleValues = EnumValues({
//   "Elevation Drawing": DrawingTitle.ELEVATION_DRAWING,
//   "Window Drawing": DrawingTitle.WINDOW_DRAWING,
//   "Working Drawing": DrawingTitle.WORKING_DRAWING
// });

class DrawingVersion {
  String? name;
  String? pdfRemark;
  String? dwgRemark;
  List<PdfElement>? pdf;
  List<PdfElement>? dwg;

  DrawingVersion({
    this.name,
    this.pdfRemark,
    this.dwgRemark,
    this.pdf,
    this.dwg,
  });

  factory DrawingVersion.fromJson(Map<String, dynamic> json) => DrawingVersion(
        name: json["name"],
        pdfRemark: json["pdf_remark"],
        dwgRemark: json["dwg_remark"],
        pdf: json["pdf"] == null
            ? []
            : List<PdfElement>.from(
                json["pdf"].map((x) => PdfElement.fromJson(x))),
        dwg: json["dwg"] == null
            ? []
            : List<PdfElement>.from(
                json["dwg"].map((x) => PdfElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "pdf_remark": pdfRemark,
        "dwg_remark": dwgRemark,
        "pdf":
            pdf == null ? [] : List<dynamic>.from(pdf!.map((x) => x.toJson())),
        "dwg":
            dwg == null ? [] : List<dynamic>.from(dwg!.map((x) => x.toJson())),
      };
}

class PdfElement {
  String? slabDrawingImgName;
  String? drawingDate;
  String? fileUrl;
  String? documentName;

  PdfElement({
    this.slabDrawingImgName,
    this.drawingDate,
    this.fileUrl,
    this.documentName,
  });

  factory PdfElement.fromJson(Map<String, dynamic> json) => PdfElement(
        slabDrawingImgName: json["slab_drawing_img_name"],
        drawingDate: json["drawing_date"],
        fileUrl: json["file_url"],
        documentName: json["document_name"],
      );

  Map<String, dynamic> toJson() => {
        "slab_drawing_img_name": slabDrawingImgName,
        "drawing_date": drawingDate,
        "file_url": fileUrl,
        "document_name": documentName,
      };
}

// enum DrawingDate { THE_17082023, THE_18082023, THE_23052023, THE_28082023 }

// final drawingDateValues = EnumValues({
//   "17/08/2023": DrawingDate.THE_17082023,
//   "18/08/2023": DrawingDate.THE_18082023,
//   "23/05/2023": DrawingDate.THE_23052023,
//   "28/08/2023": DrawingDate.THE_28082023
// });

// enum Remark { EMPTY, TESTING }

// final remarkValues = EnumValues({"": Remark.EMPTY, "testing": Remark.TESTING});

// enum Name { VERSION }

// final nameValues = EnumValues({"Version": Name.VERSION});

// enum DwgEnum {
//   ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS31_DWG,
//   ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS3_DWG,
//   ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS4_DWG,
//   ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS5_DWG,
//   ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS6_DWG,
//   ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS7_DWG,
//   ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS8_DWG
// }

// final dwgEnumValues = EnumValues({
//   "architectural_-_annotation_scaling_and_multileaders31.dwg":
//       DwgEnum.ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS31_DWG,
//   "architectural_-_annotation_scaling_and_multileaders3.dwg":
//       DwgEnum.ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS3_DWG,
//   "architectural_-_annotation_scaling_and_multileaders4.dwg":
//       DwgEnum.ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS4_DWG,
//   "architectural_-_annotation_scaling_and_multileaders5.dwg":
//       DwgEnum.ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS5_DWG,
//   "architectural_-_annotation_scaling_and_multileaders6.dwg":
//       DwgEnum.ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS6_DWG,
//   "architectural_-_annotation_scaling_and_multileaders7.dwg":
//       DwgEnum.ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS7_DWG,
//   "architectural_-_annotation_scaling_and_multileaders8.dwg":
//       DwgEnum.ARCHITECTURAL_ANNOTATION_SCALING_AND_MULTILEADERS8_DWG
// });

// enum Pdf {
//   JAN1004_GRN_1202311_PDF,
//   JAN1004_GRN_120231_PDF,
//   PAD1030_20231_PDF,
//   PAD1030_2023_PDF,
//   PAD1034_20231_PDF,
//   PAD1099_20231_PDF,
//   PAYMENT_RECEIPT_PAD_SL29120232_PDF,
//   PAYMENT_RECEIPT_PAD_SL2912023_PDF
// }

// final pdfValues = EnumValues({
//   "Jan1004-GRN-1-2023_(1)1.pdf": Pdf.JAN1004_GRN_1202311_PDF,
//   "Jan1004-GRN-1-2023_(1).pdf": Pdf.JAN1004_GRN_120231_PDF,
//   "Pad1030-2023_(1).pdf": Pdf.PAD1030_20231_PDF,
//   "Pad1030-2023.pdf": Pdf.PAD1030_2023_PDF,
//   "Pad1034-2023_(1).pdf": Pdf.PAD1034_20231_PDF,
//   "Pad1099-20231.pdf": Pdf.PAD1099_20231_PDF,
//   "Payment-Receipt-PadSL29120232.pdf": Pdf.PAYMENT_RECEIPT_PAD_SL29120232_PDF,
//   "Payment-Receipt-PadSL2912023.pdf": Pdf.PAYMENT_RECEIPT_PAD_SL2912023_PDF
// });

// enum ErrorTitle { EMPTY, WINDOW_AND_ELEVATION_DRAWINGS_PENDING }

// final errorTitleValues = EnumValues({
//   "": ErrorTitle.EMPTY,
//   "Window  and  Elevation Drawings Pending":
//       ErrorTitle.WINDOW_AND_ELEVATION_DRAWINGS_PENDING
// });

class MasonryCheck {
  String? headTitle;
  String? headId;
  List<InnerBlock>? innerBlock;
  String? headCheck;

  MasonryCheck({
    this.headTitle,
    this.headId,
    this.innerBlock,
    this.headCheck,
  });

  factory MasonryCheck.fromJson(Map<String, dynamic> json) => MasonryCheck(
        headTitle: json["head_title"],
        headId: json["head_id"],
        innerBlock: json["inner_block"] == null
            ? []
            : List<InnerBlock>.from(
                json["inner_block"]!.map((x) => InnerBlock.fromJson(x))),
        headCheck: json["head_check"],
      );

  Map<String, dynamic> toJson() => {
        "head_title": headTitle,
        "head_id": headId,
        "inner_block": innerBlock == null
            ? []
            : List<dynamic>.from(innerBlock!.map((x) => x.toJson())),
        "head_check": headCheck,
      };
}

// enum HeadTitle { BLOCK_WORK, EXTERNAL_PLASTER, INTERNAL_PLASTER }

// final headTitleValues = EnumValues({
//   "Block Work": HeadTitle.BLOCK_WORK,
//   "External Plaster": HeadTitle.EXTERNAL_PLASTER,
//   "Internal Plaster": HeadTitle.INTERNAL_PLASTER
// });

class InnerBlock {
  String? checkTitle;
  String? checkId;
  String? isSetupDone;
  String? checkStatusOk;
  String? checkStatusIssue;
  String? clickActive;

  InnerBlock({
    this.checkTitle,
    this.checkId,
    this.isSetupDone,
    this.checkStatusOk,
    this.checkStatusIssue,
    this.clickActive,
  });

  factory InnerBlock.fromJson(Map<String, dynamic> json) => InnerBlock(
        checkTitle: json["check_title"],
        checkId: json["check_id"],
        isSetupDone: json["is_setup_done"],
        checkStatusOk: json["check_status_ok"],
        checkStatusIssue: json["check_status_issue"],
        clickActive: json["click_active"],
      );

  Map<String, dynamic> toJson() => {
        "check_title": checkTitle,
        "check_id": checkId,
        "is_setup_done": isSetupDone,
        "check_status_ok": checkStatusOk,
        "check_status_issue": checkStatusIssue,
        "click_active": clickActive,
      };
}

// enum CheckTitle { DEVELOPER, RCC_CONTRACTOR }

// final checkTitleValues = EnumValues({
//   "Developer": CheckTitle.DEVELOPER,
//   "RCC Contractor": CheckTitle.RCC_CONTRACTOR
// });

class TowarList {
  String? towarId;
  String? towarName;

  TowarList({
    this.towarId,
    this.towarName,
  });

  factory TowarList.fromJson(Map<String, dynamic> json) => TowarList(
        towarId: json["towar_id"],
        towarName: json["towar_name"],
      );

  Map<String, dynamic> toJson() => {
        "towar_id": towarId,
        "towar_name": towarName,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
