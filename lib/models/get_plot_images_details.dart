// To parse this JSON data, do
//
//     final plotdrawingimages = plotdrawingimagesFromJson(jsonString);

import 'dart:convert';

Plotdrawingimages plotdrawingimagesFromJson(String str) => Plotdrawingimages.fromJson(json.decode(str));

String plotdrawingimagesToJson(Plotdrawingimages data) => json.encode(data.toJson());

class Plotdrawingimages {
  ResponsePlotdrawingimages? response;

  Plotdrawingimages({
    this.response,
  });

  factory Plotdrawingimages.fromJson(Map<String, dynamic> json) => Plotdrawingimages(
    response: ResponsePlotdrawingimages.fromJson(json["Response"]),
  );

  Map<String, dynamic> toJson() => {
    "Response": response?.toJson(),
  };
}

class ResponsePlotdrawingimages {
  String? errorCode;
  String? msg;
  List<PlotDetail>? plotDetails;

  ResponsePlotdrawingimages({
    this.errorCode,
    this.msg,
    this.plotDetails,
  });

  factory ResponsePlotdrawingimages.fromJson(Map<String, dynamic> json) => ResponsePlotdrawingimages(
    errorCode: json["error_code"],
    msg: json["msg"],
    plotDetails: List<PlotDetail>.from(json["plot_details"].map((x) => PlotDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "error_code": errorCode,
    "msg": msg,
    "plot_details": List<dynamic>.from(plotDetails!.map((x) => x.toJson())),
  };
}

class PlotDetail {
  String? name;
  String? description;
  List<Images>? images;

  PlotDetail({
    this.name,
    this.description,
    this.images,
  });

  factory PlotDetail.fromJson(Map<String, dynamic> json) => PlotDetail(
    name: json["name"],
    description: json["description"],
    images: List<Images>.from(json["images"].map((x) => Images.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "images": List<dynamic>.from(images!.map((x) => x.toJson())),
  };
}

class Images {
  String? name;
  String? title;

  Images({
    this.name,
    this.title,
  });

  factory Images.fromJson(Map<String, dynamic> json) => Images(
    name: json["name"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "title": title,
  };
}
