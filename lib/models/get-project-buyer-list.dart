// To parse this JSON data, do
//
//     final wsgetprojectbuyerlist = wsgetprojectbuyerlistFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_broker_details.dart';

Wsgetprojectbuyerlist wsgetprojectbuyerlistFromJson(String str) =>
    Wsgetprojectbuyerlist.fromJson(json.decode(str));

String wsgetprojectbuyerlistToJson(Wsgetprojectbuyerlist data) =>
    json.encode(data.toJson());

class Wsgetprojectbuyerlist {
  ResponseWsgetprojectbuyerlist? response;

  Wsgetprojectbuyerlist({
    this.response,
  });

  factory Wsgetprojectbuyerlist.fromJson(Map<String, dynamic> json) =>
      Wsgetprojectbuyerlist(
        response: json["Response"] == null
            ? null
            : ResponseWsgetprojectbuyerlist.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseWsgetprojectbuyerlist {
  String? errorCode;
  String? msg;
  List<FlatBuyerRequest>? projectBuyerDetailsList;
  String? offset;

  ResponseWsgetprojectbuyerlist({
    this.errorCode,
    this.msg,
    this.projectBuyerDetailsList,
    this.offset,
  });

  factory ResponseWsgetprojectbuyerlist.fromJson(Map<String, dynamic> json) =>
      ResponseWsgetprojectbuyerlist(
        errorCode: json["error_code"],
        msg: json["msg"],
        projectBuyerDetailsList: json["project_buyer_details_list"] == null
            ? []
            : List<FlatBuyerRequest>.from(json["project_buyer_details_list"]!
                .map((x) => FlatBuyerRequest.fromJson(x))),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "project_buyer_details_list": projectBuyerDetailsList == null
            ? []
            : List<dynamic>.from(
                projectBuyerDetailsList!.map((x) => x.toJson())),
        "offset": offset,
      };
}

/*class ProjectBuyerDetailsList {
  String? flatBuyerId;
  String? projectIdFk;
  String? flatIdFk;
  String? userIdFk;
  String? flatBuyerName;
  String? flatBuyerName1;
  String? flatBuyerNumber;
  String? flatBuyerEmail;
  String? flatArea;
  String? flatRateCal;
  String? flatValue;
  String? podiumIdFk;
  String? noOfParking;
  String? flatBrokerageValue;
  String? flatStampDutyValue;
  String? flatStampDutyActualValue;
  String? flatGstValue;
  String? flatTotalValue;
  String? finshingType;
  String? flatBuyerPayementType;
  String? flatApprovedById;
  String? buyerFlatStatus;
  DateTime? buyerFlatUpatedAt;
  DateTime? buyerFlatCreateAt;
  String? flatBuyerOrderNo;
  String? flatBuyerSerialNo;
  DateTime? flatRequestDate;
  DateTime? flatApprovedDate;
  String? flatAllotLetter;
  String? flagInvestor;
  String? aadharNo;
  String? panNo;
  String? flatGstPercentage;
  String? flatStumpPercentage;
  String? flatTdsPercentage;
  String? flatTotalWithoutGst;
  String? flatBuyerAddress1;
  String? flatBuyerAddress2;
  String? flatAutoEmailSend;
  String? requestCancelationRes;
  String? brokerIdFk;
  String? brokerPercentage;
  dynamic flatAadharDoc;
  dynamic flatPanDoc;
  String? brokerGstPer;
  String? brokerGstValue;
  String? brokerTotal;
  String? flatBuyerDocUploadStatus;
  String? flatBuyerTowarIdFk;
  String? flatMarketValue;
  String? flagStumpCal;
  String? flatFundingType;
  String? flatBookingRemark;
  String? bankIdFk;
  String? inventryFlatName;
  String? flatApprovedByName;
  String? flatTotalValueWithGst;
  String? showValue;
  String? flatRequestedByName;
  List<ParkingList>? parkingList;

  ProjectBuyerDetailsList({
    this.flatBuyerId,
    this.projectIdFk,
    this.flatIdFk,
    this.userIdFk,
    this.flatBuyerName,
    this.flatBuyerName1,
    this.flatBuyerNumber,
    this.flatBuyerEmail,
    this.flatArea,
    this.flatRateCal,
    this.flatValue,
    this.podiumIdFk,
    this.noOfParking,
    this.flatBrokerageValue,
    this.flatStampDutyValue,
    this.flatStampDutyActualValue,
    this.flatGstValue,
    this.flatTotalValue,
    this.finshingType,
    this.flatBuyerPayementType,
    this.flatApprovedById,
    this.buyerFlatStatus,
    this.buyerFlatUpatedAt,
    this.buyerFlatCreateAt,
    this.flatBuyerOrderNo,
    this.flatBuyerSerialNo,
    this.flatRequestDate,
    this.flatApprovedDate,
    this.flatAllotLetter,
    this.flagInvestor,
    this.aadharNo,
    this.panNo,
    this.flatGstPercentage,
    this.flatStumpPercentage,
    this.flatTdsPercentage,
    this.flatTotalWithoutGst,
    this.flatBuyerAddress1,
    this.flatBuyerAddress2,
    this.flatAutoEmailSend,
    this.requestCancelationRes,
    this.brokerIdFk,
    this.brokerPercentage,
    this.flatAadharDoc,
    this.flatPanDoc,
    this.brokerGstPer,
    this.brokerGstValue,
    this.brokerTotal,
    this.flatBuyerDocUploadStatus,
    this.flatBuyerTowarIdFk,
    this.flatMarketValue,
    this.flagStumpCal,
    this.flatFundingType,
    this.flatBookingRemark,
    this.bankIdFk,
    this.inventryFlatName,
    this.flatApprovedByName,
    this.flatTotalValueWithGst,
    this.showValue,
    this.flatRequestedByName,
    this.parkingList,
  });

  factory ProjectBuyerDetailsList.fromJson(Map<String, dynamic> json) => ProjectBuyerDetailsList(
    flatBuyerId: json["flat_buyer_id"],
    projectIdFk: json["project_id_fk"],
    flatIdFk: json["flat_id_fk"],
    userIdFk: json["user_id_fk"],
    flatBuyerName: json["flat_buyer_name"],
    flatBuyerName1: json["flat_buyer_name_1"],
    flatBuyerNumber: json["flat_buyer_number"],
    flatBuyerEmail: json["flat_buyer_email"],
    flatArea: json["flat_area"],
    flatRateCal: json["flat_rate_cal"],
    flatValue: json["flat_value"],
    podiumIdFk: json["podium_id_fk"],
    noOfParking: json["no_of_parking"],
    flatBrokerageValue: json["flat_brokerage_value"],
    flatStampDutyValue: json["flat_stamp_duty_value"],
    flatStampDutyActualValue: json["flat_stamp_duty_actual_value"],
    flatGstValue: json["flat_gst_value"],
    flatTotalValue: json["flat_total_value"],
    finshingType: json["finshing_type"],
    flatBuyerPayementType: json["flat_buyer_payement_type"],
    flatApprovedById: json["flat_approved_by_id"],
    buyerFlatStatus: json["buyer_flat_status"],
    buyerFlatUpatedAt: json["buyer_flat_upated_at"] == null ? null : DateTime.parse(json["buyer_flat_upated_at"]),
    buyerFlatCreateAt: json["buyer_flat_create_at"] == null ? null : DateTime.parse(json["buyer_flat_create_at"]),
    flatBuyerOrderNo: json["flat_buyer_order_no"],
    flatBuyerSerialNo: json["flat_buyer_serial_no"],
    flatRequestDate: json["flat_request_date"] == null ? null : DateTime.parse(json["flat_request_date"]),
    flatApprovedDate: json["flat_approved_date"] == null ? null : DateTime.parse(json["flat_approved_date"]),
    flatAllotLetter: json["flat_allot_letter"],
    flagInvestor: json["flag_investor"],
    aadharNo: json["aadhar_no"],
    panNo: json["pan_no"],
    flatGstPercentage: json["flat_gst_percentage"],
    flatStumpPercentage: json["flat_stump_percentage"],
    flatTdsPercentage: json["flat_tds_percentage"],
    flatTotalWithoutGst: json["flat_total_without_gst"],
    flatBuyerAddress1: json["flat_buyer_address1"],
    flatBuyerAddress2: json["flat_buyer_address2"],
    flatAutoEmailSend: json["flat_auto_email_send"],
    requestCancelationRes: json["request_cancelation_res"] ?? "",
    brokerIdFk: json["broker_id_fk"],
    brokerPercentage: json["broker_percentage"],
    flatAadharDoc: json["flat_aadhar_doc"],
    flatPanDoc: json["flat_pan_doc"],
    brokerGstPer: json["broker_gst_per"],
    brokerGstValue: json["broker_gst_value"],
    brokerTotal: json["broker_total"],
    flatBuyerDocUploadStatus: json["flat_buyer_doc_upload_status"],
    flatBuyerTowarIdFk: json["flat_buyer_towar_id_fk"],
    flatMarketValue: json["flat_market_value"],
    flagStumpCal: json["flag_stump_cal"],
    flatFundingType: json["flat_funding_type"],
    flatBookingRemark: json["flat_booking_remark"],
    bankIdFk: json["bank_id_fk"],
    inventryFlatName: json["inventry_flat_name"],
    flatApprovedByName: json["flat_approved_by_name"],
    flatTotalValueWithGst: json["flat_total_value_with_gst"],
    showValue: json["show_value"],
    flatRequestedByName: json["flat_requested_by_name"],
    parkingList: json["parking_list"] == null
        ? []
        : List<ParkingList>.from(
        json["parking_list"]!.map((x) => ParkingList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "flat_buyer_id": flatBuyerId,
    "project_id_fk": projectIdFk,
    "flat_id_fk": flatIdFk,
    "user_id_fk": userIdFk,
    "flat_buyer_name": flatBuyerName,
    "flat_buyer_name_1": flatBuyerName1,
    "flat_buyer_number": flatBuyerNumber,
    "flat_buyer_email": flatBuyerEmail,
    "flat_area": flatArea,
    "flat_rate_cal": flatRateCal,
    "flat_value": flatValue,
    "podium_id_fk": podiumIdFk,
    "no_of_parking": noOfParking,
    "flat_brokerage_value": flatBrokerageValue,
    "flat_stamp_duty_value": flatStampDutyValue,
    "flat_stamp_duty_actual_value": flatStampDutyActualValue,
    "flat_gst_value": flatGstValue,
    "flat_total_value": flatTotalValue,
    "finshing_type": finshingType,
    "flat_buyer_payement_type": flatBuyerPayementType,
    "flat_approved_by_id": flatApprovedById,
    "buyer_flat_status": buyerFlatStatus,
    "buyer_flat_upated_at": buyerFlatUpatedAt?.toIso8601String(),
    "buyer_flat_create_at": buyerFlatCreateAt?.toIso8601String(),
    "flat_buyer_order_no": flatBuyerOrderNo,
    "flat_buyer_serial_no": flatBuyerSerialNo,
    "flat_request_date": "${flatRequestDate!.year.toString().padLeft(4, '0')}-${flatRequestDate!.month.toString().padLeft(2, '0')}-${flatRequestDate!.day.toString().padLeft(2, '0')}",
    "flat_approved_date": "${flatApprovedDate!.year.toString().padLeft(4, '0')}-${flatApprovedDate!.month.toString().padLeft(2, '0')}-${flatApprovedDate!.day.toString().padLeft(2, '0')}",
    "flat_allot_letter": flatAllotLetter,
    "flag_investor": flagInvestor,
    "aadhar_no": aadharNo,
    "pan_no": panNo,
    "flat_gst_percentage": flatGstPercentage,
    "flat_stump_percentage": flatStumpPercentage,
    "flat_tds_percentage": flatTdsPercentage,
    "flat_total_without_gst": flatTotalWithoutGst,
    "flat_buyer_address1": flatBuyerAddress1,
    "flat_buyer_address2": flatBuyerAddress2,
    "flat_auto_email_send": flatAutoEmailSend,
    "request_cancelation_res": requestCancelationRes,
    "broker_id_fk": brokerIdFk,
    "broker_percentage": brokerPercentage,
    "flat_aadhar_doc": flatAadharDoc,
    "flat_pan_doc": flatPanDoc,
    "broker_gst_per": brokerGstPer,
    "broker_gst_value": brokerGstValue,
    "broker_total": brokerTotal,
    "flat_buyer_doc_upload_status": flatBuyerDocUploadStatus,
    "flat_buyer_towar_id_fk": flatBuyerTowarIdFk,
    "flat_market_value": flatMarketValue,
    "flag_stump_cal": flagStumpCal,
    "flat_funding_type": flatFundingType,
    "flat_booking_remark": flatBookingRemark,
    "bank_id_fk": bankIdFk,
    "inventry_flat_name": inventryFlatName,
    "flat_approved_by_name": flatApprovedByName,
    "flat_total_value_with_gst": flatTotalValueWithGst,
    "show_value": showValue,
    "flat_requested_by_name": flatRequestedByName,
    "parking_list": parkingList == null
        ? []
        : List<dynamic>.from(parkingList!.map((x) => x)),
  };
}*/
