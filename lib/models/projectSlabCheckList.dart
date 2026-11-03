// To parse this JSON data, do
//
//     final projectSlabCheckList = projectSlabCheckListFromJson(jsonString);

import 'dart:convert';

ProjectSlabCheckList projectSlabCheckListFromJson(String str) =>
    ProjectSlabCheckList.fromJson(json.decode(str));

String projectSlabCheckListToJson(ProjectSlabCheckList data) =>
    json.encode(data.toJson());

class ProjectSlabCheckList {
  SlabCheckListResponse? response;

  ProjectSlabCheckList({
    this.response,
  });

  factory ProjectSlabCheckList.fromJson(Map<String, dynamic> json) =>
      ProjectSlabCheckList(
        response: json["Response"] == null
            ? null
            : SlabCheckListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class SlabCheckListResponse {
  String? errorCode;
  String? msg;
  String? remark;
  String? projectSlabCheckId;
  List<SlabCheckList>? slabCheckList;
  List<SlabCheckList>? slabCheckListEdited;
  String? checkListFlag;

  SlabCheckListResponse({
    this.errorCode,
    this.msg,
    this.remark,
    this.projectSlabCheckId,
    this.slabCheckList,
    this.slabCheckListEdited,
    this.checkListFlag,
  });

  factory SlabCheckListResponse.fromJson(Map<String, dynamic> json) =>
      SlabCheckListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        remark: json["remark"],
        projectSlabCheckId: json["project_slab_check_id"],
        slabCheckList: json["slab_check_list"] == null
            ? []
            : List<SlabCheckList>.from(
                json["slab_check_list"]!.map((x) => SlabCheckList.fromJson(x))),
        slabCheckListEdited: json["slab_check_list_edited"] == null
            ? []
            : List<SlabCheckList>.from(json["slab_check_list_edited"]!
                .map((x) => SlabCheckList.fromJson(x))),
        checkListFlag: json["check_list_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "remark": remark,
        "project_slab_check_id": projectSlabCheckId,
        "slab_check_list": slabCheckList == null
            ? []
            : List<dynamic>.from(slabCheckList!.map((x) => x.toJson())),
        "slab_check_list_edited": slabCheckListEdited == null
            ? []
            : List<dynamic>.from(slabCheckListEdited!.map((x) => x.toJson())),
        "check_list_flag": checkListFlag,
      };
}

class SlabCheckList {
  String? id;
  String? name;
  List<ListElement>? list;
  String? isCollapse;
  SlabCheckList({
    this.id,
    this.name,
    this.list,
    this.isCollapse = '0',
  });

  factory SlabCheckList.fromJson(Map<String, dynamic> json) => SlabCheckList(
      id: json["id"],
      name: json["name"],
      list: json["list"] == null
          ? []
          : List<ListElement>.from(
              json["list"]!.map((x) => ListElement.fromJson(x))),
      isCollapse: "0");

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "list": list == null
            ? []
            : List<dynamic>.from(list!.map((x) => x.toJson())),
        // "isCollapse": "0"
      };
}

class ListElement {
  String? name;
  String? id;
  String? checkFlag;
  String? checkRemark;
  bool isChanged = false; // track if item was changed
  bool disabled = false; // <--- Add this

  ListElement({
    this.name,
    this.id,
    this.checkFlag,
    this.checkRemark,
    this.isChanged = false,
    this.disabled = false, // <--- Initialize
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        name: json["name"],
        id: json["id"],
        checkFlag: json["check_flag"],
        checkRemark: json["check_remark"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "check_flag": checkFlag,
        "check_remark": checkRemark,
      };
}
