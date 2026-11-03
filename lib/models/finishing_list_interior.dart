// // To parse this JSON data, do
// //
// //     final finisingListInterior = finisingListInteriorFromJson(jsonString);

// import 'dart:convert';

// import 'package:stallion/models/finishing_flat_listing.dart';

// FinisingListInterior finisingListInteriorFromJson(String str) =>
//     FinisingListInterior.fromJson(json.decode(str));

// String finisingListInteriorToJson(FinisingListInterior data) =>
//     json.encode(data.toJson());

// class FinisingListInterior {
//   FinisingListInteriorResponse? response;

//   FinisingListInterior({
//     this.response,
//   });

//   factory FinisingListInterior.fromJson(Map<String, dynamic> json) =>
//       FinisingListInterior(
//         response: json["Response"] == null
//             ? null
//             : FinisingListInteriorResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class FinisingListInteriorResponse {
//   String? errorCode;
//   String? msg;
//   List<FinalResult>? finalResult;
//   List<FinishingList>? finishingList;

//   FinisingListInteriorResponse({
//     this.errorCode,
//     this.msg,
//     this.finalResult,
//     this.finishingList,
//   });

//   factory FinisingListInteriorResponse.fromJson(Map<String, dynamic> json) =>
//       FinisingListInteriorResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         finalResult: json["final_result"] == null
//             ? []
//             : List<FinalResult>.from(
//                 json["final_result"]!.map((x) => FinalResult.fromJson(x))),
//         finishingList: json["finishing_list"] == null
//             ? []
//             : List<FinishingList>.from(
//                 json["finishing_list"]!.map((x) => FinishingList.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "final_result": finalResult == null
//             ? []
//             : List<dynamic>.from(finalResult!.map((x) => x.toJson())),
//         "finishing_list": finishingList == null
//             ? []
//             : List<dynamic>.from(finishingList!.map((x) => x.toJson())),
//       };
// }

// class FinalResult {
//   String? floorId;
//   String? floorData;
//   List<FinishingDetail>? finishingDetails;

//   FinalResult({
//     this.floorId,
//     this.floorData,
//     this.finishingDetails,
//   });

//   factory FinalResult.fromJson(Map<String, dynamic> json) => FinalResult(
//         floorId: json["floor_id"],
//         floorData: json["floor_data"],
//         finishingDetails: json["finishing_details"] == null
//             ? []
//             : List<FinishingDetail>.from(json["finishing_details"]!
//                 .map((x) => FinishingDetail.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "floor_id": floorId,
//         "floor_data": floorData,
//         "finishing_details": finishingDetails == null
//             ? []
//             : List<dynamic>.from(finishingDetails!.map((x) => x.toJson())),
//       };
// }

// class FinishingDetail {
//   String? gradeName;
//   String? finishingId;
//   String? finishingQty;
//   String? consumeQty;

//   FinishingDetail({
//     this.gradeName,
//     this.finishingId,
//     this.finishingQty,
//     this.consumeQty,
//   });

//   factory FinishingDetail.fromJson(Map<String, dynamic> json) =>
//       FinishingDetail(
//         gradeName: json["grade_name"],
//         finishingId: json["finishing_id"],
//         finishingQty: json["finishing_qty"],
//         consumeQty: json["consume_qty"],
//       );

//   Map<String, dynamic> toJson() => {
//         "grade_name": gradeName,
//         "finishing_id": finishingId,
//         "finishing_qty": finishingQty,
//         "consume_qty": consumeQty,
//       };
// }

// // enum GradeName {
// //   BLOCKS,
// //   CABLES_WIRE,
// //   CAMERA,
// //   CCTV_CAMERA,
// //   CI_PIPE,
// //   CP_FITTINGS,
// //   DOOR,
// //   DOOR_FRAMES,
// //   DOOR_SHUTTER,
// //   FABRICATION_WORK,
// //   FINISHING,
// //   FIRE_STICKER
// // }

// // final gradeNameValues = EnumValues({
// //   "Blocks": GradeName.BLOCKS,
// //   "Cables & Wire": GradeName.CABLES_WIRE,
// //   "Camera": GradeName.CAMERA,
// //   "CCTV Camera": GradeName.CCTV_CAMERA,
// //   "CI PIPE": GradeName.CI_PIPE,
// //   "CP FITTINGS": GradeName.CP_FITTINGS,
// //   "Door": GradeName.DOOR,
// //   "Door Frames": GradeName.DOOR_FRAMES,
// //   "Door Shutter": GradeName.DOOR_SHUTTER,
// //   "Fabrication work": GradeName.FABRICATION_WORK,
// //   "FINISHING": GradeName.FINISHING,
// //   "Fire Sticker": GradeName.FIRE_STICKER
// // });

// // class FinishingList {
// //   String? gradeName;
// //   String? finishingId;

// //   FinishingList({
// //     this.gradeName,
// //     this.finishingId,
// //   });

// //   factory FinishingList.fromJson(Map<String, dynamic> json) => FinishingList(
// //         gradeName: json["grade_name"],
// //         finishingId: json["finishing_id"],
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "grade_name": gradeName,
// //         "finishing_id": finishingId,
// //       };
// // }

// // class EnumValues<T> {
// //   Map<String, T> map;
// //   late Map<T, String> reverseMap;

// //   EnumValues(this.map);

// //   Map<T, String> get reverse {
// //     reverseMap = map.map((k, v) => MapEntry(v, k));
// //     return reverseMap;
// //   }
// // }
