// To parse this JSON data, do
//
//     final getRehabTenant = getRehabTenantFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_flat_list_by_project.dart';

GetRehabTenant getRehabTenantFromJson(String str) =>
    GetRehabTenant.fromJson(json.decode(str));

String getRehabTenantToJson(GetRehabTenant data) => json.encode(data.toJson());

class GetRehabTenant {
  GetRehabTenantResponse? response;

  GetRehabTenant({this.response});

  factory GetRehabTenant.fromJson(Map<String, dynamic> json) => GetRehabTenant(
        response: json["Response"] == null
            ? null
            : GetRehabTenantResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetRehabTenantResponse {
  String? errorCode;
  String? msg;
  List<FlatDetail>? flatDetails;
  String? totalTenntPaid;
  List<ParkingList>? parkingList;
  List<TenentDetail>? tenentDetails;
  GstStumpDuty? gstStumpDuty;
  // TenentFlatDetails? tenentFlatDetails;

  GetRehabTenantResponse({
    this.errorCode,
    this.msg,
    this.flatDetails,
    this.totalTenntPaid,
    this.parkingList,
    this.tenentDetails,
    this.gstStumpDuty,
    // this.tenentFlatDetails,
  });

  factory GetRehabTenantResponse.fromJson(Map<String, dynamic> json) =>
      GetRehabTenantResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        flatDetails: json["flat_details"] == null
            ? []
            : List<FlatDetail>.from(
                json["flat_details"]!.map((x) => FlatDetail.fromJson(x))),
        totalTenntPaid: json["total_tennt_paid"],
        parkingList: json["parking_list"] == null
            ? []
            : List<ParkingList>.from(
                json["parking_list"]!.map((x) => ParkingList.fromJson(x))),
        tenentDetails: json["tenent_details"] == null
            ? []
            : List<TenentDetail>.from(
                json["tenent_details"]!.map((x) => TenentDetail.fromJson(x))),
        gstStumpDuty: json["gst_stump_duty"] == null
            ? null
            : GstStumpDuty.fromJson(json["gst_stump_duty"]),
        // tenentFlatDetails: json["tenent_flat_details"] == null
        //     ? null
        //     : TenentFlatDetails.fromJson(json["tenent_flat_details"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "flat_details": flatDetails == null
            ? []
            : List<dynamic>.from(flatDetails!.map((x) => x.toJson())),
        "total_tennt_paid": totalTenntPaid,
        "parking_list": parkingList == null
            ? []
            : List<dynamic>.from(parkingList!.map((x) => x.toJson())),
        "tenent_details": tenentDetails == null
            ? []
            : List<dynamic>.from(tenentDetails!.map((x) => x.toJson())),
        "gst_stump_duty": gstStumpDuty?.toJson(),
        // "tenent_flat_details": tenentFlatDetails?.toJson(),
      };
}

class TenentFlatDetails {
  List<BuyerContactDetail>? buyerContactDetails;
  List<FlatBuyerDetail>? flatBuyerDetails;
  String? otherChargesFlag;
  String? flatArea;
  String? flatRateCal;
  String? flatValue;
  String? noOfParking;
  List<BuyerPaymentDetail>? buyerPaymentDetails;
  PaymentBottomBar? paymentBottomBar;
  List<dynamic>? flatPaymentHistory;
  dynamic buyerPaymentDetails1;
  List<PaymentType>? paymentType;
  String? flatPaymentAmount;
  List<dynamic>? arrRegistrationDoc;
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

  TenentFlatDetails({
    this.buyerContactDetails,
    this.flatBuyerDetails,
    this.otherChargesFlag,
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
  });

  factory TenentFlatDetails.fromJson(Map<String, dynamic> json) =>
      TenentFlatDetails(
        buyerContactDetails: json["buyer_contact_details"] == null
            ? []
            : List<BuyerContactDetail>.from(json["buyer_contact_details"]!
                .map((x) => BuyerContactDetail.fromJson(x))),
        flatBuyerDetails: json["flat_buyer_details"] == null
            ? []
            : List<FlatBuyerDetail>.from(json["flat_buyer_details"]!
                .map((x) => FlatBuyerDetail.fromJson(x))),
        otherChargesFlag: json["other_charges_flag"],
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
            : List<dynamic>.from(json["flat_payment_history"]!.map((x) => x)),
        buyerPaymentDetails1: json["buyer_payment_details1"],
        paymentType: json["payment_type"] == null
            ? []
            : List<PaymentType>.from(
                json["payment_type"]!.map((x) => PaymentType.fromJson(x))),
        flatPaymentAmount: json["flat_payment_amount"],
        arrRegistrationDoc: json["arr_registration_doc"] == null
            ? []
            : List<dynamic>.from(json["arr_registration_doc"]!.map((x) => x)),
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
      );

