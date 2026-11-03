// To parse this JSON data, do
//
//     final getAllSalesLead = getAllSalesLeadFromJson(jsonString);

import 'dart:convert';

GetAllSalesLead getAllSalesLeadFromJson(String str) =>
    GetAllSalesLead.fromJson(json.decode(str));

String getAllSalesLeadToJson(GetAllSalesLead data) =>
    json.encode(data.toJson());

class GetAllSalesLead {
  ResponseGetAllSalesLead? response;

  GetAllSalesLead({
    this.response,
  });

  factory GetAllSalesLead.fromJson(Map<String, dynamic> json) =>
      GetAllSalesLead(
        response: json["Response"] == null
            ? null
            : ResponseGetAllSalesLead.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetAllSalesLead {
  String? errorCode;
  String? msg;
  String? maskContact;
  List<SalesLead>? salesLead;
  String? offset;
  String? generatedLead;
  String? cancelLead;
  String? convertedLead;
  String? clientAccess;

  ResponseGetAllSalesLead({
    this.errorCode,
    this.msg,
    this.maskContact,
    this.salesLead,
    this.offset,
    this.generatedLead,
    this.cancelLead,
    this.convertedLead,
    this.clientAccess,
  });

  factory ResponseGetAllSalesLead.fromJson(Map<String, dynamic> json) =>
      ResponseGetAllSalesLead(
        errorCode: json["error_code"],
        msg: json["msg"],
        clientAccess: json["client_access"],
        maskContact: json["mask_contact"],
        salesLead: json["sales_lead"] == null
            ? []
            : List<SalesLead>.from(
                json["sales_lead"]!.map((x) => SalesLead.fromJson(x))),
        offset: json["offset"],
        generatedLead: json["generated_lead"],
        cancelLead: json["cancel_lead"],
        convertedLead: json["converted_lead"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "client_access": clientAccess,
        "mask_contact": maskContact,
        "sales_lead": salesLead == null
            ? []
            : List<dynamic>.from(salesLead!.map((x) => x.toJson())),
        "offset": offset,
        "generated_lead": generatedLead,
        "cancel_lead": cancelLead,
        "converted_lead": convertedLead,
      };
}

class SalesLead {
  String? mstSalesLeadId;
  String? projectIdFk;
  String? towarIdFk;
  String? flatBuyerIdFk;
  String? leadBuyerName;
  String? leadBuyerPhone;
  String? leadBuyerEmail;
  String? leadRequirement;
  String? leadBudgetValue;
  String? leadSource;
  String? leadIntrested;
  String? leadFlatIdFk;
  String? leadLocation;
  String? brokerIdFk;
  String? subSourceIdFk;
  String? ethinicityIdFk;
  String? leadStageIdFk;
  String? lostReasonIdFk;
  String? areaRangeIdFk;
  String? locationIdFk;
  String? regionIdFk;
  String? leadBudgetIdFk;
  String? leadSourceIdFk;
  String? leadUpdateAccess;
  String? leadBuyerStatus;
  String? leadVerifyMessageId;
  String? leadBankName;
  String? leadBankAccountHolderName;
  String? leadBankAccountNo;
  String? leadBankIfsc;
  String? leadBankBranch;
  String? leadBuyerUpdatedAt;
  DateTime? leadBuyerCreatedAt;
  String? subSourceName;
  String? ethinicityIdName;
  String? leadStageIdName;
  String? lostReasonName;
  String? areaRangeName;
  String? locationName;
  String? regionName;
  String? editFlag;
  List<Map<String, String?>>? details;
  String? leadOwner;
  String? totalLead;
  String? flatName;
  String? brokerName;
  String? leadSourceManagerId;
  String? sourceManagerName;
  String? emailVerify;
  String? smsVerify;
  List<AlternatePhone>? alternatePhone;
  String? buyerTypeIdFk;
  String? fundingTypeIdFk;
  String? age;
  String? campaignIdFk;
  String? currentOwnerIdFk;
  String? nationalityIdFk;
  String? currentConfigurationIdFk;
  String? currentOwner;
  String? currentConfiguration;
  String? campaign;
  String? nationality;
  String? pincode;
  String? leadClosingManagerId;
  String? closingManagerName;

  SalesLead({
    this.mstSalesLeadId,
    this.projectIdFk,
    this.towarIdFk,
    this.flatBuyerIdFk,
    this.leadBuyerName,
    this.leadBuyerPhone,
    this.leadBuyerEmail,
    this.leadRequirement,
    this.leadBudgetValue,
    this.leadSource,
    this.leadIntrested,
    this.leadFlatIdFk,
    this.leadLocation,
    this.brokerIdFk,
    this.subSourceIdFk,
    this.ethinicityIdFk,
    this.leadStageIdFk,
    this.lostReasonIdFk,
    this.areaRangeIdFk,
    this.locationIdFk,
    this.regionIdFk,
    this.leadBudgetIdFk,
    this.leadSourceIdFk,
    this.leadUpdateAccess,
    this.leadBuyerStatus,
    this.leadVerifyMessageId,
    this.leadBankName,
    this.leadBankAccountHolderName,
    this.leadBankAccountNo,
    this.leadBankIfsc,
    this.leadBankBranch,
    this.leadBuyerUpdatedAt,
    this.leadBuyerCreatedAt,
    this.subSourceName,
    this.ethinicityIdName,
    this.leadStageIdName,
    this.lostReasonName,
    this.areaRangeName,
    this.locationName,
    this.regionName,
    this.editFlag,
    this.details,
    this.leadOwner,
    this.totalLead,
    this.flatName,
    this.brokerName,
    this.leadSourceManagerId,
    this.sourceManagerName,
    this.emailVerify,
    this.smsVerify,
    this.alternatePhone,
    this.age,
    this.buyerTypeIdFk,
    this.fundingTypeIdFk,
    this.campaignIdFk,
    this.currentOwnerIdFk,
    this.nationalityIdFk,
    this.currentConfigurationIdFk,
    this.currentOwner,
    this.currentConfiguration,
    this.campaign,
    this.nationality,
    this.pincode,
    this.leadClosingManagerId,
    this.closingManagerName,
  });

  factory SalesLead.fromJson(Map<String, dynamic> json) => SalesLead(
        mstSalesLeadId: json["mst_sales_lead_id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        flatBuyerIdFk: json["flat_buyer_id_fk"],
        leadBuyerName: json["lead_buyer_name"],
        leadBuyerPhone: json["lead_buyer_phone"],
        leadBuyerEmail: json["lead_buyer_email"],
        leadRequirement: json["lead_requirement"],
        leadBudgetValue: json["lead_budget_value"],
        leadSource: json["lead_source"],
        leadIntrested: json["lead_intrested"],
        leadFlatIdFk: json["lead_flat_id_fk"],
        leadLocation: json["lead_location"],
        brokerIdFk: json["broker_id_fk"],
        subSourceIdFk: json["sub_source_id_fk"],
        ethinicityIdFk: json["ethinicity_id_fk"],
        leadStageIdFk: json["lead_stage_id_fk"],
        lostReasonIdFk: json["lost_reason_id_fk"],
        areaRangeIdFk: json["area_range_id_fk"],
        locationIdFk: json["location_id_fk"],
        regionIdFk: json["region_id_fk"],
        leadBudgetIdFk: json["lead_budget_id_fk"],
        leadSourceIdFk: json["lead_source_id_fk"],
        leadSourceManagerId: json["lead_source_manager_id"],
        leadUpdateAccess: json["lead_update_access"],
        leadBuyerStatus: json["lead_buyer_status"],
        emailVerify: json["email_verify"],
        smsVerify: json["sms_verify"],
        leadVerifyMessageId: json["lead_verify_messageID"],
        leadBankName: json["lead_bank_name"],
        leadBankAccountHolderName: json["lead_bank_account_holder_name"],
        leadBankAccountNo: json["lead_bank_account_no"],
        leadBankIfsc: json["lead_bank_ifsc"],
        leadBankBranch: json["lead_bank_branch"],
        leadBuyerUpdatedAt: json["lead_buyer_updated_at"],
        leadBuyerCreatedAt: json["lead_buyer_created_at"] == null
            ? null
            : DateTime.parse(json["lead_buyer_created_at"]),
        sourceManagerName: json["source_manager_name"],
        subSourceName: json["sub_source_name"],
        ethinicityIdName: json["ethinicity_id_name"],
        leadStageIdName: json["lead_stage_id_name"],
        lostReasonName: json["lost_reason_name"],
        areaRangeName: json["area_range_name"],
        locationName: json["location_name"],
        regionName: json["region_name"],
        editFlag: json["edit_flag"],
        details: json["details"] == null
            ? []
            : List<Map<String, String?>>.from(json["details"]!.map((x) =>
                Map.from(x).map((k, v) => MapEntry<String, String?>(k, v)))),
        leadOwner: json["lead_owner"],
        totalLead: json["total_lead"],
        flatName: json["flat_name"],
        brokerName: json["broker_name"],
        alternatePhone: json["alternate_phone"] == null
            ? []
            : List<AlternatePhone>.from(json["alternate_phone"]!
                .map((x) => AlternatePhone.fromJson(x))),
        age: json["age"],
        buyerTypeIdFk: json["buyer_type_id_fk"],
        fundingTypeIdFk: json["funding_type_id_fk"],
        campaignIdFk: json["campaign_id_fk"],
        currentOwnerIdFk: json["current_owner_id_fk"],
        nationalityIdFk: json["nationality_id_fk"],
        currentConfigurationIdFk: json["current_configuration_id_fk"],
        currentOwner: json["current_owner"],
        currentConfiguration: json["current_configuration"],
        campaign: json["campaign"],
        nationality: json["nationality"],
        pincode: json["pincode"],
        leadClosingManagerId: json["lead_closing_manager_id"],
        closingManagerName: json["closing_manager_name"],
      );

  Map<String, dynamic> toJson() => {
        "mst_sales_lead_id": mstSalesLeadId,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "flat_buyer_id_fk": flatBuyerIdFk,
        "lead_buyer_name": leadBuyerName,
        "lead_buyer_phone": leadBuyerPhone,
        "lead_buyer_email": leadBuyerEmail,
        "lead_requirement": leadRequirement,
        "lead_budget_value": leadBudgetValue,
        "lead_source": leadSource,
        "lead_intrested": leadIntrested,
        "lead_flat_id_fk": leadFlatIdFk,
        "lead_location": leadLocation,
        "broker_id_fk": brokerIdFk,
        "sub_source_id_fk": subSourceIdFk,
        "ethinicity_id_fk": ethinicityIdFk,
        "lead_stage_id_fk": leadStageIdFk,
        "lost_reason_id_fk": lostReasonIdFk,
        "area_range_id_fk": areaRangeIdFk,
        "location_id_fk": locationIdFk,
        "region_id_fk": regionIdFk,
        "lead_budget_id_fk": leadBudgetIdFk,
        "lead_source_id_fk": leadSourceIdFk,
        "lead_source_manager_id": leadSourceManagerId,
        "lead_update_access": leadUpdateAccess,
        "lead_buyer_status": leadBuyerStatus,
        "email_verify": emailVerify,
        "sms_verify": smsVerify,
        "lead_verify_messageID": leadVerifyMessageId,
        "lead_bank_name": leadBankName,
        "lead_bank_account_holder_name": leadBankAccountHolderName,
        "lead_bank_account_no": leadBankAccountNo,
        "lead_bank_ifsc": leadBankIfsc,
        "lead_bank_branch": leadBankBranch,
        "lead_buyer_updated_at": leadBuyerUpdatedAt,
        "lead_buyer_created_at": leadBuyerCreatedAt?.toIso8601String(),
        "source_manager_name": sourceManagerName,
        "sub_source_name": subSourceName,
        "ethinicity_id_name": ethinicityIdName,
        "lead_stage_id_name": leadStageIdName,
        "lost_reason_name": lostReasonName,
        "area_range_name": areaRangeName,
        "location_name": locationName,
        "region_name": regionName,
        "edit_flag": editFlag,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) =>
                Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
        "lead_owner": leadOwner,
        "total_lead": totalLead,
        "flat_name": flatName,
        "broker_name": brokerName,
        "alternate_phone": alternatePhone == null
            ? []
            : List<dynamic>.from(alternatePhone!.map((x) => x.toJson())),
        "age": age,
        "buyer_type_id_fk": buyerTypeIdFk,
        "funding_type_id_fk": fundingTypeIdFk,
        "campaign_id_fk": campaignIdFk,
        "current_owner_id_fk": currentOwnerIdFk,
        "nationality_id_fk": nationalityIdFk,
        "current_configuration_id_fk": currentConfigurationIdFk,
        "current_owner": currentOwner,
        "current_configuration": currentConfiguration,
        "campaign": campaign,
        "nationality": nationality,
        "pincode": pincode,
        "lead_closing_manager_id": leadClosingManagerId,
        "closing_manager_name": closingManagerName,
      };
}

class AlternatePhone {
  String? mobilenumber;

  AlternatePhone({
    this.mobilenumber,
  });

  factory AlternatePhone.fromJson(Map<String, dynamic> json) => AlternatePhone(
        mobilenumber: json["mobilenumber"],
      );

  Map<String, dynamic> toJson() => {
        "mobilenumber": mobilenumber,
      };
}
