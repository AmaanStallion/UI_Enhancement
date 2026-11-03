// // To parse this JSON data, do
// //
// //     final getBuyerPaymentsDetailsNew = getBuyerPaymentsDetailsNewFromJson(jsonString);

// import 'dart:convert';

// import 'package:stallion/models/get_flat_list_by_project.dart';

// GetBuyerPaymentsDetailsNew getBuyerPaymentsDetailsNewFromJson(String str) =>
//     GetBuyerPaymentsDetailsNew.fromJson(json.decode(str));

// String getBuyerPaymentsDetailsNewToJson(GetBuyerPaymentsDetailsNew data) =>
//     json.encode(data.toJson());

// class GetBuyerPaymentsDetailsNew {
//   GetBuyerPaymentsDetailsNewResponse? response;

//   GetBuyerPaymentsDetailsNew({
//     this.response,
//   });

//   factory GetBuyerPaymentsDetailsNew.fromJson(Map<String, dynamic> json) =>
//       GetBuyerPaymentsDetailsNew(
//         response: json["Response"] == null
//             ? null
//             : GetBuyerPaymentsDetailsNewResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class GetBuyerPaymentsDetailsNewResponse {
//   String? errorCode;
//   String? msg;
//   List<BuyerContactDetail>? buyerContactDetails;
//   List<FlatBuyerDetail>? flatBuyerDetails;
//   String? otherChargesFlag;
//   String? flatArea;
//   String? flatRateCal;
//   String? flatValue;
//   String? noOfParking;
//   List<dynamic>? buyerPaymentDetails;
//   PaymentBottomBar? paymentBottomBar;
//   List<dynamic>? flatPaymentHistory;
//   int? buyerPaymentDetails1;
//   List<PaymentType>? paymentType;
//   String? flatPaymentAmount;
//   List<dynamic>? arrRegistrationDoc;
//   String? flatStumpDuty;
//   String? flatGstAmount;
//   String? flatTdsAmount;
//   String? flatStumpPercentage;
//   String? flatGstPercentage;
//   String? flatTdsPercentage;
//   String? flatTotalAmountDue;
//   List<List<CustomCharge>>? customCharges;
//   String? totalGstPaid;
//   String? totalGstPayable;
//   String? totalGstGenerated;
//   String? totalGstGeneratedHistry;
//   String? totalGstDue;

//   GetBuyerPaymentsDetailsNewResponse({
//     this.errorCode,
//     this.msg,
//     this.buyerContactDetails,
//     this.flatBuyerDetails,
//     this.otherChargesFlag,
//     this.flatArea,
//     this.flatRateCal,
//     this.flatValue,
//     this.noOfParking,
//     this.buyerPaymentDetails,
//     this.paymentBottomBar,
//     this.flatPaymentHistory,
//     this.buyerPaymentDetails1,
//     this.paymentType,
//     this.flatPaymentAmount,
//     this.arrRegistrationDoc,
//     this.flatStumpDuty,
//     this.flatGstAmount,
//     this.flatTdsAmount,
//     this.flatStumpPercentage,
//     this.flatGstPercentage,
//     this.flatTdsPercentage,
//     this.flatTotalAmountDue,
//     this.customCharges,
//     this.totalGstPaid,
//     this.totalGstPayable,
//     this.totalGstGenerated,
//     this.totalGstGeneratedHistry,
//     this.totalGstDue,
//   });