  Map<String, dynamic> toJson() => {
        "buyer_contact_details": buyerContactDetails == null
            ? []
            : List<dynamic>.from(buyerContactDetails!.map((x) => x.toJson())),
        "flat_buyer_details": flatBuyerDetails == null
            ? []
            : List<dynamic>.from(flatBuyerDetails!.map((x) => x.toJson())),
        "other_charges_flag": otherChargesFlag,
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
      };
}

class TenentDetail {
  String? tenantId;
  String? tenantName;
  String? tenantPanCard;
  String? roomNo;
  String? mobile;
  String? email;
  dynamic consort;
  dynamic paa;
  String? obtain;
  String? userResidnt;
  dynamic monthRent;
  String? numberAllocated;
  String? categoryIdFk;
  String? status;
  String? projectIdFk;
  String? towerIdFk;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? occuTenantName;
  String? occuMobile;
  String? occuEmail;
  String? tenantUserFlag;
  String? tenantExitArea;
  String? tenantProposedArea;
  String? tenantSrNo;
  String? origin;
  String? tenantReceiveAmount;
  String? proposedConsideration;
  String? proposedRatePerSqft;
  String? tenentLampAdjusted;
  String? balanceConsideration;
  String? tenantStampduty;
  String? tenantStampper;
  String? tenantRemark;
  String? tenantGstAmount;
  String? tenentFocArea;
  String? tenentMahadArea;
  String? tenentPurchaseArea;
  String? tenentFocAreaPerc;
  String? registrationFees;
  String? tenantGstPercentage;
  // String ? tenant_flag_opt;
  String? tenantFlagOpt;
  String? tenantTdsAmount;

  TenentDetail({
    this.tenantId,
    this.tenantName,
    this.tenantPanCard,
    this.roomNo,
    this.mobile,
    this.email,
    this.consort,
    this.paa,
    this.obtain,
    this.userResidnt,
    this.monthRent,
    this.numberAllocated,
    this.categoryIdFk,
    this.status,
    this.projectIdFk,
    this.towerIdFk,
    this.createdAt,
    this.updatedAt,
    this.occuTenantName,
    this.occuMobile,
    this.occuEmail,
    this.tenantUserFlag,
    this.tenantExitArea,
    this.tenantProposedArea,
    this.tenantSrNo,
    this.origin,
    this.tenantReceiveAmount,
    this.proposedConsideration,
    this.proposedRatePerSqft,
    this.tenentLampAdjusted,
    this.balanceConsideration,
    this.tenantStampduty,
    this.tenantStampper,
    this.tenantRemark,
    this.tenantGstAmount,
    this.tenentFocArea,
    this.tenentMahadArea,
    this.tenentPurchaseArea,
    this.tenentFocAreaPerc,
    this.registrationFees,
    this.tenantGstPercentage,
    this.tenantFlagOpt,
    this.tenantTdsAmount,
  });

