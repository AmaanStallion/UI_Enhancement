// To parse this JSON data, do
//
//     final getPoPreviewHtml = getPoPreviewHtmlFromJson(jsonString);

import 'dart:convert';

GetPoPreviewHtml getPoPreviewHtmlFromJson(String str) =>
    GetPoPreviewHtml.fromJson(json.decode(str));

String getPoPreviewHtmlToJson(GetPoPreviewHtml data) =>
    json.encode(data.toJson());

class GetPoPreviewHtml {
  GetPoPreviewHtml({
    this.response,
  });

  ResponseGetPoPreviewHtml? response;

  factory GetPoPreviewHtml.fromJson(Map<String, dynamic> json) =>
      GetPoPreviewHtml(
        response: ResponseGetPoPreviewHtml.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPoPreviewHtml {
  ResponseGetPoPreviewHtml(
      {this.errorCode,
      this.msg,
      this.budgetNotSetMsg,
      this.authorizeFlag,
      this.budgetOverBuget,
      this.priceStructure,
      this.budgetGradeDetails,
      this.signatureUpload,
      this.showAccounts,
      this.poStructure,
      this.po_pdf,
      this.filePath,
      this.fileName,
      this.po_file_name});
  String? authorizeFlag;

  String? errorCode;
  String? msg;
  String? po_pdf;
  String? po_file_name;
  String? budgetNotSetMsg;
  String? budgetOverBuget;
  List<PriceStructure>? priceStructure;
  List<dynamic>? budgetGradeDetails;
  String? signatureUpload;
  String? showAccounts;
  PoStructure? poStructure;
  String? filePath;
  String? fileName;

  factory ResponseGetPoPreviewHtml.fromJson(Map<String, dynamic> json) =>
      ResponseGetPoPreviewHtml(
        errorCode: json["error_code"],
        msg: json["msg"],
        po_pdf: json["po_pdf"],
        authorizeFlag: json["authorize_flag"],
        po_file_name: json["po_file_name"],
        budgetNotSetMsg: json["budget_not_set_msg"],
        budgetOverBuget: json["budget_over_buget"],
        priceStructure: List<PriceStructure>.from(
            json["price_structure"].map((x) => PriceStructure.fromJson(x))),
        // budgetGradeDetails:
        //     List<dynamic>.from(json["budget_grade_details"].map((x) => x)),
        signatureUpload: json["signature_upload"],
        showAccounts: json["show_accounts"],
        poStructure: PoStructure.fromJson(json["po_structure"]),
        filePath: json["filePath"],
        fileName: json["fileName"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "authorize_flag": authorizeFlag,
        "po_pdf": po_pdf,
        "po_file_name": po_file_name,
        "budget_not_set_msg": budgetNotSetMsg,
        "budget_over_buget": budgetOverBuget,
        "price_structure":
            List<dynamic>.from(priceStructure!.map((x) => x.toJson())),
        "budget_grade_details":
            List<dynamic>.from(budgetGradeDetails!.map((x) => x)),
        "signature_upload": signatureUpload,
        "show_accounts": showAccounts,
        "po_structure": poStructure!.toJson(),
        "filePath": filePath,
        "fileName": fileName,
      };
}

class PoStructure {
  PoStructure({
    this.subject,
    this.content,
    this.poStatus,
  });

  String? subject;
  String? content;
  String? poStatus;

  factory PoStructure.fromJson(Map<String, dynamic> json) => PoStructure(
        subject: json["subject"],
        content: json["content"],
        poStatus: json["po_status"],
      );

  Map<String, dynamic> toJson() => {
        "subject": subject,
        "content": content,
        "po_status": poStatus,
      };
}

class PriceStructure {
  PriceStructure({
    this.transGradeTypeName,
    this.gradeIdFk,
    this.slabSupplierId,
    this.unitPrice,
    this.oldPrice,
    this.poNo,
    this.unitPricePercentage,
    this.unitPriceDifference,
    this.averagePrice,
  });

  String? transGradeTypeName;
  String? gradeIdFk;
  String? slabSupplierId;
  String? unitPrice;
  String? oldPrice;
  String? poNo;
  String? unitPricePercentage;
  String? unitPriceDifference;
  String? averagePrice;

  factory PriceStructure.fromJson(Map<String, dynamic> json) => PriceStructure(
        transGradeTypeName: json["trans_grade_type_name"],
        gradeIdFk: json["grade_id_fk"],
        slabSupplierId: json["slab_supplier_id"],
        unitPrice: json["unit_price"],
        oldPrice: json["old_price"],
        poNo: json["po_no"],
        unitPricePercentage: json["unit_price_percentage"],
        unitPriceDifference: json["unit_price_difference"],
        averagePrice: json["average_price"],
      );

  Map<String, dynamic> toJson() => {
        "trans_grade_type_name": transGradeTypeName,
        "grade_id_fk": gradeIdFk,
        "slab_supplier_id": slabSupplierId,
        "unit_price": unitPrice,
        "old_price": oldPrice,
        "po_no": poNo,
        "unit_price_percentage": unitPricePercentage,
        "unit_price_difference": unitPriceDifference,
        "average_price": averagePrice,
      };
}
