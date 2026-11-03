// To parse this JSON data, do
//
//     final getProjectMyContracts = getProjectMyContractsFromJson(jsonString);

import 'dart:convert';

GetProjectMyContracts getProjectMyContractsFromJson(String str) =>
    GetProjectMyContracts.fromJson(json.decode(str));

String getProjectMyContractsToJson(GetProjectMyContracts data) =>
    json.encode(data.toJson());

class GetProjectMyContracts {
  GetProjectMyContracts({
    this.response,
  });

  ResponseGetProjectMyContracts? response;

  factory GetProjectMyContracts.fromJson(Map<String, dynamic> json) =>
      GetProjectMyContracts(
        response: ResponseGetProjectMyContracts.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetProjectMyContracts {
  ResponseGetProjectMyContracts(
      {this.errorCode,
      this.msg,
      this.contractLists,
      this.totalBar,
      this.orderList,
      this.typeUser,
      this.towarList,
      this.accountFlag,
      this.offset});

  String? errorCode;
  String? msg;
  List<ContractList>? contractLists;
  TotalBar? totalBar;
  List<OrderList>? orderList;
  String? typeUser;
  String? offset;
  List<TowarList>? towarList;
  String? accountFlag;

  factory ResponseGetProjectMyContracts.fromJson(Map<String, dynamic> json) =>
      ResponseGetProjectMyContracts(
        errorCode: json["error_code"],
        msg: json["msg"],
        contractLists: List<ContractList>.from(
            json["contract_lists"].map((x) => ContractList.fromJson(x))),
        totalBar: TotalBar.fromJson(json["total_bar"]),
        orderList: List<OrderList>.from(
            json["order_list"].map((x) => OrderList.fromJson(x))),
        typeUser: json["type_user"],
        offset: json["offset"],
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"].map((x) => TowarList.fromJson(x))),
        accountFlag: json["account_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "contract_lists":
            List<dynamic>.from(contractLists!.map((x) => x.toJson())),
        "total_bar": totalBar!.toJson(),
        "order_list": List<dynamic>.from(orderList!.map((x) => x.toJson())),
        "type_user": typeUser,
        "offset": offset,
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
        "account_flag": accountFlag,
      };
}

class ContractList {
  ContractList({
    this.companyType,
    this.mstCompanyName,
    this.gradeId,
    this.woOrderNo,
    this.woOrderId,
    this.projectId,
    this.towarId,
    this.estDate,
    this.projectName,
    this.contractType,
    this.woTypeOrder,
    this.dueamount,
    this.totalPercentage,
    this.woOrderCount,
    this.remarks,
    this.uploadNoteImage,
    this.woRuningStatus,
    this.pendingInvoice,
    this.totalInvoice,
    this.companyIdFk,
  });

  String? companyIdFk;

  String? companyType;
  String? mstCompanyName;
  String? gradeId;
  String? woOrderNo;
  String? woOrderId;
  String? projectId;
  String? towarId;
  String? estDate;
  String? projectName;
  String? contractType;
  String? woTypeOrder;
  String? dueamount;
  String? totalPercentage;
  String? woOrderCount;
  String? remarks;
  String? woRuningStatus;
  List<dynamic>? uploadNoteImage;
  String? pendingInvoice;
  String? totalInvoice;

  factory ContractList.fromJson(Map<String, dynamic> json) => ContractList(
        companyType: json["company_type"],
        mstCompanyName: json["mst_company_name"],
        gradeId: json["grade_id"],
        woOrderNo: json["wo_order_no"],
        woOrderId: json["wo_order_id"],
        projectId: json["project_id"],
        towarId: json["towar_id"] ?? "",
        estDate: json["est_date"],
        projectName: json["project_name"],
        contractType: json["contract_type"],
        woTypeOrder: json["wo_type_order"],
        dueamount: json["dueamount"],
        totalPercentage: json["total_percentage"],
        woOrderCount: json["wo_order_count"],
        woRuningStatus: json["wo_runing_status"],
        remarks: json["remarks"] ?? "",
        uploadNoteImage: json["upload_note_image"] == null
            ? null
            : List<dynamic>.from(json["upload_note_image"].map((x) => x)),
        pendingInvoice: json["pending_invoice"],
        totalInvoice: json["total_invoice"],
        companyIdFk: json["company_id_fk"],
      );

  Map<String, dynamic> toJson() => {
        "company_type": companyType,
        "mst_company_name": mstCompanyName,
        "grade_id": gradeId,
        "wo_order_no": woOrderNo,
        "wo_order_id": woOrderId,
        "project_id": projectId,
        "towar_id": towarId ?? "",
        "est_date": estDate,
        "project_name": projectName,
        "contract_type": contractType,
        "wo_type_order": woTypeOrder,
        "dueamount": dueamount,
        "total_percentage": totalPercentage,
        "wo_order_count": woOrderCount,
        "wo_runing_status": woRuningStatus,
        "remarks": remarks ?? "",
        "upload_note_image": uploadNoteImage == null
            ? null
            : List<dynamic>.from(uploadNoteImage!.map((x) => x)),
        "pending_invoice": pendingInvoice,
        "total_invoice": totalInvoice,
        "company_id_fk": companyIdFk,
      };
}

class OrderList {
  OrderList({
    this.id,
    this.name,
    this.towarList,
  });

  String? id;
  String? name;
  List<TowarList>? towarList;

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"].map((x) => TowarList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? "",
        "name": name ?? "",
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
      };
}

class TotalBar {
  TotalBar({
    this.totalAmount,
    this.workDone,
    this.totalPaid,
    this.payables,
    this.discountAmount,
    this.contractorTotalAmount,
    this.contractorWorkDone,
    this.contractorTotalPaid,
    this.contractorPayables,
    this.contractorDiscountAmount,
    this.consultantTotalAmount,
    this.consultantWorkDone,
    this.consultantTotalPaid,
    this.consultantPayables,
    this.consultantDiscountAmount,
  });

  String? totalAmount;
  String? workDone;
  String? totalPaid;
  String? payables;
  String? discountAmount;
  String? contractorTotalAmount;
  String? contractorWorkDone;
  String? contractorTotalPaid;
  String? contractorPayables;
  String? contractorDiscountAmount;
  String? consultantTotalAmount;
  String? consultantWorkDone;
  String? consultantTotalPaid;
  String? consultantPayables;
  String? consultantDiscountAmount;

  factory TotalBar.fromJson(Map<String, dynamic> json) => TotalBar(
        totalAmount: json["total_amount"],
        workDone: json["work_done"],
        totalPaid: json["total_paid"],
        payables: json["payables"],
        discountAmount: json["discount_amount"],
        contractorTotalAmount: json["contractor_total_amount"],
        contractorWorkDone: json["contractor_work_done"],
        contractorTotalPaid: json["contractor_total_paid"],
        contractorPayables: json["contractor_payables"],
        contractorDiscountAmount: json["contractor_discount_amount"],
        consultantTotalAmount: json["consultant_total_amount"],
        consultantWorkDone: json["consultant_work_done"],
        consultantTotalPaid: json["consultant_total_paid"],
        consultantPayables: json["consultant_payables"],
        consultantDiscountAmount: json["consultant_discount_amount"],
      );

  Map<String, dynamic> toJson() => {
        "total_amount": totalAmount,
        "work_done": workDone,
        "total_paid": totalPaid,
        "payables": payables,
        "discount_amount": discountAmount,
        "contractor_total_amount": contractorTotalAmount,
        "contractor_work_done": contractorWorkDone,
        "contractor_total_paid": contractorTotalPaid,
        "contractor_payables": contractorPayables,
        "contractor_discount_amount": contractorDiscountAmount,
        "consultant_total_amount": consultantTotalAmount,
        "consultant_work_done": consultantWorkDone,
        "consultant_total_paid": consultantTotalPaid,
        "consultant_payables": consultantPayables,
        "consultant_discount_amount": consultantDiscountAmount,
      };
}

class TowarList {
  TowarList({
    this.towarId,
    this.towarName,
  });

  String? towarId;
  String? towarName;

  factory TowarList.fromJson(Map<String, dynamic> json) => TowarList(
        towarId: json["towar_id"] ?? "",
        towarName: json["towar_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "towar_id": towarId ?? "",
        "towar_name": towarName ?? "",
      };
}
