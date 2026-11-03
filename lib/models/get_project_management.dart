// // To parse this JSON data, do
// //
// //     final projectManagement = projectManagementFromJson(jsonString);

// import 'dart:convert';

// import 'get_rccissuereport_data.dart';

// ProjectManagement ProjectManagementFromJson(String str) =>
//     ProjectManagement.fromJson(json.decode(str));

// String ProjectManagementToJson(ProjectManagement data) =>
//     json.encode(data.toJson());

// class ProjectManagement {
//   ProjectManagementResponse? response;

//   ProjectManagement({
//     this.response,
//   });

//   factory ProjectManagement.fromJson(Map<String, dynamic> json) =>
//       ProjectManagement(
//         response: json["Response"] == null
//             ? null
//             : ProjectManagementResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class ProjectManagementResponse {
//   String? errorCode;
//   String? msg;
//   List<ProjectStructure>? projectStructure;
//   List<TemaDetail>? temaDetails;
//   int? projectOverView;
//   List<SlabIssueReport>? slabIssueDetails;

//   ProjectManagementResponse({
//     this.errorCode,
//     this.msg,
//     this.projectStructure,
//     this.temaDetails,
//     this.projectOverView,
//     this.slabIssueDetails,
//   });

//   factory ProjectManagementResponse.fromJson(Map<String, dynamic> json) =>
//       ProjectManagementResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         projectStructure: json["project_structure"] == null
//             ? []
//             : List<ProjectStructure>.from(json["project_structure"]!
//                 .map((x) => ProjectStructure.fromJson(x))),
//         temaDetails: json["Tema_Details"] == null
//             ? []
//             : List<TemaDetail>.from(
//                 json["Tema_Details"]!.map((x) => TemaDetail.fromJson(x))),
//         projectOverView: json["project_over_view"],
//         slabIssueDetails: json["slab_issue_details"] == null
//             ? []
//             : List<SlabIssueReport>.from(json["slab_issue_details"]!
//                 .map((x) => SlabIssueReport.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "project_structure": projectStructure == null
//             ? []
//             : List<dynamic>.from(projectStructure!.map((x) => x.toJson())),
//         "Tema_Details": temaDetails == null
//             ? []
//             : List<dynamic>.from(temaDetails!.map((x) => x.toJson())),
//         "project_over_view": projectOverView,
//         "slab_issue_details": slabIssueDetails == null
//             ? []
//             : List<dynamic>.from(slabIssueDetails!.map((x) => x.toJson())),
//       };
// }

// class ProjectStructure {
//   String? title;
//   String? discription;
//   dynamic isActive;
//   String? complete;
//   String? issuse;
//   String? isSetupDone;
//   List<SlabIssueReport>? issueDetails;

//   ProjectStructure({
//     this.title,
//     this.discription,
//     this.isActive,
//     this.complete,
//     this.issuse,
//     this.isSetupDone,
//     this.issueDetails,
//   });

//   factory ProjectStructure.fromJson(Map<String, dynamic> json) =>
//       ProjectStructure(
//         title: json["title"],
//         discription: json["discription"],
//         isActive: json["is_active"],
//         complete: json["complete"],
//         issuse: json["issuse"],
//         isSetupDone: json["is_setup_done"],
//         issueDetails: json["issue_details"] == null
//             ? []
//             : List<SlabIssueReport>.from(
//                 json["issue_details"]!.map((x) => SlabIssueReport.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "title": title,
//         "discription": discription,
//         "is_active": isActive,
//         "complete": complete,
//         "issuse": issuse,
//         "is_setup_done": isSetupDone,
//         "issue_details": issueDetails == null
//             ? []
//             : List<dynamic>.from(issueDetails!.map((x) => x.toJson())),
//       };
// }

// class SlabIssueReport {
//   int? mstSlabIssuerReportId;
//   int? issueIn;
//   String? reports;
//   String? extracomment;
//   String? submitdate;
//   DateTime? resolvedate;
//   int? userIdFk;
//   String? issueResolve;
//   String? slabIssueCheckType;
//   int? slabIdFk;
//   String? issusInName;
//   String? reportedBy;
//   String? slabNumber;
//   String? reportToName;
//   String? reportTo;
//   String? issueResolveBtn;
//   String? resolvedDate;
//   List<String>? image;
//   String? imagePath;
//   List<String>? slabVedio;
//   final String? reportBy;
//   final String? empname;

