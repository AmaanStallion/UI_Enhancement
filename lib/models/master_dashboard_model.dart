// // To parse this JSON data, do
// //
// //     final masterDashboard = masterDashboardFromJson(jsonString);

// import 'dart:convert';

// MasterDashboard masterDashboardFromJson(String str) =>
//     MasterDashboard.fromJson(json.decode(str));

// String masterDashboardToJson(MasterDashboard data) =>
//     json.encode(data.toJson());

// class MasterDashboard {
//   MasterDashboardResponse? response;

//   MasterDashboard({
//     this.response,
//   });

//   factory MasterDashboard.fromJson(Map<String, dynamic> json) =>
//       MasterDashboard(
//         response: json["Response"] == null
//             ? null
//             : MasterDashboardResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class MasterDashboardResponse {
//   String? errorCode;
//   String? msg;
//   List<MasterDashboardElement>? masterDashboard;

//   MasterDashboardResponse({
//     this.errorCode,
//     this.msg,
//     this.masterDashboard,
//   });

//   factory MasterDashboardResponse.fromJson(Map<String, dynamic> json) =>
//       MasterDashboardResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         masterDashboard: json["master_dashboard"] == null
//             ? []
//             : List<MasterDashboardElement>.from(json["master_dashboard"]!
//                 .map((x) => MasterDashboardElement.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "master_dashboard": masterDashboard == null
//             ? []
//             : List<dynamic>.from(masterDashboard!.map((x) => x.toJson())),
//       };
// }

// class MasterDashboardElement {
//   String? name;
//   List<String>? headers;
//   List<Project>? projects;

//   MasterDashboardElement({
//     this.name,
//     this.headers,
//     this.projects,
//   });

//   factory MasterDashboardElement.fromJson(Map<String, dynamic> json) =>
//       MasterDashboardElement(
//         name: json["name"],
//         headers: json["headers"] == null
//             ? []
//             : List<String>.from(json["headers"]!.map((x) => x)),
//         projects: json["projects"] == null
//             ? []
//             : List<Project>.from(
//                 json["projects"]!.map((x) => Project.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "headers":
//             headers == null ? [] : List<dynamic>.from(headers!.map((x) => x)),
//         "projects": projects == null
//             ? []
//             : List<dynamic>.from(projects!.map((x) => x.toJson())),
//       };
// }

// class Project {
//   String? name;
//   List<String>? counts;

//   Project({
//     this.name,
//     this.counts,
//   });

//   factory Project.fromJson(Map<String, dynamic> json) => Project(
//         name: json["name"],
//         counts: json["counts"] == null
//             ? []
//             : List<String>.from(json["counts"]!.map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "counts":
//             counts == null ? [] : List<dynamic>.from(counts!.map((x) => x)),
//       };
// }

// To parse this JSON data, do
//
//     final masterDashboard = masterDashboardFromJson(jsonString);

import 'dart:convert';

MasterDashboard masterDashboardFromJson(String str) =>
    MasterDashboard.fromJson(json.decode(str));

String masterDashboardToJson(MasterDashboard data) =>
    json.encode(data.toJson());

class MasterDashboard {
  MasterDashboardResponse? response;

  MasterDashboard({
    this.response,
  });