//   factory GetBuyerPaymentsDetailsNewResponse.fromJson(
//           Map<String, dynamic> json) =>
//       GetBuyerPaymentsDetailsNewResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         buyerContactDetails: json["buyer_contact_details"] == null
//             ? []
//             : List<BuyerContactDetail>.from(json["buyer_contact_details"]!
//                 .map((x) => BuyerContactDetail.fromJson(x))),
//         flatBuyerDetails: json["flat_buyer_details"] == null
//             ? []
//             : List<FlatBuyerDetail>.from(json["flat_buyer_details"]!
//                 .map((x) => FlatBuyerDetail.fromJson(x))),
//         otherChargesFlag: json["other_charges_flag"],
//         flatArea: json["flat_area"],
//         flatRateCal: json["flat_rate_cal"],
//         flatValue: json["flat_value"],
//         noOfParking: json["no_of_parking"],
//         buyerPaymentDetails: json["buyer_payment_details"] == null
//             ? []
//             : List<dynamic>.from(json["buyer_payment_details"]!.map((x) => x)),
//         paymentBottomBar: json["payment_bottom_bar"] == null
//             ? null
//             : PaymentBottomBar.fromJson(json["payment_bottom_bar"]),
//         flatPaymentHistory: json["flat_payment_history"] == null
//             ? []
//             : List<dynamic>.from(json["flat_payment_history"]!.map((x) => x)),
//         buyerPaymentDetails1: json["buyer_payment_details1"],
//         paymentType: json["payment_type"] == null
//             ? []
//             : List<PaymentType>.from(
//                 json["payment_type"]!.map((x) => PaymentType.fromJson(x))),
//         flatPaymentAmount: json["flat_payment_amount"],
//         arrRegistrationDoc: json["arr_registration_doc"] == null
//             ? []
//             : List<dynamic>.from(json["arr_registration_doc"]!.map((x) => x)),
//         flatStumpDuty: json["flat_stump_duty"],
//         flatGstAmount: json["flat_gst_amount"],
//         flatTdsAmount: json["flat_tds_amount"],
//         flatStumpPercentage: json["flat_stump_percentage"],
//         flatGstPercentage: json["flat_gst_percentage"],
//         flatTdsPercentage: json["flat_tds_percentage"],
//         flatTotalAmountDue: json["flat_total_amount_due"],
//         customCharges: json["custom_charges"] == null
//             ? []
//             : List<List<CustomCharge>>.from(json["custom_charges"]!.map((x) =>
//                 List<CustomCharge>.from(
//                     x.map((x) => CustomCharge.fromJson(x))))),
//         totalGstPaid: json["total_gst_paid"],
//         totalGstPayable: json["total_gst_payable"],
//         totalGstGenerated: json["total_gst_generated"],
//         totalGstGeneratedHistry: json["total_gst_generated_histry"],
//         totalGstDue: json["total_gst_due"],
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "buyer_contact_details": buyerContactDetails == null
//             ? []
//             : List<dynamic>.from(buyerContactDetails!.map((x) => x.toJson())),
//         "flat_buyer_details": flatBuyerDetails == null
//             ? []
//             : List<dynamic>.from(flatBuyerDetails!.map((x) => x.toJson())),
//         "other_charges_flag": otherChargesFlag,
//         "flat_area": flatArea,
//         "flat_rate_cal": flatRateCal,
//         "flat_value": flatValue,
//         "no_of_parking": noOfParking,
//         "buyer_payment_details": buyerPaymentDetails == null
//             ? []
//             : List<dynamic>.from(buyerPaymentDetails!.map((x) => x)),
//         "payment_bottom_bar": paymentBottomBar?.toJson(),
//         "flat_payment_history": flatPaymentHistory == null
//             ? []
//             : List<dynamic>.from(flatPaymentHistory!.map((x) => x)),
//         "buyer_payment_details1": buyerPaymentDetails1,
//         "payment_type": paymentType == null
//             ? []
//             : List<dynamic>.from(paymentType!.map((x) => x.toJson())),
//         "flat_payment_amount": flatPaymentAmount,
//         "arr_registration_doc": arrRegistrationDoc == null
//             ? []
//             : List<dynamic>.from(arrRegistrationDoc!.map((x) => x)),
//         "flat_stump_duty": flatStumpDuty,
//         "flat_gst_amount": flatGstAmount,
//         "flat_tds_amount": flatTdsAmount,
//         "flat_stump_percentage": flatStumpPercentage,
//         "flat_gst_percentage": flatGstPercentage,
//         "flat_tds_percentage": flatTdsPercentage,
//         "flat_total_amount_due": flatTotalAmountDue,
//         "custom_charges": customCharges == null
//             ? []
//             : List<dynamic>.from(customCharges!
//                 .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
//         "total_gst_paid": totalGstPaid,
//         "total_gst_payable": totalGstPayable,
//         "total_gst_generated": totalGstGenerated,
//         "total_gst_generated_histry": totalGstGeneratedHistry,
//         "total_gst_due": totalGstDue,
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

