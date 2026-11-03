// To parse this JSON data, do
//
//     final projectPermissionmodel = projectPermissionmodelFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_overview.dart';

ProjectPermissionmodel projectPermissionmodelFromJson(String str) =>
    ProjectPermissionmodel.fromJson(json.decode(str));

String projectPermissionmodelToJson(ProjectPermissionmodel data) =>
    json.encode(data.toJson());

class ProjectPermissionmodel {
  ProjectPermissionmodelResponse? response;

  ProjectPermissionmodel({
    this.response,
  });

  factory ProjectPermissionmodel.fromJson(Map<String, dynamic> json) =>
      ProjectPermissionmodel(
        response: json["Response"] == null
            ? null
            : ProjectPermissionmodelResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectPermissionmodelResponse {
  String? errorCode;
  String? msg;
  PermissionModule? permissionModule;

  ProjectPermissionmodelResponse({
    this.errorCode,
    this.msg,
    this.permissionModule,
  });

  factory ProjectPermissionmodelResponse.fromJson(Map<String, dynamic> json) =>
      ProjectPermissionmodelResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        permissionModule: json["permission_module"] == null
            ? null
            : PermissionModule.fromJson(json["permission_module"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "permission_module": permissionModule?.toJson(),
      };
}

// class PermissionModule {
//   List<PieChart>? pieChart;
//   List<PieChart>? pieChartValue;
//   List<String>? latestIssued;
//   List<TotoalExpired>? totoalExpired;
//   List<String>? totoalPending;
//   String? isActive;

//   PermissionModule({
//     this.pieChart,
//     this.pieChartValue,
//     this.latestIssued,
//     this.totoalExpired,
//     this.totoalPending,
//     this.isActive,
//   });

//   factory PermissionModule.fromJson(Map<String, dynamic> json) =>
//       PermissionModule(
//         pieChart: json["pie_chart"] == null
//             ? []
//             : List<PieChart>.from(
//                 json["pie_chart"]!.map((x) => PieChart.fromJson(x))),
//         pieChartValue: json["pie_chart_value"] == null
//             ? []
//             : List<PieChart>.from(
//                 json["pie_chart_value"]!.map((x) => PieChart.fromJson(x))),
//         latestIssued: json["latest_issued"] == null
//             ? []
//             : List<String>.from(json["latest_issued"]!.map((x) => x)),
//         totoalExpired: json["totoal_expired"] == null
//             ? []
//             : List<TotoalExpired>.from(
//                 json["totoal_expired"]!.map((x) => TotoalExpired.fromJson(x))),
//         totoalPending: json["totoal_pending"] == null
//             ? []
//             : List<String>.from(json["totoal_pending"]!.map((x) => x)),
//         isActive: json["is_active"],
//       );

//   Map<String, dynamic> toJson() => {
//         "pie_chart": pieChart == null
//             ? []
//             : List<dynamic>.from(pieChart!.map((x) => x.toJson())),
//         "pie_chart_value": pieChartValue == null
//             ? []
//             : List<dynamic>.from(pieChartValue!.map((x) => x.toJson())),
//         "latest_issued": latestIssued == null
//             ? []
//             : List<dynamic>.from(latestIssued!.map((x) => x)),
//         "totoal_expired": totoalExpired == null
//             ? []
//             : List<dynamic>.from(totoalExpired!.map((x) => x.toJson())),
//         "totoal_pending": totoalPending == null
//             ? []
//             : List<dynamic>.from(totoalPending!.map((x) => x)),
//         "is_active": isActive,
//       };
// }

// class PieChart {
//   String? name;
//   String? value;
//   String? percentage;

//   PieChart({
//     this.name,
//     this.value,
//     this.percentage,
//   });

//   factory PieChart.fromJson(Map<String, dynamic> json) => PieChart(
//         name: json["name"],
//         value: json["value"],
//         percentage: json["Percentage"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "value": value,
//         "Percentage": percentage,
//       };
// }

// class TotoalExpired {
//   String? name;
//   String? date;

//   TotoalExpired({
//     this.name,
//     this.date,
//   });

//   factory TotoalExpired.fromJson(Map<String, dynamic> json) => TotoalExpired(
//         name: json["name"],
//         date: json["date"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "date": date,
//       };
// }