  factory TenentDetail.fromJson(Map<String, dynamic> json) => TenentDetail(
      tenantId: json["tenant_id"],
      tenantName: json["tenant_name"],
      tenantPanCard: json["tenant_pan_card"],
      roomNo: json["room_no"],
      mobile: json["mobile"],
      email: json["email"],
      consort: json["consort"],
      paa: json["paa"],
      obtain: json["obtain"],
      userResidnt: json["user_residnt"],
      monthRent: json["month_rent"],
      numberAllocated: json["number_allocated"],
      categoryIdFk: json["category_id_fk"],
      status: json["status"],
      projectIdFk: json["project_id_fk"],
      towerIdFk: json["tower_id_fk"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      occuTenantName: json["occu_tenant_name"],
      occuMobile: json["occu_mobile"],
      occuEmail: json["occu_email"],
      tenantUserFlag: json["tenant_user_flag"],
      tenantExitArea: json["tenant_exit_area"],
      tenantProposedArea: json["tenant_proposed_area"],
      tenantSrNo: json["tenant_sr_no"],
      origin: json["origin"],
      tenantReceiveAmount: json["tenant_receive_amount"],
      proposedConsideration: json["proposed_consideration"],
      proposedRatePerSqft: json["proposed_rate_per_sqft"],
      tenentLampAdjusted: json["tenent_lamp_adjusted"],
      balanceConsideration: json["balance_consideration"],
      tenantStampduty: json["tenant_stampduty"],
      tenantStampper: json["tenant_stampper"],
      tenantRemark: json["tenant_remark"],
      tenantGstAmount: json["tenant_gst_amount"],
      tenentFocArea: json["tenent_foc_area"],
      tenentMahadArea: json["tenent_mahad_area"],
      tenentPurchaseArea: json["tenent_purchase_area"],
      tenentFocAreaPerc: json["tenent_foc_area_perc"],
      registrationFees: json["registration_fees"],
      tenantGstPercentage: json["tenant_gst_percentage"],
      tenantFlagOpt: json["tenant_flag_opt"],
      tenantTdsAmount: json['tenant_tds_amount']);

  Map<String, dynamic> toJson() => {
        "tenant_id": tenantId,
        "tenant_name": tenantName,
        "tenant_pan_card": tenantPanCard,
        "room_no": roomNo,
        "mobile": mobile,
        "email": email,
        "consort": consort,
        "paa": paa,
        "obtain": obtain,
        "user_residnt": userResidnt,
        "month_rent": monthRent,
        "number_allocated": numberAllocated,
        "category_id_fk": categoryIdFk,
        "status": status,
        "project_id_fk": projectIdFk,
        "tower_id_fk": towerIdFk,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "occu_tenant_name": occuTenantName,
        "occu_mobile": occuMobile,
        "occu_email": occuEmail,
        "tenant_user_flag": tenantUserFlag,
        "tenant_exit_area": tenantExitArea,
        "tenant_proposed_area": tenantProposedArea,
        "tenant_sr_no": tenantSrNo,
        "origin": origin,
        "tenant_receive_amount": tenantReceiveAmount,
        "proposed_consideration": proposedConsideration,
        "proposed_rate_per_sqft": proposedRatePerSqft,
        "tenent_lamp_adjusted": tenentLampAdjusted,
        "balance_consideration": balanceConsideration,
        "tenant_stampduty": tenantStampduty,
        "tenant_stampper": tenantStampper,
        "tenant_remark": tenantRemark,
        "tenant_gst_amount": tenantGstAmount,
        "tenent_foc_area": tenentFocArea,
        "tenent_mahad_area": tenentMahadArea,
        "tenent_purchase_area": tenentPurchaseArea,
        "tenent_foc_area_perc": tenentFocAreaPerc,
        "registration_fees": registrationFees,
        "tenantGstPercentage": tenantGstPercentage,
        "tenant_flag_opt": tenantFlagOpt,
        "tenant_tds_amount": tenantTdsAmount,

        // tenantTdsAmount: json['tenant_tds_amount']
      };
}

class FlatDetail {
  String? mstInventryFlatId;
  String? invertryFloorIdFk;
  String? inventryFlatValue;
  String? inventyParkingNumber;
  String? inventryFlatName;

  FlatDetail({
    this.mstInventryFlatId,
    this.invertryFloorIdFk,
    this.inventryFlatValue,
    this.inventyParkingNumber,
    this.inventryFlatName,
  });

  factory FlatDetail.fromJson(Map<String, dynamic> json) => FlatDetail(
        mstInventryFlatId: json["mst_inventry_flat_id"],
        invertryFloorIdFk: json["invertry_floor_id_fk"],
        inventryFlatValue: json["inventry_flat_value"],
        inventyParkingNumber: json["inventy_parking_number"],
        inventryFlatName: json["inventry_flat_name"],
      );

  Map<String, dynamic> toJson() => {
        "mst_inventry_flat_id": mstInventryFlatId,
        "invertry_floor_id_fk": invertryFloorIdFk,
        "inventry_flat_value": inventryFlatValue,
        "inventy_parking_number": inventyParkingNumber,
        "inventry_flat_name": inventryFlatName,
      };
}

class GstStumpDuty {
  String? stampDurty;
  String? gstPer;
  String? tdsPercentage;

  GstStumpDuty({
    this.stampDurty,
    this.gstPer,
    this.tdsPercentage,
  });