// // class CustomCharge {
// //   String? calculated;
// //   String? chargesId;
// //   String? collected;
// //   String? id;
// //   String? value;
// //   String? totalValue;
// //   String? name;
// //   String? chargesGst;
// //   String? status;
// //   String? unit;

// //   CustomCharge({
// //     this.calculated,
// //     this.chargesId,
// //     this.collected,
// //     this.id,
// //     this.value,
// //     this.totalValue,
// //     this.name,
// //     this.chargesGst,
// //     this.status,
// //     this.unit,
// //   });

// //   factory CustomCharge.fromJson(Map<String, dynamic> json) => CustomCharge(
// //         calculated: json["calculated"],
// //         chargesId: json["charges_id"],
// //         collected: json["collected"],
// //         id: json["id"],
// //         value: json["value"],
// //         totalValue: json["total_value"],
// //         name: json["name"],
// //         chargesGst: json["charges_gst"],
// //         status: json["status"],
// //         unit: json["unit"],
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "calculated": calculated,
// //         "charges_id": chargesId,
// //         "collected": collected,
// //         "id": id,
// //         "value": value,
// //         "total_value": totalValue,
// //         "name": name,
// //         "charges_gst": chargesGst,
// //         "status": status,
// //         "unit": unit,
// //       };
// // }

// class FlatBuyerDetail {
//   String? flatBuyerId;
//   String? projectIdFk;
//   String? flatIdFk;
//   String? userIdFk;
//   String? flatBuyerName;
//   String? flatBuyerName1;
//   String? flatBuyerNumber;
//   String? flatBuyerEmail;
//   String? flatArea;
//   String? flatRateCal;
//   String? flatValue;
//   String? podiumIdFk;
//   String? noOfParking;
//   String? flatBrokerageValue;
//   String? flatStampDutyValue;
//   String? flatStampDutyActualValue;
//   String? flatGstValue;
//   String? flatTotalValue;
//   String? finshingType;
//   String? flatBuyerPayementType;
//   String? flatApprovedById;
//   String? buyerFlatStatus;
//   DateTime? buyerFlatUpatedAt;
//   DateTime? buyerFlatCreateAt;
//   String? flatBuyerOrderNo;
//   String? flatBuyerSerialNo;
//   String? flatRequestDate;
//   DateTime? flatApprovedDate;
//   String? flatAllotLetter;
//   String? flagInvestor;
//   String? aadharNo;
//   String? panNo;
//   String? flatGstPercentage;
//   String? flatStumpPercentage;
//   String? flatTdsPercentage;
//   String? flatTotalWithoutGst;
//   String? flatBuyerAddress1;
//   String? flatBuyerAddress2;
//   String? flatBuyerAddress3;
//   String? flatAutoEmailSend;
//   dynamic requestCancelationRes;
//   String? brokerIdFk;
//   String? brokerPercentage;
//   String? flatAadharDoc;
//   String? flatPanDoc;
//   String? brokerGstPer;
//   String? brokerGstValue;
//   String? brokerTotal;
//   String? flatBuyerDocUploadStatus;
//   String? flatBuyerTowarIdFk;
//   String? flatMarketValue;
//   String? flagStumpCal;
//   String? flatFundingType;
//   String? flatBookingRemark;
//   String? bankIdFk;
//   dynamic registrationDate;
//   String? fileDelete;
//   String? alotFileDelete;
//   String? panFileDelete;
//   String? adFileDelete;
//   String? flatBuyerStatusRemark;
//   String? reservedById;
//   DateTime? reservedDate;
//   String? ledgerEmailMessageId;
//   String? buyerBankName;
//   String? buyerBankAccountHolderName;
//   String? buyerBankAccountNo;
//   String? buyerBankIfsc;
//   String? buyerBankBranch;
//   String? tenantIdFk;
//   String? brokerName;
//   List<BuyerContactDetail>? buyerContactDetails;
//   List<ParkingList>? parkingList;
//   List<SelectedFlat>? selectedFlat;
//   List<List<CustomCharge>>? customCharges;

