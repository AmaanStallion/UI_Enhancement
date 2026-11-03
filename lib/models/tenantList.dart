// To parse this JSON data, do
//
//     final tenantList = tenantListFromJson(jsonString);

import 'dart:convert';

TenantList tenantListFromJson(String str) =>
    TenantList.fromJson(json.decode(str));

String tenantListToJson(TenantList data) => json.encode(data.toJson());

class TenantList {
  ResponseTenantList? response;

  TenantList({
    this.response,
  });

  factory TenantList.fromJson(Map<String, dynamic> json) => TenantList(
        response: json["Response"] == null
            ? null
            : ResponseTenantList.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseTenantList {
  String? errorCode;
  String? msg;
  String? offset;
  List<FilterArr>? filterArr;
  String? totalTenants;
  String? signedConsents;
  String? registeredPaa;
  List<TenantListElement>? tenantList;
  String? type;
  String? transitCount;
  String? rentalCount;
  String? tenantLink;

  ResponseTenantList({
    this.errorCode,
    this.msg,
    this.offset,
    this.filterArr,
    this.totalTenants,
    this.signedConsents,
    this.registeredPaa,
    this.tenantList,
    this.type,
    this.transitCount,
    this.rentalCount,
    this.tenantLink,
  });

  factory ResponseTenantList.fromJson(Map<String, dynamic> json) =>
      ResponseTenantList(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        filterArr: json["filter_arr"] == null
            ? []
            : List<FilterArr>.from(
                json["filter_arr"]!.map((x) => FilterArr.fromJson(x))),
        totalTenants: json["total_tenants"],
        signedConsents: json["signed_consents"],
        registeredPaa: json["registered_paa"],
        type: json["type"],
        tenantList: json["tenant_list"] == null
            ? []
            : List<TenantListElement>.from(
                json["tenant_list"]!.map((x) => TenantListElement.fromJson(x))),
        transitCount: json["transit_count"],
        rentalCount: json["rental_count"],
        tenantLink: json["tenant_link"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "filter_arr": filterArr == null
            ? []
            : List<dynamic>.from(filterArr!.map((x) => x.toJson())),
        "total_tenants": totalTenants,
        "signed_consents": signedConsents,
        "registered_paa": registeredPaa,
        "type": type,
        "tenant_list": tenantList == null
            ? []
            : List<dynamic>.from(tenantList!.map((x) => x.toJson())),
        "transit_count": transitCount,
        "rental_count": rentalCount,
        "tenant_link": tenantLink,
      };
}

class FilterArr {
  String? id;
  String? title;
  String? type;

  FilterArr({
    this.id,
    this.title,
    this.type,
  });

  factory FilterArr.fromJson(Map<String, dynamic> json) => FilterArr(
        id: json["id"],
        title: json["title"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "type": type,
      };
}

class TenantListElement {
  String? tenantId;
  String? tenantName;
  String? mobile;
  String? email;
  String? roomNo;
  String? obtain;
  ObtainName? obtainName;
  String? userResidnt;
  String? userResidntName;
  String? numberAllocated;
  String? numberAllocatedDetails;
  String? categoryIdFk;
  String? areaInSqft;
  String? proposedAreaInSqft;
  String? totalNumberOfYear;
  String? monthRent;
  String? categoryName;
  String? docName1;
  String? docName2;
  String? docName3;
  String? docName4;
  String? docName5;
  List<dynamic>? details;
  String? monthRentGrandTot;
  String? brokerage;
  String? shiftingCharges;
  String? demolitionDt;
  String? tenantFlagOpt;
  String? labelColor;
  String? corpusAmount;

  TenantListElement({
    this.tenantId,
    this.tenantName,
    this.mobile,
    this.email,
    this.roomNo,
    this.obtain,
    this.obtainName,
    this.userResidnt,
    this.userResidntName,
    this.numberAllocated,
    this.numberAllocatedDetails,
    this.categoryIdFk,
    this.areaInSqft,
    this.proposedAreaInSqft,
    this.totalNumberOfYear,
    this.monthRent,
    this.categoryName,
    this.docName1,
    this.docName2,
    this.docName3,
    this.docName4,
    this.docName5,
    this.details,
    this.monthRentGrandTot,
    this.brokerage,
    this.shiftingCharges,
    this.demolitionDt,
    this.tenantFlagOpt,
    this.labelColor,
    this.corpusAmount,
  });

  factory TenantListElement.fromJson(Map<String, dynamic> json) =>
      TenantListElement(
        tenantId: json["tenant_id"],
        tenantName: json["tenant_name"],
        mobile: json["mobile"],
        email: json["email"],
        roomNo: json["room_no"],
        obtain: json["obtain"],
        obtainName: obtainNameValues.map[json["obtain_name"]],
        userResidnt: json["user_residnt"],
        userResidntName: json["user_residnt_name"],
        numberAllocated: json["number_allocated"],
        numberAllocatedDetails: json["number_allocated_details"],
        categoryIdFk: json["category_id_fk"],
        areaInSqft: json["area_in_sqft"],
        proposedAreaInSqft: json["proposed_area_in_sqft"],
        totalNumberOfYear: json["total_number_of_year"],
        monthRent: json["month_rent"],
        categoryName: json["category_name"],
        docName1: json["doc_name_1"],
        docName2: json["doc_name_2"],
        docName3: json["doc_name_3"],
        docName4: json["doc_name_4"],
        docName5: json["doc_name_5"],
        details: json["details"] == null
            ? []
            : List<dynamic>.from(json["details"]!.map((x) => x)),
        monthRentGrandTot: json["month_rent_grand_tot"],
        brokerage: json["brokerage"],
        shiftingCharges: json["shifting_charges"],
        demolitionDt: json["demolition_dt"],
        tenantFlagOpt: json["tenant_flag_opt"],
        labelColor: json["label_color"],
        corpusAmount: json["corpus_amount"],
      );

  Map<String, dynamic> toJson() => {
        "tenant_id": tenantId,
        "tenant_name": tenantName,
        "mobile": mobile,
        "email": email,
        "room_no": roomNo,
        "obtain": obtain,
        "obtain_name": obtainNameValues.reverse[obtainName],
        "user_residnt": userResidnt,
        "user_residnt_name": userResidntName,
        "number_allocated": numberAllocated,
        "number_allocated_details": numberAllocatedDetails,
        "category_id_fk": categoryIdFk,
        "area_in_sqft": areaInSqft,
        "proposed_area_in_sqft": proposedAreaInSqft,
        "total_number_of_year": totalNumberOfYear,
        "month_rent": monthRent,
        "category_name": categoryName,
        "doc_name_1": docName1,
        "doc_name_2": docName2,
        "doc_name_3": docName3,
        "doc_name_4": docName4,
        "doc_name_5": docName5,
        "details":
            details == null ? [] : List<dynamic>.from(details!.map((x) => x)),
        "month_rent_grand_tot": monthRentGrandTot,
        "brokerage": brokerage,
        "shifting_charges": shiftingCharges,
        "demolition_dt": demolitionDt,
        "tenant_flag_opt": tenantFlagOpt,
        "label_color": labelColor,
        "corpus_amount": corpusAmount,
      };
}

enum ObtainName { RENT }

final obtainNameValues = EnumValues({"Rent": ObtainName.RENT});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
