// To parse this JSON data, do
//
//     final getFinishingInteriorNew = getFinishingInteriorNewFromJson(jsonString);

import 'dart:convert';

GetFinishingInteriorNew getFinishingInteriorNewFromJson(String str) =>
    GetFinishingInteriorNew.fromJson(json.decode(str));

String getFinishingInteriorNewToJson(GetFinishingInteriorNew data) =>
    json.encode(data.toJson());

class GetFinishingInteriorNew {
  Response? response;

  GetFinishingInteriorNew({
    this.response,
  });

  factory GetFinishingInteriorNew.fromJson(Map<String, dynamic> json) =>
      GetFinishingInteriorNew(
        response: json["Response"] == null
            ? null
            : Response.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class Response {
  String? errorCode;
  String? msg;
  List<FinalResultInterior>? finalResult;

  Response({
    this.errorCode,
    this.msg,
    this.finalResult,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        finalResult: json["final_result"] == null
            ? []
            : List<FinalResultInterior>.from(json["final_result"]!
                .map((x) => FinalResultInterior.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "final_result": finalResult == null
            ? []
            : List<dynamic>.from(finalResult!.map((x) => x.toJson())),
      };
}

class FinalResultInterior {
  List<HeaderPart>? headerPart;
  List<List<BodyPart>>? bodyPart;

  FinalResultInterior({
    this.headerPart,
    this.bodyPart,
  });

  factory FinalResultInterior.fromJson(Map<String, dynamic> json) =>
      FinalResultInterior(
        headerPart: json["header_part"] == null
            ? []
            : List<HeaderPart>.from(
                json["header_part"]!.map((x) => HeaderPart.fromJson(x))),
        bodyPart: json["body_part"] == null
            ? []
            : List<List<BodyPart>>.from(json["body_part"]!.map((x) =>
                List<BodyPart>.from(x.map((x) => BodyPart.fromJson(x))))),
      );

  Map<String, dynamic> toJson() => {
        "header_part": headerPart == null
            ? []
            : List<dynamic>.from(headerPart!.map((x) => x.toJson())),
        "body_part": bodyPart == null
            ? []
            : List<dynamic>.from(bodyPart!
                .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
      };
}

class BodyPart {
  String? name;
  String? id;
  final String? floorId;
  dynamic finishingQty;
  dynamic consumeQty;
  String? floorArea;
  String? flatType;
  String? finishTypeId;
  String? readyPosition;

  BodyPart({
    this.name,
    this.id,
    this.floorId,
    this.finishingQty,
    this.consumeQty,
    this.floorArea,
    this.flatType,
    this.finishTypeId,
    this.readyPosition,
  });

  factory BodyPart.fromJson(Map<String, dynamic> json) => BodyPart(
        name: json["name"],
        id: json["id"],
        finishingQty: json["finishing_qty"],
        floorId: json["floor_id"],
        consumeQty: json["consume_qty"],
        floorArea: json["floor_area"],
        flatType: json["flat_type"],
        finishTypeId: json["finish_type_id"],
        readyPosition: json["ready_position"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "finishing_qty": finishingQty,
        "consume_qty": consumeQty,
        "floor_id": floorId,
        "floor_area": floorArea,
        "flat_type": flatType,
        "finish_type_id": finishTypeId,
        "ready_position": readyPosition,
      };
}

class HeaderPart {
  String? name;
  String? id;
  String? floorArea;
  String? readyPosition;
  String? finishingQty;
  String? consumeQty;

  HeaderPart({
    this.name,
    this.id,
    this.floorArea,
    this.readyPosition,
    this.finishingQty,
    this.consumeQty,
  });

  factory HeaderPart.fromJson(Map<String, dynamic> json) => HeaderPart(
        name: json["name"],
        id: json["id"],
        floorArea: json["floor_area"],
        readyPosition: json["ready_position"],
        finishingQty: json["finishing_qty"],
        consumeQty: json["consume_qty"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "floor_area": floorArea,
        "ready_position": readyPosition,
        "finishing_qty": finishingQty,
        "consume_qty": consumeQty,
      };
}
