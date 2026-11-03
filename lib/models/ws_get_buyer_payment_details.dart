// To parse this JSON data, do
//
//     final getBuyerPaymentsDetails = getBuyerPaymentsDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_broker_details.dart';

import 'get_flat_list_by_project.dart';

GetBuyerPaymentsDetails getBuyerPaymentsDetailsFromJson(String str) =>
    GetBuyerPaymentsDetails.fromJson(json.decode(str));

String getBuyerPaymentsDetailsToJson(GetBuyerPaymentsDetails data) =>
    json.encode(data.toJson());

class GetBuyerPaymentsDetails {
  ResponseGetBuyerPaymentsDetails? response;

  GetBuyerPaymentsDetails({
    this.response,
  });

  factory GetBuyerPaymentsDetails.fromJson(Map<String, dynamic> json) =>
      GetBuyerPaymentsDetails(
        response: json["Response"] == null
            ? null
            : ResponseGetBuyerPaymentsDetails.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetBuyerPaymentsDetails {
  String? errorCode;
  String? msg;
  String? flatArea;
  String? flatRateCal;
  String? flatValue;
  String? noOfParking;
  List<BuyerPaymentDetail>? buyerPaymentDetails;
  PaymentBottomBar? paymentBottomBar;
  List<FlatPaymentHistory>? flatPaymentHistory;
  int? buyerPaymentDetails1;
  List<PaymentType>? paymentType;
  String? flatPaymentAmount;
  List<ArrRegistrationDoc>? arrRegistrationDoc;
  String? flatStumpDuty;
  String? flatGstAmount;
  String? flatTdsAmount;
  String? flatStumpPercentage;
  String? flatGstPercentage;
  String? flatTdsPercentage;
  String? flatTotalAmountDue;
  List<List<CustomCharge>>? customCharges;
  String? totalGstPaid;
  String? totalGstPayable;
  String? totalGstGenerated;
  String? totalGstGeneratedHistry;
  String? totalGstDue;
  String? other_charges_flag;
  List<FlatBuyerRequest>? flatBuyerDetails;
  List<FlatBuyerInfo>? buyerContactDetails;

  ResponseGetBuyerPaymentsDetails({
    this.errorCode,
    this.msg,
    this.flatArea,
    this.flatRateCal,
    this.flatValue,
    this.noOfParking,
    this.buyerPaymentDetails,
    this.paymentBottomBar,
    this.flatPaymentHistory,
    this.buyerPaymentDetails1,
    this.paymentType,
    this.flatPaymentAmount,
    this.arrRegistrationDoc,
    this.flatStumpDuty,
    this.flatGstAmount,
    this.flatTdsAmount,
    this.flatStumpPercentage,
    this.flatGstPercentage,
    this.flatTdsPercentage,
    this.flatTotalAmountDue,
    this.customCharges,
    this.totalGstPaid,
    this.totalGstPayable,
    this.totalGstGenerated,
    this.totalGstGeneratedHistry,
    this.totalGstDue,
    this.other_charges_flag,
    this.flatBuyerDetails,
    this.buyerContactDetails,
  });

  factory ResponseGetBuyerPaymentsDetails.fromJson(Map<String, dynamic> json) =>
      ResponseGetBuyerPaymentsDetails(
        flatBuyerDetails: json["flat_buyer_details"] == null
            ? []
            : List<FlatBuyerRequest>.from(json["flat_buyer_details"]!
                .map((x) => FlatBuyerRequest.fromJson(x))),
        errorCode: json["error_code"],
        other_charges_flag: json['other_charges_flag'],
        msg: json["msg"],
        flatArea: json["flat_area"],
        flatRateCal: json["flat_rate_cal"],
        flatValue: json["flat_value"],
        noOfParking: json["no_of_parking"],
        buyerPaymentDetails: json["buyer_payment_details"] == null
            ? []
            : List<BuyerPaymentDetail>.from(json["buyer_payment_details"]!
                .map((x) => BuyerPaymentDetail.fromJson(x))),
        paymentBottomBar: json["payment_bottom_bar"] == null
            ? null
            : PaymentBottomBar.fromJson(json["payment_bottom_bar"]),
        flatPaymentHistory: json["flat_payment_history"] == null
            ? []
            : List<FlatPaymentHistory>.from(json["flat_payment_history"]!
                .map((x) => FlatPaymentHistory.fromJson(x))),
        buyerPaymentDetails1: json["buyer_payment_details1"],
        paymentType: json["payment_type"] == null
            ? []
            : List<PaymentType>.from(
                json["payment_type"]!.map((x) => PaymentType.fromJson(x))),
        flatPaymentAmount: json["flat_payment_amount"],
        arrRegistrationDoc: json["arr_registration_doc"] == null
            ? []
            : List<ArrRegistrationDoc>.from(json["arr_registration_doc"]!
                .map((x) => ArrRegistrationDoc.fromJson(x))),
        flatStumpDuty: json["flat_stump_duty"],
        flatGstAmount: json["flat_gst_amount"],
        flatTdsAmount: json["flat_tds_amount"],
        flatStumpPercentage: json["flat_stump_percentage"],
        flatGstPercentage: json["flat_gst_percentage"],
        flatTdsPercentage: json["flat_tds_percentage"],
        flatTotalAmountDue: json["flat_total_amount_due"],
        customCharges: json["custom_charges"] == null
            ? []
            : List<List<CustomCharge>>.from(json["custom_charges"]!.map((x) =>
                List<CustomCharge>.from(
                    x.map((x) => CustomCharge.fromJson(x))))),
        totalGstPaid: json["total_gst_paid"],
        totalGstPayable: json["total_gst_payable"],
        totalGstGenerated: json["total_gst_generated"],
        totalGstGeneratedHistry: json["total_gst_generated_histry"],
        totalGstDue: json["total_gst_due"],
        buyerContactDetails: json["buyer_contact_details"] == null
            ? []
            : List<FlatBuyerInfo>.from(json["buyer_contact_details"]!
                .map((x) => FlatBuyerInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "flat_buyer_details": flatBuyerDetails == null
            ? []
            : List<dynamic>.from(flatBuyerDetails!.map((x) => x.toJson())),
        "error_code": errorCode,
        "other_charges_flag": other_charges_flag,
        "msg": msg,
        "flat_area": flatArea,
        "flat_rate_cal": flatRateCal,
        "flat_value": flatValue,
        "no_of_parking": noOfParking,
        "buyer_payment_details": buyerPaymentDetails == null
            ? []
            : List<dynamic>.from(buyerPaymentDetails!.map((x) => x.toJson())),
        "payment_bottom_bar": paymentBottomBar?.toJson(),
        "flat_payment_history": flatPaymentHistory == null
            ? []
            : List<dynamic>.from(flatPaymentHistory!.map((x) => x)),
        "buyer_payment_details1": buyerPaymentDetails1,
        "payment_type": paymentType == null
            ? []
            : List<dynamic>.from(paymentType!.map((x) => x.toJson())),
        "flat_payment_amount": flatPaymentAmount,
        "arr_registration_doc": arrRegistrationDoc == null
            ? []
            : List<dynamic>.from(arrRegistrationDoc!.map((x) => x)),
        "flat_stump_duty": flatStumpDuty,
        "flat_gst_amount": flatGstAmount,
        "flat_tds_amount": flatTdsAmount,
        "flat_stump_percentage": flatStumpPercentage,
        "flat_gst_percentage": flatGstPercentage,
        "flat_tds_percentage": flatTdsPercentage,
        "flat_total_amount_due": flatTotalAmountDue,
        "custom_charges": customCharges == null
            ? []
            : List<dynamic>.from(customCharges!
                .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        "total_gst_paid": totalGstPaid,
        "total_gst_payable": totalGstPayable,
        "total_gst_generated": totalGstGenerated,
        "total_gst_generated_histry": totalGstGeneratedHistry,
        "total_gst_due": totalGstDue,
        "buyer_contact_details": buyerContactDetails == null
            ? []
            : List<dynamic>.from(buyerContactDetails!.map((x) => x.toJson())),
      };
}

class BuyerPaymentDetail {
  String? mstFlatPaymentId;
  String? flatBuyerIdFk;
  String? masonryIdFk;
  DateTime? flatPaymentDate;
  DateTime? flatPaymentEndDate;

  String? flatPaymentTest;
  String? flatPaymentPercentage;
  String? flatPaymentAmount;
  String? flatGstPerValue;
  String? flatPaymentGstAmount;
  String? flatPaymentOrder;
  String? flatPaymentActive;
  String? flatPaymentDoneStatus;
  String? paymentForceStatus;
  DateTime? flatPaymentUpdateAt;
  DateTime? flatPaymentCreatedAt;
  String? flatPaymentDemandSend;
  String? flatPaymentSelectType;
  String? flatPaymentTemplateRemark;
  String? flatPaymentDateType;

  BuyerPaymentDetail({
    this.mstFlatPaymentId,
    this.flatBuyerIdFk,
    this.masonryIdFk,
    this.flatPaymentDate,
    this.flatPaymentEndDate,
    this.flatPaymentTest,
    this.flatPaymentPercentage,
    this.flatPaymentAmount,
    this.flatGstPerValue,
    this.flatPaymentGstAmount,
    this.flatPaymentOrder,
    this.flatPaymentActive,
    this.flatPaymentDoneStatus,
    this.paymentForceStatus,
    this.flatPaymentUpdateAt,
    this.flatPaymentCreatedAt,
    this.flatPaymentDemandSend,
    this.flatPaymentSelectType,
    this.flatPaymentTemplateRemark,
    this.flatPaymentDateType,
  });

  factory BuyerPaymentDetail.fromJson(Map<String, dynamic> json) =>
      BuyerPaymentDetail(
        mstFlatPaymentId: json["mst_flat_payment_id"],
        flatBuyerIdFk: json["flat_buyer_id_fk"],
        masonryIdFk: json["masonry_id_fk"],
        flatPaymentDate: json["flat_payment_date"] == null
            ? null
            : DateTime.parse(json["flat_payment_date"]),
        flatPaymentEndDate: json["flat_payment_end_date"] == null
            ? null
            : DateTime.parse(json["flat_payment_end_date"]),
        flatPaymentTest: json["flat_payment_test"],
        flatPaymentPercentage: json["flat_payment_percentage"],
        flatPaymentAmount: json["flat_payment_amount"],
        flatGstPerValue: json["flat_gst_per_value"],
        flatPaymentGstAmount: json["flat_payment_gst_amount"],
        flatPaymentOrder: json["flat_payment_order"],
        flatPaymentActive: json["flat_payment_active"],
        flatPaymentDoneStatus: json["flat_payment_done_status"],
        paymentForceStatus: json["payment_force_status"],
        flatPaymentUpdateAt: json["flat_payment_update_at"] == null
            ? null
            : DateTime.parse(json["flat_payment_update_at"]),
        flatPaymentCreatedAt: json["flat_payment_created_at"] == null
            ? null
            : DateTime.parse(json["flat_payment_created_at"]),
        flatPaymentDemandSend: json["flat_payment_demand_send"],
        flatPaymentSelectType: json["flat_payment_select_type"],
        flatPaymentTemplateRemark: json["flat_payment_template_remark"],
        flatPaymentDateType: json["flat_payment_date_type"],
      );

  Map<String, dynamic> toJson() => {
        "mst_flat_payment_id": mstFlatPaymentId,
        "flat_buyer_id_fk": flatBuyerIdFk,
        "masonry_id_fk": masonryIdFk,
        "flat_payment_date":
            "${flatPaymentDate!.year.toString().padLeft(4, '0')}-${flatPaymentDate!.month.toString().padLeft(2, '0')}-${flatPaymentDate!.day.toString().padLeft(2, '0')}",
        "flat_payment_end_date":
            "${flatPaymentEndDate!.year.toString().padLeft(4, '0')}-${flatPaymentEndDate!.month.toString().padLeft(2, '0')}-${flatPaymentEndDate!.day.toString().padLeft(2, '0')}",
        "flat_payment_test": flatPaymentTest,
        "flat_payment_percentage": flatPaymentPercentage,
        "flat_payment_amount": flatPaymentAmount,
        "flat_gst_per_value": flatGstPerValue,
        "flat_payment_gst_amount": flatPaymentGstAmount,
        "flat_payment_order": flatPaymentOrder,
        "flat_payment_active": flatPaymentActive,
        "flat_payment_done_status": flatPaymentDoneStatus,
        "payment_force_status": paymentForceStatus,
        "flat_payment_update_at": flatPaymentUpdateAt?.toIso8601String(),
        "flat_payment_created_at": flatPaymentCreatedAt?.toIso8601String(),
        "flat_payment_demand_send": flatPaymentDemandSend,
        "flat_payment_select_type": flatPaymentSelectType,
        "flat_payment_template_remark": flatPaymentTemplateRemark,
        "flat_payment_date_type": flatPaymentDateType,
      };
}

class PaymentBottomBar {
  String? totalFlatAmount;
  String? received;
  String? balance;
  String? overdue;

  PaymentBottomBar({
    this.totalFlatAmount,
    this.received,
    this.balance,
    this.overdue,
  });

  factory PaymentBottomBar.fromJson(Map<String, dynamic> json) =>
      PaymentBottomBar(
        totalFlatAmount: json["total_flat_amount"],
        received: json["received"],
        balance: json["balance"],
        overdue: json["overdue"],
      );

  Map<String, dynamic> toJson() => {
        "total_flat_amount": totalFlatAmount,
        "received": received,
        "balance": balance,
        "overdue": overdue,
      };
}

class ArrRegistrationDoc {
  String? flatDocName;

  ArrRegistrationDoc({
    this.flatDocName,
  });

  factory ArrRegistrationDoc.fromJson(Map<String, dynamic> json) =>
      ArrRegistrationDoc(
        flatDocName: json["flat_doc_name"],
      );

  Map<String, dynamic> toJson() => {
        "flat_doc_name": flatDocName,
      };
}

class PaymentType {
  String? id;
  String? name;

  PaymentType({
    this.id,
    this.name,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) => PaymentType(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class FlatPaymentHistory {
  String? mstFlatBuyerPaymentId;
  String? flatBuyerIdFk;
  String? flatBuyerPaymentAmount;
  String? flatBuyerPaymentDate;
  String? flatBuyerPayementMode;
  String? flatBuyerPaymentStatus;
  DateTime? flatBuyerPaymentUpdateAt;
  DateTime? flatBuyerPaymentCreatedAt;
  String? flatBuyerPaymentRemarks;
  String? flatBuyerPaymentType;
  String? customChargesIdFk;
  String? demandNoteIdFk;
  String? paymentDate;
  String? cumulativeIdFk;
  String? projectBankIdFk;
  DateTime? paymentRecivedDt;
  String? flatBuyerFlag;
  String? flatBuyerDelectStatus;
  String? flatPaymentRequestUserId;
  String? flatPaymentDelectUserId;
  dynamic deletedReson;
  String? flatBuyerPenatiltyStatus;
  String? flatPanaltyIdFk;
  String? customChargesName;
  String? title;
  String? demandNumber;

  FlatPaymentHistory({
    this.mstFlatBuyerPaymentId,
    this.flatBuyerIdFk,
    this.flatBuyerPaymentAmount,
    this.flatBuyerPaymentDate,
    this.flatBuyerPayementMode,
    this.flatBuyerPaymentStatus,
    this.flatBuyerPaymentUpdateAt,
    this.flatBuyerPaymentCreatedAt,
    this.flatBuyerPaymentRemarks,
    this.flatBuyerPaymentType,
    this.customChargesIdFk,
    this.demandNoteIdFk,
    this.paymentDate,
    this.cumulativeIdFk,
    this.projectBankIdFk,
    this.paymentRecivedDt,
    this.flatBuyerFlag,
    this.flatBuyerDelectStatus,
    this.flatPaymentRequestUserId,
    this.flatPaymentDelectUserId,
    this.deletedReson,
    this.flatBuyerPenatiltyStatus,
    this.flatPanaltyIdFk,
    this.customChargesName,
    this.title,
    this.demandNumber,
  });

  factory FlatPaymentHistory.fromJson(Map<String, dynamic> json) =>
      FlatPaymentHistory(
        mstFlatBuyerPaymentId: json["mst_flat_buyer_payment_id"],
        flatBuyerIdFk: json["flat_buyer_id_fk"],
        flatBuyerPaymentAmount: json["flat_buyer_payment_amount"],
        flatBuyerPaymentDate: json["flat_buyer_payment_date"] ?? '',
        flatBuyerPayementMode: json["flat_buyer_payement_mode"],
        flatBuyerPaymentStatus: json["flat_buyer_payment_status"],
        flatBuyerPaymentUpdateAt: json["flat_buyer_payment_update_at"] == null
            ? null
            : DateTime.parse(json["flat_buyer_payment_update_at"]),
        flatBuyerPaymentCreatedAt: json["flat_buyer_payment_created_at"] == null
            ? null
            : DateTime.parse(json["flat_buyer_payment_created_at"]),
        flatBuyerPaymentRemarks: json["flat_buyer_payment_remarks"],
        flatBuyerPaymentType: json["flat_buyer_payment_type"],
        customChargesIdFk: json["custom_charges_id_fk"],
        demandNoteIdFk: json["demand_note_id_fk"],
        paymentDate: json["payment_date"] ?? '',
        cumulativeIdFk: json["cumulative_id_fk"],
        projectBankIdFk: json["project_bank_id_fk"],
        paymentRecivedDt: json["payment_recived_dt"] == null
            ? null
            : DateTime.parse(json["payment_recived_dt"]),
        flatBuyerFlag: json["flat_buyer_flag"],
        flatBuyerDelectStatus: json["flat_buyer_delect_status"],
        flatPaymentRequestUserId: json["flat_payment_request_user_id"],
        flatPaymentDelectUserId: json["flat_payment_delect_user_id"],
        deletedReson: json["deleted_reson"],
        flatBuyerPenatiltyStatus: json["flat_buyer_penatilty_status"],
        flatPanaltyIdFk: json["flat_panalty_id_fk"],
        customChargesName: json["custom_charges_name"],
        title: json["title"],
        demandNumber: json["demand_number"],
      );

  Map<String, dynamic> toJson() => {
        "mst_flat_buyer_payment_id": mstFlatBuyerPaymentId,
        "flat_buyer_id_fk": flatBuyerIdFk,
        "flat_buyer_payment_amount": flatBuyerPaymentAmount,
        "flat_buyer_payment_date": flatBuyerPaymentDate,
        "flat_buyer_payement_mode": flatBuyerPayementMode,
        "flat_buyer_payment_status": flatBuyerPaymentStatus,
        "flat_buyer_payment_update_at":
            flatBuyerPaymentUpdateAt?.toIso8601String(),
        "flat_buyer_payment_created_at":
            flatBuyerPaymentCreatedAt?.toIso8601String(),
        "flat_buyer_payment_remarks": flatBuyerPaymentRemarks,
        "flat_buyer_payment_type": flatBuyerPaymentType,
        "custom_charges_id_fk": customChargesIdFk,
        "demand_note_id_fk": demandNoteIdFk,
        "payment_date": paymentDate,
        "cumulative_id_fk": cumulativeIdFk,
        "project_bank_id_fk": projectBankIdFk,
        "payment_recived_dt":
            "${paymentRecivedDt!.year.toString().padLeft(4, '0')}-${paymentRecivedDt!.month.toString().padLeft(2, '0')}-${paymentRecivedDt!.day.toString().padLeft(2, '0')}",
        "flat_buyer_flag": flatBuyerFlag,
        "flat_buyer_delect_status": flatBuyerDelectStatus,
        "flat_payment_request_user_id": flatPaymentRequestUserId,
        "flat_payment_delect_user_id": flatPaymentDelectUserId,
        "deleted_reson": deletedReson,
        "flat_buyer_penatilty_status": flatBuyerPenatiltyStatus,
        "flat_panalty_id_fk": flatPanaltyIdFk,
        "custom_charges_name": customChargesName,
        "title": title,
        "demand_number": demandNumber,
      };
}