//   FlatBuyerDetail({
//     this.flatBuyerId,
//     this.projectIdFk,
//     this.flatIdFk,
//     this.userIdFk,
//     this.flatBuyerName,
//     this.flatBuyerName1,
//     this.flatBuyerNumber,
//     this.flatBuyerEmail,
//     this.flatArea,
//     this.flatRateCal,
//     this.flatValue,
//     this.podiumIdFk,
//     this.noOfParking,
//     this.flatBrokerageValue,
//     this.flatStampDutyValue,
//     this.flatStampDutyActualValue,
//     this.flatGstValue,
//     this.flatTotalValue,
//     this.finshingType,
//     this.flatBuyerPayementType,
//     this.flatApprovedById,
//     this.buyerFlatStatus,
//     this.buyerFlatUpatedAt,
//     this.buyerFlatCreateAt,
//     this.flatBuyerOrderNo,
//     this.flatBuyerSerialNo,
//     this.flatRequestDate,
//     this.flatApprovedDate,
//     this.flatAllotLetter,
//     this.flagInvestor,
//     this.aadharNo,
//     this.panNo,
//     this.flatGstPercentage,
//     this.flatStumpPercentage,
//     this.flatTdsPercentage,
//     this.flatTotalWithoutGst,
//     this.flatBuyerAddress1,
//     this.flatBuyerAddress2,
//     this.flatBuyerAddress3,
//     this.flatAutoEmailSend,
//     this.requestCancelationRes,
//     this.brokerIdFk,
//     this.brokerPercentage,
//     this.flatAadharDoc,
//     this.flatPanDoc,
//     this.brokerGstPer,
//     this.brokerGstValue,
//     this.brokerTotal,
//     this.flatBuyerDocUploadStatus,
//     this.flatBuyerTowarIdFk,
//     this.flatMarketValue,
//     this.flagStumpCal,
//     this.flatFundingType,
//     this.flatBookingRemark,
//     this.bankIdFk,
//     this.registrationDate,
//     this.fileDelete,
//     this.alotFileDelete,
//     this.panFileDelete,
//     this.adFileDelete,
//     this.flatBuyerStatusRemark,
//     this.reservedById,
//     this.reservedDate,
//     this.ledgerEmailMessageId,
//     this.buyerBankName,
//     this.buyerBankAccountHolderName,
//     this.buyerBankAccountNo,
//     this.buyerBankIfsc,
//     this.buyerBankBranch,
//     this.tenantIdFk,
//     this.brokerName,
//     this.buyerContactDetails,
//     this.parkingList,
//     this.selectedFlat,
//     this.customCharges,
//   });

