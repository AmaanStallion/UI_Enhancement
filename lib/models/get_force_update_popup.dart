// To parse this JSON data, do
//
//     final webforceupdatepopup = webforceupdatepopupFromJson(jsonString);

import 'dart:convert';

Webforceupdatepopup webforceupdatepopupFromJson(String str) =>
    Webforceupdatepopup.fromJson(json.decode(str));

String webforceupdatepopupToJson(Webforceupdatepopup data) =>
    json.encode(data.toJson());

class Webforceupdatepopup {
  Webforceupdatepopup({
    this.response,
  });

  ResponseWebforceupdatepopup? response;

  factory Webforceupdatepopup.fromJson(Map<String, dynamic> json) =>
      Webforceupdatepopup(
        response: ResponseWebforceupdatepopup.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseWebforceupdatepopup {
  ResponseWebforceupdatepopup({
    this.enabledPopup,
    this.currentVersionIos,
    this.currentVersionAndroid,
    this.underMaintainsForIos,
    this.underMaintainsForAndroid,
    this.macOsMaintains,
    this.macOsVersion,
    this.windowsMaintains,
    this.windowsVersion,
    this.webForceUpdate,
    this.errorCode,
  });

  String? enabledPopup;
  String? currentVersionIos;
  String? currentVersionAndroid;
  String? underMaintainsForIos;
  String? underMaintainsForAndroid;
  String? macOsMaintains;
  String? macOsVersion;
  String? windowsMaintains;
  String? windowsVersion;
  String? webForceUpdate;
  String? errorCode;

  factory ResponseWebforceupdatepopup.fromJson(Map<String, dynamic> json) =>
      ResponseWebforceupdatepopup(
        enabledPopup: json["enabled_popup"],
        currentVersionIos: json["current_version_ios"],
        currentVersionAndroid: json["current_version_android"],
        underMaintainsForIos: json["under_maintains_for_ios"],
        underMaintainsForAndroid: json["under_maintains_for_android"],
        macOsMaintains: json["mac_os_maintains"],
        macOsVersion: json["mac_os_version"],
        windowsMaintains: json["windows_maintains"],
        windowsVersion: json["windows_version"],
        webForceUpdate: json["web_force_update"],
        errorCode: json["error_code"],
      );

  Map<String, dynamic> toJson() => {
        "enabled_popup": enabledPopup,
        "current_version_ios": currentVersionIos,
        "current_version_android": currentVersionAndroid,
        "under_maintains_for_ios": underMaintainsForIos,
        "under_maintains_for_android": underMaintainsForAndroid,
        "mac_os_maintains": macOsMaintains,
        "mac_os_version": macOsVersion,
        "windows_maintains": windowsMaintains,
        "windows_version": windowsVersion,
        "web_force_update": webForceUpdate,
        "error_code": errorCode,
      };
}
