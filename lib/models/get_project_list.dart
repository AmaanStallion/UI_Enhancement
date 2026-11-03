// // To parse this JSON data, do
// //
// //     final getprojectlist = getprojectlistFromJson(jsonString);

// import 'dart:convert';

// Getprojectlist getprojectlistFromJson(String str) =>
//     Getprojectlist.fromJson(json.decode(str));

// String getprojectlistToJson(Getprojectlist data) => json.encode(data.toJson());

// class Getprojectlist {
//   getprojectlistResponse? response;

//   Getprojectlist({
//     this.response,
//   });

//   factory Getprojectlist.fromJson(Map<String, dynamic> json) => Getprojectlist(
//         response: json["Response"] == null
//             ? null
//             : getprojectlistResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class getprojectlistResponse {
//   String? errorCode;
//   String? msg;
//   String? isDeveloper;
//   String? isConsultant;
//   String? isContractor;
//   String? passwordSetTab;
//   String? aboutButtonTab;
//   String? orderHistoryTabActive;
//   String? saleMagActive;
//   String? taskManagerActive;
//   String? accountsTabActive;
//   String? contractorActive;
//   String? supplierActive;
//   String? accountMagActive;
//   List<UserDetail>? userDetails;
//   List<ProjectDetail>? projectDetails;
//   String? projectImgPath;

//   getprojectlistResponse({
//     this.errorCode,
//     this.msg,
//     this.isDeveloper,
//     this.isConsultant,
//     this.isContractor,
//     this.passwordSetTab,
//     this.aboutButtonTab,
//     this.orderHistoryTabActive,
//     this.saleMagActive,
//     this.taskManagerActive,
//     this.accountsTabActive,
//     this.contractorActive,
//     this.supplierActive,
//     this.accountMagActive,
//     this.userDetails,
//     this.projectDetails,
//     this.projectImgPath,
//   });

//   factory getprojectlistResponse.fromJson(Map<String, dynamic> json) =>
//       getprojectlistResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         isDeveloper: json["is_developer"],
//         isConsultant: json["is_consultant"],
//         isContractor: json["is_contractor"],
//         passwordSetTab: json["password_set_tab"],
//         aboutButtonTab: json["about_button_tab"],
//         orderHistoryTabActive: json["order_history_tab_active"],
//         saleMagActive: json["sale_mag_active"],
//         taskManagerActive: json["task_manager_active"],
//         accountsTabActive: json["accounts_tab_active"],
//         contractorActive: json["contractor_active"],
//         supplierActive: json["supplier_active"],
//         accountMagActive: json["account_mag_active"],
//         userDetails: json["user_details"] == null
//             ? []
//             : List<UserDetail>.from(
//                 json["user_details"]!.map((x) => UserDetail.fromJson(x))),
//         projectDetails: json["project_details"] == null
//             ? []
//             : List<ProjectDetail>.from(
//                 json["project_details"]!.map((x) => ProjectDetail.fromJson(x))),
//         projectImgPath: json["project_img_path"],
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "is_developer": isDeveloper,
//         "is_consultant": isConsultant,
//         "is_contractor": isContractor,
//         "password_set_tab": passwordSetTab,
//         "about_button_tab": aboutButtonTab,
//         "order_history_tab_active": orderHistoryTabActive,
//         "sale_mag_active": saleMagActive,
//         "task_manager_active": taskManagerActive,
//         "accounts_tab_active": accountsTabActive,
//         "contractor_active": contractorActive,
//         "supplier_active": supplierActive,
//         "account_mag_active": accountMagActive,
//         "user_details": userDetails == null
//             ? []
//             : List<dynamic>.from(userDetails!.map((x) => x.toJson())),
//         "project_details": projectDetails == null
//             ? []
//             : List<dynamic>.from(projectDetails!.map((x) => x.toJson())),
//         "project_img_path": projectImgPath,
//       };
// }

// class ProjectDetail {
//   int? projectId;
//   String? projectName;
//   String? placeName;
//   int? mstCompanyId;
//   DateTime? endDt;
//   String? projectIssue;
//   String? contractorMagicLink;
//   String? vendMagicLink;
//   String? consultantMagicLink;
//   String? projectImgName;
//   int? towarId;
//   String? towerName;
//   String? towerImg;

//   ProjectDetail({
//     this.projectId,
//     this.projectName,
//     this.placeName,
//     this.mstCompanyId,
//     this.endDt,
//     this.projectIssue,
//     this.contractorMagicLink,
//     this.vendMagicLink,
//     this.consultantMagicLink,
//     this.projectImgName,
//     this.towarId,
//     this.towerName,
//     this.towerImg,
//   });

