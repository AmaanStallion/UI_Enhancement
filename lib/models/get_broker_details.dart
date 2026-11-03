// To parse this JSON data, do
//
//     final getBrokerDetails = getBrokerDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stallion/models/get_flat_list_by_project.dart';

GetBrokerDetails getBrokerDetailsFromJson(String str) =>
    GetBrokerDetails.fromJson(json.decode(str));

String getBrokerDetailsToJson(GetBrokerDetails data) =>
    json.encode(data.toJson());

class GetBrokerDetails {
  GetBrokerDetailsResponse? response;

  GetBrokerDetails({
    this.response,
  });

  factory GetBrokerDetails.fromJson(Map<String, dynamic> json) =>
      GetBrokerDetails(
        response: json["Response"] == null
            ? null
            : GetBrokerDetailsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetBrokerDetailsResponse {
  String? errorCode;
  String? msg;
  List<FlatBuyerRequest>? flatBuyerRequest;
  String? offset;

  GetBrokerDetailsResponse({
    this.errorCode,
    this.msg,
    this.flatBuyerRequest,
    this.offset,
  });

  factory GetBrokerDetailsResponse.fromJson(Map<String, dynamic> json) =>
      GetBrokerDetailsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        flatBuyerRequest: json["flat_buyer_request"] == null
            ? []
            : List<FlatBuyerRequest>.from(json["flat_buyer_request"]!
                .map((x) => FlatBuyerRequest.fromJson(x))),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "flat_buyer_request": flatBuyerRequest == null
            ? []
            : List<dynamic>.from(flatBuyerRequest!.map((x) => x.toJson())),
        "offset": offset,
      };
}

class FlatBuyerRequest {
  String? tenantIdFk;
  String? flatBuyerId;
  String? projectIdFk;
  String? flatIdFk;
  String? userIdFk;
  String? showValue;
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
  String? flatAadharDoc;
  String? flatPanDoc;
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
  String? brokerName;
  String? gstFlatTotalValue;
  List<List<CustomCharge>>? customCharges;
  String? brokerTotalPaid;
  List<ParkingList>? parkingList;
  List<FlatList>? selectedFlat = [];
  String? docUpload;
  String? flatRequestedByName;
  List<MemberDetail>? memberDetails;
  String? reApprovedReson;
  String? flatTotalValueWithGst;

  String? flatReservedByName;
  DateTime? reservedDate;
  List<FlatBuyerInfo>? buyerContactDetails;
  TextEditingController? textEditingController;
  String? mobile_number;
  String? penaltyFlag;
  String? flatTdsValue;
  String? flatBookingType;

  FlatBuyerRequest({
    this.flatBuyerId,
    this.projectIdFk,
    this.flatIdFk,
    this.userIdFk,
    this.showValue,
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
    this.brokerName,
    this.gstFlatTotalValue,
    this.customCharges,
    this.brokerTotalPaid,
    this.parkingList,
    this.selectedFlat,
    this.docUpload,
    this.flatRequestedByName,
    this.reApprovedReson,
    this.flatTotalValueWithGst,
    this.memberDetails,
    this.reservedDate,
    this.flatReservedByName,
    this.buyerContactDetails,
    this.textEditingController,
    this.mobile_number,
    this.tenantIdFk,
    this.penaltyFlag,
    this.flatTdsValue,
    this.flatBookingType,
  });

