// To parse this JSON data, do
//
//     final getExcavationList = getExcavationListFromJson(jsonString);

import 'dart:convert';
import 'package:stallion/models/excavation_api_models.dart';

GetExcavationList getExcavationListFromJson(String str) =>
    GetExcavationList.fromJson(json.decode(str));

String getExcavationListToJson(GetExcavationList data) =>
    json.encode(data.toJson());

class GetExcavationList {
  GetExcavationListResponse? response;

  GetExcavationList({
    this.response,
  });

  factory GetExcavationList.fromJson(Map<String, dynamic> json) =>
      GetExcavationList(
        response: json["Response"] == null
            ? null
            : GetExcavationListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetExcavationListResponse {
  String? errorCode;
  String? msg;
  List<FinalExcavalionList>? finalExcavalionList = [];
  String? totalValue;
  String? hardRock;
  String? softRock;
  String? murramRock;
  String? sandRock;
  List<BottomBar>? bottomBar = [];

  List<BottomBar>? filterBar;
  String? offset;

  GetExcavationListResponse({
    this.errorCode,
    this.msg,
    this.finalExcavalionList,
    this.totalValue,
    this.hardRock,
    this.softRock,
    this.murramRock,
    this.sandRock,
    this.bottomBar,
    this.filterBar,
    this.offset,
  });

  factory GetExcavationListResponse.fromJson(Map<String, dynamic> json) =>
      GetExcavationListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        finalExcavalionList: json["final_excavalion_list"] == null
            ? []
            : List<FinalExcavalionList>.from(json["final_excavalion_list"]!
                .map((x) => FinalExcavalionList.fromJson(x))),
        totalValue: json["total_value"],
        hardRock: json["hard_rock"],
        softRock: json["soft_rock"],
        murramRock: json["murram_rock"],
        sandRock: json["sand_rock"],
        bottomBar: json["bottom_bar"] == null
            ? []
            : List<BottomBar>.from(
                json["bottom_bar"]!.map((x) => BottomBar.fromJson(x))),
        filterBar: json["filter_bar"] == null
            ? []
            : List<BottomBar>.from(
                json["filter_bar"]!.map((x) => BottomBar.fromJson(x))),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "final_excavalion_list": finalExcavalionList == null
            ? []
            : List<dynamic>.from(finalExcavalionList!.map((x) => x.toJson())),
        "total_value": totalValue,
        "hard_rock": hardRock,
        "soft_rock": softRock,
        "murram_rock": murramRock,
        "sand_rock": sandRock,
        "bottom_bar": bottomBar == null
            ? []
            : List<dynamic>.from(bottomBar!.map((x) => x.toJson())),
        "filter_bar": filterBar == null
            ? []
            : List<dynamic>.from(filterBar!.map((x) => x.toJson())),
        "offset": offset,
      };
}

class BottomBar {
  String? id;
  String? name;
  String? value;
  String? truckValue;

  BottomBar({
    this.id,
    this.name,
    this.value,
    this.truckValue,
  });

  factory BottomBar.fromJson(Map<String, dynamic> json) => BottomBar(
        id: json["id"],
        name: json["name"],
        value: json["value"],
        truckValue: json["truck_value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
        "truck_value": truckValue,
      };
}

class FinalExcavalionList {
  String? mstExcavationId;
  String? projectIdFk;
  String? towarIdFk;
  String? slabIdFk;
  String? vehicelType;
  String? vehicelNo;
  String? truckSize;
  String? royalityType;
  String? cumLoadValue;
  String? excavationChallanNo;
  String? hiringCharges;
  String? shiftRequired;
  String? shiftStartDate;
  String? shiftStartTime;
  String? shiftEndTime;
  String? shiftEndDate;
  String? consumDate;
  String? excavationUsedFor;
  String? fromExcavation;
  String? userIdFk;
  String? excavationStatus;
  String? excavationRemark;
  String? excavationSlabJson;
  DateTime? excavationCreatedAt;
  DateTime? excavationUpdatedAt;
  String? vehilceTypeName;
  String? truckSizeName;
  String? challanNo;
  String? typeRoyalityName;
  List<String>? chalanDocument;
  List<ExcavationDocumentItem>? rawDocuments;
  String? userName;

  FinalExcavalionList({
    this.mstExcavationId,
    this.projectIdFk,
    this.towarIdFk,
    this.slabIdFk,
    this.vehicelType,
    this.vehicelNo,
    this.truckSize,
    this.royalityType,
    this.cumLoadValue,
    this.excavationChallanNo,
    this.hiringCharges,
    this.shiftRequired,
    this.shiftStartDate,
    this.shiftStartTime,
    this.shiftEndTime,
    this.shiftEndDate,
    this.consumDate,
    this.excavationUsedFor,
    this.fromExcavation,
    this.userIdFk,
    this.excavationStatus,
    this.excavationRemark,
    this.excavationSlabJson,
    this.excavationCreatedAt,
    this.excavationUpdatedAt,
    this.vehilceTypeName,
    this.truckSizeName,
    this.challanNo,
    this.typeRoyalityName,
    this.chalanDocument,
    this.rawDocuments,
    this.userName,
  });

