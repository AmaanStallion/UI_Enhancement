// To parse this JSON data, do
//
//     final rccIssueReportDropdownData = rccIssueReportDropdownDataFromJson(jsonString);

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

RccIssueReportDropdownData rccIssueReportDropdownDataFromJson(String str) =>
    RccIssueReportDropdownData.fromJson(json.decode(str));

String rccIssueReportDropdownDataToJson(RccIssueReportDropdownData data) =>
    json.encode(data.toJson());

class RccIssueReportDropdownData {
  RccIssueReportDropdownData({
    required this.response,
  });

  final RccIssueReportDropdownDataResponse response;

  factory RccIssueReportDropdownData.fromJson(Map<String, dynamic> json) =>
      RccIssueReportDropdownData(
        response: RccIssueReportDropdownDataResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response.toJson(),
      };
}

class RccIssueReportDropdownDataResponse {
  RccIssueReportDropdownDataResponse({
    required this.errorCode,
    required this.msg,
    required this.issueIn,
    required this.reportTo,
  });

  final String errorCode;
  final String msg;
  final List<IssueIn> issueIn;
  final List<ReportTo> reportTo;

  factory RccIssueReportDropdownDataResponse.fromJson(
          Map<String, dynamic> json) =>
      RccIssueReportDropdownDataResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        issueIn: List<IssueIn>.from(
            json["issue_in"].map((x) => IssueIn.fromJson(x))),
        reportTo: List<ReportTo>.from(
            json["report_to"].map((x) => ReportTo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "issue_in": List<dynamic>.from(issueIn.map((x) => x.toJson())),
        "report_to": List<dynamic>.from(reportTo.map((x) => x.toJson())),
      };
}

class IssueIn {
  IssueIn({
    required this.issueInId,
    required this.issueInName,
  });

  final String issueInId;
  final String issueInName;

  factory IssueIn.fromJson(Map<String, dynamic> json) => IssueIn(
        issueInId: json["issue_in_id"],
        issueInName: json["issue_in_name"],
      );

  Map<String, dynamic> toJson() => {
        "issue_in_id": issueInId,
        "issue_in_name": issueInName,
      };
}

class ReportTo {
  ReportTo({
    required this.reportToId,
    required this.reportToName,
    this.isSelected = false,
  });

  final String reportToId;
  final String reportToName;
  bool? isSelected = false;

  factory ReportTo.fromJson(Map<String, dynamic> json) => ReportTo(
        reportToId: json["report_to_id"],
        reportToName: json["report_to_name"],
        isSelected: false,
      );

  Map<String, dynamic> toJson() => {
        "report_to_id": reportToId,
        "report_to_name": reportToName,
        "isSelected": isSelected
      };
}

class AddIssue {
  AddIssue({
    required this.issueTextEditingController,
    required this.selectReportingToStrings,
    required this.selectReportingToController,
    this.arrayFiles,
    this.arrayFilesBytes,
  });

  TextEditingController issueTextEditingController;
  String selectReportingToStrings;
  TextEditingController selectReportingToController;
  PlatformFile? arrayFiles;
  List? arrayFilesBytes = [];

  factory AddIssue.fromJson(Map<String, dynamic> json) => AddIssue(
        issueTextEditingController: json["issueTextEditingController"],
        selectReportingToStrings: json["selectReportingToStrings"],
        selectReportingToController: json["selectReportingToController"],
        arrayFiles: json["arrayFiles"],
        arrayFilesBytes: json["arrayFilesBytes"],
      );

  Map<String, dynamic> toJson() => {
        "issueTextEditingController": issueTextEditingController,
        "selectReportingToStrings": selectReportingToStrings,
        "selectReportingToController": selectReportingToController,
        "arrayFiles": arrayFiles,
        "arrayFilesBytes": arrayFilesBytes,
      };
}
