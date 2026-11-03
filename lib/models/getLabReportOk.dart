// To parse this JSON data, do
//
//     final getLabReportOk = getLabReportOkFromJson(jsonString);

import 'dart:convert';

GetLabReportOk getLabReportOkFromJson(String str) =>
    GetLabReportOk.fromJson(json.decode(str));

String getLabReportOkToJson(GetLabReportOk data) => json.encode(data.toJson());

class GetLabReportOk {
  GetLabReportOkResponse? response;

  GetLabReportOk({
    this.response,
  });

  factory GetLabReportOk.fromJson(Map<String, dynamic> json) => GetLabReportOk(
        response: json["Response"] == null
            ? null
            : GetLabReportOkResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetLabReportOkResponse {
  String? errorCode;
  String? msg;
  List<SlabReport>? slabReport;
  String? isExpire;

  GetLabReportOkResponse({
    this.errorCode,
    this.msg,
    this.slabReport,
    this.isExpire,
  });

  factory GetLabReportOkResponse.fromJson(Map<String, dynamic> json) =>
      GetLabReportOkResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        slabReport: json["slab_report"] == null
            ? []
            : List<SlabReport>.from(
                json["slab_report"]!.map((x) => SlabReport.fromJson(x))),
        isExpire: json["is_expire"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "slab_report": slabReport == null
            ? []
            : List<dynamic>.from(slabReport!.map((x) => x.toJson())),
        "is_expire": isExpire,
      };
}

class SlabReport {
  String? slabStartDate;
  String? slabReportReview;
  String? slabReportOkId;
  String? submitDate;
  String? estCompletDate;
  List<String>? image;
  List<dynamic>? reportVedio;
  String? imagePath;

  SlabReport({
    this.slabStartDate,
    this.slabReportReview,
    this.slabReportOkId,
    this.submitDate,
    this.estCompletDate,
    this.image,
    this.reportVedio,
    this.imagePath,
  });

  factory SlabReport.fromJson(Map<String, dynamic> json) => SlabReport(
        slabStartDate: json["slab_start_date"],
        slabReportReview: json["slab_report_review"],
        slabReportOkId: json["slab_report_ok_id"],
        submitDate: json["submit_date"],
        estCompletDate: json["est_complet_date"],
        image: json["image"] == null
            ? []
            : List<String>.from(json["image"]!.map((x) => x)),
        reportVedio: json["report_vedio"] == null
            ? []
            : List<dynamic>.from(json["report_vedio"]!.map((x) => x)),
        imagePath: json["image_path"],
      );

  Map<String, dynamic> toJson() => {
        "slab_start_date": slabStartDate,
        "slab_report_review": slabReportReview,
        "slab_report_ok_id": slabReportOkId,
        "submit_date": submitDate,
        "est_complet_date": estCompletDate,
        "image": image == null ? [] : List<dynamic>.from(image!.map((x) => x)),
        "report_vedio": reportVedio == null
            ? []
            : List<dynamic>.from(reportVedio!.map((x) => x)),
        "image_path": imagePath,
      };
}
