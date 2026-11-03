// To parse this JSON data, do
//
//     final getPaymentDetailsByVendor = getPaymentDetailsByVendorFromJson(jsonString);

import 'dart:convert';

GetPaymentDetailsByVendor getPaymentDetailsByVendorFromJson(String str) =>
    GetPaymentDetailsByVendor.fromJson(json.decode(str));

String getPaymentDetailsByVendorToJson(GetPaymentDetailsByVendor data) =>
    json.encode(data.toJson());

class GetPaymentDetailsByVendor {
  GetPaymentDetailsByVendor({
    this.response,
  });

  ResponseGetPaymentDetailsByVendor? response;

  factory GetPaymentDetailsByVendor.fromJson(Map<String, dynamic> json) =>
      GetPaymentDetailsByVendor(
        response: ResponseGetPaymentDetailsByVendor.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPaymentDetailsByVendor {
  ResponseGetPaymentDetailsByVendor({
    this.errorCode,
    this.msg,
    this.searchData,
    this.venderGrade,
    this.invoicePath,
    this.paymentHistory,
    this.totalInvoice,
    this.totalPayment,
    this.totalBalance,
    this.totalOverdue,
  });

  String? errorCode;
  String? msg;
  List<SearchDatum>? searchData;
  List<VenderGrade>? venderGrade;
  String? invoicePath;
  List<PaymentHistory>? paymentHistory;
  String? totalInvoice;
  String? totalPayment;
  String? totalBalance;
  String? totalOverdue;

  factory ResponseGetPaymentDetailsByVendor.fromJson(
          Map<String, dynamic> json) =>
      ResponseGetPaymentDetailsByVendor(
        errorCode: json["error_code"],
        msg: json["msg"],
        searchData: List<SearchDatum>.from(
            json["search_data"].map((x) => SearchDatum.fromJson(x))),
        venderGrade: List<VenderGrade>.from(
            json["vender_grade"].map((x) => VenderGrade.fromJson(x))),
        invoicePath: json["invoice_path"],
        paymentHistory: List<PaymentHistory>.from(
            json["payment_history"].map((x) => PaymentHistory.fromJson(x))),
        totalInvoice: json["total_invoice"],
        totalPayment: json["total_payment"],
        totalBalance: json["total_balance"],
        totalOverdue: json["total_overdue"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "search_data": List<dynamic>.from(searchData!.map((x) => x.toJson())),
        "vender_grade": List<dynamic>.from(venderGrade!.map((x) => x.toJson())),
        "invoice_path": invoicePath,
        "payment_history":
            List<dynamic>.from(paymentHistory!.map((x) => x.toJson())),
        "total_invoice": totalInvoice,
        "total_payment": totalPayment,
        "total_balance": totalBalance,
        "total_overdue": totalOverdue,
      };
}

class PaymentHistory {
  PaymentHistory({
    this.key,
    this.projectName,
    this.challanUploadStatus,
    this.poNo,
    this.purchaseOrderNumber,
    this.invoiceNumber,
    this.dueDate,
    this.deliveryDate,
    this.amount,
    this.creditType,
    this.dueType,
    this.orderId,
    this.paymentType,
    this.invoicePdf,
    this.raisedBy,
    this.poApproveBy,
    this.invoiceStatus,
    this.invoicePdfArr,
    this.invoiceListArr,
    this.isPaid,
    this.orderType,
    this.orderTypeComma,
    this.status,
    this.poApproveStatus,
    this.totalInv,
    this.paidInvCount,
    this.pendingInvoice,
    this.poSignDate,
    this.isStarMarked,
  });

  DateTime? key;
  String? isStarMarked;

  String? projectName;
  String? challanUploadStatus;
  String? poNo;
  String? purchaseOrderNumber;
  String? invoiceNumber;
  String? dueDate;
  String? deliveryDate;
  String? amount;
  String? creditType;
  String? dueType;
  String? orderId;
  String? paymentType;
  String? invoicePdf;
  String? raisedBy;
  String? poApproveBy;
  String? invoiceStatus;
  List<dynamic>? invoicePdfArr;
  List<dynamic>? invoiceListArr;
  String? isPaid;
  List<SearchDatum>? orderType;
  String? orderTypeComma;
  String? status;
  String? poApproveStatus;
  dynamic totalInv;
  dynamic paidInvCount;
  dynamic pendingInvoice;
  String? poSignDate;

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => PaymentHistory(
        isStarMarked: json["is_star_marked"],
        key: DateTime.parse(json["key"]),
        projectName: json["project_name"] ?? '',
        challanUploadStatus: json["challan_upload_status"] ?? '',
        poNo: json["po_no"],
        purchaseOrderNumber: json["purchase_order_number"] ?? '',
        invoiceNumber: json["invoice_number"] ?? '',
        dueDate: json["due_date"] ?? '',
        deliveryDate: json["delivery_date"] ?? '',
        amount: json["amount"] ?? '',
        creditType: json["credit_type"] ?? '',
        dueType: json["due_type"] ?? '',
        orderId: json["order_id"] ?? '',
        paymentType: json["payment_type"] ?? '',
        invoicePdf: json["invoice_pdf"] ?? '',
        raisedBy: json["raised_by"] ?? '',
        poApproveBy: json["po_approve_by"] ?? '',
        invoiceStatus: json["invoice_status"] ?? '',
        invoicePdfArr:
            List<dynamic>.from(json["invoice_pdf_arr"].map((x) => x)),
        invoiceListArr:
            List<dynamic>.from(json["invoice_list_arr"].map((x) => x)),
        isPaid: json["is_paid"],
        orderType: List<SearchDatum>.from(
            json["order_type"].map((x) => SearchDatum.fromJson(x))),
        orderTypeComma: json["order_type_comma"],
        status: json["status"],
        poApproveStatus: json["po_approve_status"] == null
            ? null
            : json["po_approve_status"],
        totalInv: json["totalInv"],
        paidInvCount: json["paidInvCount"],
        pendingInvoice: json["pending_invoice"],
        poSignDate: json["po_sign_date"],
      );

  Map<String, dynamic> toJson() => {
        "is_star_marked": isStarMarked,
        "key": key?.toIso8601String(),
        "project_name": projectName,
        "challan_upload_status": challanUploadStatus,
        "po_no": poNo,
        "purchase_order_number": purchaseOrderNumber,
        "invoice_number": invoiceNumber,
        "due_date": dueDate,
        "delivery_date": deliveryDate,
        "amount": amount,
        "credit_type": creditType,
        "due_type": dueType,
        "order_id": orderId,
        "payment_type": paymentType,
        "invoice_pdf": invoicePdf,
        "raised_by": raisedBy,
        "po_approve_by": poApproveBy,
        "invoice_status": invoiceStatus,
        "invoice_pdf_arr": List<dynamic>.from(invoicePdfArr!.map((x) => x)),
        "invoice_list_arr": List<dynamic>.from(invoiceListArr!.map((x) => x)),
        "is_paid": isPaid,
        "order_type": List<dynamic>.from(orderType!.map((x) => x.toJson())),
        "order_type_comma": orderTypeComma,
        "status": status,
        "po_approve_status": poApproveStatus == null ? null : poApproveStatus,
        "totalInv": totalInv,
        "paidInvCount": paidInvCount,
        "pending_invoice": pendingInvoice,
        "po_sign_date": poSignDate,
      };
}

class SearchDatum {
  SearchDatum({
    this.gradeName,
    this.gradeId,
  });

  String? gradeName;
  String? gradeId;

  factory SearchDatum.fromJson(Map<String, dynamic> json) => SearchDatum(
        gradeName: json["grade_name"],
        gradeId: json["grade_id"],
      );

  Map<String, dynamic> toJson() => {
        "grade_name": gradeName,
        "grade_id": gradeId,
      };
}

class VenderGrade {
  VenderGrade({
    this.gradePrice,
    this.gradeTypeName,
    this.gradeUnit,
  });

  String? gradePrice;
  String? gradeTypeName;
  String? gradeUnit;

  factory VenderGrade.fromJson(Map<String, dynamic> json) => VenderGrade(
        gradePrice: json["grade_price"],
        gradeTypeName: json["grade_type_name"],
        gradeUnit: json["grade_unit"],
      );

  Map<String, dynamic> toJson() => {
        "grade_price": gradePrice,
        "grade_type_name": gradeTypeName,
        "grade_unit": gradeUnit,
      };
}
