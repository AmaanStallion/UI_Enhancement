// To parse this JSON data, do
//
//     final wsslabmasonrystructure = wsslabmasonrystructureFromJson(jsonString);

import 'dart:convert';

Wsslabmasonrystructure wsslabmasonrystructureFromJson(String str) =>
    Wsslabmasonrystructure.fromJson(json.decode(str));

String wsslabmasonrystructureToJson(Wsslabmasonrystructure data) =>
    json.encode(data.toJson());

class Wsslabmasonrystructure {
  Wsslabmasonrystructure({
    this.response,
  });

  ResponseWsslabmasonrystructure? response;

  factory Wsslabmasonrystructure.fromJson(Map<String, dynamic> json) =>
      Wsslabmasonrystructure(
        response: ResponseWsslabmasonrystructure.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseWsslabmasonrystructure {
  ResponseWsslabmasonrystructure({
    this.errorCode,
    this.msg,
    this.list,
  });

  String? errorCode;
  String? msg;
  List<ListElement>? list;

  factory ResponseWsslabmasonrystructure.fromJson(Map<String, dynamic> json) =>
      ResponseWsslabmasonrystructure(
        errorCode: json["error_code"],
        msg: json["msg"],
        list: List<ListElement>.from(
            json["list"].map((x) => ListElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "list": List<dynamic>.from(list!.map((x) => x.toJson())),
      };
}

class ListElement {
  ListElement({
    this.name,
    this.id,
    this.selected,
    this.slablist,
    this.masonrylist,
  });

  String? name;
  String? id;
  String? selected;
  List<Slablist>? slablist;
  List<Masonrylist>? masonrylist;

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        name: json["name"],
        id: json["id"],
        selected: json["selected"],
        slablist: json["slablist"] == null
            ? null
            : List<Slablist>.from(
                json["slablist"].map((x) => Slablist.fromJson(x))),
        masonrylist: json["masonrylist"] == null
            ? null
            : List<Masonrylist>.from(
                json["masonrylist"].map((x) => Masonrylist.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "selected": selected,
        "slablist": slablist == null
            ? null
            : List<dynamic>.from(slablist!.map((x) => x.toJson())),
        "masonrylist": masonrylist == null
            ? null
            : List<dynamic>.from(masonrylist!.map((x) => x.toJson())),
      };
}

class Masonrylist {
  Masonrylist({
    this.masonryId,
    this.masonryName,
    this.block,
  });

  String? masonryId;
  String? masonryName;
  List<Block>? block;

  factory Masonrylist.fromJson(Map<String, dynamic> json) => Masonrylist(
        masonryId: json["masonry_id"],
        masonryName: json["masonry_name"],
        block: List<Block>.from(json["block"].map((x) => Block.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "masonry_id": masonryId,
        "masonry_name": masonryName,
        "block": List<dynamic>.from(block!.map((x) => x.toJson())),
      };
}

class Block {
  Block({
    this.blockId,
    this.blockName,
  });

  String? blockId;
  String? blockName;

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        blockId: json["block_id"],
        blockName: json["block_name"],
      );

  Map<String, dynamic> toJson() => {
        "block_id": blockId,
        "block_name": blockName,
      };
}

class Slablist {
  Slablist({
    this.slabId,
    this.slabName,
  });

  String? slabId;
  String? slabName;

  factory Slablist.fromJson(Map<String, dynamic> json) => Slablist(
        slabId: json["slab_id"],
        slabName: json["slab_name"],
      );

  Map<String, dynamic> toJson() => {
        "slab_id": slabId,
        "slab_name": slabName,
      };
}

class EnumValues<T> {
  Map<String, T>? map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map?.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap!;
  }
}