  factory FlatBuyerRequest.fromJson(Map<String, dynamic> json) =>
      FlatBuyerRequest(
        flatBuyerId: json["flat_buyer_id"],
        projectIdFk: json["project_id_fk"],
        flatIdFk: json["flat_id_fk"],
        userIdFk: json["user_id_fk"],
        showValue: json["show_value"],
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
        buyerFlatUpatedAt: json["buyer_flat_upated_at"] == null
            ? null
            : DateTime.parse(json["buyer_flat_upated_at"]),
        buyerFlatCreateAt: json["buyer_flat_create_at"] == null
            ? null
            : DateTime.parse(json["buyer_flat_create_at"]),
        flatBuyerOrderNo: json["flat_buyer_order_no"],
        flatBuyerSerialNo: json["flat_buyer_serial_no"],
        flatRequestDate:
            json["flat_request_date"] == null || json["flat_request_date"] == ''
                ? null
                : DateTime.parse(json["flat_request_date"]),
        flatApprovedDate: json["flat_approved_date"] == null
            ? null
            : DateTime.parse(json["flat_approved_date"]),
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
        requestCancelationRes: json["request_cancelation_res"],
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
        brokerName: json["broker_name"],
        gstFlatTotalValue: json["gst_flat_total_value"],
        customCharges: json["custom_charges"] == null
            ? []
            : List<List<CustomCharge>>.from(json["custom_charges"]!.map((x) =>
                List<CustomCharge>.from(
                    x.map((x) => CustomCharge.fromJson(x))))),
        brokerTotalPaid: json["broker_total_paid"],
        parkingList: json["parking_list"] == null
            ? []
            : List<ParkingList>.from(
                json["parking_list"]!.map((x) => ParkingList.fromJson(x))),
        selectedFlat: json["selected_flat"] == null
            ? []
            : List<FlatList>.from(
                json["selected_flat"]!.map((x) => FlatList.fromJson(x))),
        docUpload: json["doc_upload"],
        flatRequestedByName: json["flat_requested_by_name"],
        reApprovedReson: json["re_approved_reson"],
        flatTotalValueWithGst: json["flat_total_value_with_gst"],
        memberDetails: json["member_details"] == null
            ? []
            : List<MemberDetail>.from(
                json["member_details"]?.map((x) => MemberDetail.fromJson(x))),
        flatReservedByName: json["flat_reserved_by_name"],
        // reservedDate: json["reserved_date"],
        reservedDate:
            json["reserved_date"] == null || json["reserved_date"] == ''
                ? null
                : DateTime.parse(json["reserved_date"]),
        textEditingController: TextEditingController(),

        buyerContactDetails: json["buyer_contact_details"] == null
            ? []
            : List<FlatBuyerInfo>.from(json["buyer_contact_details"]!
                .map((x) => FlatBuyerInfo.fromJson(x))),
        mobile_number: json["mobile_number"], tenantIdFk: json["tenant_id_fk"],
        penaltyFlag: json["penalty_flag"],
        flatTdsValue: json["flat_tds_value"],
        flatBookingType: json["flat_booking_type"],
      );
  Map<String, dynamic> toJson() => {
        "flat_buyer_id": flatBuyerId,
        "project_id_fk": projectIdFk,
        "flat_id_fk": flatIdFk,
        "user_id_fk": userIdFk,
        "show_value": showValue,
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
        "flat_request_date": flatRequestDate?.toIso8601String(),
        "flat_approved_date": flatApprovedDate?.toIso8601String(),
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
        "broker_name": brokerName,
        "gst_flat_total_value": gstFlatTotalValue,
        "custom_charges": customCharges
            ?.map((e) => e.map((c) => c.toJson()).toList())
            .toList(),
        "broker_total_paid": brokerTotalPaid,
        "parking_list": parkingList?.map((e) => e.toJson()).toList(),
        "selected_flat": selectedFlat?.map((e) => e.toJson()).toList(),
        "doc_upload": docUpload,
        "flat_requested_by_name": flatRequestedByName,
        "re_approved_reson": reApprovedReson,
        "flat_total_value_with_gst": flatTotalValueWithGst,
        "member_details": memberDetails?.map((e) => e.toJson()).toList(),
        "reserved_date": reservedDate?.toIso8601String(),
        "flat_reserved_by_name": flatReservedByName,
        "buyer_contact_details":
            buyerContactDetails?.map((e) => e.toJson()).toList(),
        "mobile_number": mobile_number,
        "tenant_id_fk": tenantIdFk,
        "flat_tds_value": flatTdsValue,
        "flat_booking_type": flatBookingType,
      };
}

class MemberDetail {
  String? memberShipId;
  String? flatBuyerIdFk;
  String? memberShipNo;
  String? memberFormNumber;
  String? memberDob;
  String? spouseName;
  String? spouseDob;
  String? childName1;
  String? child1Dob;
  String? childName2;
  String? child2Dob;
  String? weddingAniversary;
  String? residentialAddress;
  String? correspndenceAddress;
  String? exprectedWeddingYear;
  String? memberShipPeriod;
  String? memberShipStatus;
  String? memberStartNo;
  String? formStartNo;
  DateTime? memberShipUpdateAt;
  DateTime? memberShipCreatedAt;