  factory MasterDashboard.fromJson(Map<String, dynamic> json) =>
      MasterDashboard(
        response: json["Response"] == null
            ? null
            : MasterDashboardResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class MasterDashboardResponse {
  String? errorCode;
  String? msg;
  List<MasterDashboardElement>? masterDashboard;

  MasterDashboardResponse({
    this.errorCode,
    this.msg,
    this.masterDashboard,
  });

  factory MasterDashboardResponse.fromJson(Map<String, dynamic> json) =>
      MasterDashboardResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        masterDashboard: json["master_dashboard"] == null
            ? []
            : List<MasterDashboardElement>.from(json["master_dashboard"]!
                .map((x) => MasterDashboardElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "master_dashboard": masterDashboard == null
            ? []
            : List<dynamic>.from(masterDashboard!.map((x) => x.toJson())),
      };
}

class MasterDashboardElement {
  String? projectDisplayName;
  String? projectTowerId;
  String? projectId;
  String? poDueAmount;
  String? poOverDueAmount;
  String? woDueAmount;
  int? pendPerm;
  int? issuePerm;
  int? totalPerm;
  String? totalOpenPo;
  String? poIssued;
  String? woIssued;
  String? totalOpenWo;
  String? totalSold;
  String? totalUnsold;
  String? dpr;
  String? dprUrl;
  int? poInvoicePaid;
  int? poInvoiceUnpaid;
  int? woInvoicePaid;
  int? woInvoiceUnpaid;
  String? slabId;
  double? poInvoicePaidAmount;
  double? poInvoiceTotalAmount;
  double? poInvoiceTotalUnpaid;
  double? woInvoicePaidAmount;
  double? woInvoiceTotalAmount;
  int? woInvoiceTotalUnpaid;
  String? groupFlag;
  String? woWorkDoneAmount;
  String? totalPoRaise;
  String? totalWoRaise;
  String? collectable;
  String? collected;
  String? salesBalance;
  String? slabName;
  String? towerName;

  MasterDashboardElement({
    this.projectDisplayName,
    this.projectTowerId,
    this.projectId,
    this.poDueAmount,
    this.poOverDueAmount,
    this.woDueAmount,
    this.pendPerm,
    this.issuePerm,
    this.totalPerm,
    this.totalOpenPo,
    this.poIssued,
    this.woIssued,
    this.totalOpenWo,
    this.totalSold,
    this.totalUnsold,
    this.dpr,
    this.dprUrl,
    this.poInvoicePaid,
    this.poInvoiceUnpaid,
    this.woInvoicePaid,
    this.woInvoiceUnpaid,
    this.slabId,
    this.poInvoicePaidAmount,
    this.poInvoiceTotalAmount,
    this.poInvoiceTotalUnpaid,
    this.woInvoicePaidAmount,
    this.woInvoiceTotalAmount,
    this.woInvoiceTotalUnpaid,
    this.groupFlag,
    this.woWorkDoneAmount,
    this.totalPoRaise,
    this.totalWoRaise,
    this.collectable,
    this.collected,
    this.salesBalance,
    this.slabName,
    this.towerName,
  });

  factory MasterDashboardElement.fromJson(Map<String, dynamic> json) =>
      MasterDashboardElement(
        projectDisplayName: json["project_display_name"],
        projectTowerId: json["project_tower_id"],
        projectId: json["project_id"],
        poDueAmount: json["poDueAmount"],
        poOverDueAmount: json["poOverDueAmount"],
        woDueAmount: json["woDueAmount"],
        pendPerm: json["pendPerm"],
        issuePerm: json["issuePerm"],
        totalPerm: json["totalPerm"],
        totalOpenPo: json["totalOpenPo"],
        poIssued: json["poIssued"],
        woIssued: json["woIssued"],
        totalOpenWo: json["totalOpenWo"],
        totalSold: json["total_sold"],
        totalUnsold: json["total_unsold"],
        dpr: json["dpr"],
        dprUrl: json["dpr_url"],
        poInvoicePaid: json["po_invoice_paid"],
        poInvoiceUnpaid: json["po_invoice_unpaid"],
        woInvoicePaid: json["wo_invoice_paid"],
        woInvoiceUnpaid: json["wo_invoice_unpaid"],
        slabId: json["slab_id"],
        poInvoicePaidAmount: json["po_invoice_paid_amount"]?.toDouble(),
        poInvoiceTotalAmount: json["po_invoice_total_amount"]?.toDouble(),
        poInvoiceTotalUnpaid: json["po_invoice_total_unpaid"]?.toDouble(),
        woInvoicePaidAmount: json["wo_invoice_paid_amount"]?.toDouble(),
        woInvoiceTotalAmount: json["wo_invoice_total_amount"]?.toDouble(),
        woInvoiceTotalUnpaid: json["wo_invoice_total_unpaid"],
        groupFlag: json["group_flag"],
        woWorkDoneAmount: json["woWorkDoneAmount"],
        totalPoRaise: json["TotalPORaise"],
        totalWoRaise: json["TotalWORaise"],
        collectable: json["collectable"],
        collected: json["collected"],
        salesBalance: json["sales_balance"],
        slabName: json["slab_name"],
        towerName: json["tower_name"],
      );

  Map<String, dynamic> toJson() => {
        "project_display_name": projectDisplayName,
        "project_tower_id": projectTowerId,
        "project_id": projectId,
        "poDueAmount": poDueAmount,
        "poOverDueAmount": poOverDueAmount,
        "woDueAmount": woDueAmount,
        "pendPerm": pendPerm,
        "issuePerm": issuePerm,
        "totalPerm": totalPerm,
        "totalOpenPo": totalOpenPo,
        "poIssued": poIssued,
        "woIssued": woIssued,
        "totalOpenWo": totalOpenWo,
        "total_sold": totalSold,
        "total_unsold": totalUnsold,
        "dpr": dpr,
        "dpr_url": dprUrl,
        "po_invoice_paid": poInvoicePaid,
        "po_invoice_unpaid": poInvoiceUnpaid,
        "wo_invoice_paid": woInvoicePaid,
        "wo_invoice_unpaid": woInvoiceUnpaid,
        "slab_id": slabId,
        "po_invoice_paid_amount": poInvoicePaidAmount,
        "po_invoice_total_amount": poInvoiceTotalAmount,
        "po_invoice_total_unpaid": poInvoiceTotalUnpaid,
        "wo_invoice_paid_amount": woInvoicePaidAmount,
        "wo_invoice_total_amount": woInvoiceTotalAmount,
        "wo_invoice_total_unpaid": woInvoiceTotalUnpaid,
        "group_flag": groupFlag,
        "woWorkDoneAmount": woWorkDoneAmount,
        "TotalPORaise": totalPoRaise,
        "TotalWORaise": totalWoRaise,
        "collectable": collectable,
        "collected": collected,
        "sales_balance": salesBalance,
        "slab_name": slabName,
        "tower_name": towerName,
      };
}
