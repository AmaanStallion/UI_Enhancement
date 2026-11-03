// To parse this JSON data, do
//
//     final getOverView = getOverViewFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/projectRccmodel.dart';

GetOverView getOverViewFromJson(String str) =>
    GetOverView.fromJson(json.decode(str));

String getOverViewToJson(GetOverView data) => json.encode(data.toJson());

class GetOverView {
  GetOverViewResponse? response;

  GetOverView({
    this.response,
  });

  factory GetOverView.fromJson(Map<String, dynamic> json) => GetOverView(
        response: json["Response"] == null
            ? null
            : GetOverViewResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetOverViewResponse {
  String? errorCode;
  String? msg;
  RccModule? rccModule;
  // OModule? poModule;
  // OModule? woModule;
  PermissionModule? permissionModule;
  BudgetModule? budgetModule;
  SalesModule? salesModule;

  GetOverViewResponse({
    this.errorCode,
    this.msg,
    this.rccModule,
    // this.poModule,
    // this.woModule,
    this.permissionModule,
    this.budgetModule,
    this.salesModule,
  });

  factory GetOverViewResponse.fromJson(Map<String, dynamic> json) =>
      GetOverViewResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        rccModule: json["rcc_module"] == null
            ? null
            : RccModule.fromJson(json["rcc_module"]),
        // poModule: json["po_module"] == null
        //     ? null
        //     : OModule.fromJson(json["po_module"]),
        // woModule: json["wo_module"] == null
        //     ? null
        //     : OModule.fromJson(json["wo_module"]),
        permissionModule: json["permission_module"] == null
            ? null
            : PermissionModule.fromJson(json["permission_module"]),
        budgetModule: json["budget_module"] == null
            ? null
            : BudgetModule.fromJson(json["budget_module"]),
        salesModule: json["sales_module"] == null
            ? null
            : SalesModule.fromJson(json["sales_module"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "rcc_module": rccModule?.toJson(),
        // "po_module": poModule?.toJson(),
        // "wo_module": woModule?.toJson(),
        "permission_module": permissionModule?.toJson(),
        "budget_module": budgetModule?.toJson(),
        "sales_module": salesModule?.toJson(),
      };
}

class BudgetModule {
  String? halfPie;
  String? halfPieValue;
  String? totalBudget;
  String? totalSpend;
  List<ContractOverBudget>? rawMaterialOverBudget;
  List<ContractOverBudget>? contractOverBudget;
  String? isActive;

  BudgetModule({
    this.halfPie,
    this.halfPieValue,
    this.totalBudget,
    this.totalSpend,
    this.rawMaterialOverBudget,
    this.contractOverBudget,
    this.isActive,
  });

  factory BudgetModule.fromJson(Map<String, dynamic> json) => BudgetModule(
        halfPie: json["half_pie"],
        halfPieValue: json["half_pie_value"],
        totalBudget: json["total_budget"],
        totalSpend: json["total_spend"],
        rawMaterialOverBudget: json["raw_material_over_budget"] == null
            ? []
            : List<ContractOverBudget>.from(json["raw_material_over_budget"]!
                .map((x) => ContractOverBudget.fromJson(x))),
        contractOverBudget: json["contract_over_budget"] == null
            ? []
            : List<ContractOverBudget>.from(json["contract_over_budget"]!
                .map((x) => ContractOverBudget.fromJson(x))),
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "half_pie": halfPie,
        "half_pie_value": halfPieValue,
        "total_budget": totalBudget,
        "total_spend": totalSpend,
        "raw_material_over_budget": rawMaterialOverBudget == null
            ? []
            : List<dynamic>.from(rawMaterialOverBudget!.map((x) => x)),
        "contract_over_budget": contractOverBudget == null
            ? []
            : List<dynamic>.from(contractOverBudget!.map((x) => x.toJson())),
        "is_active": isActive,
      };
}

class ContractOverBudget {
  String? name;
  String? amount;

  ContractOverBudget({
    this.name,
    this.amount,
  });

  factory ContractOverBudget.fromJson(Map<String, dynamic> json) =>
      ContractOverBudget(
        name: json["name"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "amount": amount,
      };
}

class PermissionModule {
  List<PieChart>? pieChart;
  List<PieChart>? pieChartValue;
  List<String>? latestIssued;
  List<TotoalExpired>? totoalExpired;
  List<String>? totoalPending;
  String? isActive;

  PermissionModule({
    this.pieChart,
    this.pieChartValue,
    this.latestIssued,
    this.totoalExpired,
    this.totoalPending,
    this.isActive,
  });

  factory PermissionModule.fromJson(Map<String, dynamic> json) =>
      PermissionModule(
        pieChart: json["pie_chart"] == null
            ? []
            : List<PieChart>.from(
                json["pie_chart"]!.map((x) => PieChart.fromJson(x))),
        pieChartValue: json["pie_chart_value"] == null
            ? []
            : List<PieChart>.from(
                json["pie_chart_value"]!.map((x) => PieChart.fromJson(x))),
        latestIssued: json["latest_issued"] == null
            ? []
            : List<String>.from(json["latest_issued"]!.map((x) => x)),
        totoalExpired: json["totoal_expired"] == null
            ? []
            : List<TotoalExpired>.from(
                json["totoal_expired"]!.map((x) => TotoalExpired.fromJson(x))),
        totoalPending: json["totoal_pending"] == null
            ? []
            : List<String>.from(json["totoal_pending"]!.map((x) => x)),
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "pie_chart": pieChart == null
            ? []
            : List<dynamic>.from(pieChart!.map((x) => x.toJson())),
        "pie_chart_value": pieChartValue == null
            ? []
            : List<dynamic>.from(pieChartValue!.map((x) => x.toJson())),
        "latest_issued": latestIssued == null
            ? []
            : List<dynamic>.from(latestIssued!.map((x) => x)),
        "totoal_expired": totoalExpired == null
            ? []
            : List<dynamic>.from(totoalExpired!.map((x) => x.toJson())),
        "totoal_pending": totoalPending == null
            ? []
            : List<dynamic>.from(totoalPending!.map((x) => x)),
        "is_active": isActive,
      };
}

class PieChart {
  String? name;
  String? value;
  String? percentage;

  PieChart({
    this.name,
    this.value,
    this.percentage,
  });

  factory PieChart.fromJson(Map<String, dynamic> json) => PieChart(
        name: json["name"],
        value: json["value"],
        percentage: json["Percentage"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
        "Percentage": percentage,
      };
}

class TotoalExpired {
  String? name;
  String? date;

  TotoalExpired({
    this.name,
    this.date,
  });

  factory TotoalExpired.fromJson(Map<String, dynamic> json) => TotoalExpired(
        name: json["name"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "date": date,
      };
}

// class OModule {
//   String? totalOpenPo;
//   String? totalIssuedPo;
//   String? totalDue;
//   String? totalPaid;
//   List<LastUpdate>? lastUpdate;
//   String? isActive;

//   OModule({
//     this.totalOpenPo,
//     this.totalIssuedPo,
//     this.totalDue,
//     this.totalPaid,
//     this.lastUpdate,
//     this.isActive,
//   });

//   factory OModule.fromJson(Map<String, dynamic> json) => OModule(
//         totalOpenPo: json["total_open_po"],
//         totalIssuedPo: json["total_issued_po"],
//         totalDue: json["total_due"],
//         totalPaid: json["total_paid"],
//         lastUpdate: json["last_update"] == null
//             ? []
//             : List<LastUpdate>.from(
//                 json["last_update"]!.map((x) => LastUpdate.fromJson(x))),
//         isActive: json["is_active"],
//       );

//   Map<String, dynamic> toJson() => {
//         "total_open_po": totalOpenPo,
//         "total_issued_po": totalIssuedPo,
//         "total_due": totalDue,
//         "total_paid": totalPaid,
//         "last_update": lastUpdate == null
//             ? []
//             : List<dynamic>.from(lastUpdate!.map((x) => x.toJson())),
//         "is_active": isActive,
//       };
// }

// class LastUpdate {
//   String? name;
//   String? type;

//   LastUpdate({
//     this.name,
//     this.type,
//   });

//   factory LastUpdate.fromJson(Map<String, dynamic> json) => LastUpdate(
//         name: json["name"],
//         type: json["type"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "type": type,
//       };
// }

// class RccModule {
//   List<LineChart>? lineChart;
//   String? slabSpeed;
//   List<SlabConsumption>? slabConsumption;
//   List<String>? lastUpdate;
//   String? isActive;

//   RccModule({
//     this.lineChart,
//     this.slabSpeed,
//     this.slabConsumption,
//     this.lastUpdate,
//     this.isActive,
//   });

//   factory RccModule.fromJson(Map<String, dynamic> json) => RccModule(
//         lineChart: json["line_chart"] == null
//             ? []
//             : List<LineChart>.from(
//                 json["line_chart"]!.map((x) => LineChart.fromJson(x))),
//         slabSpeed: json["slab_speed"],
//         slabConsumption: json["slab_consumption"] == null
//             ? []
//             : List<SlabConsumption>.from(json["slab_consumption"]!
//                 .map((x) => SlabConsumption.fromJson(x))),
//         lastUpdate: json["last_update"] == null
//             ? []
//             : List<String>.from(json["last_update"]!.map((x) => x)),
//         isActive: json["is_active"],
//       );

//   Map<String, dynamic> toJson() => {
//         "line_chart": lineChart == null
//             ? []
//             : List<dynamic>.from(lineChart!.map((x) => x.toJson())),
//         "slab_speed": slabSpeed,
//         "slab_consumption": slabConsumption == null
//             ? []
//             : List<dynamic>.from(slabConsumption!.map((x) => x.toJson())),
//         "last_update": lastUpdate == null
//             ? []
//             : List<dynamic>.from(lastUpdate!.map((x) => x)),
//         "is_active": isActive,
//       };
// }

// class LineChart {
//   String? name;
//   String? id;
//   String? percentage;

//   LineChart({
//     this.name,
//     this.id,
//     this.percentage,
//   });

//   factory LineChart.fromJson(Map<String, dynamic> json) => LineChart(
//         name: json["name"],
//         id: json["id"],
//         percentage: json["percentage"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "id": id,
//         "percentage": percentage,
//       };
// }

// class SlabConsumption {
//   String? name;
//   String? quantity;
//   String? totalQuantity;
//   String? unit;

//   SlabConsumption({
//     this.name,
//     this.quantity,
//     this.totalQuantity,
//     this.unit,
//   });

//   factory SlabConsumption.fromJson(Map<String, dynamic> json) =>
//       SlabConsumption(
//         name: json["name"],
//         quantity: json["quantity"],
//         totalQuantity: json["total_quantity"],
//         unit: json["unit"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "quantity": quantity,
//         "total_quantity": totalQuantity,
//         "unit": unit,
//       };
// }

class SalesModule {
  String? paymentStatusReceive;
  String? paymentStatusOver;
  String? paymentCollectable;
  List<AvailableValue>? availableValue;
  List<AvailableValue>? successLead;
  String? pendingRequest;
  String? nextTargetPrice;
  String? flatReserved;
  String? totalSoldSqft;
  String? totalSoldAvg;
  String? totalUnsoldAvg;
  String? unsoldInventry;

  String? isActive;
  List<BrokerDetail>? brokerDetail;
  String? flatReservedPencentage;

  SalesModule({
    this.paymentStatusReceive,
    this.paymentStatusOver,
    this.paymentCollectable,
    this.availableValue,
    this.successLead,
    this.pendingRequest,
    this.nextTargetPrice,
    this.unsoldInventry,
    this.flatReserved,
    this.totalSoldSqft,
    this.totalSoldAvg,
    this.totalUnsoldAvg,
    this.isActive,
    this.brokerDetail,
    this.flatReservedPencentage,
  });

  factory SalesModule.fromJson(Map<String, dynamic> json) => SalesModule(
        paymentStatusReceive: json["payment_status_receive"],
        paymentStatusOver: json["payment_status_over"],
        paymentCollectable: json["payment_collectable"],
        availableValue: json["available_value"] == null
            ? []
            : List<AvailableValue>.from(json["available_value"]!
                .map((x) => AvailableValue.fromJson(x))),
        successLead: json["success_lead"] == null
            ? []
            : List<AvailableValue>.from(
                json["success_lead"]!.map((x) => AvailableValue.fromJson(x))),
        pendingRequest: json["pending_request"],
        nextTargetPrice: json["next_target_price"],
        unsoldInventry: json["unsold_inventry"],
        flatReserved: json["flat_reserved"],
        totalSoldSqft: json["total_sold_sqft"],
        totalSoldAvg: json["total_sold_avg"],
        totalUnsoldAvg: json["total_unsold_avg"],
        isActive: json["is_active"],
        brokerDetail: json["broker_detail"] == null
            ? []
            : List<BrokerDetail>.from(
                json["broker_detail"]!.map((x) => BrokerDetail.fromJson(x))),
        flatReservedPencentage: json["flat_reserved_pencentage"],
      );

  Map<String, dynamic> toJson() => {
        "payment_status_receive": paymentStatusReceive,
        "payment_status_over": paymentStatusOver,
        "payment_collectable": paymentCollectable,
        "available_value": availableValue == null
            ? []
            : List<dynamic>.from(availableValue!.map((x) => x.toJson())),
        "success_lead": successLead == null
            ? []
            : List<dynamic>.from(successLead!.map((x) => x.toJson())),
        "pending_request": pendingRequest,
        "next_target_price": nextTargetPrice,
        "unsold_inventry": unsoldInventry,
        "flat_reserved": flatReserved,
        "total_sold_sqft": totalSoldSqft,
        "total_sold_avg": totalSoldAvg,
        "total_unsold_avg": totalUnsoldAvg,
        "is_active": isActive,
        "broker_detail": brokerDetail == null
            ? []
            : List<dynamic>.from(brokerDetail!.map((x) => x.toJson())),
        "flat_reserved_pencentage": flatReservedPencentage,
      };
}

class AvailableValue {
  String? percentage;
  String? value;

  AvailableValue({
    this.percentage,
    this.value,
  });

  factory AvailableValue.fromJson(Map<String, dynamic> json) => AvailableValue(
        percentage: json["percentage"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "percentage": percentage,
        "value": value,
      };
}

class BrokerDetail {
  String? brokerTotal;
  String? companyName;
  String? totalSold;
  String? totPaid;

  BrokerDetail({
    this.brokerTotal,
    this.companyName,
    this.totalSold,
    this.totPaid,
  });

  factory BrokerDetail.fromJson(Map<String, dynamic> json) => BrokerDetail(
        brokerTotal: json["broker_total"],
        companyName: json["company_name"],
        totalSold: json["total_sold"],
        totPaid: json["tot_paid"],
      );

  Map<String, dynamic> toJson() => {
        "broker_total": brokerTotal,
        "company_name": companyName,
        "total_sold": totalSold,
        "tot_paid": totPaid,
      };
}