  factory FinalExcavalionList.fromApiEntry(ExcavationEntryItem item) {
    return FinalExcavalionList(
      mstExcavationId: item.id,
      projectIdFk: item.projectId,
      towarIdFk: item.slab?.tower?.id,
      slabIdFk: item.slabId,
      vehicelType: item.vehicleTypeId,
      vehicelNo: item.vehicleNo,
      truckSize: item.truckSizeId,
      royalityType: item.royaltyTypeId,
      cumLoadValue: item.cumLoaded,
      excavationChallanNo: item.challanNo,
      hiringCharges: item.hiringCharges,
      shiftRequired: item.shiftRequired,
      shiftStartDate: item.shiftFrom,
      shiftEndDate: item.shiftTo,
      excavationUsedFor: item.excavationFrom,
      fromExcavation: item.excavationFrom,
      userIdFk: item.createdBy,
      excavationRemark: item.remarks,
      excavationCreatedAt: item.createdAt != null ? DateTime.tryParse(item.createdAt!) : null,
      excavationUpdatedAt: item.updatedAt != null ? DateTime.tryParse(item.updatedAt!) : null,
      vehilceTypeName: item.vehicleType?.name ??
          (item.vehicleTypeId == '4'
              ? 'Dumper'
              : item.vehicleTypeId == '5'
                  ? 'JCB'
                  : item.vehicleTypeId == '6'
                      ? 'Poclain'
                      : 'Vehicle Entry'),
      truckSizeName: item.truckSize?.name,
      typeRoyalityName: item.royaltyType?.name,
      userName: item.createdByUser?.name,
      chalanDocument: item.documents
          .map((d) => d.fileUrl ?? d.fileKey ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
      rawDocuments: item.documents,
    );
  }

  factory FinalExcavalionList.fromJson(Map<String, dynamic> json) =>
      FinalExcavalionList(
        mstExcavationId: json["mst_excavation_id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        slabIdFk: json["slab_id_fk"],
        vehicelType: json["vehicel_type"],
        vehicelNo: json["vehicel_no"],
        truckSize: json["truck_size"],
        royalityType: json["royality_type"],
        cumLoadValue: json["cum_load_value"],
        excavationChallanNo: json["excavation_challan_no"],
        hiringCharges: json["hiring_charges"],
        shiftRequired: json["shift_required"],
        shiftStartDate: json["shift_start_date"],
        shiftStartTime: json["shift_start_time"],
        shiftEndTime: json["shift_end_time"],
        shiftEndDate: json["shift_end_date"],
        consumDate: json["consum_date"],
        excavationUsedFor: json["excavation_used_for"],
        fromExcavation: json["from_excavation"],
        userIdFk: json["user_id_fk"],
        excavationStatus: json["excavation_status"],
        excavationRemark: json["excavation_remark"],
        excavationSlabJson: json["excavation_slab_json"],
        excavationCreatedAt: json["excavation_created_at"] == null
            ? null
            : DateTime.parse(json["excavation_created_at"]),
        excavationUpdatedAt: json["excavation_updated_at"] == null
            ? null
            : DateTime.parse(json["excavation_updated_at"]),
        vehilceTypeName: json["vehilce_type_name"],
        truckSizeName: json["truck_size_name"],
        challanNo: json["challan_no"],
        typeRoyalityName: json["type_royality_name"],
        chalanDocument: json["chalan_document"] == null
            ? []
            : List<String>.from(json["chalan_document"]!.map((x) => x.toString())),
        rawDocuments: json["documents"] != null
            ? List<ExcavationDocumentItem>.from(
                json["documents"].map((x) => ExcavationDocumentItem.fromJson(x)))
            : null,
        userName: json["user_name"],
      );

  Map<String, dynamic> toJson() => {
        "mst_excavation_id": mstExcavationId,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "slab_id_fk": slabIdFk,
        "vehicel_type": vehicelType,
        "vehicel_no": vehicelNo,
        "truck_size": truckSize,
        "royality_type": royalityType,
        "cum_load_value": cumLoadValue,
        "excavation_challan_no": excavationChallanNo,
        "hiring_charges": hiringCharges,
        "shift_required": shiftRequired,
        "shift_start_date": shiftStartDate,
        "shift_start_time": shiftStartTime,
        "shift_end_time": shiftEndTime,
        "shift_end_date": shiftEndDate,
        "consum_date": consumDate,
        "excavation_used_for": excavationUsedFor,
        "from_excavation": fromExcavation,
        "user_id_fk": userIdFk,
        "excavation_status": excavationStatus,
        "excavation_remark": excavationRemark,
        "excavation_slab_json": excavationSlabJson,
        "excavation_created_at": excavationCreatedAt?.toIso8601String(),
        "excavation_updated_at": excavationUpdatedAt?.toIso8601String(),
        "vehilce_type_name": vehilceTypeName,
        "truck_size_name": truckSizeName,
        "challan_no": challanNo,
        "type_royality_name": typeRoyalityName,
        "chalan_document": chalanDocument == null
            ? []
            : List<dynamic>.from(chalanDocument!.map((x) => x)),
        "user_name": userName,
      };
}

// enum UserName { KRISHNA, VAIBHAV_PEDNEKAR }

// final userNameValues = EnumValues({
//   "Krishna": UserName.KRISHNA,
//   "Vaibhav Pednekar": UserName.VAIBHAV_PEDNEKAR
// });

// enum VehilceTypeName { DUMPER, JCB, POKLANE }

// final vehilceTypeNameValues = EnumValues({
//   "Dumper": VehilceTypeName.DUMPER,
//   "JCB": VehilceTypeName.JCB,
//   "Poklane": VehilceTypeName.POKLANE
// });

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