//   factory FlatBuyerDetail.fromJson(Map<String, dynamic> json) =>
//       FlatBuyerDetail(
//         flatBuyerId: json["flat_buyer_id"],
//         projectIdFk: json["project_id_fk"],
//         flatIdFk: json["flat_id_fk"],
//         userIdFk: json["user_id_fk"],
//         flatBuyerName: json["flat_buyer_name"],
//         flatBuyerName1: json["flat_buyer_name_1"],
//         flatBuyerNumber: json["flat_buyer_number"],
//         flatBuyerEmail: json["flat_buyer_email"],
//         flatArea: json["flat_area"],
//         flatRateCal: json["flat_rate_cal"],
//         flatValue: json["flat_value"],
//         podiumIdFk: json["podium_id_fk"],
//         noOfParking: json["no_of_parking"],
//         flatBrokerageValue: json["flat_brokerage_value"],
//         flatStampDutyValue: json["flat_stamp_duty_value"],
//         flatStampDutyActualValue: json["flat_stamp_duty_actual_value"],
//         flatGstValue: json["flat_gst_value"],
//         flatTotalValue: json["flat_total_value"],
//         finshingType: json["finshing_type"],
//         flatBuyerPayementType: json["flat_buyer_payement_type"],
//         flatApprovedById: json["flat_approved_by_id"],
//         buyerFlatStatus: json["buyer_flat_status"],
//         buyerFlatUpatedAt: json["buyer_flat_upated_at"] == null
//             ? null
//             : DateTime.parse(json["buyer_flat_upated_at"]),
//         buyerFlatCreateAt: json["buyer_flat_create_at"] == null
//             ? null
//             : DateTime.parse(json["buyer_flat_create_at"]),
//         flatBuyerOrderNo: json["flat_buyer_order_no"],
//         flatBuyerSerialNo: json["flat_buyer_serial_no"],
//         flatRequestDate: json["flat_request_date"],
//         flatApprovedDate: json["flat_approved_date"] == null
//             ? null
//             : DateTime.parse(json["flat_approved_date"]),
//         flatAllotLetter: json["flat_allot_letter"],
//         flagInvestor: json["flag_investor"],
//         aadharNo: json["aadhar_no"],
//         panNo: json["pan_no"],
//         flatGstPercentage: json["flat_gst_percentage"],
//         flatStumpPercentage: json["flat_stump_percentage"],
//         flatTdsPercentage: json["flat_tds_percentage"],
//         flatTotalWithoutGst: json["flat_total_without_gst"],
//         flatBuyerAddress1: json["flat_buyer_address1"],
//         flatBuyerAddress2: json["flat_buyer_address2"],
//         flatBuyerAddress3: json["flat_buyer_address3"],
//         flatAutoEmailSend: json["flat_auto_email_send"],
//         requestCancelationRes: json["request_cancelation_res"],
//         brokerIdFk: json["broker_id_fk"],
//         brokerPercentage: json["broker_percentage"],
//         flatAadharDoc: json["flat_aadhar_doc"],
//         flatPanDoc: json["flat_pan_doc"],
//         brokerGstPer: json["broker_gst_per"],
//         brokerGstValue: json["broker_gst_value"],
//         brokerTotal: json["broker_total"],
//         flatBuyerDocUploadStatus: json["flat_buyer_doc_upload_status"],
//         flatBuyerTowarIdFk: json["flat_buyer_towar_id_fk"],
//         flatMarketValue: json["flat_market_value"],
//         flagStumpCal: json["flag_stump_cal"],
//         flatFundingType: json["flat_funding_type"],
//         flatBookingRemark: json["flat_booking_remark"],
//         bankIdFk: json["bank_id_fk"],
//         registrationDate: json["registration_date"],
//         fileDelete: json["file_delete"],
//         alotFileDelete: json["alot_file_delete"],
//         panFileDelete: json["pan_file_delete"],
//         adFileDelete: json["ad_file_delete"],
//         flatBuyerStatusRemark: json["flat_buyer_status_remark"],
//         reservedById: json["reserved_by_id"],
//         reservedDate: json["reserved_date"] == null
//             ? null
//             : DateTime.parse(json["reserved_date"]),
//         ledgerEmailMessageId: json["ledger_email_messageId"],
//         buyerBankName: json["buyer_bank_name"],
//         buyerBankAccountHolderName: json["buyer_bank_account_holder_name"],
//         buyerBankAccountNo: json["buyer_bank_account_no"],
//         buyerBankIfsc: json["buyer_bank_ifsc"],
//         buyerBankBranch: json["buyer_bank_branch"],
//         tenantIdFk: json["tenant_id_fk"],
//         brokerName: json["broker_name"],
//         buyerContactDetails: json["buyer_contact_details"] == null
//             ? []
//             : List<BuyerContactDetail>.from(json["buyer_contact_details"]!
//                 .map((x) => BuyerContactDetail.fromJson(x))),
//         parkingList: json["parking_list"] == null
//             ? []
//             : List<ParkingList>.from(
//                 json["parking_list"]!.map((x) => ParkingList.fromJson(x))),
//         selectedFlat: json["selected_flat"] == null
//             ? []
//             : List<SelectedFlat>.from(
//                 json["selected_flat"]!.map((x) => SelectedFlat.fromJson(x))),
//         customCharges: json["custom_charges"] == null
//             ? []
//             : List<List<CustomCharge>>.from(json["custom_charges"]!.map((x) =>
//                 List<CustomCharge>.from(
//                     x.map((x) => CustomCharge.fromJson(x))))),
//       );

