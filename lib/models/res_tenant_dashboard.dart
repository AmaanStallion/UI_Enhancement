// To parse this JSON data, do
//
//     final resTenantDashbord = resTenantDashbordFromJson(jsonString);

import 'dart:convert';

ResTenantDashbord resTenantDashbordFromJson(String str) =>
    ResTenantDashbord.fromJson(json.decode(str));

String resTenantDashbordToJson(ResTenantDashbord data) =>
    json.encode(data.toJson());

class ResTenantDashbord {
  ResTenantDashbordResponse? response;

  ResTenantDashbord({
    this.response,
  });

  factory ResTenantDashbord.fromJson(Map<String, dynamic> json) =>
      ResTenantDashbord(
        response: json["Response"] == null
            ? null
            : ResTenantDashbordResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResTenantDashbordResponse {
  String? errorCode;
  String? msg;
  TenantTab? tenantTab;
  TenantPie? tenantPie;
  List<TenantRent>? tenantRent;
  List<TenantAddintionaArea>? tenantAddintionaArea;
  String? tenantModule;

  ResTenantDashbordResponse({
    this.errorCode,
    this.msg,
    this.tenantTab,
    this.tenantPie,
    this.tenantRent,
    this.tenantAddintionaArea,
    this.tenantModule,
  });

  factory ResTenantDashbordResponse.fromJson(Map<String, dynamic> json) =>
      ResTenantDashbordResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        tenantTab: json["tenant_tab"] == null
            ? null
            : TenantTab.fromJson(json["tenant_tab"]),
        tenantPie: json["tenant_pie"] == null
            ? null
            : TenantPie.fromJson(json["tenant_pie"]),
        tenantRent: json["tenant_rent"] == null
            ? []
            : List<TenantRent>.from(
                json["tenant_rent"]!.map((x) => TenantRent.fromJson(x))),
        tenantAddintionaArea: json["tenant_addintiona_area"] == null
            ? []
            : List<TenantAddintionaArea>.from(json["tenant_addintiona_area"]!
                .map((x) => TenantAddintionaArea.fromJson(x))),
        tenantModule: json["tenant_module"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "tenant_tab": tenantTab?.toJson(),
        "tenant_pie": tenantPie?.toJson(),
        "tenant_rent": tenantRent == null
            ? []
            : List<dynamic>.from(tenantRent!.map((x) => x.toJson())),
        "tenant_addintiona_area": tenantAddintionaArea == null
            ? []
            : List<dynamic>.from(tenantAddintionaArea!.map((x) => x.toJson())),
        "tenant_module": tenantModule,
      };
}

class TenantAddintionaArea {
  String? name;
  String? total;

  TenantAddintionaArea({
    this.name,
    this.total,
  });

  factory TenantAddintionaArea.fromJson(Map<String, dynamic> json) =>
      TenantAddintionaArea(
        name: json["name"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "total": total,
      };
}

class TenantPie {
  String? paaa;
  String? consents;
  String? tot;
  String? tototal;

  TenantPie({
    this.paaa,
    this.consents,
    this.tot,
    this.tototal,
  });

  factory TenantPie.fromJson(Map<String, dynamic> json) => TenantPie(
        paaa: json["paaa"],
        consents: json["consents"],
        tot: json["tot"],
        tototal: json["tototal"],
      );

  Map<String, dynamic> toJson() => {
        "paaa": paaa,
        "consents": consents,
        "tot": tot,
        "tototal": tototal,
      };
}

class TenantRent {
  String? name;
  String? total;
  String? paid;
  String? balance;

  TenantRent({
    this.name,
    this.total,
    this.paid,
    this.balance,
  });

  factory TenantRent.fromJson(Map<String, dynamic> json) => TenantRent(
        name: json["name"],
        total: json["total"],
        paid: json["paid"],
        balance: json["balance"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "total": total,
        "paid": paid,
        "balance": balance,
      };
}

class TenantTab {
  String? totalTenant;
  String? recidential;
  String? nonRecidential;

  TenantTab({
    this.totalTenant,
    this.recidential,
    this.nonRecidential,
  });

  factory TenantTab.fromJson(Map<String, dynamic> json) => TenantTab(
        totalTenant: json["total_tenant"],
        recidential: json["recidential"],
        nonRecidential: json["non_recidential"],
      );

  Map<String, dynamic> toJson() => {
        "total_tenant": totalTenant,
        "recidential": recidential,
        "non_recidential": nonRecidential,
      };
}
