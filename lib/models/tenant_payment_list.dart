import 'dart:convert';

TenantPaymentList tenantPaymentListFromJson(String str) =>
    TenantPaymentList.fromJson(json.decode(str));

String tenantPaymentListToJson(TenantPaymentList data) =>
    json.encode(data.toJson());

class TenantPaymentList {
  TenantPaymentListResponse? response;

  TenantPaymentList({
    this.response,
  });

  factory TenantPaymentList.fromJson(Map<String, dynamic> json) =>
      TenantPaymentList(
        response: json["Response"] == null
            ? null
            : TenantPaymentListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class TenantPaymentListResponse {
  String? errorCode;
  String? msg;
  List<TenantPaymentListElement>? tenantPaymentList;
  String? invoicePath;

  TenantPaymentListResponse({
    this.errorCode,
    this.msg,
    this.tenantPaymentList,
    this.invoicePath,
  });

  factory TenantPaymentListResponse.fromJson(Map<String, dynamic> json) =>
      TenantPaymentListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        tenantPaymentList: json["tenant_payment_list"] == null
            ? []
            : List<TenantPaymentListElement>.from(json["tenant_payment_list"]!
                .map((x) => TenantPaymentListElement.fromJson(x))),
        invoicePath: json["invoice_path"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "tenant_payment_list": tenantPaymentList == null
            ? []
            : List<dynamic>.from(tenantPaymentList!.map((x) => x.toJson())),
        "invoice_path": invoicePath,
      };
}

class TenantPaymentListElement {
  String? transTenantPayementId;
  String? tenantPayName;
  String? tenantPayDeleteRemark;
  String? tenantPayPuchUserId;
  String? tenantPayDeleteUserId;
  String? transTenantPayStatus;
  String? paidAmount;
  String? remark;
  String? tenantDatePunch;
  String? tenantPayMode;
  String? tenantInvoiceSrNo;
  String? paymentReceipt;

  TenantPaymentListElement({
    this.transTenantPayementId,
    this.tenantPayName,
    this.tenantPayDeleteRemark,
    this.tenantPayPuchUserId,
    this.tenantPayDeleteUserId,
    this.transTenantPayStatus,
    this.paidAmount,
    this.remark,
    this.tenantDatePunch,
    this.tenantPayMode,
    this.tenantInvoiceSrNo,
    this.paymentReceipt,
  });

  factory TenantPaymentListElement.fromJson(Map<String, dynamic> json) =>
      TenantPaymentListElement(
        transTenantPayementId: json["trans_tenant_payement_id"],
        tenantPayName: json["tenant_pay_name"],
        tenantPayDeleteRemark: json["tenant_pay_delete_remark"],
        tenantPayPuchUserId: json["tenant_pay_puch_user_id"],
        tenantPayDeleteUserId: json["tenant_pay_delete_user_id"],
        transTenantPayStatus: json["trans_tenant_pay_status"],
        paidAmount: json["paid_amount"],
        remark: json["remark"],
        tenantDatePunch: json["tenant_date_punch"],
        tenantPayMode: json["tenant_pay_mode"],
        tenantInvoiceSrNo: json["tenant_invoice_sr_no"],
        paymentReceipt: json["payment_receipt"],
      );

  Map<String, dynamic> toJson() => {
        "trans_tenant_payement_id": transTenantPayementId,
        "tenant_pay_name": tenantPayName,
        "tenant_pay_delete_remark": tenantPayDeleteRemark,
        "tenant_pay_puch_user_id": tenantPayPuchUserId,
        "tenant_pay_delete_user_id": tenantPayDeleteUserId,
        "trans_tenant_pay_status": transTenantPayStatus,
        "paid_amount": paidAmount,
        "remark": remark,
        "tenant_date_punch": tenantDatePunch,
        "tenant_pay_mode": tenantPayMode,
        "tenant_invoice_sr_no": tenantInvoiceSrNo,
        "payment_receipt": paymentReceipt,
      };
}
