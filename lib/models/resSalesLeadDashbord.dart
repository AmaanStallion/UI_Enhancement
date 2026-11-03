// To parse this JSON data, do
//
//     final resSalesLeadDashbord = resSalesLeadDashbordFromJson(jsonString);

import 'dart:convert';

ResSalesLeadDashbord resSalesLeadDashbordFromJson(String str) =>
    ResSalesLeadDashbord.fromJson(json.decode(str));

String resSalesLeadDashbordToJson(ResSalesLeadDashbord data) =>
    json.encode(data.toJson());

class ResSalesLeadDashbord {
  ResSalesLeadDashbordResponse? response;

  ResSalesLeadDashbord({
    this.response,
  });

  factory ResSalesLeadDashbord.fromJson(Map<String, dynamic> json) =>
      ResSalesLeadDashbord(
        response: json["response"] == null
            ? null
            : ResSalesLeadDashbordResponse.fromJson(json["response"]),
      );

  Map<String, dynamic> toJson() => {
        "response": response?.toJson(),
      };
}

class ResSalesLeadDashbordResponse {
  String? errorCode;
  String? msg;
  LeadModule? leadModule;
  FollowUp? followUp;
  PotentialClient? potentialClient;
  LeadSource? leadSource;
  List<Active>? activeSalesExe;
  List<Active>? activeChennelPart;
  List<Budget>? budget;
  List<Reason>? reason;

  ResSalesLeadDashbordResponse({
    this.errorCode,
    this.msg,
    this.leadModule,
    this.followUp,
    this.potentialClient,
    this.leadSource,
    this.activeSalesExe,
    this.activeChennelPart,
    this.budget,
    this.reason,
  });

  factory ResSalesLeadDashbordResponse.fromJson(Map<String, dynamic> json) =>
      ResSalesLeadDashbordResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        leadModule: json["lead_module"] == null
            ? null
            : LeadModule.fromJson(json["lead_module"]),
        followUp: json["followUp"] == null
            ? null
            : FollowUp.fromJson(json["followUp"]),
        potentialClient: json["potential_client"] == null
            ? null
            : PotentialClient.fromJson(json["potential_client"]),
        leadSource: json["lead_source"] == null
            ? null
            : LeadSource.fromJson(json["lead_source"]),
        activeSalesExe: json["active_sales_exe"] == null
            ? []
            : List<Active>.from(
                json["active_sales_exe"]!.map((x) => Active.fromJson(x))),
        activeChennelPart: json["active_chennel_part"] == null
            ? []
            : List<Active>.from(
                json["active_chennel_part"]!.map((x) => Active.fromJson(x))),
        budget: json["budget"] == null
            ? []
            : List<Budget>.from(json["budget"]!.map((x) => Budget.fromJson(x))),
        reason: json["reason"] == null
            ? []
            : List<Reason>.from(json["reason"]!.map((x) => Reason.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "lead_module": leadModule?.toJson(),
        "followUp": followUp?.toJson(),
        "potential_client": potentialClient?.toJson(),
        "lead_source": leadSource?.toJson(),
        "active_sales_exe": activeSalesExe == null
            ? []
            : List<dynamic>.from(activeSalesExe!.map((x) => x.toJson())),
        "active_chennel_part": activeChennelPart == null
            ? []
            : List<dynamic>.from(activeChennelPart!.map((x) => x.toJson())),
        "budget": budget == null
            ? []
            : List<dynamic>.from(budget!.map((x) => x.toJson())),
        "reason": reason == null
            ? []
            : List<dynamic>.from(reason!.map((x) => x.toJson())),
      };
}

class Reason {
  String? name;
  String? totSource;
  String? totLead;
  String? percent;

  Reason({
    this.name,
    this.totSource,
    this.totLead,
    this.percent,
  });

  factory Reason.fromJson(Map<String, dynamic> json) => Reason(
        name: json["name"],
        totSource: json["tot_source"],
        totLead: json["tot_lead"],
        percent: json["percent"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "tot_source": totSource,
        "tot_lead": totLead,
        "percent": percent,
      };
}

class Active {
  String? name;
  String? totLead;
  String? followUp;
  String? success;
  String? missLead;

  Active({
    this.name,
    this.totLead,
    this.followUp,
    this.success,
    this.missLead,
  });

