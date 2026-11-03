// To parse this JSON data, do
//
//     final getWorkOrderDetails = getWorkOrderDetailsFromJson(jsonString);

import 'dart:convert';

GetWorkOrderDetails getWorkOrderDetailsFromJson(String str) =>
    GetWorkOrderDetails.fromJson(json.decode(str));

String getWorkOrderDetailsToJson(GetWorkOrderDetails data) =>
    json.encode(data.toJson());

class GetWorkOrderDetails {
  GetWorkOrderDetails({
    this.response,
  });

  ResponseGetWorkOrderDetails? response;

  factory GetWorkOrderDetails.fromJson(Map<String, dynamic> json) =>
      GetWorkOrderDetails(
        response: ResponseGetWorkOrderDetails.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetWorkOrderDetails {
  ResponseGetWorkOrderDetails({
    this.errorCode,
    this.msg,
    this.discountArr,
    this.headerPart,
    this.contractorDetails,
    this.totalBar,
    this.payBtnActive,
  });

  String? errorCode;
  String? msg;
  List<DiscountArr>? discountArr;
  HeaderPart? headerPart;
  List<ContractorDetail>? contractorDetails;
  TotalBar? totalBar;
  String? payBtnActive;

  factory ResponseGetWorkOrderDetails.fromJson(Map<String, dynamic> json) =>
      ResponseGetWorkOrderDetails(
        errorCode: json["error_code"],
        msg: json["msg"],
        discountArr: List<DiscountArr>.from(
            json["discount_arr"].map((x) => DiscountArr.fromJson(x))),
        headerPart: HeaderPart.fromJson(json["header_part"]),
        contractorDetails: List<ContractorDetail>.from(
            json["contractor_details"]
                .map((x) => ContractorDetail.fromJson(x))),
        totalBar: TotalBar.fromJson(json["total_bar"]),
        payBtnActive: json["pay_btn_active"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "discount_arr": List<dynamic>.from(discountArr!.map((x) => x.toJson())),
        "header_part": headerPart?.toJson(),
        "contractor_details":
            List<dynamic>.from(contractorDetails!.map((x) => x.toJson())),
        "total_bar": totalBar?.toJson(),
        "pay_btn_active": payBtnActive,
      };
}

class ContractorDetail {
  ContractorDetail({
    this.transId,
    this.name,
    this.headerName,
    this.id,
    this.type,
    this.checkTypeId,
    this.key,
    this.percentage,
    this.woRate,
    this.amount,
    this.woUnitName,
    this.percentageCompleted,
    this.isPaid,
    this.isCompleted,
    this.isRequested,
    this.amountCompleted,
    this.dueFlag,
    this.partialFlag,
  });
  String? partialFlag;

  String? transId;
  String? name;
  String? headerName;
  String? id;
  String? type;
  String? checkTypeId;
  String? key;
  String? percentage;
  String? woRate;
  String? amount;
  String? woUnitName;
  String? percentageCompleted;
  String? isPaid;
  String? isCompleted;
  String? isRequested;
  String? amountCompleted;
  String? dueFlag;

  factory ContractorDetail.fromJson(Map<String, dynamic> json) =>
      ContractorDetail(
        transId: json["trans_id"],
        name: json["name"],
        headerName: json["header_name"],
        id: json["id"],
        type: json["type"],
        checkTypeId: json["check_type_id"],
        key: json["key"],
        percentage: json["percentage"],
        woRate: json["wo_rate"],
        amount: json["amount"],
        woUnitName: json["wo_unit_name"],
        percentageCompleted: json["percentage_completed"],
        isPaid: json["is_paid"],
        isCompleted: json["is_completed"],
        isRequested: json["is_requested"],
        amountCompleted: json["amount_completed"],
        dueFlag: json["due_flag"],
        partialFlag: json["partial_flag"],
      );

  Map<String, dynamic> toJson() => {
        "trans_id": transId,
        "name": name,
        "header_name": headerName,
        "id": id,
        "type": type,
        "check_type_id": checkTypeId,
        "key": key,
        "percentage": percentage,
        "wo_rate": woRate,
        "amount": amount,
        "wo_unit_name": woUnitName,
        "percentage_completed": percentageCompleted,
        "is_paid": isPaid,
        "is_completed": isCompleted,
        "is_requested": isRequested,
        "amount_completed": amountCompleted,
        "due_flag": dueFlag,
        "partial_flag": partialFlag,
      };
}

class DiscountArr {
  DiscountArr(
      {this.discountAmountt,
      this.discountDescription,
      this.discountAddDate,
      this.discountImage});

  String? discountAmountt;
  String? discountDescription;
  String? discountImage;
  DateTime? discountAddDate;

  factory DiscountArr.fromJson(Map<String, dynamic> json) => DiscountArr(
        discountAmountt: json["discount_amount"],
        discountImage: json["discount_image"],
        discountDescription: json["discount_description"],
        discountAddDate: DateTime.parse(json["discount_add_date"]),
      );

  Map<String, dynamic> toJson() => {
        "discount_amount": discountAmountt,
        "discount_image": discountImage,
        "discount_description": discountDescription,
        "discount_add_date":
            "${discountAddDate?.year.toString().padLeft(4, '0')}-${discountAddDate?.month.toString().padLeft(2, '0')}-${discountAddDate?.day.toString().padLeft(2, '0')}",
      };
}

class HeaderPart {
  HeaderPart({
    this.valueOne,
    this.valueTwo,
    this.valueTotal,
    this.gstPercentage,
    this.discountAmount,
    this.retentionPercentage,
    this.retentionAmount,
    this.subTotal,
    this.gstAmount,
    this.woTypeOrder,
    this.woTds,
    this.woTdsPercentage,
  });

  String? valueOne;
  String? valueTwo;
  String? valueTotal;
  String? gstPercentage;
  String? discountAmount;
  String? retentionPercentage;
  String? retentionAmount;
  String? subTotal;
  String? gstAmount;
  String? woTypeOrder;
  String? woTds;
  String? woTdsPercentage;

  factory HeaderPart.fromJson(Map<String, dynamic> json) => HeaderPart(
        valueOne: json["value_one"],
        valueTwo: json["value_two"],
        valueTotal: json["value_total"],
        gstPercentage: json["gst_percentage"],
        discountAmount: json["discount_amount"],
        retentionPercentage: json["retention_percentage"],
        retentionAmount: json["retention_amount"],
        subTotal: json["sub_total"],
        gstAmount: json["gst_amount"],
        woTypeOrder: json["wo_type_order"],
        woTds: json["wo_tds"],
        woTdsPercentage: json["wo_tds_percentage"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "value_one": valueOne,
        "value_two": valueTwo,
        "value_total": valueTotal,
        "gst_percentage": gstPercentage,
        "discount_amount": discountAmount,
        "retention_percentage": retentionPercentage,
        "retention_amount": retentionAmount,
        "sub_total": subTotal,
        "gst_amount": gstAmount,
        "wo_type_order": woTypeOrder,
        "wo_tds": woTds,
        "wo_tds_percentage": woTdsPercentage,
      };
}

class TotalBar {
  TotalBar({
    this.totalAmount,
    this.workDone,
    this.totalPaid,
    this.payables,
  });

  String? totalAmount;
  String? workDone;
  String? totalPaid;
  String? payables;

  factory TotalBar.fromJson(Map<String, dynamic> json) => TotalBar(
        totalAmount: json["total_amount"],
        workDone: json["work_done"],
        totalPaid: json["total_paid"],
        payables: json["payables"],
      );

  Map<String, dynamic> toJson() => {
        "total_amount": totalAmount,
        "work_done": workDone,
        "total_paid": totalPaid,
        "payables": payables,
      };
}

class ListArray {
  ListArray({
    this.contractorDetails,
  });

  List<dynamic>? contractorDetails;

  factory ListArray.fromJson(Map<String, dynamic> json) => ListArray(
        contractorDetails: List<dynamic>.from(json["contractorDetails"]),
      );

  Map<String, dynamic> toJson() => {
        "contractorDetails": contractorDetails,
      };
}
