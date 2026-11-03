// To parse this JSON data, do
//
//     final getProjectMyContractsSubListing = getProjectMyContractsSubListingFromJson(jsonString);

import 'dart:convert';

GetProjectMyContractsSubListing getProjectMyContractsSubListingFromJson(
        String str) =>
    GetProjectMyContractsSubListing.fromJson(json.decode(str));

String getProjectMyContractsSubListingToJson(
        GetProjectMyContractsSubListing data) =>
    json.encode(data.toJson());

class GetProjectMyContractsSubListing {
  GetProjectMyContractsSubListing({
    this.response,
  });

  ResponseGetProjectMyContractsSubListing? response;

  factory GetProjectMyContractsSubListing.fromJson(Map<String, dynamic> json) =>
      GetProjectMyContractsSubListing(
        response:
            ResponseGetProjectMyContractsSubListing.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetProjectMyContractsSubListing {
  ResponseGetProjectMyContractsSubListing(
      {this.errorCode,
      this.msg,
      this.contractLists,
      this.totalBar,
      this.orderList,
      this.offset});

  String? errorCode;
  String? msg;
  String? offset;
  List<ContractList>? contractLists;
  TotalBar? totalBar;
  List<OrderList>? orderList;

  factory ResponseGetProjectMyContractsSubListing.fromJson(
          Map<String, dynamic> json) =>
      ResponseGetProjectMyContractsSubListing(
        errorCode: json["error_code"],
        msg: json["msg"],
        contractLists: List<ContractList>.from(
            json["contract_lists"].map((x) => ContractList.fromJson(x))),
        totalBar: TotalBar.fromJson(json["total_bar"]),
        orderList: List<OrderList>.from(
            json["order_list"].map((x) => OrderList.fromJson(x))),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "contract_lists":
            List<dynamic>.from(contractLists!.map((x) => x.toJson())),
        "total_bar": totalBar!.toJson(),
        "order_list": List<dynamic>.from(orderList!.map((x) => x.toJson())),
      };
}

class ContractList {
  ContractList({
    this.companyIdFk,
    this.mstCompanyName,
    this.gradeId,
    this.woOrderNo,
    this.woOrderId,
    this.projectId,
    this.towarId,
    this.estDate,
    this.projectName,
    this.remarks,
    this.woRuningStatus,
    this.uploadNoteImage,
    this.contractType,
    this.dueamount,
    this.totalPercentage,
    this.pendingInvoice,
    this.totalInvoice,
  });

  String? companyIdFk;
  String? mstCompanyName;
  String? gradeId;
  String? woOrderNo;
  String? woOrderId;
  String? projectId;
  String? towarId;
  String? estDate;
  String? projectName;
  String? remarks;
  String? woRuningStatus;
  List<dynamic>? uploadNoteImage;
  String? contractType;
  String? dueamount;
  String? totalPercentage;
  String? pendingInvoice;
  String? totalInvoice;

  factory ContractList.fromJson(Map<String, dynamic> json) => ContractList(
        companyIdFk: json["company_id_fk"],
        mstCompanyName: json["mst_company_name"],
        gradeId: json["grade_id"],
        woOrderNo: json["wo_order_no"],
        woOrderId: json["wo_order_id"],
        projectId: json["project_id"],
        towarId: json["towar_id"],
        estDate: json["est_date"],
        projectName: json["project_name"],
        remarks: json["remarks"],
        woRuningStatus: json["wo_runing_status"],
        uploadNoteImage:
            List<dynamic>.from(json["upload_note_image"].map((x) => x)),
        contractType: json["contract_type"],
        dueamount: json["dueamount"],
        totalPercentage: json["total_percentage"],
        pendingInvoice: json["pending_invoice"],
        totalInvoice: json["total_invoice"],
      );

  Map<String, dynamic> toJson() => {
        "company_id_fk": companyIdFk,
        "mst_company_name": mstCompanyName,
        "grade_id": gradeId,
        "wo_order_no": woOrderNo,
        "wo_order_id": woOrderId,
        "project_id": projectId,
        "towar_id": towarId,
        "est_date": estDate,
        "project_name": projectName,
        "remarks": remarks,
        "wo_runing_status": woRuningStatus,
        "upload_note_image": List<dynamic>.from(uploadNoteImage!.map((x) => x)),
        "contract_type": contractType,
        "dueamount": dueamount,
        "total_percentage": totalPercentage,
        "pending_invoice": pendingInvoice,
        "total_invoice": totalInvoice,
      };
}

class OrderList {
  OrderList({
    this.id,
    this.name,
  });

  String? id;
  String? name;

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class TotalBar {
  TotalBar({
    this.totalAmount,
    this.workDone,
    this.totalPaid,
    this.payables,
    this.discountAmount,
  });

  String? totalAmount;
  String? workDone;
  String? totalPaid;
  String? payables;
  String? discountAmount;

  factory TotalBar.fromJson(Map<String, dynamic> json) => TotalBar(
        totalAmount: json["total_amount"],
        workDone: json["work_done"],
        totalPaid: json["total_paid"],
        payables: json["payables"],
        discountAmount: json["discount_amount"],
      );

  Map<String, dynamic> toJson() => {
        "total_amount": totalAmount,
        "work_done": workDone,
        "total_paid": totalPaid,
        "payables": payables,
        "discount_amount": discountAmount,
      };
}
