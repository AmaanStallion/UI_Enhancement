// To parse this JSON data, do
//
//     final getAcquisitionList = getAcquisitionListFromJson(jsonString);

import 'dart:convert';

GetAcquisitionList getAcquisitionListFromJson(String str) =>
    GetAcquisitionList.fromJson(json.decode(str));

String getAcquisitionListToJson(GetAcquisitionList data) =>
    json.encode(data.toJson());

class GetAcquisitionList {
  GetAcquisitionListResponse? response;

  GetAcquisitionList({
    this.response,
  });

  factory GetAcquisitionList.fromJson(Map<String, dynamic> json) =>
      GetAcquisitionList(
        response: json["Response"] == null
            ? null
            : GetAcquisitionListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetAcquisitionListResponse {
  String? errorCode;
  String? msg;
  PaymentFlag? paymentFlag;
  List<PlotPayemntList>? plotPayemntList;

  GetAcquisitionListResponse({
    this.errorCode,
    this.msg,
    this.paymentFlag,
    this.plotPayemntList,
  });

  factory GetAcquisitionListResponse.fromJson(Map<String, dynamic> json) =>
      GetAcquisitionListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        paymentFlag: json["payment_flag"] == null
            ? null
            : PaymentFlag.fromJson(json["payment_flag"]),
        plotPayemntList: json["plotPayemntList"] == null
            ? []
            : List<PlotPayemntList>.from(json["plotPayemntList"]!
                .map((x) => PlotPayemntList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "payment_flag": paymentFlag?.toJson(),
        "plotPayemntList": plotPayemntList == null
            ? []
            : List<dynamic>.from(plotPayemntList!.map((x) => x.toJson())),
      };
}

class PaymentFlag {
  String? pending;
  String? approved;
  String? hold;
  String? reject;

  PaymentFlag({
    this.pending,
    this.approved,
    this.hold,
    this.reject,
  });

  factory PaymentFlag.fromJson(Map<String, dynamic> json) => PaymentFlag(
        pending: json["Pending"],
        approved: json["Approved"],
        hold: json["Hold"],
        reject: json["Reject"],
      );

  Map<String, dynamic> toJson() => {
        "Pending": pending,
        "Approved": approved,
        "Hold": hold,
        "Reject": reject,
      };
}

class PlotPayemntList {
  String? id;
  String? developerIdFk;
  String? plotPaymentAmount;
  String? plotPaymentTitle;
  String? plotPaymentRemark;
  DateTime? plotPaymentDate;
  String? plotPaymentDocument;
  String? plotPaymentStatus;
  String? userIdFk;
  String? approvedUserId;
  String? plotPaymentDeleteFlag;
  String? paymentDeleteUserId;
  String? paymentDeleteResaon;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? requestUser;
  String? approvedUser;
  String? deleteUser;
  String? plotPaymentStatusLabel;

  PlotPayemntList({
    this.id,
    this.developerIdFk,
    this.plotPaymentAmount,
    this.plotPaymentTitle,
    this.plotPaymentRemark,
    this.plotPaymentDate,
    this.plotPaymentDocument,
    this.plotPaymentStatus,
    this.userIdFk,
    this.approvedUserId,
    this.plotPaymentDeleteFlag,
    this.paymentDeleteUserId,
    this.paymentDeleteResaon,
    this.createdAt,
    this.updatedAt,
    this.requestUser,
    this.approvedUser,
    this.deleteUser,
    this.plotPaymentStatusLabel,
  });

  factory PlotPayemntList.fromJson(Map<String, dynamic> json) =>
      PlotPayemntList(
        id: json["id"],
        developerIdFk: json["developer_id_fk"],
        plotPaymentAmount: json["plot_payment_amount"],
        plotPaymentTitle: json["plot_payment_title"],
        plotPaymentRemark: json["plot_payment_remark"],
        plotPaymentDate: json["plot_payment_date"] == null
            ? null
            : DateTime.parse(json["plot_payment_date"]),
        plotPaymentDocument: json["plot_payment_document"],
        plotPaymentStatus: json["plot_payment_status"],
        userIdFk: json["user_id_fk"],
        approvedUserId: json["approved_user_id"],
        plotPaymentDeleteFlag: json["plot_payment_delete_flag"],
        paymentDeleteUserId: json["payment_delete_user_id"],
        paymentDeleteResaon: json["payment_delete_resaon"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        requestUser: json["request_user"],
        approvedUser: json["approved_user"],
        deleteUser: json["delete_user"],
        plotPaymentStatusLabel: json["plot_payment_status_label"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "developer_id_fk": developerIdFk,
        "plot_payment_amount": plotPaymentAmount,
        "plot_payment_title": plotPaymentTitle,
        "plot_payment_remark": plotPaymentRemark,
        "plot_payment_date":
            "${plotPaymentDate!.year.toString().padLeft(4, '0')}-${plotPaymentDate!.month.toString().padLeft(2, '0')}-${plotPaymentDate!.day.toString().padLeft(2, '0')}",
        "plot_payment_document": plotPaymentDocument,
        "plot_payment_status": plotPaymentStatus,
        "user_id_fk": userIdFk,
        "approved_user_id": approvedUserId,
        "plot_payment_delete_flag": plotPaymentDeleteFlag,
        "payment_delete_user_id": paymentDeleteUserId,
        "payment_delete_resaon": paymentDeleteResaon,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "request_user": requestUser,
        "approved_user": approvedUser,
        "delete_user": deleteUser,
        "plot_payment_status_label": plotPaymentStatusLabel,
      };
}
