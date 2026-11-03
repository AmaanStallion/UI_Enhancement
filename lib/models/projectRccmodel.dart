// To parse this JSON data, do
//
//     final projectRccModel = projectRccModelFromJson(jsonString);

import 'dart:convert';

ProjectRccModel projectRccModelFromJson(String str) =>
    ProjectRccModel.fromJson(json.decode(str));

String projectRccModelToJson(ProjectRccModel data) =>
    json.encode(data.toJson());

class ProjectRccModel {
  ProjectRccModelResponse? response;

  ProjectRccModel({
    this.response,
  });

  factory ProjectRccModel.fromJson(Map<String, dynamic> json) =>
      ProjectRccModel(
        response: json["Response"] == null
            ? null
            : ProjectRccModelResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectRccModelResponse {
  String? errorCode;
  String? msg;
  RccModule? rccModule;

  ProjectRccModelResponse({
    this.errorCode,
    this.msg,
    this.rccModule,
  });

  factory ProjectRccModelResponse.fromJson(Map<String, dynamic> json) =>
      ProjectRccModelResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        rccModule: json["rcc_module"] == null
            ? null
            : RccModule.fromJson(json["rcc_module"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "rcc_module": rccModule?.toJson(),
      };
}

class RccModule {
  List<LineChart>? lineChart;
  String? slabSpeed;
  List<SlabConsumption>? slabConsumption;
  List<String>? lastUpdate;
  String? isActive;
  String? startDate;
  String? endDate;

  RccModule({
    this.lineChart,
    this.slabSpeed,
    this.slabConsumption,
    this.lastUpdate,
    this.isActive,
    this.startDate,
    this.endDate,
  });

  factory RccModule.fromJson(Map<String, dynamic> json) => RccModule(
        lineChart: json["line_chart"] == null
            ? []
            : List<LineChart>.from(
                json["line_chart"]!.map((x) => LineChart.fromJson(x))),
        slabSpeed: json["slab_speed"],
        slabConsumption: json["slab_consumption"] == null
            ? []
            : List<SlabConsumption>.from(json["slab_consumption"]!
                .map((x) => SlabConsumption.fromJson(x))),
        lastUpdate: json["last_update"] == null
            ? []
            : List<String>.from(json["last_update"]!.map((x) => x)),
        isActive: json["is_active"],
        startDate: json["start_date"],
        endDate: json["end_date"],
      );

  Map<String, dynamic> toJson() => {
        "line_chart": lineChart == null
            ? []
            : List<dynamic>.from(lineChart!.map((x) => x.toJson())),
        "slab_speed": slabSpeed,
        "slab_consumption": slabConsumption == null
            ? []
            : List<dynamic>.from(slabConsumption!.map((x) => x.toJson())),
        "last_update": lastUpdate == null
            ? []
            : List<dynamic>.from(lastUpdate!.map((x) => x)),
        "is_active": isActive,
        "start_date": startDate,
        "end_date": endDate,
      };
}

class LineChart {
  String? name;
  String? id;
  String? percentage;

  LineChart({
    this.name,
    this.id,
    this.percentage,
  });

  factory LineChart.fromJson(Map<String, dynamic> json) => LineChart(
        name: json["name"],
        id: json["id"],
        percentage: json["percentage"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "percentage": percentage,
      };
}

class SlabConsumption {
  String? name;
  String? quantity;
  String? totalQuantity;
  String? unit;

  SlabConsumption({
    this.name,
    this.quantity,
    this.totalQuantity,
    this.unit,
  });

  factory SlabConsumption.fromJson(Map<String, dynamic> json) =>
      SlabConsumption(
        name: json["name"],
        quantity: json["quantity"],
        totalQuantity: json["total_quantity"],
        unit: json["unit"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "quantity": quantity,
        "total_quantity": totalQuantity,
        "unit": unit,
      };
}