//   SlabIssueReport({
//     this.mstSlabIssuerReportId,
//     this.issueIn,
//     this.reports,
//     this.extracomment,
//     this.submitdate,
//     this.resolvedate,
//     this.userIdFk,
//     this.issueResolve,
//     this.slabIssueCheckType,
//     this.slabIdFk,
//     this.issusInName,
//     this.reportedBy,
//     this.slabNumber,
//     this.reportToName,
//     this.reportTo,
//     this.issueResolveBtn,
//     this.resolvedDate,
//     this.image,
//     this.imagePath,
//     this.slabVedio,
//     this.reportBy,
//     this.empname,
//   });

//   factory SlabIssueReport.fromJson(Map<String, dynamic> json) =>
//       SlabIssueReport(
//         mstSlabIssuerReportId: json["mst_slab_issuer_report_id"],
//         issueIn: json["issue_in"],
//         reports: json["reports"],
//         extracomment: json["extracomment"],
//         submitdate: json["submitdate"],
//         resolvedate: json["resolvedate"] == null
//             ? null
//             : DateTime.parse(json["resolvedate"]),
//         userIdFk: json["user_id_fk"],
//         issueResolve: json["issue_resolve"],
//         slabIssueCheckType: json["slab_issue_check_type"],
//         slabIdFk: json["slab_id_fk"],
//         issusInName: json["issus_in_name"]!,
//         reportedBy: json["reported_by"],
//         slabNumber: json["slab_number"],
//         reportToName: json["report_to_name"],
//         reportTo: json["report_to"],
//         issueResolveBtn: json["issue_resolve_btn"],
//         resolvedDate: json["resolved_date"],
//         image: json["image"] == null
//             ? []
//             : List<String>.from(json["image"]!.map((x) => x!)),
//         imagePath: json["image_path"],
//         slabVedio: json["slab_vedio"] == null
//             ? []
//             : List<String>.from(json["slab_vedio"]!.map((x) => x)),
//         reportBy: json["report_by"],
//         empname: json["empname"],
//       );

//   Map<String, dynamic> toJson() => {
//         "mst_slab_issuer_report_id": mstSlabIssuerReportId,
//         "issue_in": issueIn,
//         "reports": reports,
//         "extracomment": extracomment,
//         "submitdate": submitdate,
//         "resolvedate": resolvedate?.toIso8601String(),
//         "user_id_fk": userIdFk,
//         "issue_resolve": issueResolve,
//         "slab_issue_check_type": slabIssueCheckType,
//         "slab_id_fk": slabIdFk,
//         "issus_in_name": issusInName,
//         "reported_by": reportedBy,
//         "slab_number": slabNumber,
//         "report_to_name": reportToName,
//         "report_to": reportTo,
//         "issue_resolve_btn": issueResolveBtn,
//         "resolved_date": resolvedDate,
//         "image": image == null ? [] : List<dynamic>.from(image!.map((x) => x)),
//         "image_path": imagePath,
//         "slab_vedio": slabVedio == null
//             ? []
//             : List<dynamic>.from(slabVedio!.map((x) => x)),
//         "report_by": reportBy,
//         "empname": empname,
//       };
// }

// class TemaDetail {
//   int? companyId;
//   String? compayName;
//   String? typeName;
//   List<MemberDetail>? memberDetails;

//   TemaDetail({
//     this.companyId,
//     this.compayName,
//     this.typeName,
//     this.memberDetails,
//   });

//   factory TemaDetail.fromJson(Map<String, dynamic> json) => TemaDetail(
//         companyId: json["company_id"],
//         compayName: json["compay_name"],
//         typeName: json["type_name"],
//         memberDetails: json["member_details"] == null
//             ? []
//             : List<MemberDetail>.from(
//                 json["member_details"]!.map((x) => MemberDetail.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "company_id": companyId,
//         "compay_name": compayName,
//         "type_name": typeName,
//         "member_details": memberDetails == null
//             ? []
//             : List<dynamic>.from(memberDetails!.map((x) => x.toJson())),
//       };
// }

