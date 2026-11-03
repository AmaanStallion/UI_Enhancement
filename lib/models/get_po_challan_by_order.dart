// To parse this JSON data, do
//
//     final getPoChallanByOrder = getPoChallanByOrderFromJson(jsonString);

import 'dart:convert';

GetPoChallanByOrder getPoChallanByOrderFromJson(String str) =>
    GetPoChallanByOrder.fromJson(json.decode(str));

String getPoChallanByOrderToJson(GetPoChallanByOrder data) =>
    json.encode(data.toJson());

class GetPoChallanByOrder {
  ResponseGetPoChallanByOrder? response;

  GetPoChallanByOrder({
    this.response,
  });

  factory GetPoChallanByOrder.fromJson(Map<String, dynamic> json) =>
      GetPoChallanByOrder(
        response: json["Response"] == null
            ? null
            : ResponseGetPoChallanByOrder.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPoChallanByOrder {
  String? errorCode;
  String? msg;
  List<ContractorList>? contractorList;
  List<GradeDetail>? gradeDetails;
  List<ChalanDetail>? chalanDetails;
  String? orderCompletFlag;
  String? sopChallanFlag;

  ResponseGetPoChallanByOrder({
    this.errorCode,
    this.msg,
    this.contractorList,
    this.gradeDetails,
    this.chalanDetails,
    this.orderCompletFlag,
    this.sopChallanFlag,
  });

  factory ResponseGetPoChallanByOrder.fromJson(Map<String, dynamic> json) =>
      ResponseGetPoChallanByOrder(
        errorCode: json["error_code"],
        msg: json["msg"],
        contractorList: json["contractor_list"] == null
            ? []
            : List<ContractorList>.from(json["contractor_list"]!
                .map((x) => ContractorList.fromJson(x))),
        gradeDetails: json["grade_details"] == null
            ? []
            : List<GradeDetail>.from(
                json["grade_details"]!.map((x) => GradeDetail.fromJson(x))),
        chalanDetails: json["chalan_details"] == null
            ? []
            : List<ChalanDetail>.from(
                json["chalan_details"]!.map((x) => ChalanDetail.fromJson(x))),
        orderCompletFlag: json["order_complet_flag"],
        sopChallanFlag: json["sop_challan_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "contractor_list": contractorList == null
            ? []
            : List<dynamic>.from(contractorList!.map((x) => x.toJson())),
        "grade_details": gradeDetails == null
            ? []
            : List<dynamic>.from(gradeDetails!.map((x) => x.toJson())),
        "chalan_details": chalanDetails == null
            ? []
            : List<dynamic>.from(chalanDetails!.map((x) => x.toJson())),
        "order_complet_flag": orderCompletFlag,
        "sop_challan_flag": sopChallanFlag,
      };
}

class ChalanDetail {
  String? gradName;
  String? gradId;
  String? chalanType;
  String? chalanQuantity;
  String? chalanId;
  String? stockRemark;
  String? companyId;
  String? challanNo;
  String? companyName;
  String? workOrderId;
  String? workOrderNumber;
  String? deliveryDate;
  String? castingUnitName;
  String? castingUnitId;
  String? editedName;
  String? stockConsumeType;

  ChalanDetail({
    this.gradName,
    this.editedName,
    this.gradId,
    this.chalanType,
    this.chalanQuantity,
    this.chalanId,
    this.stockRemark,
    this.companyId,
    this.challanNo,
    this.companyName,
    this.workOrderId,
    this.workOrderNumber,
    this.deliveryDate,
    this.castingUnitName,
    this.castingUnitId,
    this.stockConsumeType,
  });

  factory ChalanDetail.fromJson(Map<String, dynamic> json) => ChalanDetail(
        gradName: json["grad_name"],
        editedName: json["edited_name"],
        gradId: json["grad_id"],
        chalanType: json["chalan_type"],
        chalanQuantity: json["chalan_quantity"],
        chalanId: json["chalan_id"],
        stockRemark: json["stock_remark"],
        companyId: json["company_id"],
        challanNo: json["challan_no"],
        companyName: json["company_name"],
        workOrderId: json["work_order_id"],
        workOrderNumber: json["work_order_number"],
        deliveryDate: json["delivery_date"],
        castingUnitName: json["casting_unit_name"],
        castingUnitId: json["casting_unit_id"],
        stockConsumeType: json["stock_consume_type"],
      );

  Map<String, dynamic> toJson() => {
        "grad_name": gradName,
        "edited_name": editedName,
        "grad_id": gradId,
        "chalan_type": chalanType,
        "chalan_quantity": chalanQuantity,
        "chalan_id": chalanId,
        "stock_remark": stockRemark,
        "company_id": companyId,
        "challan_no": challanNo,
        "company_name": companyName,
        "work_order_id": workOrderId,
        "work_order_number": workOrderNumber,
        "delivery_date": deliveryDate,
        "casting_unit_name": castingUnitName,
        "casting_unit_id": castingUnitId,
        "stock_consume_type": stockConsumeType,
      };
}

class ContractorList {
  String? mstCompanyId;
  String? mstCompanyName;

  ContractorList({
    this.mstCompanyId,
    this.mstCompanyName,
  });

  factory ContractorList.fromJson(Map<String, dynamic> json) => ContractorList(
        mstCompanyId: json["mst_company_id"],
        mstCompanyName: json["mst_company_name"],
      );

  Map<String, dynamic> toJson() => {
        "mst_company_id": mstCompanyId,
        "mst_company_name": mstCompanyName,
      };
}

class GradeDetail {
  String? castingUnit;
  String? gradeTypeName;
  String? gradeTypeId;
  String? castingUnitName;
  String? castingUnitId;
  String? totalQty;
  String? challanQty;
  String? remainingQty;

  GradeDetail({
    this.castingUnit,
    this.gradeTypeName,
    this.gradeTypeId,
    this.castingUnitName,
    this.castingUnitId,
    this.totalQty,
    this.challanQty,
    this.remainingQty,
  });

  factory GradeDetail.fromJson(Map<String, dynamic> json) => GradeDetail(
        castingUnit: json["casting_unit"],
        gradeTypeName: json["grade_type_name"],
        gradeTypeId: json["grade_type_id"],
        castingUnitName: json["casting_unit_name"],
        castingUnitId: json["casting_unit_id"],
        totalQty: json["total_qty"],
        challanQty: json["challan_qty"],
        remainingQty: json["remaining_qty"],
      );

  Map<String, dynamic> toJson() => {
        "casting_unit": castingUnit,
        "grade_type_name": gradeTypeName,
        "grade_type_id": gradeTypeId,
        "casting_unit_name": castingUnitName,
        "casting_unit_id": castingUnitId,
        "total_qty": totalQty,
        "challan_qty": challanQty,
        "remaining_qty": remainingQty,
      };
}
