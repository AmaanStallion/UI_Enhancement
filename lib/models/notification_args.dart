// class NotificationArgs {
//   final String? notificationType;

//   // Common project info
//   final String? projectId;
//   final String? towarId;
//   final String? towarName;

//   final String? projectName;
//   final String? projectLocation;

//   // Permission specific
//   final String? permissionId;

//   // Product specific (future use)
//   final String? productId;

//   // Raw response if needed later
//   final Map<String, dynamic>? raw;

//   NotificationArgs({
//     this.notificationType,
//     this.projectId,
//     this.towarId,
//     this.towarName,
//     this.projectName,
//     this.projectLocation,
//     this.permissionId,
//     this.productId,
//     this.raw,
//   });

//   factory NotificationArgs.fromJson(Map<String, dynamic> json) {
//     return NotificationArgs(
//       notificationType: json['notification_type']?.toString(),
//       projectId: json['project_id']?.toString(),
//       towarId: json['towar_id']?.toString(),
//       towarName: json['project_location']?.toString(),
//       projectName: json['project_name']?.toString(),
//       projectLocation: json['project_location']?.toString(),
//       permissionId: json['response']?['permission_id']?.toString(),
//       productId: json['response']?['product_id']?.toString(),
//       raw: json,
//     );
//   }
// }

class NotificationArgs {
  final String? msg;
  final String? notificationType;
  final NotificationResponseData? response;
  String? projectName;
  final String? projectLocation;
  String? projectId;
  final String? towarIdFk;
  final String? notificationModuleType;
  final DateTime? createdAt;
  final String? showStatus;
  final String? towarName;


  NotificationArgs({
    this.msg,
    this.notificationType,
    this.response,
    this.projectName,
    this.projectLocation,
    this.projectId,
    this.towarIdFk,
    this.notificationModuleType,
    this.createdAt,
    this.showStatus,
    this.towarName,
  });

  factory NotificationArgs.fromJson(Map<String, dynamic> json) {
    return NotificationArgs(
      msg: json['msg'] ?? json['body'] ?? json['message'] ?? '',
      notificationType: json['notification_type'] ?? '',
      response: NotificationResponseData.fromJson(
        json['response'] ?? {},
      ),
      projectName: json['project_name'] ?? '',
      projectLocation: json['project_location'] ?? '',
      projectId: json['project_id']?.toString() ?? '',
      towarIdFk: json['towar_id_fk'] ?? json['towar_id'] ?? json['tower_id'] ?? '',
      notificationModuleType: json['notification_module_type'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      showStatus: json['show_status']?.toString() ?? '',
      towarName: json['towar_name']?.toString() ?? json['tower_name']?.toString() ?? json['project_location']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'notification_type': notificationType,
      'response': response?.toJson(),
      'project_name': projectName,
      'project_location': projectLocation,
      'project_id': projectId,
      'towar_id_fk': towarIdFk,
      'notification_module_type': notificationModuleType,
      'created_at': createdAt?.toIso8601String(),
      'show_status': showStatus,
    };
  }
}

class NotificationResponseData {
  String? projectId;
  String? permissionId;
  String? towarId;
  String? categoryId;
  String? assignToId;
  String? navigationFlag;
  String? woOrderNo;
  String? woOrderId;
  String? slabId;
  String? slabNo;
  String? slabCheckType;
  String? drawingId;
  String? drawingTitle;
  String? slabCheckId;
  String? averagedata;
  dynamic checkType;
  String? headId;
  String? checkId;
  String? masonryId;
  String? masonryNo;
  String? masonryCheckId;
  String? flagRedirect;
  String? targetType;
  String? slabDrawingTypeId;
  Map<String, String>? towerAuthorityMap;
  bool? restrictChecklistCategory;

  NotificationResponseData({
    this.projectId,
    this.permissionId,
    this.towarId,
    this.categoryId,
    this.assignToId,
    this.navigationFlag,
    this.woOrderNo,
    this.woOrderId,
    this.slabId,
    this.slabNo,
    this.slabCheckType,
    this.drawingId,
    this.drawingTitle,
    this.slabCheckId,
    this.averagedata,
    this.checkType,
    this.headId,
    this.checkId,
    this.masonryId,
    this.masonryNo,
    this.masonryCheckId,
    this.flagRedirect,
    this.targetType,
    this.slabDrawingTypeId,
    this.towerAuthorityMap,
    this.restrictChecklistCategory,
  });

  factory NotificationResponseData.fromJson(Map<String, dynamic> json) {
    return NotificationResponseData(
      projectId: json['project_id']?.toString() ?? json['projectId']?.toString() ?? '',
      permissionId: json['permission_id']?.toString() ?? json['legal_id']?.toString() ?? json['leagl_id']?.toString() ?? json['project_legal_id']?.toString() ?? '',
      towarId: json["towar_id"]?.toString() ?? json["tower_id"]?.toString() ?? '',
      categoryId: json["category_id"]?.toString() ?? json["categoryId"]?.toString() ?? json["sop_id"]?.toString() ?? json["sopId"]?.toString(),
      assignToId: json["assign_to_id"]?.toString() ?? '',
      navigationFlag: json["navigation_flag"]?.toString() ?? '',
      woOrderNo: json["wo_order_no"],
      woOrderId: json["wo_order_id"],
      slabId: json["slab_id"],
      slabNo: json["slab_no"],
      slabCheckType: json["slab_check_type"],
      drawingId: json["drawing_id"],
      drawingTitle: json["drawing_title"],
      slabCheckId: json["slab_check_id"],
      averagedata: json["averagedata"],
      checkType: json["check_type"],
      headId: json["head_id"],
      checkId: json["check_id"],
      masonryId: json["masonry_id"],
      masonryNo: json["masonry_no"],
      masonryCheckId: json["masonry_check_id"],
      flagRedirect: json["flag_redirect"],
      restrictChecklistCategory: json["restrict_checklist_category"] == true || json["restrict_checklist_category"]?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'permission_id': permissionId,
      "towar_id": towarId,
      "category_id": categoryId,
      "assign_to_id": assignToId,
      "navigation_flag": navigationFlag,
      "wo_order_no": woOrderNo,
      "wo_order_id": woOrderId,
      "slab_id": slabId,
      "slab_no": slabNo,
      "slab_check_type": slabCheckType,
      "drawing_id": drawingId,
      "drawing_title": drawingTitle,
      "slab_check_id": slabCheckId,
      "averagedata": averagedata,
      "check_type": checkType,
      "head_id": headId,
      "check_id": checkId,
      "masonry_id": masonryId,
      "masonry_no": masonryNo,
      "masonry_check_id": masonryCheckId,
      "flag_redirect": flagRedirect,
      "restrict_checklist_category": restrictChecklistCategory,
    };
  }
}
