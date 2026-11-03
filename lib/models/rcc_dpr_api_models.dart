// ==========================================
// 1. GET DPRs for Slab (API 1) Models
// ==========================================

class DprListResponse {
  final bool success;
  final String? message;
  final DprListData? data;

  DprListResponse({required this.success, this.message, this.data});

  factory DprListResponse.fromJson(Map<String, dynamic> json) {
    return DprListResponse(
      success: json['success'] == true,
      message: json['message'],
      data: json['data'] != null ? DprListData.fromJson(json['data']) : null,
    );
  }
}

class DprListData {
  final List<DprItem> dprs;
  final DprPagination? pagination;

  DprListData({required this.dprs, this.pagination});

  factory DprListData.fromJson(Map<String, dynamic> json) {
    return DprListData(
      dprs: json['data'] != null
          ? (json['data'] as List).map((i) => DprItem.fromJson(i)).toList()
          : [],
      pagination: json['pagination'] != null
          ? DprPagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class DprPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  DprPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory DprPagination.fromJson(Map<String, dynamic> json) {
    return DprPagination(
      total: _parseInt(json['total']),
      page: _parseInt(json['page']),
      limit: _parseInt(json['limit']),
      totalPages: _parseInt(json['total_pages']),
      hasNextPage: json['has_next_page'] == true,
      hasPreviousPage: json['has_previous_page'] == true,
    );
  }
}

class DprItem {
  final String id;
  final String? developerId;
  final String? projectId;
  final String? slabId;
  final String? dprDate;
  final bool isSubmitted;
  final String? workDescription;
  final int employeeOnSiteTotal;
  final String? issueDescription;
  final String? visitors;
  final bool isDeleted;
  final String? createdBy;
  final String? updatedBy;
  final String? fileUrl;
  final String? fileKey;
  final String? fileName;
  final String? createdAt;
  final String? updatedAt;
  final DprProjectInfo? project;
  final DprSlabInfo? slab;
  final List<DprEmployeeDetail> employeeDetails;
  final List<DprContractorRecord> contractors;
  final List<DprSelectedSkill> selectedSkills;
  final List<DprActivityDetail> activitiesDetails;
  final List<DprTeamMember> teamMembers;
  final List<DprWorkProgress> workProgress;
  final List<DprDocument> documents;
  final DprUser? createdByUser;
  final DprUser? updatedByUser;

  DprItem({
    required this.id,
    this.developerId,
    this.projectId,
    this.slabId,
    this.dprDate,
    required this.isSubmitted,
    this.workDescription,
    this.employeeOnSiteTotal = 0,
    this.issueDescription,
    this.visitors,
    this.isDeleted = false,
    this.createdBy,
    this.updatedBy,
    this.fileUrl,
    this.fileKey,
    this.fileName,
    this.createdAt,
    this.updatedAt,
    this.project,
    this.slab,
    this.employeeDetails = const [],
    this.contractors = const [],
    this.selectedSkills = const [],
    this.activitiesDetails = const [],
    this.teamMembers = const [],
    this.workProgress = const [],
    this.documents = const [],
    this.createdByUser,
    this.updatedByUser,
  });

  factory DprItem.fromJson(Map<String, dynamic> json) {
    return DprItem(
      id: json['id']?.toString() ?? '',
      developerId: json['developer_id']?.toString(),
      projectId: json['project_id']?.toString(),
      slabId: json['slab_id']?.toString(),
      dprDate: json['dpr_date']?.toString(),
      isSubmitted: json['is_submitted'] == true,
      workDescription: json['work_description']?.toString(),
      employeeOnSiteTotal: _parseInt(json['employee_on_site_total']),
      issueDescription: json['issue_description']?.toString(),
      visitors: json['visitors']?.toString(),
      isDeleted: json['is_deleted'] == true,
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      fileUrl: json['file_url']?.toString(),
      fileKey: json['file_key']?.toString(),
      fileName: json['file_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      project: json['project'] != null
          ? DprProjectInfo.fromJson(json['project'])
          : null,
      slab: json['slab'] != null ? DprSlabInfo.fromJson(json['slab']) : null,
      employeeDetails: json['employee_details'] != null
          ? (json['employee_details'] as List)
              .map((i) => DprEmployeeDetail.fromJson(i))
              .toList()
          : [],
      contractors: json['contractors'] != null
          ? (json['contractors'] as List)
              .map((i) => DprContractorRecord.fromJson(i))
              .toList()
          : [],
      selectedSkills: json['selected_skills'] != null
          ? (json['selected_skills'] as List)
              .map((i) => DprSelectedSkill.fromJson(i))
              .toList()
          : [],
      activitiesDetails: json['activities_details'] != null
          ? (json['activities_details'] as List)
              .map((i) => DprActivityDetail.fromJson(i))
              .toList()
          : [],
      teamMembers: json['team_members'] != null
          ? (json['team_members'] as List)
              .map((i) => DprTeamMember.fromJson(i))
              .toList()
          : [],
      workProgress: json['work_progress'] != null
          ? (json['work_progress'] as List)
              .map((i) => DprWorkProgress.fromJson(i))
              .toList()
          : [],
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((i) => DprDocument.fromJson(i))
              .toList()
          : [],
      createdByUser: json['created_by_user'] != null
          ? DprUser.fromJson(json['created_by_user'])
          : null,
      updatedByUser: json['updated_by_user'] != null
          ? DprUser.fromJson(json['updated_by_user'])
          : null,
    );
  }
}

class DprProjectInfo {
  final String id;
  final String name;

  DprProjectInfo({required this.id, required this.name});

  factory DprProjectInfo.fromJson(Map<String, dynamic> json) {
    return DprProjectInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class DprSlabInfo {
  final String id;
  final String name;
  final String? slabNumber;
  final DprTowerInfo? tower;

  DprSlabInfo({required this.id, required this.name, this.slabNumber, this.tower});

  factory DprSlabInfo.fromJson(Map<String, dynamic> json) {
    return DprSlabInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slabNumber: json['slab_number']?.toString(),
      tower: json['tower'] != null ? DprTowerInfo.fromJson(json['tower']) : null,
    );
  }
}

class DprTowerInfo {
  final String id;
  final String name;

  DprTowerInfo({required this.id, required this.name});

  factory DprTowerInfo.fromJson(Map<String, dynamic> json) {
    return DprTowerInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class DprEmployeeDetail {
  final String id;
  final String? dprId;
  final String? dprTypeId;
  final int employeeCount;
  final String? remarks;
  final DprTypeItem? dprType;

  DprEmployeeDetail({
    required this.id,
    this.dprId,
    this.dprTypeId,
    required this.employeeCount,
    this.remarks,
    this.dprType,
  });

  factory DprEmployeeDetail.fromJson(Map<String, dynamic> json) {
    return DprEmployeeDetail(
      id: json['id']?.toString() ?? '',
      dprId: json['dpr_id']?.toString(),
      dprTypeId: json['dpr_type_id']?.toString(),
      employeeCount: _parseInt(json['employee_count']),
      remarks: json['remarks']?.toString(),
      dprType: json['dpr_type'] != null
          ? DprTypeItem.fromJson(json['dpr_type'])
          : null,
    );
  }
}

class DprContractorRecord {
  final String id;
  final String? dprId;
  final String contractorId;
  final int labourCount;
  final ProjectContractorItem? contractor;

  DprContractorRecord({
    required this.id,
    this.dprId,
    required this.contractorId,
    required this.labourCount,
    this.contractor,
  });

  factory DprContractorRecord.fromJson(Map<String, dynamic> json) {
    return DprContractorRecord(
      id: json['id']?.toString() ?? '',
      dprId: json['dpr_id']?.toString(),
      contractorId: json['contractor_id']?.toString() ?? '',
      labourCount: _parseInt(json['labour_count']),
      contractor: json['contractor'] != null
          ? ProjectContractorItem.fromJson(json['contractor'])
          : null,
    );
  }
}

class DprSelectedSkill {
  final String id;
  final String? dprId;
  final String skillId;
  final ContractorSkillItem? skill;

  DprSelectedSkill({
    required this.id,
    this.dprId,
    required this.skillId,
    this.skill,
  });

  factory DprSelectedSkill.fromJson(Map<String, dynamic> json) {
    return DprSelectedSkill(
      id: json['id']?.toString() ?? '',
      dprId: json['dpr_id']?.toString(),
      skillId: json['skill_id']?.toString() ?? '',
      skill: json['skill'] != null
          ? ContractorSkillItem.fromJson(json['skill'])
          : null,
    );
  }
}

class DprActivityDetail {
  final String id;
  final String? dprId;
  final String? towerId;
  final String? parentActivityId;
  final String activityName;
  final String? targetCompletionDate;
  final bool isCompleted;
  final String? completedAt;

  DprActivityDetail({
    required this.id,
    this.dprId,
    this.towerId,
    this.parentActivityId,
    required this.activityName,
    this.targetCompletionDate,
    this.isCompleted = false,
    this.completedAt,
  });

  factory DprActivityDetail.fromJson(Map<String, dynamic> json) {
    return DprActivityDetail(
      id: json['id']?.toString() ?? '',
      dprId: json['dpr_id']?.toString(),
      towerId: json['tower_id']?.toString(),
      parentActivityId: json['parent_activity_id']?.toString(),
      activityName: json['activity_name']?.toString() ?? '',
      targetCompletionDate: json['target_completion_date']?.toString(),
      isCompleted: json['is_completed'] == true,
      completedAt: json['completed_at']?.toString(),
    );
  }
}

class DprTeamMember {
  final String? id;
  final String? dprId;
  final String name;
  final String inTime;
  final String outTime;

  DprTeamMember({
    this.id,
    this.dprId,
    required this.name,
    required this.inTime,
    required this.outTime,
  });

  factory DprTeamMember.fromJson(Map<String, dynamic> json) {
    return DprTeamMember(
      id: json['id']?.toString(),
      dprId: json['dpr_id']?.toString(),
      name: json['name']?.toString() ?? '',
      inTime: json['in_time']?.toString() ?? '',
      outTime: json['out_time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'in_time': inTime,
        'out_time': outTime,
      };
}

class DprWorkProgress {
  final String? id;
  final String? dprId;
  final String progress;

  DprWorkProgress({this.id, this.dprId, required this.progress});

  factory DprWorkProgress.fromJson(Map<String, dynamic> json) {
    return DprWorkProgress(
      id: json['id']?.toString(),
      dprId: json['dpr_id']?.toString(),
      progress: json['progress']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'progress': progress,
      };
}

class DprDocument {
  final String id;
  final String? dprId;
  final String fileName;
  final String? fileKey;
  final String fileUrl;
  final String? mimeType;
  final String? extension;
  final String? fileSize;
  final String? uploadedBy;
  final String? createdAt;

  DprDocument({
    required this.id,
    this.dprId,
    required this.fileName,
    this.fileKey,
    required this.fileUrl,
    this.mimeType,
    this.extension,
    this.fileSize,
    this.uploadedBy,
    this.createdAt,
  });

  factory DprDocument.fromJson(Map<String, dynamic> json) {
    return DprDocument(
      id: json['id']?.toString() ?? '',
      dprId: json['dpr_id']?.toString(),
      fileName: json['file_name']?.toString() ?? '',
      fileKey: json['file_key']?.toString(),
      fileUrl: json['file_url']?.toString() ?? '',
      mimeType: json['mime_type']?.toString(),
      extension: json['extension']?.toString(),
      fileSize: json['file_size']?.toString(),
      uploadedBy: json['uploaded_by']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class DprUser {
  final String id;
  final String name;
  final String? email;

  DprUser({required this.id, required this.name, this.email});

  factory DprUser.fromJson(Map<String, dynamic> json) {
    return DprUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
    );
  }
}

// ==========================================
// 2. Project Contractors (API 2) Models
// ==========================================

class ProjectContractorsResponse {
  final bool success;
  final String? message;
  final ProjectContractorsData? data;

  ProjectContractorsResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ProjectContractorsResponse.fromJson(Map<String, dynamic> json) {
    return ProjectContractorsResponse(
      success: json['success'] == true,
      message: json['message'],
      data: json['data'] != null
          ? ProjectContractorsData.fromJson(json['data'])
          : null,
    );
  }
}

class ProjectContractorsData {
  final int total;
  final List<ProjectContractorItem> contractors;

  ProjectContractorsData({required this.total, required this.contractors});

  factory ProjectContractorsData.fromJson(Map<String, dynamic> json) {
    return ProjectContractorsData(
      total: _parseInt(json['total']),
      contractors: json['contractors'] != null
          ? (json['contractors'] as List)
              .map((i) => ProjectContractorItem.fromJson(i))
              .toList()
          : [],
    );
  }
}

class ProjectContractorItem {
  final String id;
  final String? developerId;
  final String companyName;
  final String? typeOfOrganization;
  final String? contractorTypeId;
  final bool status;
  final String? emailId;
  final String? contactNumber;
  final List<ContractorSkillItem> assignedSkills;
  final List<ContractorEmployeeItem> employees;

  ProjectContractorItem({
    required this.id,
    this.developerId,
    required this.companyName,
    this.typeOfOrganization,
    this.contractorTypeId,
    this.status = true,
    this.emailId,
    this.contactNumber,
    this.assignedSkills = const [],
    this.employees = const [],
  });

  factory ProjectContractorItem.fromJson(Map<String, dynamic> json) {
    return ProjectContractorItem(
      id: json['id']?.toString() ?? '',
      developerId: json['developer_id']?.toString(),
      companyName: json['company_name']?.toString() ?? json['name']?.toString() ?? '',
      typeOfOrganization: json['type_of_organization']?.toString(),
      contractorTypeId: json['contractor_type_id']?.toString(),
      status: json['status'] == true || json['status'] == 1,
      emailId: json['email_id']?.toString(),
      contactNumber: json['contact_number']?.toString(),
      assignedSkills: json['assigned_skills'] != null
          ? (json['assigned_skills'] as List)
              .map((i) => ContractorSkillItem.fromJson(i))
              .toList()
          : [],
      employees: json['employees'] != null
          ? (json['employees'] as List)
              .map((i) => ContractorEmployeeItem.fromJson(i))
              .toList()
          : [],
    );
  }
}

class ContractorSkillItem {
  final String id;
  final String name;
  final String? finishingType;
  final String? budgetType;

  ContractorSkillItem({
    required this.id,
    required this.name,
    this.finishingType,
    this.budgetType,
  });

  factory ContractorSkillItem.fromJson(Map<String, dynamic> json) {
    return ContractorSkillItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      finishingType: json['finishing_type']?.toString(),
      budgetType: json['budget_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class ContractorEmployeeItem {
  final String id;
  final String? parentContractorId;
  final String? contractorUserId;
  final String name;
  final String? contactNumber;
  final String? designation;

  ContractorEmployeeItem({
    required this.id,
    this.parentContractorId,
    this.contractorUserId,
    required this.name,
    this.contactNumber,
    this.designation,
  });

  factory ContractorEmployeeItem.fromJson(Map<String, dynamic> json) {
    return ContractorEmployeeItem(
      id: json['id']?.toString() ?? '',
      parentContractorId: json['parent_contractor_id']?.toString(),
      contractorUserId: json['contractor_user_id']?.toString(),
      name: json['name']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString(),
      designation: json['designation']?.toString(),
    );
  }
}

// ==========================================
// 3. DPR Types (API 3) Models
// ==========================================

class DprTypesResponse {
  final bool success;
  final String? message;
  final DprTypesData? data;

  DprTypesResponse({required this.success, this.message, this.data});

  factory DprTypesResponse.fromJson(Map<String, dynamic> json) {
    return DprTypesResponse(
      success: json['success'] == true,
      message: json['message'],
      data: json['data'] != null ? DprTypesData.fromJson(json['data']) : null,
    );
  }
}

class DprTypesData {
  final int total;
  final DprProjectInfo? project;
  final List<DprTypeItem> dprTypes;

  DprTypesData({required this.total, this.project, required this.dprTypes});

  factory DprTypesData.fromJson(Map<String, dynamic> json) {
    return DprTypesData(
      total: _parseInt(json['total'] ?? json['count']),
      project: json['project'] != null
          ? DprProjectInfo.fromJson(json['project'])
          : null,
      dprTypes: json['dpr_types'] != null
          ? (json['dpr_types'] as List)
              .map((i) => DprTypeItem.fromJson(i))
              .toList()
          : [],
    );
  }
}

class DprTypeItem {
  final String id;
  final String? developerId;
  final String source; // "global" or "custom"
  final String name;
  final String? description;
  final bool createdByMobile;
  final bool isActive;
  final bool isDeleted;

  DprTypeItem({
    required this.id,
    this.developerId,
    required this.source,
    required this.name,
    this.description,
    this.createdByMobile = false,
    this.isActive = true,
    this.isDeleted = false,
  });

  factory DprTypeItem.fromJson(Map<String, dynamic> json) {
    return DprTypeItem(
      id: json['id']?.toString() ?? '',
      developerId: json['developer_id']?.toString(),
      source: json['source']?.toString() ?? 'global',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      createdByMobile: json['created_by_mobile'] == true,
      isActive: json['is_active'] != false,
      isDeleted: json['is_deleted'] == true,
    );
  }
}

// ==========================================
// Helper Utility for JSON Parsing
// ==========================================

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

// ==========================================
// DPR Payload Diff Computation for PUT API
// ==========================================

Map<String, dynamic> computeDprDiffPayload({
  required DprItem original,
  required Map<String, dynamic> currentPayload,
  required bool isSubmitted,
}) {
  final Map<String, dynamic> diff = {
    'is_submitted': isSubmitted,
  };

  // 1. DPR Date
  final String currentDate = (currentPayload['dpr_date'] ?? '').toString();
  final String origDate = (original.dprDate ?? '').split('T')[0].split(' ')[0];
  if (currentDate.isNotEmpty && currentDate != origDate) {
    diff['dpr_date'] = currentDate;
  }

  // 2. Work Description
  final String currentWork = (currentPayload['work_description'] ?? '').toString().trim();
  final String origWork = (original.workDescription ?? '').trim();
  if (currentWork != origWork) {
    diff['work_description'] = currentWork;
  }

  // 3. Issue Description
  final String currentIssue = (currentPayload['issue_description'] ?? '').toString().trim();
  final String origIssue = (original.issueDescription ?? '').trim();
  if (currentIssue != origIssue) {
    diff['issue_description'] = currentIssue;
  }

  // 4. Visitors
  final String currentVisitors = (currentPayload['visitors'] ?? '').toString().trim();
  final String origVisitors = (original.visitors ?? '').trim();
  if (currentVisitors != origVisitors) {
    diff['visitors'] = currentVisitors;
  }

  // 5. Contractors
  final List<dynamic> currentContractors =
      currentPayload['contractors'] as List<dynamic>? ?? [];
  bool contractorsChanged = currentContractors.length != original.contractors.length;
  if (!contractorsChanged) {
    for (final c in currentContractors) {
      final cId = (c['contractor_id'] ?? '').toString();
      final lCount = int.tryParse((c['labour_count'] ?? '0').toString()) ?? 0;
      final origMatch = original.contractors.firstWhere(
        (o) => o.contractorId.toString() == cId,
        orElse: () => DprContractorRecord(id: '', contractorId: '', labourCount: -1),
      );
      if (origMatch.contractorId.isEmpty || origMatch.labourCount != lCount) {
        contractorsChanged = true;
        break;
      }
    }
  }
  if (contractorsChanged) {
    diff['contractors'] = currentContractors;
  }

  // 6. Selected Skills
  final List<dynamic> currentSkills =
      currentPayload['selected_skills'] as List<dynamic>? ?? [];
  final Set<String> currentSkillSet = currentSkills.map((e) => e.toString()).toSet();
  final Set<String> origSkillSet = original.selectedSkills.map((e) => e.skillId.toString()).toSet();
  if (currentSkillSet.length != origSkillSet.length ||
      !currentSkillSet.containsAll(origSkillSet) ||
      !origSkillSet.containsAll(currentSkillSet)) {
    diff['selected_skills'] = currentSkills;
  }

  // 7. Employee Details
  final List<dynamic> currentEmpList =
      currentPayload['employee_details'] as List<dynamic>? ?? [];
  bool empChanged = currentEmpList.length != original.employeeDetails.length;
  if (!empChanged) {
    for (final emp in currentEmpList) {
      final dprTypeId = (emp['dpr_type_id'] ?? '').toString();
      final name = (emp['name'] ?? '').toString().toLowerCase().trim();
      final count = int.tryParse((emp['employee_count'] ?? '0').toString()) ?? 0;
      final remarks = (emp['remarks'] ?? '').toString().trim();

      final origMatch = original.employeeDetails.firstWhere(
        (o) =>
            (dprTypeId.isNotEmpty && o.dprTypeId.toString() == dprTypeId) ||
            (name.isNotEmpty && o.dprType?.name.toLowerCase().trim() == name),
        orElse: () => DprEmployeeDetail(id: '', employeeCount: -1, remarks: null),
      );

      if (origMatch.id.isEmpty ||
          origMatch.employeeCount != count ||
          (origMatch.remarks ?? '').trim() != remarks) {
        empChanged = true;
        break;
      }
    }
  }
  if (empChanged) {
    diff['employee_details'] = currentEmpList;
  }

  // 8. Team Members
  final List<dynamic> currentTeam =
      currentPayload['team_members'] as List<dynamic>? ?? [];
  bool teamChanged = currentTeam.length != original.teamMembers.length;
  if (!teamChanged) {
    for (int i = 0; i < currentTeam.length; i++) {
      final cName = (currentTeam[i]['name'] ?? '').toString().trim();
      final cIn = (currentTeam[i]['in_time'] ?? '').toString().trim();
      final cOut = (currentTeam[i]['out_time'] ?? '').toString().trim();

      final oMember = original.teamMembers[i];
      if (cName != oMember.name.trim() ||
          cIn != oMember.inTime.trim() ||
          cOut != oMember.outTime.trim()) {
        teamChanged = true;
        break;
      }
    }
  }
  if (teamChanged) {
    diff['team_members'] = currentTeam;
  }

  // 9. Activities
  final List<dynamic> currentActs =
      currentPayload['activities'] as List<dynamic>? ?? [];
  bool actsChanged = currentActs.length != original.activitiesDetails.length;
  if (!actsChanged) {
    for (int i = 0; i < currentActs.length; i++) {
      final cName = (currentActs[i]['activity_name'] ?? '').toString().trim();
      final cDate = (currentActs[i]['target_completion_date'] ?? '').toString().trim();
      final cComp = currentActs[i]['is_completed'] == true;

      final oAct = original.activitiesDetails[i];
      final oDate = (oAct.targetCompletionDate ?? '').split('T')[0].split(' ')[0].trim();

      if (cName != oAct.activityName.trim() ||
          (cDate.isNotEmpty && cDate != oDate) ||
          cComp != oAct.isCompleted) {
        actsChanged = true;
        break;
      }
    }
  }
  if (actsChanged) {
    diff['activities'] = currentActs;
  }

  // 10. Work Progress
  final List<dynamic> currentWp =
      currentPayload['work_progress'] as List<dynamic>? ?? [];
  bool wpChanged = currentWp.length != original.workProgress.length;
  if (!wpChanged) {
    for (int i = 0; i < currentWp.length; i++) {
      final cProg = (currentWp[i]['progress'] ?? '').toString().trim();
      final oProg = original.workProgress[i].progress.trim();
      if (cProg != oProg) {
        wpChanged = true;
        break;
      }
    }
  }
  if (wpChanged) {
    diff['work_progress'] = currentWp;
  }

  return diff;
}