//   Map<String, dynamic> toJson() => {
//         "flat_buyer_id": flatBuyerId,
//         "project_id_fk": projectIdFk,
//         "flat_id_fk": flatIdFk,
//         "user_id_fk": userIdFk,
//         "flat_buyer_name": flatBuyerName,
//         "flat_buyer_name_1": flatBuyerName1,
//         "flat_buyer_number": flatBuyerNumber,
//         "flat_buyer_email": flatBuyerEmail,
//         "flat_area": flatArea,
//         "flat_rate_cal": flatRateCal,
//         "flat_value": flatValue,
//         "podium_id_fk": podiumIdFk,
//         "no_of_parking": noOfParking,
//         "flat_brokerage_value": flatBrokerageValue,
//         "flat_stamp_duty_value": flatStampDutyValue,
//         "flat_stamp_duty_actual_value": flatStampDutyActualValue,
//         "flat_gst_value": flatGstValue,
//         "flat_total_value": flatTotalValue,
//         "finshing_type": finshingType,
//         "flat_buyer_payement_type": flatBuyerPayementType,
//         "flat_approved_by_id": flatApprovedById,
//         "buyer_flat_status": buyerFlatStatus,
//         "buyer_flat_upated_at": buyerFlatUpatedAt?.toIso8601String(),
//         "buyer_flat_create_at": buyerFlatCreateAt?.toIso8601String(),
//         "flat_buyer_order_no": flatBuyerOrderNo,
//         "flat_buyer_serial_no": flatBuyerSerialNo,
//         "flat_request_date": flatRequestDate,
//         "flat_approved_date":
//             "${flatApprovedDate!.year.toString().padLeft(4, '0')}-${flatApprovedDate!.month.toString().padLeft(2, '0')}-${flatApprovedDate!.day.toString().padLeft(2, '0')}",
//         "flat_allot_letter": flatAllotLetter,
//         "flag_investor": flagInvestor,
//         "aadhar_no": aadharNo,
//         "pan_no": panNo,
//         "flat_gst_percentage": flatGstPercentage,
//         "flat_stump_percentage": flatStumpPercentage,
//         "flat_tds_percentage": flatTdsPercentage,
//         "flat_total_without_gst": flatTotalWithoutGst,
//         "flat_buyer_address1": flatBuyerAddress1,
//         "flat_buyer_address2": flatBuyerAddress2,
//         "flat_buyer_address3": flatBuyerAddress3,
//         "flat_auto_email_send": flatAutoEmailSend,
//         "request_cancelation_res": requestCancelationRes,
//         "broker_id_fk": brokerIdFk,
//         "broker_percentage": brokerPercentage,
//         "flat_aadhar_doc": flatAadharDoc,
//         "flat_pan_doc": flatPanDoc,
//         "broker_gst_per": brokerGstPer,
//         "broker_gst_value": brokerGstValue,
//         "broker_total": brokerTotal,
//         "flat_buyer_doc_upload_status": flatBuyerDocUploadStatus,
//         "flat_buyer_towar_id_fk": flatBuyerTowarIdFk,
//         "flat_market_value": flatMarketValue,
//         "flag_stump_cal": flagStumpCal,
//         "flat_funding_type": flatFundingType,
//         "flat_booking_remark": flatBookingRemark,
//         "bank_id_fk": bankIdFk,
//         "registration_date": registrationDate,
//         "file_delete": fileDelete,
//         "alot_file_delete": alotFileDelete,
//         "pan_file_delete": panFileDelete,
//         "ad_file_delete": adFileDelete,
//         "flat_buyer_status_remark": flatBuyerStatusRemark,
//         "reserved_by_id": reservedById,
//         "reserved_date":
//             "${reservedDate!.year.toString().padLeft(4, '0')}-${reservedDate!.month.toString().padLeft(2, '0')}-${reservedDate!.day.toString().padLeft(2, '0')}",
//         "ledger_email_messageId": ledgerEmailMessageId,
//         "buyer_bank_name": buyerBankName,
//         "buyer_bank_account_holder_name": buyerBankAccountHolderName,
//         "buyer_bank_account_no": buyerBankAccountNo,
//         "buyer_bank_ifsc": buyerBankIfsc,
//         "buyer_bank_branch": buyerBankBranch,
//         "tenant_id_fk": tenantIdFk,
//         "broker_name": brokerName,
//         "buyer_contact_details": buyerContactDetails == null
//             ? []
//             : List<dynamic>.from(buyerContactDetails!.map((x) => x.toJson())),
//         "parking_list": parkingList == null
//             ? []
//             : List<dynamic>.from(parkingList!.map((x) => x.toJson())),
//         "selected_flat": selectedFlat == null
//             ? []
//             : List<dynamic>.from(selectedFlat!.map((x) => x.toJson())),
//         "custom_charges": customCharges == null
//             ? []
//             : List<dynamic>.from(customCharges!
//                 .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
//       };
// }

