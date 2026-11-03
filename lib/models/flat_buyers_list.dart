class BuyerListDetail {
  String? buyer_name;
  String? mobile_number;
  String? emailid;
  String? address;
  String? flatNo;
  String? flatArea;
  String? flat_id;
  String? index;
  String? pan;
  String? aadhar;
  String? aadharfileName;
  String? panfileName;


  BuyerListDetail({
    this.buyer_name,
    this.mobile_number,
    this.emailid,
    this.address,
    this.flatNo,
    this.flatArea,
    this.flat_id,
    this.index,
    this.pan,
    this.aadhar,
    this.aadharfileName,
    this.panfileName,
  });

  factory BuyerListDetail.fromJson(Map<String, dynamic> json) => BuyerListDetail(
    buyer_name: json["buyer_name"],
    mobile_number: json["mobile_number"],
    emailid: json["emailid"],
    address: json["address"],
    flatNo: json["flatNo"],
    flatArea: json["flatArea"],
    flat_id: json["flat_id"],
    index: json["index"],
    pan: json["pan"],
    aadhar: json["aadhar"],
    aadharfileName: json["aadharfileName"],
    panfileName: json["panfileName"],
  );

  Map<String, dynamic> toJson() => {
    "buyer_name": buyer_name,
    "mobile_number": mobile_number,
    "emailid": emailid,
    "address": address,
    "flatNo": flatNo,
    "flatArea": flatArea,
    "flat_id": flat_id,
    "index": index,
    "pan": pan,
    "aadhar": aadhar,
    "panfileName": panfileName,
    "aadharfileName": aadharfileName,
  };
}