  factory Active.fromJson(Map<String, dynamic> json) => Active(
        name: json["name"],
        totLead: json["tot_lead"],
        followUp: json["follow_up"],
        success: json["success"],
        missLead: json["miss_lead"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "tot_lead": totLead,
        "follow_up": followUp,
        "success": success,
        "miss_lead": missLead,
      };
}

class Budget {
  String? leadBudgetIdFk;
  String? name;
  String? percentage;

  Budget({
    this.leadBudgetIdFk,
    this.name,
    this.percentage,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        leadBudgetIdFk: json["lead_budget_id_fk"],
        name: json["name"],
        percentage: json["percentage"],
      );

  Map<String, dynamic> toJson() => {
        "lead_budget_id_fk": leadBudgetIdFk,
        "name": name,
        "percentage": percentage,
      };
}

class FollowUp {
  String? totalFollow;
  String? luractive;
  String? enquiry;
  String? potential;
  String? totalMisslead;
  String? walkIn;

  FollowUp({
    this.totalFollow,
    this.luractive,
    this.enquiry,
    this.potential,
    this.totalMisslead,
    this.walkIn,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) => FollowUp(
        totalFollow: json["total_follow"],
        luractive: json["luractive"],
        enquiry: json["enquiry"],
        potential: json["potential"],
        totalMisslead: json["total_misslead"],
        walkIn: json["walk_in"],
      );

  Map<String, dynamic> toJson() => {
        "total_follow": totalFollow,
        "luractive": luractive,
        "enquiry": enquiry,
        "potential": potential,
        "total_misslead": totalMisslead,
        "walk_in": walkIn,
      };
}

class LeadModule {
  String? totalLead;
  String? successLead;
  String? failLead;
  String? conversionRate;

  LeadModule({
    this.totalLead,
    this.successLead,
    this.failLead,
    this.conversionRate,
  });

  factory LeadModule.fromJson(Map<String, dynamic> json) => LeadModule(
        totalLead: json["total_lead"],
        successLead: json["success_lead"],
        failLead: json["fail_lead"],
        conversionRate: json["conversion_rate"],
      );

  Map<String, dynamic> toJson() => {
        "total_lead": totalLead,
        "success_lead": successLead,
        "fail_lead": failLead,
        "conversion_rate": conversionRate,
      };
}

class LeadSource {
  List<GetLeadSource>? getLeadSource;

  LeadSource({
    this.getLeadSource,
  });

  factory LeadSource.fromJson(Map<String, dynamic> json) => LeadSource(
        getLeadSource: json["getLeadSource"] == null
            ? []
            : List<GetLeadSource>.from(
                json["getLeadSource"]!.map((x) => GetLeadSource.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "getLeadSource": getLeadSource == null
            ? []
            : List<dynamic>.from(getLeadSource!.map((x) => x.toJson())),
      };
}

class GetLeadSource {
  String? name;
  String? totSource;
  String? totLead;
  String? percent;

  GetLeadSource({
    this.name,
    this.totSource,
    this.totLead,
    this.percent,
  });

  factory GetLeadSource.fromJson(Map<String, dynamic> json) => GetLeadSource(
        name: json["name"],
        totSource: json["tot_source"],
        totLead: json["tot_lead"],
        percent: json["percent"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "tot_source": totSource,
        "tot_lead": totLead,
        "percent": percent,
      };
}

class PotentialClient {
  List<Potential>? potential;

  PotentialClient({
    this.potential,
  });

  factory PotentialClient.fromJson(Map<String, dynamic> json) =>
      PotentialClient(
        potential: json["potential"] == null
            ? []
            : List<Potential>.from(
                json["potential"]!.map((x) => Potential.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "potential": potential == null
            ? []
            : List<dynamic>.from(potential!.map((x) => x.toJson())),
      };
}

class Potential {
  String? leadBuyerName;
  String? leadRequirement;
  String? leadBudgetValue;

  Potential({
    this.leadBuyerName,
    this.leadRequirement,
    this.leadBudgetValue,
  });

  factory Potential.fromJson(Map<String, dynamic> json) => Potential(
        leadBuyerName: json["lead_buyer_name"],
        leadRequirement: json["lead_requirement"],
        leadBudgetValue: json["lead_budget_value"],
      );

  Map<String, dynamic> toJson() => {
        "lead_buyer_name": leadBuyerName,
        "lead_requirement": leadRequirement,
        "lead_budget_value": leadBudgetValue,
      };
}