  MemberDetail({
    this.memberShipId,
    this.flatBuyerIdFk,
    this.memberShipNo,
    this.memberFormNumber,
    this.memberDob,
    this.spouseName,
    this.spouseDob,
    this.childName1,
    this.child1Dob,
    this.childName2,
    this.child2Dob,
    this.weddingAniversary,
    this.residentialAddress,
    this.correspndenceAddress,
    this.exprectedWeddingYear,
    this.memberShipPeriod,
    this.memberShipStatus,
    this.memberStartNo,
    this.formStartNo,
    this.memberShipUpdateAt,
    this.memberShipCreatedAt,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json) => MemberDetail(
        memberShipId: json["member_ship_id"],
        flatBuyerIdFk: json["flat_buyer_id_fk"],
        memberShipNo: json["member_ship_no"],
        memberFormNumber: json["member_form_number"],
        memberDob: json["member_dob"],
        spouseName: json["spouse_name"],
        spouseDob: json["spouse_dob"],
        childName1: json["child_name_1"],
        child1Dob: json["child_1_dob"],
        childName2: json["child_name_2"],
        child2Dob: json["child_2_dob"],
        weddingAniversary: json["wedding_aniversary"],
        residentialAddress: json["residential_address"],
        correspndenceAddress: json["correspndence_address"],
        exprectedWeddingYear: json["exprected_wedding_year"],
        memberShipPeriod: json["member_ship_period"],
        memberShipStatus: json["member_ship_status"],
        memberStartNo: json["member_start_no"],
        formStartNo: json["form_start_no"],
        memberShipUpdateAt: json["member_ship_update_at"] == null
            ? null
            : DateTime.parse(json["member_ship_update_at"]),
        memberShipCreatedAt: json["member_ship_created_at"] == null
            ? null
            : DateTime.parse(json["member_ship_created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "member_ship_id": memberShipId,
        "flat_buyer_id_fk": flatBuyerIdFk,
        "member_ship_no": memberShipNo,
        "member_form_number": memberFormNumber,
        "member_dob": memberDob,
        "spouse_name": spouseName,
        "spouse_dob": spouseDob,
        "child_name_1": childName1,
        "child_1_dob": child1Dob,
        "child_name_2": childName2,
        "child_2_dob": child2Dob,
        "wedding_aniversary": weddingAniversary,
        "residential_address": residentialAddress,
        "correspndence_address": correspndenceAddress,
        "exprected_wedding_year": exprectedWeddingYear,
        "member_ship_period": memberShipPeriod,
        "member_ship_status": memberShipStatus,
        "member_start_no": memberStartNo,
        "form_start_no": formStartNo,
        "member_ship_update_at": memberShipUpdateAt?.toIso8601String(),
        "member_ship_created_at": memberShipCreatedAt?.toIso8601String(),
      };
}

// class CustomCharge {
//   String? calculated;
//   String? chargesId;
//   String? collected;
//   String? id;
//   String? value;
//   String? totalValue;
//   String? name;
//   String? chargesGst;
//   String? status;
//   String? unit;

//   CustomCharge({
// this.calculated,
// this.chargesId,
// this.collected,
// this.id,
// this.value,
// this.totalValue,
// this.name,
// this.chargesGst,
// this.status,
// this.unit,
//   });

//   factory CustomCharge.fromJson(Map<String, dynamic> json) => CustomCharge(
//         calculated: json["calculated"],
//         chargesId: json["charges_id"],
//         collected: json["collected"],
//         id: json["id"],
//         value: json["value"],
//         totalValue: json["total_value"],
//         name: json["name"],
//         chargesGst: json["charges_gst"],
//         status: json["status"],
//         unit: json["unit"],
//       );

//   Map<String, dynamic> toJson() => {
//         "calculated": calculated,
//         "charges_id": chargesId,
//         "collected": collected,
//         "id": id,
//         "value": value,
//         "total_value": totalValue,
//         "name": name,
//         "charges_gst": chargesGst,
//         "status": status,
//         "unit": unit,
//       };
// }

// class BuyerContactDetail {
//   String? id;
//   String? buyerName;
//   String? mobileNumber;
//   String? emailid;
//   String? address;
//   String? address1;
//   String? address2;
//   String? flatNo;
//   String? flatId;
//   String? flatArea;
//   String? bankName;
//   String? bankAccountHolderName;
//   String? bankAccountNo;
//   String? bankIfsc;
//   String? bankBranch;
//   String? pan;
//   String? aadhar;

//   BuyerContactDetail({
//     this.id,
//     this.buyerName,
//     this.mobileNumber,
//     this.emailid,
//     this.address,
//     this.address1,
//     this.address2,
//     this.flatNo,
//     this.flatId,
//     this.flatArea,
//     this.bankName,
//     this.bankAccountHolderName,
//     this.bankAccountNo,
//     this.bankIfsc,
//     this.bankBranch,
//     this.pan,
//     this.aadhar,
//   });

//   factory BuyerContactDetail.fromJson(Map<String, dynamic> json) =>
//       BuyerContactDetail(
//         id: json["id"],
//         buyerName: json["buyer_name"],
//         mobileNumber: json["mobile_number"],
//         emailid: json["emailid"],
//         address: json["address"],
//         address1: json["address1"],
//         address2: json["address2"],
//         flatNo: json["flatNo"],
//         flatId: json["flat_id"],
//         flatArea: json["flatArea"],
//         bankName: json["bank_name"],
//         bankAccountHolderName: json["bank_account_holder_name"],
//         bankAccountNo: json["bank_account_no"],
//         bankIfsc: json["bank_ifsc"],
//         bankBranch: json["bank_branch"],
//         pan: json["pan"],
//         aadhar: json["aadhar"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "buyer_name": buyerName,
//         "mobile_number": mobileNumber,
//         "emailid": emailid,
//         "address": address,
//         "address1": address1,
//         "address2": address2,
//         "flatNo": flatNo,
//         "flat_id": flatId,
//         "flatArea": flatArea,
//         "bank_name": bankName,
//         "bank_account_holder_name": bankAccountHolderName,
//         "bank_account_no": bankAccountNo,
//         "bank_ifsc": bankIfsc,
//         "bank_branch": bankBranch,
//         "pan": pan,
//         "aadhar": aadhar,
//       };
// }

class FlatBuyerInfo {
  String? id;
  String? buyerName;
  String? mobileNumber;
  String? emailId;
  String? address;
  String? address1;
  String? address2;
  String? flatNo;
  String? flatId;
  String? flatArea;
  // String? index;
  String? bankName;
  String? bankAccountHolderName;
  String? bankAccountNo;
  String? bankIfsc;
  String? bankBranch;
  String? pan;
  String? aadhar;
  String gstno;
  TextEditingController? textEditingController;

  FlatBuyerInfo({
    this.id = '',
    this.buyerName = '',
    this.mobileNumber = '',
    this.emailId = '',
    this.address = '',
    this.address1 = '',
    this.address2 = '',
    this.flatNo = '',
    this.flatId = '',
    this.flatArea = '',
    this.bankName = '',
    this.bankAccountHolderName = '',
    this.bankAccountNo = '',
    this.bankIfsc = '',
    this.bankBranch = '',
    this.pan = '',
    this.aadhar = '',
    this.textEditingController,
    this.gstno = '',
  });

  factory FlatBuyerInfo.fromJson(Map<String, dynamic> json) => FlatBuyerInfo(
        id: json["id"] ?? '',
        buyerName: json["buyer_name"] ?? '',
        mobileNumber: json["mobile_number"] ?? '',
        emailId: json["emailid"] ?? '',
        address: json["address"] ?? '',
        address1: json["address1"] ?? '',
        address2: json["address2"] ?? '',
        flatNo: json["flatNo"] ?? '',
        flatId: json["flat_id"] ?? '',
        flatArea: json["flatArea"] ?? '',
        bankName: json["bank_name"] ?? '',
        bankAccountHolderName: json["bank_account_holder_name"] ?? '',
        bankAccountNo: json["bank_account_no"] ?? '',
        bankIfsc: json["bank_ifsc"] ?? '',
        bankBranch: json["bank_branch"] ?? '',
        pan: json["pan"] ?? '',
        aadhar: json["aadhar"] ?? '',
        gstno: json["gstno"] ?? '',
        textEditingController: TextEditingController(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "buyer_name": buyerName,
        "mobile_number": mobileNumber,
        "emailid": emailId,
        "address": address,
        "address1": address1,
        "address2": address2,
        "flatNo": flatNo,
        "flat_id": flatId,
        "flatArea": flatArea,
        "bank_name": bankName,
        "bank_account_holder_name": bankAccountHolderName,
        "bank_account_no": bankAccountNo,
        "bank_ifsc": bankIfsc,
        "bank_branch": bankBranch,
        "pan": pan,
        "aadhar": aadhar,
        "gstno": gstno,
      };
}
