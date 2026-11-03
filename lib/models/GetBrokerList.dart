// To parse this JSON data, do
//
//     final getBrokerList = getBrokerListFromJson(jsonString);

import 'dart:convert';

GetBrokerList getBrokerListFromJson(String str) => GetBrokerList.fromJson(json.decode(str));

String getBrokerListToJson(GetBrokerList data) => json.encode(data.toJson());

class GetBrokerList {
    GetBrokerListResponse? response;

    GetBrokerList({
        this.response,
    });

    factory GetBrokerList.fromJson(Map<String, dynamic> json) => GetBrokerList(
        response: json["Response"] == null ? null : GetBrokerListResponse.fromJson(json["Response"]),
    );

    Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
    };
}

class GetBrokerListResponse {
    String? errorCode;
    String? msg;
    List<BrokerPayment>? brokerPayment;

    GetBrokerListResponse({
        this.errorCode,
        this.msg,
        this.brokerPayment,
    });

    factory GetBrokerListResponse.fromJson(Map<String, dynamic> json) => GetBrokerListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        brokerPayment: json["broker_payment"] == null ? [] : List<BrokerPayment>.from(json["broker_payment"]!.map((x) => BrokerPayment.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "broker_payment": brokerPayment == null ? [] : List<dynamic>.from(brokerPayment!.map((x) => x.toJson())),
    };
}

class BrokerPayment {
    String? brokerPaymentId;
    String? flatBuyerOrderNo;
    String? paymentAmount;
    DateTime? paymentOnDate;
    String? paymentMode;
    String? brokerPaymentApprovedBy;
    String? paymentRemark;
    DateTime? createdAt;
    String? flatBrokerPaymentStatus;
    String? invoiceNo;
    String? approvedByName;

    BrokerPayment({
        this.brokerPaymentId,
        this.flatBuyerOrderNo,
        this.paymentAmount,
        this.paymentOnDate,
        this.paymentMode,
        this.brokerPaymentApprovedBy,
        this.paymentRemark,
        this.createdAt,
        this.flatBrokerPaymentStatus,
        this.invoiceNo,
        this.approvedByName,
    });

    factory BrokerPayment.fromJson(Map<String, dynamic> json) => BrokerPayment(
        brokerPaymentId: json["broker_payment_id"],
        flatBuyerOrderNo: json["flat_buyer_order_no"],
        paymentAmount: json["payment_amount"],
        paymentOnDate: json["payment_on_date"] == null ? null : DateTime.parse(json["payment_on_date"]),
        paymentMode: json["payment_mode"],
        brokerPaymentApprovedBy: json["broker_payment_approved_by"],
        paymentRemark: json["payment_remark"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        flatBrokerPaymentStatus: json["flat_broker_payment_status"],
        invoiceNo: json["invoice_no"],
        approvedByName: json["approved_by_name"],
    );

    Map<String, dynamic> toJson() => {
        "broker_payment_id": brokerPaymentId,
        "flat_buyer_order_no": flatBuyerOrderNo,
        "payment_amount": paymentAmount,
        "payment_on_date": "${paymentOnDate!.year.toString().padLeft(4, '0')}-${paymentOnDate!.month.toString().padLeft(2, '0')}-${paymentOnDate!.day.toString().padLeft(2, '0')}",
        "payment_mode": paymentMode,
        "broker_payment_approved_by": brokerPaymentApprovedBy,
        "payment_remark": paymentRemark,
        "created_at": createdAt?.toIso8601String(),
        "flat_broker_payment_status": flatBrokerPaymentStatus,
        "invoice_no": invoiceNo,
        "approved_by_name": approvedByName,
    };
}