// class MemberDetail {
//   String? memberName;
//   String? contactNubmer;
//   int? memberId;
//   String? designation;
//   String? profileImg;

//   MemberDetail({
//     this.memberName,
//     this.contactNubmer,
//     this.memberId,
//     this.designation,
//     this.profileImg,
//   });

//   factory MemberDetail.fromJson(Map<String, dynamic> json) => MemberDetail(
//         memberName: json["member_name"],
//         contactNubmer: json["contact_nubmer"],
//         memberId: json["member_id"],
//         designation: json["Designation"],
//         profileImg: json["profile_img"],
//       );

//   Map<String, dynamic> toJson() => {
//         "member_name": memberName,
//         "contact_nubmer": contactNubmer,
//         "member_id": memberId,
//         "Designation": designation,
//         "profile_img": profileImg,
//       };
// }
import 'dart:convert';

import 'get_rccissuereport_data.dart';

ProjectManagement ProjectManagementFromJson(String str) =>
    ProjectManagement.fromJson(json.decode(str));

String ProjectManagementToJson(ProjectManagement data) =>
    json.encode(data.toJson());

class ProjectManagement {
  ProjectManagementResponse? response;

  ProjectManagement({this.response});

  ProjectManagement.fromJson(Map<String, dynamic> json) {
    response = json['Response'] != null
        ? ProjectManagementResponse.fromJson(json['Response'])
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

class ProjectManagementResponse {
  String? errorCode;
  String? msg;
  String? projectOverView;
  List<ProjectStructure>? projectStructure = [];
  List<TemaDetails>? temaDetails = [];
  List<SlabIssueDetails>? slabIssueDetails = [];

  ProjectManagementResponse(
      {this.errorCode,
      this.msg,
      this.projectStructure,
      this.projectOverView,
      this.temaDetails,
      this.slabIssueDetails});

  ProjectManagementResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['error_code'];
    projectOverView = json["project_over_view"];
    msg = json['msg'];
    if (json['project_structure'] != null) {
      //projectStructure = new List<ProjectStructure>();
      json['project_structure'].forEach((v) {
        projectStructure?.add(ProjectStructure.fromJson(v));
      });
    }
    if (json['Tema_Details'] != null) {
      //temaDetails = new List<TemaDetails>();
      json['Tema_Details'].forEach((v) {
        temaDetails?.add(TemaDetails.fromJson(v));
      });
    }
    if (json['slab_issue_details'] != null) {
      //slabIssueDetails = new List<SlabIssueDetails>();
      json['slab_issue_details'].forEach((v) {
        slabIssueDetails?.add(SlabIssueDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error_code'] = errorCode;
    data['project_over_view'] = projectOverView;
    data['msg'] = msg;
    if (projectStructure != null) {
      data['project_structure'] =
          projectStructure?.map((v) => v.toJson()).toList();
    }
    if (temaDetails != null) {
      data['Tema_Details'] = temaDetails?.map((v) => v.toJson()).toList();
    }
    if (slabIssueDetails != null) {
      data['slab_issue_details'] =
          slabIssueDetails?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProjectStructure {
  String? title;
  String? discription;
  String? complete;
  String? issuse;
  String? isActive;
  String? isSetupDone;
  List<SlabIssueReport>? issueDetails = [];
  String? groupFlag;

  ProjectStructure({
    this.title,
    this.discription,
    this.complete,
    this.issuse,
    this.isActive,
    this.isSetupDone,
    this.issueDetails,
    this.groupFlag,
  });

  ProjectStructure.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    discription = json['discription'];
    complete = json['complete'];
    issuse = json['issuse'];
    isActive = json['is_active'];
    isSetupDone = json['is_setup_done'];
    groupFlag = json["group_flag"];
    if (json['issue_details'] != null) {
      //issueDetails = new List<IssueDetails>();
      json['issue_details'].forEach((v) {
        issueDetails?.add(SlabIssueReport.fromJson(v));
      });
    }
    ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['discription'] = discription;
    data['complete'] = complete;
    data['issuse'] = issuse;
    data['is_active'] = isActive;
    data['is_setup_done'] = isSetupDone;
    data['group_flag'] = groupFlag;

    if (issueDetails != null) {
      data['issue_details'] = issueDetails?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class IssueDetails {
//   String? mstSlabIssuerReportId;
//   String? issueIn;
//   String? reports;
//   String? extracomment;
//   String? submitdate;
//   String? resolvedate;
//   String? userIdFk;
//   String? issueResolve;
//   String? slabIssueCheckType;
//   String? slabIdFk;
//   String? issusInName;
//   String? reportedBy;
//   String? slabNumber;
//   String? reportToName;
//   String? reportTo;
//   String? issueResolveBtn;
//   String? resolvedDate;
//   List<String>? image;
//   String? imagePath;
//   String? typeMagIdFk;
//   String? slabIssueStaus;
//   String? slabIssueUpdateDate;
//   String? slabIssueAddDate;
//   String? projectName;

//   IssueDetails(
//       {this.mstSlabIssuerReportId,
//       this.issueIn,
//       this.reports,
//       this.extracomment,
//       this.submitdate,
//       this.resolvedate,
//       this.userIdFk,
//       this.issueResolve,
//       this.slabIssueCheckType,
//       this.slabIdFk,
//       this.issusInName,
//       this.reportedBy,
//       this.slabNumber,
//       this.reportToName,
//       this.reportTo,
//       this.issueResolveBtn,
//       this.resolvedDate,
//       this.image,
//       this.imagePath,
//       this.typeMagIdFk,
//       this.slabIssueStaus,
//       this.slabIssueUpdateDate,
//       this.slabIssueAddDate,
//       this.projectName});

//   IssueDetails.fromJson(Map<String, dynamic> json) {
//     mstSlabIssuerReportId = json['mst_slab_issuer_report_id'];
//     issueIn = json['issue_in'];
//     reports = json['reports'];
//     extracomment = json['extracomment'];
//     submitdate = json['submitdate'];
//     resolvedate = json['resolvedate'];
//     userIdFk = json['user_id_fk'];
//     issueResolve = json['issue_resolve'];
//     slabIssueCheckType = json['slab_issue_check_type'];
//     slabIdFk = json['slab_id_fk'];
//     issusInName = json['issus_in_name'];
//     reportedBy = json['reported_by'];
//     slabNumber = json['slab_number'];
//     reportToName = json['report_to_name'];
//     reportTo = json['report_to'];
//     issueResolveBtn = json['issue_resolve_btn'];
//     resolvedDate = json['resolved_date'];
//     image = json['image'].cast<String>();
//     imagePath = json['image_path'];
//     typeMagIdFk = json['type_mag_id_fk'];
//     slabIssueStaus = json['slab_issue_staus'];
//     slabIssueUpdateDate = json['slab_issue_update_date'];
//     slabIssueAddDate = json['slab_issue_add_date'];
//     projectName = json['project_name'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['mst_slab_issuer_report_id'] = this.mstSlabIssuerReportId;
//     data['issue_in'] = this.issueIn;
//     data['reports'] = this.reports;
//     data['extracomment'] = this.extracomment;
//     data['submitdate'] = this.submitdate;
//     data['resolvedate'] = this.resolvedate;
//     data['user_id_fk'] = this.userIdFk;
//     data['issue_resolve'] = this.issueResolve;
//     data['slab_issue_check_type'] = this.slabIssueCheckType;
//     data['slab_id_fk'] = this.slabIdFk;
//     data['issus_in_name'] = this.issusInName;
//     data['reported_by'] = this.reportedBy;
//     data['slab_number'] = this.slabNumber;
//     data['report_to_name'] = this.reportToName;
//     data['report_to'] = this.reportTo;
//     data['issue_resolve_btn'] = this.issueResolveBtn;
//     data['resolved_date'] = this.resolvedDate;
//     data['image'] = this.image;
//     data['image_path'] = this.imagePath;
//     data['type_mag_id_fk'] = this.typeMagIdFk;
//     data['slab_issue_staus'] = this.slabIssueStaus;
//     data['slab_issue_update_date'] = this.slabIssueUpdateDate;
//     data['slab_issue_add_date'] = this.slabIssueAddDate;
//     data['project_name'] = this.projectName;
//     return data;
//   }
// }

class TemaDetails {
  String? companyId;
  String? compayName;
  String? typeName;
  List<MemberDetails>? memberDetails = [];

  TemaDetails(
      {this.companyId, this.compayName, this.typeName, this.memberDetails});

  TemaDetails.fromJson(Map<String, dynamic> json) {
    companyId = json['company_id'];
    compayName = json['compay_name'];
    typeName = json['type_name'];
    if (json['member_details'] != null) {
      //memberDetails = new List<MemberDetails>();
      json['member_details'].forEach((v) {
        memberDetails?.add(MemberDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company_id'] = companyId;
    data['compay_name'] = compayName;
    data['type_name'] = typeName;
    if (memberDetails != null) {
      data['member_details'] = memberDetails?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberDetails {
  String? memberName;
  String? contactNubmer;
  String? memberId;
  String? designation;
  String? profileImg;

  MemberDetails(
      {this.memberName,
      this.contactNubmer,
      this.memberId,
      this.designation,
      this.profileImg});

  MemberDetails.fromJson(Map<String, dynamic> json) {
    memberName = json['member_name'];
    contactNubmer = json['contact_nubmer'];
    memberId = json['member_id'];
    designation = json['Designation'];
    profileImg = json['profile_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['member_name'] = memberName;
    data['contact_nubmer'] = contactNubmer;
    data['member_id'] = memberId;
    data['Designation'] = designation;
    data['profile_img'] = profileImg;
    return data;
  }
}

class SlabIssueDetails {
  String? mstSlabIssuerReportId;
  String? issueIn;
  String? reports;
  String? extracomment;
  String? submitdate;
  String? resolvedate;
  String? userIdFk;
  String? issueResolve;
  String? slabIssueCheckType;
  String? slabIdFk;
  String? issusInName;
  String? reportedBy;
  String? slabNumber;
  String? reportToName;
  String? reportTo;
  String? issueResolveBtn;
  String? resolvedDate;
  List<String>? image;
  String? imagePath;

  SlabIssueDetails(
      {this.mstSlabIssuerReportId,
      this.issueIn,
      this.reports,
      this.extracomment,
      this.submitdate,
      this.resolvedate,
      this.userIdFk,
      this.issueResolve,
      this.slabIssueCheckType,
      this.slabIdFk,
      this.issusInName,
      this.reportedBy,
      this.slabNumber,
      this.reportToName,
      this.reportTo,
      this.issueResolveBtn,
      this.resolvedDate,
      this.image,
      this.imagePath});

  SlabIssueDetails.fromJson(Map<String, dynamic> json) {
    mstSlabIssuerReportId = json['mst_slab_issuer_report_id'];
    issueIn = json['issue_in'];
    reports = json['reports'];
    extracomment = json['extracomment'];
    submitdate = json['submitdate'];
    resolvedate = json['resolvedate'];
    userIdFk = json['user_id_fk'];
    issueResolve = json['issue_resolve'];
    slabIssueCheckType = json['slab_issue_check_type'];
    slabIdFk = json['slab_id_fk'];
    issusInName = json['issus_in_name'];
    reportedBy = json['reported_by'];
    slabNumber = json['slab_number'];
    reportToName = json['report_to_name'];
    reportTo = json['report_to'];
    issueResolveBtn = json['issue_resolve_btn'];
    resolvedDate = json['resolved_date'];
    image = json['image'].cast<String>();
    imagePath = json['image_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mst_slab_issuer_report_id'] = mstSlabIssuerReportId;
    data['issue_in'] = issueIn;
    data['reports'] = reports;
    data['extracomment'] = extracomment;
    data['submitdate'] = submitdate;
    data['resolvedate'] = resolvedate;
    data['user_id_fk'] = userIdFk;
    data['issue_resolve'] = issueResolve;
    data['slab_issue_check_type'] = slabIssueCheckType;
    data['slab_id_fk'] = slabIdFk;
    data['issus_in_name'] = issusInName;
    data['reported_by'] = reportedBy;
    data['slab_number'] = slabNumber;
    data['report_to_name'] = reportToName;
    data['report_to'] = reportTo;
    data['issue_resolve_btn'] = issueResolveBtn;
    data['resolved_date'] = resolvedDate;
    data['image'] = image;
    data['image_path'] = imagePath;
    return data;
  }
}