  factory GstStumpDuty.fromJson(Map<String, dynamic> json) => GstStumpDuty(
        stampDurty: json["stamp_durty"],
        gstPer: json["gst_per"],
        tdsPercentage: json["tds_percentage"],
      );

  Map<String, dynamic> toJson() => {
        "stamp_durty": stampDurty,
        "gst_per": gstPer,
        "tds_percentage": tdsPercentage,
      };
}

// class ParkingList {
//   String? parkingSerialNo;
//   String? mstParkingId;

//   ParkingList({
//     this.parkingSerialNo,
//     this.mstParkingId,
//   });

//   factory ParkingList.fromJson(Map<String, dynamic> json) => ParkingList(
//         parkingSerialNo: json["parking_serial_no"],
//         mstParkingId: json["mst_parking_id"],
//       );

//   Map<String, dynamic> toJson() => {
//         "parking_serial_no": parkingSerialNo,
//         "mst_parking_id": mstParkingId,
//       };
// }
class BuyerContactDetail {
  String? id;
  String? buyerName;
  String? mobileNumber;
  String? emailid;
  String? address;
  dynamic address1;
  String? address2;
  String? flatNo;
  String? flatId;
  String? flatArea;
  String? bankName;
  String? bankAccountHolderName;
  String? bankAccountNo;
  String? bankIfsc;
  String? bankBranch;
  String? pan;
  String? aadhar;

  BuyerContactDetail({
    this.id,
    this.buyerName,
    this.mobileNumber,
    this.emailid,
    this.address,
    this.address1,
    this.address2,
    this.flatNo,
    this.flatId,
    this.flatArea,
    this.bankName,
    this.bankAccountHolderName,
    this.bankAccountNo,
    this.bankIfsc,
    this.bankBranch,
    this.pan,
    this.aadhar,
  });

  factory BuyerContactDetail.fromJson(Map<String, dynamic> json) =>
      BuyerContactDetail(
        id: json["id"],
        buyerName: json["buyer_name"],
        mobileNumber: json["mobile_number"],
        emailid: json["emailid"],
        address: json["address"],
        address1: json["address1"],
        address2: json["address2"],
        flatNo: json["flatNo"],
        flatId: json["flat_id"],
        flatArea: json["flatArea"],
        bankName: json["bank_name"],
        bankAccountHolderName: json["bank_account_holder_name"],
        bankAccountNo: json["bank_account_no"],
        bankIfsc: json["bank_ifsc"],
        bankBranch: json["bank_branch"],
        pan: json["pan"],
        aadhar: json["aadhar"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "buyer_name": buyerName,
        "mobile_number": mobileNumber,
        "emailid": emailid,
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
      };
}

class FlatBuyerDetail {
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
  String? flatTdsValue;
  String? flatTotalWithoutGst;
  String? flatBuyerAddress1;
  dynamic flatBuyerAddress2;
  String? flatBuyerAddress3;
  String? flatBuyerGstNo;
  String? flatAutoEmailSend;
  dynamic requestCancelationRes;
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
  dynamic registrationDate;
  String? fileDelete;
  String? alotFileDelete;
  String? panFileDelete;
  String? adFileDelete;
  String? flatBuyerStatusRemark;
  String? reservedById;
  String? reservedDate;
  String? ledgerEmailMessageId;
  String? buyerBankName;
  String? buyerBankAccountHolderName;
  String? buyerBankAccountNo;
  String? buyerBankIfsc;
  String? buyerBankBranch;
  String? tenantIdFk;
  String? flatbuyerMessageId;
  String? futureDemandDays;
  String? flatBuyerImg;
  String? allotSendDate;
  dynamic registrationReceiptNo;
  List<dynamic>? parkingList;
  List<SelectedFlat>? selectedFlat;

  FlatBuyerDetail({
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
    this.flatTdsValue,
    this.flatTotalWithoutGst,
    this.flatBuyerAddress1,
    this.flatBuyerAddress2,
    this.flatBuyerAddress3,
    this.flatBuyerGstNo,
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
    this.registrationDate,
    this.fileDelete,
    this.alotFileDelete,
    this.panFileDelete,
    this.adFileDelete,
    this.flatBuyerStatusRemark,
    this.reservedById,
    this.reservedDate,
    this.ledgerEmailMessageId,
    this.buyerBankName,
    this.buyerBankAccountHolderName,
    this.buyerBankAccountNo,
    this.buyerBankIfsc,
    this.buyerBankBranch,
    this.tenantIdFk,
    this.flatbuyerMessageId,
    this.futureDemandDays,
    this.flatBuyerImg,
    this.allotSendDate,
    this.registrationReceiptNo,
    this.parkingList,
    this.selectedFlat,
  });

