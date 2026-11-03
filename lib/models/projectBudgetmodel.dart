// To parse this JSON data, do
//
//     final projectBudgetmodel = projectBudgetmodelFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_overview.dart';

ProjectBudgetmodel projectBudgetmodelFromJson(String str) =>
    ProjectBudgetmodel.fromJson(json.decode(str));

String projectBudgetmodelToJson(ProjectBudgetmodel data) =>
    json.encode(data.toJson());

class ProjectBudgetmodel {
  ProjectBudgetmodelResponse? response;

  ProjectBudgetmodel({
    this.response,
  });

  factory ProjectBudgetmodel.fromJson(Map<String, dynamic> json) =>
      ProjectBudgetmodel(
        response: json["Response"] == null
            ? null
            : ProjectBudgetmodelResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectBudgetmodelResponse {
  String? errorCode;
  String? msg;
  BudgetModule? budgetModule;

  ProjectBudgetmodelResponse({
    this.errorCode,
    this.msg,
    this.budgetModule,
  });

  factory ProjectBudgetmodelResponse.fromJson(Map<String, dynamic> json) =>
      ProjectBudgetmodelResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        budgetModule: json["budget_module"] == null
            ? null
            : BudgetModule.fromJson(json["budget_module"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "budget_module": budgetModule?.toJson(),
      };
}

// class BudgetModule {
//   String? halfPie;
//   String? halfPieValue;
//   String? totalBudget;
//   String? totalSpend;
//   List<dynamic>? rawMaterialOverBudget;
//   List<ContractOverBudget>? contractOverBudget;
//   String? isActive;

//   BudgetModule({
//     this.halfPie,
//     this.halfPieValue,
//     this.totalBudget,
//     this.totalSpend,
//     this.rawMaterialOverBudget,
//     this.contractOverBudget,
//     this.isActive,
//   });

//   factory BudgetModule.fromJson(Map<String, dynamic> json) => BudgetModule(
//         halfPie: json["half_pie"],
//         halfPieValue: json["half_pie_value"],
//         totalBudget: json["total_budget"],
//         totalSpend: json["total_spend"],
//         rawMaterialOverBudget: json["raw_material_over_budget"] == null
//             ? []
//             : List<dynamic>.from(
//                 json["raw_material_over_budget"]!.map((x) => x)),
//         contractOverBudget: json["contract_over_budget"] == null
//             ? []
//             : List<ContractOverBudget>.from(json["contract_over_budget"]!
//                 .map((x) => ContractOverBudget.fromJson(x))),
//         isActive: json["is_active"],
//       );

//   Map<String, dynamic> toJson() => {
//         "half_pie": halfPie,
//         "half_pie_value": halfPieValue,
//         "total_budget": totalBudget,
//         "total_spend": totalSpend,
//         "raw_material_over_budget": rawMaterialOverBudget == null
//             ? []
//             : List<dynamic>.from(rawMaterialOverBudget!.map((x) => x)),
//         "contract_over_budget": contractOverBudget == null
//             ? []
//             : List<dynamic>.from(contractOverBudget!.map((x) => x.toJson())),
//         "is_active": isActive,
//       };
// }

// class ContractOverBudget {
//   String? name;
//   String? amount;

//   ContractOverBudget({
//     this.name,
//     this.amount,
//   });

//   factory ContractOverBudget.fromJson(Map<String, dynamic> json) =>
//       ContractOverBudget(
//         name: json["name"],
//         amount: json["amount"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "amount": amount,
//       };
// }