// // class ParkingList {
// //   String? parkingSerialNo;
// //   String? mstParkingId;

// //   ParkingList({
// //     this.parkingSerialNo,
// //     this.mstParkingId,
// //   });

// //   factory ParkingList.fromJson(Map<String, dynamic> json) => ParkingList(
// //         parkingSerialNo: json["parking_serial_no"],
// //         mstParkingId: json["mst_parking_id"],
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "parking_serial_no": parkingSerialNo,
// //         "mst_parking_id": mstParkingId,
// //       };
// // }

// class SelectedFlat {
//   String? flatName;
//   String? flatId;
//   String? inventryFlatType;
//   String? inventryFlatName;
//   String? flatArea;
//   String? masonryIdFk;
//   String? inventyParkingNumber;
//   String? masnoryName;
//   String? floorNumber;
//   List<dynamic>? parkingList;

//   SelectedFlat({
//     this.flatName,
//     this.flatId,
//     this.inventryFlatType,
//     this.inventryFlatName,
//     this.flatArea,
//     this.masonryIdFk,
//     this.inventyParkingNumber,
//     this.masnoryName,
//     this.floorNumber,
//     this.parkingList,
//   });

//   factory SelectedFlat.fromJson(Map<String, dynamic> json) => SelectedFlat(
//         flatName: json["flat_name"],
//         flatId: json["flat_id"],
//         inventryFlatType: json["inventry_flat_type"],
//         inventryFlatName: json["inventry_flat_name"],
//         flatArea: json["flat_area"],
//         masonryIdFk: json["masonry_id_fk"],
//         inventyParkingNumber: json["inventy_parking_number"],
//         masnoryName: json["masnory_name"],
//         floorNumber: json["floor_number"],
//         parkingList: json["parking_list"] == null
//             ? []
//             : List<dynamic>.from(json["parking_list"]!.map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "flat_name": flatName,
//         "flat_id": flatId,
//         "inventry_flat_type": inventryFlatType,
//         "inventry_flat_name": inventryFlatName,
//         "flat_area": flatArea,
//         "masonry_id_fk": masonryIdFk,
//         "inventy_parking_number": inventyParkingNumber,
//         "masnory_name": masnoryName,
//         "floor_number": floorNumber,
//         "parking_list": parkingList == null
//             ? []
//             : List<dynamic>.from(parkingList!.map((x) => x)),
//       };
// }

// class PaymentBottomBar {
//   String? totalFlatAmount;
//   String? received;
//   String? balance;
//   String? overdue;

//   PaymentBottomBar({
//     this.totalFlatAmount,
//     this.received,
//     this.balance,
//     this.overdue,
//   });

//   factory PaymentBottomBar.fromJson(Map<String, dynamic> json) =>
//       PaymentBottomBar(
//         totalFlatAmount: json["total_flat_amount"],
//         received: json["received"],
//         balance: json["balance"],
//         overdue: json["overdue"],
//       );

//   Map<String, dynamic> toJson() => {
//         "total_flat_amount": totalFlatAmount,
//         "received": received,
//         "balance": balance,
//         "overdue": overdue,
//       };
// }

// class PaymentType {
//   String? id;
//   String? name;

//   PaymentType({
//     this.id,
//     this.name,
//   });

//   factory PaymentType.fromJson(Map<String, dynamic> json) => PaymentType(
//         id: json["id"],
//         name: json["name"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//       };
// }