  factory FlatBuyerDetail.fromJson(Map<String, dynamic> json) =>
      FlatBuyerDetail(
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
        buyerFlatUpatedAt: json["buyer_flat_upated_at"] == null
            ? null
            : DateTime.parse(json["buyer_flat_upated_at"]),
        buyerFlatCreateAt: json["buyer_flat_create_at"] == null
            ? null
            : DateTime.parse(json["buyer_flat_create_at"]),
        flatBuyerOrderNo: json["flat_buyer_order_no"],
        flatBuyerSerialNo: json["flat_buyer_serial_no"],
        flatRequestDate: json["flat_request_date"] == null
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
        flatTdsValue: json["flat_tds_value"],
        flatTotalWithoutGst: json["flat_total_without_gst"],
        flatBuyerAddress1: json["flat_buyer_address1"],
        flatBuyerAddress2: json["flat_buyer_address2"],
        flatBuyerAddress3: json["flat_buyer_address3"],
        flatBuyerGstNo: json["flat_buyer_gst_no"],
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
        registrationDate: json["registration_date"],
        fileDelete: json["file_delete"],
        alotFileDelete: json["alot_file_delete"],
        panFileDelete: json["pan_file_delete"],
        adFileDelete: json["ad_file_delete"],
        flatBuyerStatusRemark: json["flat_buyer_status_remark"],
        reservedById: json["reserved_by_id"],
        reservedDate: json["reserved_date"],
        ledgerEmailMessageId: json["ledger_email_messageId"],
        buyerBankName: json["buyer_bank_name"],
        buyerBankAccountHolderName: json["buyer_bank_account_holder_name"],
        buyerBankAccountNo: json["buyer_bank_account_no"],
        buyerBankIfsc: json["buyer_bank_ifsc"],
        buyerBankBranch: json["buyer_bank_branch"],
        tenantIdFk: json["tenant_id_fk"],
        flatbuyerMessageId: json["flatbuyer_MessageId"],
        futureDemandDays: json["future_demand_days"],
        flatBuyerImg: json["flat_buyer_img"],
        allotSendDate: json["allot_send_date"],
        registrationReceiptNo: json["registration_receipt_no"],
        parkingList: json["parking_list"] == null
            ? []
            : List<dynamic>.from(json["parking_list"]!.map((x) => x)),
        selectedFlat: json["selected_flat"] == null
            ? []
            : List<SelectedFlat>.from(
                json["selected_flat"]!.map((x) => SelectedFlat.fromJson(x))),
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
        "flat_request_date":
            "${flatRequestDate!.year.toString().padLeft(4, '0')}-${flatRequestDate!.month.toString().padLeft(2, '0')}-${flatRequestDate!.day.toString().padLeft(2, '0')}",
        "flat_approved_date":
            "${flatApprovedDate!.year.toString().padLeft(4, '0')}-${flatApprovedDate!.month.toString().padLeft(2, '0')}-${flatApprovedDate!.day.toString().padLeft(2, '0')}",
        "flat_allot_letter": flatAllotLetter,
        "flag_investor": flagInvestor,
        "aadhar_no": aadharNo,
        "pan_no": panNo,
        "flat_gst_percentage": flatGstPercentage,
        "flat_stump_percentage": flatStumpPercentage,
        "flat_tds_percentage": flatTdsPercentage,
        "flat_tds_value": flatTdsValue,
        "flat_total_without_gst": flatTotalWithoutGst,
        "flat_buyer_address1": flatBuyerAddress1,
        "flat_buyer_address2": flatBuyerAddress2,
        "flat_buyer_address3": flatBuyerAddress3,
        "flat_buyer_gst_no": flatBuyerGstNo,
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
        "registration_date": registrationDate,
        "file_delete": fileDelete,
        "alot_file_delete": alotFileDelete,
        "pan_file_delete": panFileDelete,
        "ad_file_delete": adFileDelete,
        "flat_buyer_status_remark": flatBuyerStatusRemark,
        "reserved_by_id": reservedById,
        "reserved_date": reservedDate,
        "ledger_email_messageId": ledgerEmailMessageId,
        "buyer_bank_name": buyerBankName,
        "buyer_bank_account_holder_name": buyerBankAccountHolderName,
        "buyer_bank_account_no": buyerBankAccountNo,
        "buyer_bank_ifsc": buyerBankIfsc,
        "buyer_bank_branch": buyerBankBranch,
        "tenant_id_fk": tenantIdFk,
        "flatbuyer_MessageId": flatbuyerMessageId,
        "future_demand_days": futureDemandDays,
        "flat_buyer_img": flatBuyerImg,
        "allot_send_date": allotSendDate,
        "registration_receipt_no": registrationReceiptNo,
        "parking_list": parkingList == null
            ? []
            : List<dynamic>.from(parkingList!.map((x) => x)),
        "selected_flat": selectedFlat == null
            ? []
            : List<dynamic>.from(selectedFlat!.map((x) => x.toJson())),
      };
}

class SelectedFlat {
  String? flatName;
  String? flatId;
  String? inventryFlatType;
  String? inventryFlatName;
  String? flatArea;
  String? masonryIdFk;
  String? inventyParkingNumber;
  String? floorTypeId;
  List<ParkingList>? parkingList;

