// To parse this JSON data, do
//
//     final getBuyerPenaltyList = getBuyerPenaltyListFromJson(jsonString);

import 'dart:convert';

GetBuyerPenaltyList getBuyerPenaltyListFromJson(String str) =>
    GetBuyerPenaltyList.fromJson(json.decode(str));

String getBuyerPenaltyListToJson(GetBuyerPenaltyList data) =>
    json.encode(data.toJson());

class GetBuyerPenaltyList {
  BuyerPenaltyListResponse? response;

  GetBuyerPenaltyList({
    this.response,
  });

  factory GetBuyerPenaltyList.fromJson(Map<String, dynamic> json) =>
      GetBuyerPenaltyList(
        response: json["Response"] == null
            ? null
            : BuyerPenaltyListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class BuyerPenaltyListResponse {
  String? errorCode;
  String? msg;
  List<PenaltyDetail>? penaltyDetails;

  BuyerPenaltyListResponse({
    this.errorCode,
    this.msg,
    this.penaltyDetails,
  });

  factory BuyerPenaltyListResponse.fromJson(Map<String, dynamic> json) =>
      BuyerPenaltyListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        penaltyDetails: json["penalty_details"] == null
            ? []
            : List<PenaltyDetail>.from(
                json["penalty_details"]!.map((x) => PenaltyDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "penalty_details": penaltyDetails == null
            ? []
            : List<dynamic>.from(penaltyDetails!.map((x) => x.toJson())),
      };
}

class PenaltyDetail {
  String? penaltyGenerateId;
  String? penaltyDecripId;
  String? penaltyRemark;
  String? penaltyBalAmt;
  String? penaltyPerce;
  String? penaltyDays;
  String? penaltyTotal;
  String? penaltyGstPerce;
  String? penaltyGstAmout;
  String? penaltyGrandTotAmt;
  String? flatBuyerIdFk;
  String? penaltyStatus;
  String? penaltyApprovedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? mstFlatPaymentId;
  String? demandNoteName;
  String? flatPaymentTest;
  String? penaltyWavierPerc;

  PenaltyDetail({
    this.penaltyGenerateId,
    this.penaltyDecripId,
    this.penaltyRemark,
    this.penaltyBalAmt,
    this.penaltyPerce,
    this.penaltyDays,
    this.penaltyTotal,
    this.penaltyGstPerce,
    this.penaltyGstAmout,
    this.penaltyGrandTotAmt,
    this.flatBuyerIdFk,
    this.penaltyStatus,
    this.penaltyApprovedBy,
    this.createdAt,
    this.updatedAt,
    this.mstFlatPaymentId,
    this.demandNoteName,
    this.flatPaymentTest,
    this.penaltyWavierPerc,
  });

  factory PenaltyDetail.fromJson(Map<String, dynamic> json) => PenaltyDetail(
        penaltyGenerateId: json["penalty_generate_id"],
        penaltyDecripId: json["penalty_decrip_id"],
        penaltyRemark: json["penalty_remark"],
        penaltyBalAmt: json["penalty_bal_amt"],
        penaltyPerce: json["penalty_perce"],
        penaltyDays: json["penalty_days"],
        penaltyTotal: json["penalty_total"],
        penaltyGstPerce: json["penalty_gst_perce"],
        penaltyGstAmout: json["penalty_gst_amout"],
        penaltyGrandTotAmt: json["penalty_grand_tot_amt"],
        flatBuyerIdFk: json["flat_buyer_id_fk"],
        penaltyStatus: json["penalty_status"],
        penaltyApprovedBy: json["penalty_approved_by"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        mstFlatPaymentId: json["mst_flat_payment_id"],
        demandNoteName: json["demand_note_name"],
        flatPaymentTest: json["flat_payment_test"],
        penaltyWavierPerc: json["penalty_wavier_perc"],
      );

  Map<String, dynamic> toJson() => {
        "penalty_generate_id": penaltyGenerateId,
        "penalty_decrip_id": penaltyDecripId,
        "penalty_remark": penaltyRemark,
        "penalty_bal_amt": penaltyBalAmt,
        "penalty_perce": penaltyPerce,
        "penalty_days": penaltyDays,
        "penalty_total": penaltyTotal,
        "penalty_gst_perce": penaltyGstPerce,
        "penalty_gst_amout": penaltyGstAmout,
        "penalty_grand_tot_amt": penaltyGrandTotAmt,
        "flat_buyer_id_fk": flatBuyerIdFk,
        "penalty_status": penaltyStatus,
        "penalty_approved_by": penaltyApprovedBy,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "mst_flat_payment_id": mstFlatPaymentId,
        "demand_note_name": demandNoteName,
        "flat_payment_test": flatPaymentTest,
        "penalty_wavier_perc": penaltyWavierPerc,
      };
}