//   factory ProjectDetail.fromJson(Map<String, dynamic> json) => ProjectDetail(
//         projectId: json["project_id"],
//         projectName: json["project_name"],
//         placeName: json["place_name"],
//         mstCompanyId: json["mst_company_id"],
//         endDt: json["end_dt"] == null ? null : DateTime.parse(json["end_dt"]),
//         projectIssue: json["project_issue"],
//         contractorMagicLink: json["contractor_magic_link"],
//         vendMagicLink: json["vend_magic_link"],
//         consultantMagicLink: json["consultant_magic_link"],
//         projectImgName: json["project_img_name"],
//         towarId: json["towar_id"],
//         towerName: json["tower_name"],
//         towerImg: json["tower_img"],
//       );

//   Map<String, dynamic> toJson() => {
//         "project_id": projectId,
//         "project_name": projectName,
//         "place_name": placeName,
//         "mst_company_id": mstCompanyId,
//         "end_dt": endDt?.toIso8601String(),
//         "project_issue": projectIssue,
//         "contractor_magic_link": contractorMagicLink,
//         "vend_magic_link": vendMagicLink,
//         "consultant_magic_link": consultantMagicLink,
//         "project_img_name": projectImgName,
//         "towar_id": towarId,
//         "tower_name": towerName,
//         "tower_img": towerImg,
//       };
// }

// class UserDetail {
//   int? userId;
//   String? mobileNo;
//   String? userName;
//   int? companyId;
//   String? companyName;
//   String? userProfile;
//   String? designation;
//   String? profileImg;

//   UserDetail({
//     this.userId,
//     this.mobileNo,
//     this.userName,
//     this.companyId,
//     this.companyName,
//     this.userProfile,
//     this.designation,
//     this.profileImg,
//   });

//   factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
//         userId: json["user_id"],
//         mobileNo: json["mobile_no"],
//         userName: json["user_name"],
//         companyId: json["company_id"],
//         companyName: json["company_name"],
//         userProfile: json["user_profile"],
//         designation: json["designation"],
//         profileImg: json["profile_img"],
//       );

//   Map<String, dynamic> toJson() => {
//         "user_id": userId,
//         "mobile_no": mobileNo,
//         "user_name": userName,
//         "company_id": companyId,
//         "company_name": companyName,
//         "user_profile": userProfile,
//         "designation": designation,
//         "profile_img": profileImg,
//       };
// }

import 'dart:convert';

getprojectlist getprojectlistFromJson(String str) =>
    getprojectlist.fromJson(json.decode(str));

String getprojectlistToJson(getprojectlist data) => json.encode(data.toJson());

class getprojectlist {
  getprojectlistResponse? response;

  getprojectlist({this.response});

  getprojectlist.fromJson(Map<String, dynamic> json) {
    response = json['Response'] != null
        ? new getprojectlistResponse.fromJson(json['Response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (response != null) {
      data['Response'] = response?.toJson();
    }
    return data;
  }
}

class getprojectlistResponse {
  String? errorCode;
  String? msg;
  String? saleMagActive;
  String? accountsTabActive;
  String? contractorActive;
  String? supplierActive;
  String? accountMagActive;
  String? orderHistoryTabActive;
  String? is_developer;
  String? is_consultant;
  String? is_contractor;
  String? masterDashboardFlag;

  List<UserDetails>? userDetails = [];
  List<ProjectDetails>? projectDetails = [];
  String? projectImgPath;
  String? acquisitionTab;
  String? groupFlag;

  getprojectlistResponse({
    this.errorCode,
    this.msg,
    this.saleMagActive,
    this.accountsTabActive,
    this.contractorActive,
    this.supplierActive,
    this.accountMagActive,
    this.orderHistoryTabActive,
    this.userDetails,
    this.projectDetails,
    this.projectImgPath,
    this.is_consultant,
    this.is_developer,
    this.is_contractor,
    this.acquisitionTab,
    this.groupFlag,
    this.masterDashboardFlag,
  });

  getprojectlistResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['error_code'];
    msg = json['msg'];
    saleMagActive = json['sale_mag_active'];
    accountsTabActive = json['accounts_tab_active'];
    contractorActive = json['contractor_active'];
    supplierActive = json['supplier_active'];
    accountMagActive = json['account_mag_active'];
    orderHistoryTabActive = json['order_history_tab_active'];
    is_consultant = json['is_consultant'];
    is_developer = json['is_developer'];
    is_contractor = json['is_contractor'];
    acquisitionTab = json['acquisition_tab'];
    if (json['user_details'] != null) {
      //userDetails = new List<UserDetails>();
      json['user_details'].forEach((v) {
        userDetails?.add(UserDetails.fromJson(v));
      });
    }
    if (json['project_details'] != null) {
      //projectDetails = new List<ProjectDetails>();
      json['project_details'].forEach((v) {
        projectDetails?.add(new ProjectDetails.fromJson(v));
      });
    }
    projectImgPath = json['project_img_path'];
    groupFlag = json["group_flag"];
    masterDashboardFlag = json["master_dashboard_flag"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error_code'] = errorCode;
    data['msg'] = msg;
    data['sale_mag_active'] = saleMagActive;
    data['accounts_tab_active'] = accountsTabActive;
    data['contractor_active'] = contractorActive;
    data['supplier_active'] = supplierActive;
    data['account_mag_active'] = accountMagActive;
    data['order_history_tab_active'] = orderHistoryTabActive;
    data['is_consultant'] = is_consultant;
    data['is_developer'] = is_developer;
    data['is_contractor'] = is_contractor;
    data['acquisition_tab'] = acquisitionTab;

    if (userDetails != null) {
      data['user_details'] = userDetails?.map((v) => v.toJson()).toList();
    }
    if (projectDetails != null) {
      data['project_details'] = projectDetails?.map((v) => v.toJson()).toList();
    }
    data['project_img_path'] = projectImgPath;
    data['group_flag'] = groupFlag;
    data["master_dashboard_flag"] = masterDashboardFlag;

    return data;
  }
}

class ProjectDetails {
  String? projectId;
  String? towarId;
  String? towarName;
  String? projectName;
  String? placeName;
  String? isAdmin;
  String? endDt;
  String? projectIssue;
  String? projectImgName;
  String? contractorMagicLink;
  String? vendMagicLink;
  String? consultantMagicLink;
  String? towerFlag;
  bool? applyDwg;
  bool? exactlyOneTower;
  String? role;
  List<dynamic>? modules;

  ProjectDetails({
    this.projectId,
    this.towarId,
    this.towarName,
    this.projectName,
    this.placeName,
    this.isAdmin,
    this.endDt,
    this.projectIssue,
    this.projectImgName,
    this.contractorMagicLink,
    this.vendMagicLink,
    this.consultantMagicLink,
    this.towerFlag,
    this.applyDwg,
    this.exactlyOneTower,
    this.role,
    this.modules,
  });

  ProjectDetails.fromJson(Map<String, dynamic> json) {
    projectId = json['project_id'] ?? json['id']?.toString();
    towarId = json['towar_id'] ?? "";
    towarName = json['tower_name'] ?? "";
    projectName = json['project_name'] ?? json['name'];
    placeName = json['place_name'] ?? json['location'];
    isAdmin = json['is_admin'];
    endDt = json['end_dt'];
    projectIssue = json['project_issue'];
    projectImgName = json['project_img_name'] ?? json['project_image_url'] ?? "";
    contractorMagicLink = json["contractor_magic_link"];
    vendMagicLink = json["vend_magic_link"];
    consultantMagicLink = json["consultant_magic_link"];
    towerFlag = json["tower_flag"];
    applyDwg = json['apply_dwg'] == true || json['apply_dwg']?.toString() == 'true';
    exactlyOneTower = json['exactlyOneTower'] == true || json['exactlyOneTower']?.toString() == 'true';
    role = json['role']?.toString() ?? json['role in this project']?.toString();
    if (json['modules'] != null && json['modules'] is List) {
      modules = List<dynamic>.from(json['modules']);
    } else {
      modules = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['project_id'] = projectId;
    data['towar_id'] = towarId ?? "";
    data['tower_name'] = towarName ?? "";
    data['project_name'] = projectName;
    data['place_name'] = placeName;
    data['is_admin'] = isAdmin;
    data['end_dt'] = endDt;
    data['project_issue'] = projectIssue;
    data['project_img_name'] = projectImgName;
    data['contractor_magic_link'] = contractorMagicLink;
    data['vend_magic_link'] = vendMagicLink;
    data['consultant_magic_link'] = consultantMagicLink;
    data['tower_flag'] = towerFlag;
    data['apply_dwg'] = applyDwg;
    data['exactlyOneTower'] = exactlyOneTower;
    data['role'] = role;
    data['modules'] = modules;

    return data;
  }
}

class UserDetails {
  String userId = "";
  String mobileNo = "";
  String userName = "";
  String? companyId;
  String? companyName;
  String? userProfile;
  String? desingnation;
  String? profileImg;

  UserDetails(
      {required this.userId,
      required this.mobileNo,
      required this.userName,
      this.companyId,
      this.companyName,
      this.userProfile,
      this.desingnation,
      this.profileImg});

  UserDetails.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    mobileNo = json['mobile_no'];
    userName = json['user_name'];
    companyId = json['company_id'];
    companyName = json['company_name'];
    userProfile = json['user_profile'];
    desingnation = json['desingnation'];
    profileImg = json['profile_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['mobile_no'] = mobileNo;
    data['user_name'] = userName;
    data['company_id'] = companyId;
    data['company_name'] = companyName;
    data['user_profile'] = userProfile;
    data['desingnation'] = desingnation;
    data['profile_img'] = profileImg;
    return data;
  }
}
