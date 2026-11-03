// To parse this JSON data, do
//
//     final getPaymentDetailsStatus = getPaymentDetailsStatusFromJson(jsonString);

import 'dart:convert';

GetPaymentDetailsStatus getPaymentDetailsStatusFromJson(String str) =>
    GetPaymentDetailsStatus.fromJson(json.decode(str));

String getPaymentDetailsStatusToJson(GetPaymentDetailsStatus data) =>
    json.encode(data.toJson());

class GetPaymentDetailsStatus {
  GetPaymentDetailsStatus({
    this.response,
  });

  ResponseGetPaymentDetailsStatus? response;

  factory GetPaymentDetailsStatus.fromJson(Map<String, dynamic> json) =>
      GetPaymentDetailsStatus(
        response: ResponseGetPaymentDetailsStatus.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPaymentDetailsStatus {
  ResponseGetPaymentDetailsStatus({
    this.errorCode,
    this.msg,
    this.poWoPayment,
  });

  String? errorCode;
  String? msg;
  List<PoWoPayment>? poWoPayment;

  factory ResponseGetPaymentDetailsStatus.fromJson(Map<String, dynamic> json) =>
      ResponseGetPaymentDetailsStatus(
        errorCode: json["error_code"],
        msg: json["msg"],
        poWoPayment: List<PoWoPayment>.from(
            json["po_wo_payment"].map((x) => PoWoPayment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "po_wo_payment":
            List<dynamic>.from(poWoPayment!.map((x) => x.toJson())),
      };
}

class PoWoPayment {
  PoWoPayment({
    this.paymentVenderId,
    this.venderName,
    this.requestBy,
    this.dueAmount,
    this.overdueAmount,
    this.poWoFlag,
    this.poNo,
    this.invoiceNo,
    this.amountRequest,
    this.status,
    this.paymentMode,
    this.poInvoiceImage,
    this.invoicePaymentUpdatedAt,
    this.invoicePaymentCreatedAt,
    this.holdStatus,
    this.advanceAmount,
    this.approvedBy,
    this.documentImg,
    this.documentRemark,
  });

  String? paymentVenderId;
  String? venderName;
  String? requestBy;
  String? dueAmount;
  String? overdueAmount;
  String? poWoFlag;
  String? poNo;
  String? invoiceNo;
  String? amountRequest;
  String? status;
  String? paymentMode;
  String? poInvoiceImage;
  String? invoicePaymentUpdatedAt;
  String? invoicePaymentCreatedAt;
  String? holdStatus;
  String? approvedBy;
  String? advanceAmount;
  String? documentImg;
  String? documentRemark;

  factory PoWoPayment.fromJson(Map<String, dynamic> json) => PoWoPayment(
        paymentVenderId: json["payment_vender_id"],
        approvedBy: json["approved_by"],
        venderName: json["vender_name"],
        holdStatus: json["hold_status"],
        requestBy: json["request_by"],
        dueAmount: json["due_amount"],
        overdueAmount: json["overdue_amount"],
        poWoFlag: json["po_wo_flag"],
        poNo: json["po_no"],
        invoiceNo: json["invoice_no"],
        amountRequest: json["amount_request"],
        status: json["status"],
        paymentMode: json["payment_mode"],
        poInvoiceImage: json["po_invoice_image"] ?? "",
        invoicePaymentUpdatedAt: json["invoice_payment_updated_at"],
        invoicePaymentCreatedAt: json["invoice_payment_created_at"],
        advanceAmount: json["advance_amount"],
        documentImg: json["document_img"],
        documentRemark: json["document_remark"],
      );

  Map<String, dynamic> toJson() => {
        "payment_vender_id": paymentVenderId,
        "approved_by": approvedBy,
        "hold_status": holdStatus,
        "vender_name": venderName,
        "request_by": requestBy,
        "due_amount": dueAmount,
        "overdue_amount": overdueAmount,
        "po_wo_flag": poWoFlag,
        "po_no": poNo,
        "invoice_no": invoiceNo,
        "amount_request": amountRequest,
        "status": status,
        "payment_mode": paymentMode,
        "po_invoice_image": poInvoiceImage,
        "invoice_payment_updated_at": invoicePaymentUpdatedAt,
        "invoice_payment_created_at": invoicePaymentCreatedAt,
        "advance_amount": advanceAmount,
        "document_img": documentImg,
        "document_remark": documentRemark,
      };
}
