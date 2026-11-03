// To parse this JSON data, do
//
//     final getProjectWoRequest = getProjectWoRequestFromJson(jsonString);

import 'dart:convert';

// import 'package:stallion/models/get_po_details_by_status.dart';

GetProjectWoRequest getProjectWoRequestFromJson(String str) =>
    GetProjectWoRequest.fromJson(json.decode(str));

String getProjectWoRequestToJson(GetProjectWoRequest data) =>
    json.encode(data.toJson());

class GetProjectWoRequest {
  GetProjectWoRequest({
    this.response,
  });

  ResponseGetProjectWoRequest? response;

  factory GetProjectWoRequest.fromJson(Map<String, dynamic> json) =>
      GetProjectWoRequest(
        response: ResponseGetProjectWoRequest.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetProjectWoRequest {
  ResponseGetProjectWoRequest({
    this.errorCode,
    this.msg,
    this.offset,
    this.woOrderList,
    this.woMaskFlag,
    this.invoiceFilterList,
    this.handSignUrl,

    // this.authorizeFlag,
  });

  String? errorCode;
  String? msg;
  String? offset;
  List<WoOrderList>? woOrderList;
  String? woMaskFlag;
  List<InvoiceFilterList>? invoiceFilterList;
  String? handSignUrl;

  // String? authorizeFlag;

  factory ResponseGetProjectWoRequest.fromJson(Map<String, dynamic> json) =>
      ResponseGetProjectWoRequest(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        woMaskFlag: json["wo_mask_flag"],
        invoiceFilterList: json["invoice_filter_list"] == null
            ? []
            : List<InvoiceFilterList>.from(json["invoice_filter_list"]!
                .map((x) => InvoiceFilterList.fromJson(x))),
        woOrderList: List<WoOrderList>.from(
            json["wo_order_list"].map((x) => WoOrderList.fromJson(x))),
        // authorizeFlag: json["authorize_flag"],
        handSignUrl: json["hand_sign_url"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "invoice_filter_list": invoiceFilterList == null
            ? []
            : List<dynamic>.from(invoiceFilterList!.map((x) => x.toJson())),
        "wo_mask_flag": woMaskFlag,
        "wo_order_list":
            List<dynamic>.from(woOrderList!.map((x) => x.toJson())),
        "hand_sign_url": handSignUrl,

        // "authorize_flag": authorizeFlag,
      };
}

class InvoiceFilterList {
  String? id;
  String? name;
  String? invoiceCount;

  InvoiceFilterList({
    this.id,
    this.name,
    this.invoiceCount,
  });

  factory InvoiceFilterList.fromJson(Map<String, dynamic> json) =>
      InvoiceFilterList(
        id: json["id"],
        name: json["name"],
        invoiceCount: json["invoice_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "invoice_count": invoiceCount,
      };
}

class WoOrderList {
  WoOrderList({
    this.companyName,
    this.companyId,
    this.woOrderNo,
    this.woOrderId,
    this.projectIdFk,
    this.towarIdFk,
    this.towarId,
    this.gradeId,
    this.contractType,
    this.valueTotal,
    this.valueOne,
    this.valueTwo,
    this.estDate,
    this.gstAmount,
    this.discountAmount,
    this.retentionValue,
    this.woIsIssued,
    this.woIssuedBy,
    this.projectName,
    this.approvedBy,
    this.remarks,
    this.reApprovedReson,
    this.uploadNoteImage,
    this.is_star_marked,
    this.woCheckedByDate,
    this.woCheckedBy,
    this.woAssingTo,
    this.draftFlag,
    this.arrWoDoc,
    this.woAssingToName,
    this.reApprovedDate,
    this.woVerifyFlag,
    this.woSignDate,
    this.woAssignDate,
    this.woHandSignImg,
    this.woHandSignName,
    this.woHandSignDate,
    this.authorizeFlag,
    this.poHandSignImg,
    this.valueTotalWithOutGst,
  });

  String? valueTotalWithOutGst;
  String? poHandSignImg;

  String? draftFlag;
  List<ArrWoDoc>? arrWoDoc;
  String? woAssingToName;
  String? reApprovedDate;
  String? woVerifyFlag;
  String? woSignDate;
  String? woAssignDate;
  String? woAssingTo;
  String? companyName;
  String? companyId;
  String? woOrderNo;
  String? woOrderId;
  String? projectIdFk;
  String? towarIdFk;
  String? towarId;
  String? gradeId;
  String? contractType;
  String? valueTotal;
  String? valueOne;
  String? valueTwo;
  String? estDate;
  String? gstAmount;
  String? discountAmount;
  String? retentionValue;
  String? woIsIssued;
  String? woIssuedBy;
  String? projectName;
  String? approvedBy;
  String? remarks;
  String? reApprovedReson;
  String? is_star_marked;
  List<dynamic>? uploadNoteImage;
  String? woCheckedByDate;
  String? woCheckedBy;
  String? woHandSignImg;
  String? woHandSignName;
  String? woHandSignDate;
  String? authorizeFlag;

  factory WoOrderList.fromJson(Map<String, dynamic> json) => WoOrderList(
        valueTotalWithOutGst: json["value_total_with_out_gst"],
        poHandSignImg: json["po_hand_sign_img"],
        draftFlag: json["draft_flag"],
        arrWoDoc: json["arr_wo_doc"] == null
            ? []
            : List<ArrWoDoc>.from(
                json["arr_wo_doc"]!.map((x) => ArrWoDoc.fromJson(x))),
        woAssingToName: json["wo_assing_to_name"],
        reApprovedDate: json["re_approved_date"],
        woVerifyFlag: json["wo_verify_flag"],
        woAssignDate: json["wo_assign_date"],
        woSignDate: json["wo_sign_date"],
        woAssingTo: json["wo_assing_to"],
        companyName: json["company_name"],
        reApprovedReson: json["re_approved_reson"],
        companyId: json["company_id"],
        woOrderNo: json["wo_order_no"],
        woOrderId: json["wo_order_id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        towarId: json["towar_id"],
        gradeId: json["grade_id"],
        contractType: json["contract_type"],
        valueTotal: json["value_total"],
        valueOne: json["value_one"],
        valueTwo: json["value_two"],
        estDate: json["est_date"],
        gstAmount: json["gst_amount"],
        discountAmount: json["discount_amount"],
        retentionValue: json["retention_value"],
        woIsIssued: json["wo_is_issued"],
        woIssuedBy: json["wo_issued_by"],
        projectName: json["project_name"],
        approvedBy: json["approved_by"],
        remarks: json["remarks"],
        is_star_marked: json["is_star_marked"],
        woCheckedByDate: json["wo_checked_by_date"],
        woCheckedBy: json["wo_checked_by"],
        uploadNoteImage:
            List<dynamic>.from(json["upload_note_image"].map((x) => x)),
        woHandSignImg: json["wo_hand_sign_img"],
        woHandSignName: json["wo_hand_sign_name"],
        woHandSignDate: json["wo_hand_sign_date"],
        authorizeFlag: json["authorize_flag"],
      );

  Map<String, dynamic> toJson() => {
        "value_total_with_out_gst": valueTotalWithOutGst,
        "po_hand_sign_img": poHandSignImg,
        "draft_flag": draftFlag,
        "arr_wo_doc": arrWoDoc == null
            ? []
            : List<dynamic>.from(arrWoDoc!.map((x) => x.toJson())),
        "wo_assing_to_name": woAssingToName,
        "re_approved_date": reApprovedDate,
        "wo_verify_flag": woVerifyFlag,
        "wo_assign_date": woAssignDate,
        "wo_sign_date": woSignDate,
        "company_name": companyName,
        "re_approved_reson": reApprovedReson,
        "company_id": companyId,
        "wo_order_no": woOrderNo,
        "wo_order_id": woOrderId,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "towar_id": towarId,
        "grade_id": gradeId,
        "contract_type": contractType,
        "value_total": valueTotal,
        "value_one": valueOne,
        "value_two": valueTwo,
        "est_date": estDate,
        "gst_amount": gstAmount,
        "discount_amount": discountAmount,
        "retention_value": retentionValue,
        "wo_is_issued": woIsIssued,
        "wo_issued_by": woIssuedBy,
        "project_name": projectName,
        "approved_by": approvedBy,
        "remarks": remarks,
        "is_star_marked": is_star_marked,
        "wo_checked_by_date": woCheckedByDate,
        "wo_checked_by": woCheckedBy,
        "upload_note_image": List<dynamic>.from(uploadNoteImage!.map((x) => x)),
        "wo_assing_to": woAssingTo,
        "wo_hand_sign_img": woHandSignImg,
        "wo_hand_sign_name": woHandSignName,
        "wo_hand_sign_date": woHandSignDate,
        "authorize_flag": authorizeFlag,
      };
}

class ArrWoDoc {
  String? fileName;
  String? createdAt;
  String? isPdf;
  String? filePath;

  ArrWoDoc({
    this.fileName,
    this.createdAt,
    this.isPdf,
    this.filePath,
  });

  factory ArrWoDoc.fromJson(Map<String, dynamic> json) => ArrWoDoc(
        fileName: json["file_name"],
        createdAt: json["created_at"],
        isPdf: json["is_pdf"],
        filePath: json["file_path"],
      );

  Map<String, dynamic> toJson() => {
        "file_name": fileName,
        "created_at": createdAt,
        "is_pdf": isPdf,
        "file_path": filePath,
      };
}