  SelectedFlat({
    this.flatName,
    this.flatId,
    this.inventryFlatType,
    this.inventryFlatName,
    this.flatArea,
    this.masonryIdFk,
    this.inventyParkingNumber,
    this.floorTypeId,
    this.parkingList,
  });

  factory SelectedFlat.fromJson(Map<String, dynamic> json) => SelectedFlat(
        flatName: json["flat_name"],
        flatId: json["flat_id"],
        inventryFlatType: json["inventry_flat_type"],
        inventryFlatName: json["inventry_flat_name"],
        flatArea: json["flat_area"],
        masonryIdFk: json["masonry_id_fk"],
        inventyParkingNumber: json["inventy_parking_number"],
        floorTypeId: json["floor_type_id"],
        parkingList: json["parking_list"] == null
            ? []
            : List<ParkingList>.from(
                json["parking_list"]!.map((x) => ParkingList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "flat_name": flatName,
        "flat_id": flatId,
        "inventry_flat_type": inventryFlatType,
        "inventry_flat_name": inventryFlatName,
        "flat_area": flatArea,
        "masonry_id_fk": masonryIdFk,
        "inventy_parking_number": inventyParkingNumber,
        "floor_type_id": floorTypeId,
        "parking_list": parkingList == null
            ? []
            : List<dynamic>.from(parkingList!.map((x) => x.toJson())),
      };
}

class BuyerPaymentDetail {
  String? mstFlatPaymentId;
  String? flatBuyerIdFk;
  String? masonryIdFk;
  DateTime? flatPaymentDate;
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
  String? flatPaymentMessageId;
  String? flatPaymentTdsAmount;

  BuyerPaymentDetail({
    this.mstFlatPaymentId,
    this.flatBuyerIdFk,
    this.masonryIdFk,
    this.flatPaymentDate,
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
    this.flatPaymentMessageId,
    this.flatPaymentTdsAmount,
  });

  factory BuyerPaymentDetail.fromJson(Map<String, dynamic> json) =>
      BuyerPaymentDetail(
        mstFlatPaymentId: json["mst_flat_payment_id"],
        flatBuyerIdFk: json["flat_buyer_id_fk"],
        masonryIdFk: json["masonry_id_fk"],
        flatPaymentDate: json["flat_payment_date"] == null
            ? null
            : DateTime.parse(json["flat_payment_date"]),
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
        flatPaymentMessageId: json["flat_payment_messageId"],
        flatPaymentTdsAmount: json["flat_payment_tds_amount"],
      );

  Map<String, dynamic> toJson() => {
        "mst_flat_payment_id": mstFlatPaymentId,
        "flat_buyer_id_fk": flatBuyerIdFk,
        "masonry_id_fk": masonryIdFk,
        "flat_payment_date":
            "${flatPaymentDate!.year.toString().padLeft(4, '0')}-${flatPaymentDate!.month.toString().padLeft(2, '0')}-${flatPaymentDate!.day.toString().padLeft(2, '0')}",
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
        "flat_payment_messageId": flatPaymentMessageId,
        "flat_payment_tds_amount": flatPaymentTdsAmount,
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
