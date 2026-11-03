import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stallion/models/flat_buyer_upload_files.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/ui/views/salesmanagement/setLeasePaymentTermsView.dart';
import 'package:stallion/ui/views/salesmanagement/setpaymenttermsview.dart';
import '../../../models/flat_buyers_list.dart';
import '../../../models/get_flat_list_by_project.dart';
import '../../shared/ui_helpers.dart';

class BuyerDetailsViewEndBuyer extends StatefulWidget {
  BuyerDetailsViewEndBuyer({
    Key? key,
    this.projectName,
    this.projectId,
    this.towarId,
    this.buyerName,
    this.buyerEmail,
    this.flaginvestor,
    this.buyerMobileNumber,
    this.flatArea,
    this.strFinishingTypeSelected,
    this.arrSelectedFlatForSaleList,
    this.strParkingID,
    this.strNoOfParking,
    this.strAadharCardNo,
    this.strPanCardNo,
    this.arrSelectedParkingList,
    this.strSalesLeadId,
    this.strFlatValue,
    this.strFlatArea,
    this.strRateSqFt,
    this.RatePerSqFt,
    this.strGSTValue,
    this.TotalValue,
    this.strMarketValue,
    this.strSDValue,
    this.strStampDutyFlag,
    this.arrCharges,
    this.strBuyerID,
    this.strBrokerIDSelected,
    this.strBrokerPercentage,
    this.fundingType,
    this.strRemark,
    this.towarName = "",
    this.arr_buyer_flatlist,
    this.flatNumber,
    required this.tdsPercentage,
    required this.tdsValue,
    required this.gst_percentage,
    required this.gst_value,
    this.txtControllerLeaseValueMonthly,
    this.txtControllerLeaseValueYearly,
  }) : super(key: key);

  final List<FlatBuyerInfo>? arr_buyer_flatlist;
  final String? flatNumber;
  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? buyerName;
  String? buyerEmail;
  final String? buyerMobileNumber;
  final String? flaginvestor;
  final double? flatArea;
  final String? strNoOfParking;
  final String? strFinishingTypeSelected;
  final String? strParkingID;
  final String? strPanCardNo;
  final String? strAadharCardNo;
  final String? strSalesLeadId;
  final double? RatePerSqFt;
  final String? strFlatValue;
  final String? strFlatArea;
  final String? strRateSqFt;
  final String? strGSTValue;
  final String? strSDValue;
  final String? TotalValue;
  final String? strMarketValue;
  final String? strStampDutyFlag;
  final String? strBuyerID;
  final String? strBrokerIDSelected;
  final String? strBrokerPercentage;
  List<CustomCharge>? arrCharges;
  List<FlatList>? arrSelectedFlatForSaleList;
  List<ParkingList>? arrSelectedParkingList;
  final String? fundingType;
  final String? strRemark;
  final String? towarName;
  final String? tdsPercentage;
  final String? tdsValue;
  final String? gst_percentage;
  final String? gst_value;
  final String? txtControllerLeaseValueMonthly;
  final String? txtControllerLeaseValueYearly;

  @override
  State<BuyerDetailsViewEndBuyer> createState() => _BuyerDetailsViewState();
}

class _BuyerDetailsViewState extends State<BuyerDetailsViewEndBuyer> {
  //TextEditingController txtControllerAadharCard = TextEditingController();
  //TextEditingController txtControllerPanCard = TextEditingController();
  //TextEditingController txtControllerAddress = TextEditingController();
  TextEditingController bankNameControler = TextEditingController();
  TextEditingController accountHolderControler = TextEditingController();
  TextEditingController accountNoControler = TextEditingController();
  TextEditingController ifscCodeControler = TextEditingController();
  TextEditingController branchNameControler = TextEditingController();

  List<TextEditingController> arrtxtControllerAadharCard = [];
  List<TextEditingController> arrtxtControllerPanCard = [];
  List<TextEditingController> arrtxtControllerAddress = [];
  List<TextEditingController> arrtxtControllerName = [];
  List<TextEditingController> arrtxtControllerEmail = [];
  List<TextEditingController> arrtxtControllerMobileNo = [];

  List<PlatformFile>? arrayAadharFiles = [];
  List<Uint8List>? arrayAadharFilesBytes = [];
  List<PlatformFile>? arrayPanCardFiles = [];
  List<Uint8List>? arrayPanCardFilesBytes = [];

  List<BuyerListDetail>? arrBuyerDetails = [];

  List<BuyerUploadFiles>? arrAadharFilesUpload = [];
  List<BuyerUploadFiles>? arrPanFilesUpload = [];

  //var aadharFileName = '';
  //var pancardFileName = '';

  List<String>? listaadharFileName = [];
  List<String>? listpancardFileName = [];

  @override
  void initState() {
    super.initState();

    if (widget.flaginvestor == '0') {
      var dict = BuyerListDetail(
        buyer_name: widget.buyerName!,
        mobile_number: widget.buyerMobileNumber!,
        emailid: widget.buyerEmail!,
        address: "",
        flatNo: widget.flatNumber!,
        flatArea: "",
        flat_id: "",
        index: "0",
        pan: "",
        aadhar: "",
        aadharfileName: "",
        panfileName: "",
      );
      arrBuyerDetails?.add(dict);
    } else {
      for (int i = 0; i < widget.arrSelectedFlatForSaleList!.length; i++) {
        var dict = BuyerListDetail(
          buyer_name: "",
          mobile_number: widget.arrSelectedFlatForSaleList![i].mobile_number,
          emailid: widget.arrSelectedFlatForSaleList![i].emailid,
          address: widget.arrSelectedFlatForSaleList![i].address,
          flatNo: widget.arrSelectedFlatForSaleList![i].flatName,
          flatArea: widget.arrSelectedFlatForSaleList![i].flatArea,
          flat_id: widget.arrSelectedFlatForSaleList![i].flatId,
          index: "$i",
          pan: "",
          aadhar: widget.arrSelectedFlatForSaleList![i].aadhar,
          aadharfileName: "",
          panfileName: "",
        );
        arrBuyerDetails?.add(dict);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),

            // widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              itemCount: widget.flaginvestor == '0'
                  ? widget.arr_buyer_flatlist!.length
                  : widget.arrSelectedFlatForSaleList?.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.flaginvestor == '0'
                        ? [
                            verticalSpaceSmall15,
                            // widget.flaginvestor == '0'
                            //     ?
                            _flatNumber(widget.flatNumber),
                            // : _flatNumber(widget
                            //     .arrSelectedFlatForSaleList?[index]
                            //     .inventryFlatName),
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("Buyer's Name",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        controller:
                                            //  widget
                                            //     .arr_buyer_flatlist?[index]
                                            //     .textEditingController,
                                            TextEditingController(
                                                text: widget
                                                    .arr_buyer_flatlist?[index]
                                                    .buyerName),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter Buyer Name',
                                        ),
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .buyerName = str;
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("Email",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: widget
                                                .arr_buyer_flatlist?[index]
                                                .emailId),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter Email Address',
                                        ),
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .emailId = str;
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("Mobile Number",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: widget
                                                .arr_buyer_flatlist?[index]
                                                .mobileNumber),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter Mobile Number',
                                        ),
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .mobileNumber = str;
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("Adhar Card No.",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: widget
                                                .arr_buyer_flatlist?[index]
                                                .aadhar),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText:
                                              'Enter Adhar Card No. (Optional)',
                                        ),
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .aadhar = str;
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 240.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'jpg',
                                          'jpeg',
                                          'png',
                                          'JPG',
                                          'JPEG',
                                          'PNG',
                                          "pdf"
                                        ],
                                      );
                                      if (result != null) {
                                        PlatformFile file = result.files.first;
                                        print("FILE SELECTED");
                                        print(file.name);
                                        print(file.bytes);
                                        print(file.size);
                                        print(file.extension);
                                        print(file.path);
                                        //Uint8List? fileBytes = result.files.first.bytes;
                                        //String fileName = result.files.first.name;
                                        //arrayAadharFilesBytes?.add(fileBytes!);

                                        arrAadharFilesUpload?.add(
                                            BuyerUploadFiles(
                                                name: file.name,
                                                index: index,
                                                imageData: file));

                                        arrayAadharFiles?.add(file);
                                        // arrBuyerDetails![index].aadharfileName =
                                        //     file.name;
                                        setState(() {});
                                      } else {
                                        // User canceled the picker
                                      }
                                    },
                                    child: Container(
                                      width: 200,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      child: const Text(
                                        'Upload Aadhaar Card',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                // Text(arrBuyerDetails?[index].aadharfileName ??
                                //     ''),
                              ],
                            ),
                            verticalSpaceSmall15,
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("Pan Card No.",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: widget
                                                .arr_buyer_flatlist?[index]
                                                .pan),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText:
                                              'Enter Pan Card No. (Optional)',
                                        ),
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .pan = str;
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 240.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'jpg',
                                          'jpeg',
                                          'png',
                                          'JPG',
                                          'JPEG',
                                          'PNG',
                                          "pdf"
                                        ],
                                      );
                                      if (result != null) {
                                        PlatformFile file = result.files.first;
                                        print("FILE SELECTED");
                                        print(file.name);
                                        print(file.bytes);
                                        print(file.size);
                                        print(file.extension);
                                        print(file.path);
                                        //Uint8List? fileBytes = result.files.first.bytes;
                                        //String fileName = result.files.first.name;
                                        //arrayAadharFilesBytes?.add(fileBytes!);

                                        arrAadharFilesUpload?.add(
                                            BuyerUploadFiles(
                                                name: file.name,
                                                index: index,
                                                imageData: file));

                                        arrayAadharFiles?.add(file);
                                        // arrBuyerDetails![index].aadharfileName =
                                        //     file.name;
                                        setState(() {});
                                      } else {
                                        // User canceled the picker
                                      }
                                    },
                                    child: Container(
                                      width: 200,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      child: const Text(
                                        'Upload Pan Card',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                // Text(arrBuyerDetails![index].aadharfileName!),
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("GST No.",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .gstno = str;
                                        },
                                        controller: TextEditingController(
                                            text: widget
                                                .arr_buyer_flatlist?[index]
                                                .gstno),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter GST No.',
                                        ),
                                        // onChanged: (String str) {
                                        //   widget.arr_buyer_flatlist?[index]
                                        //       .address = str;
                                        // },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("Address",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: widget
                                                .arr_buyer_flatlist?[index]
                                                .address),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText: 'Flat No./Building',
                                        ),
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .address = str;
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: widget
                                                .arr_buyer_flatlist?[index]
                                                .address1),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText: 'Area/Street/Location',
                                        ),
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .address1 = str;
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            verticalSpaceSmall15,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 230.0,
                                  height: 40.0,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("",
                                        style: TextStyle(
                                            backgroundColor: Colors.white,
                                            fontSize: 15,
                                            color: Colors.black)),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Container(
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                        color: kcTextFieldColor,
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: TextField(
                                        controller: TextEditingController(
                                            text: widget
                                                .arr_buyer_flatlist?[index]
                                                .address2),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 18.0),
                                          border: InputBorder.none,
                                          hintText: 'City / State / Pin Code',
                                        ),
                                        onChanged: (String str) {
                                          widget.arr_buyer_flatlist?[index]
                                              .address2 = str;
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            // _buyerName(index),
                            // verticalSpaceSmall15,
                            // _buyerEmail(index),
                            // verticalSpaceSmall15,
                            // _buyerMobileNumber(index),
                            // verticalSpaceSmall15,
                            // _buyerAadharCardNo(index),
                            // verticalSpaceSmall15,
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: [
                            //     Padding(
                            //       padding: const EdgeInsets.only(left: 240.0),
                            //       child: GestureDetector(
                            //         onTap: () async {
                            //           FilePickerResult? result =
                            //               await FilePicker.platform.pickFiles(
                            //             type: FileType.custom,
                            //             allowedExtensions: [
                            //               'jpg',
                            //               'jpeg',
                            //               'png',
                            //               'JPG',
                            //               'JPEG',
                            //               'PNG',
                            //               "pdf"
                            //             ],
                            //           );
                            //           if (result != null) {
                            //             PlatformFile file = result.files.first;
                            //             print("FILE SELECTED");
                            //             print(file.name);
                            //             print(file.bytes);
                            //             print(file.size);
                            //             print(file.extension);
                            //             print(file.path);
                            //             //Uint8List? fileBytes = result.files.first.bytes;
                            //             //String fileName = result.files.first.name;
                            //             //arrayAadharFilesBytes?.add(fileBytes!);

                            //             arrAadharFilesUpload?.add(BuyerUploadFiles(
                            //                 name: file.name,
                            //                 index: index,
                            //                 imageData: file));

                            //             arrayAadharFiles?.add(file);
                            //             arrBuyerDetails![index].aadharfileName =
                            //                 file.name;
                            //             setState(() {});
                            //           } else {
                            //             // User canceled the picker
                            //           }
                            //         },
                            //         child: Container(
                            //           width: 200,
                            //           height: 40,
                            //           alignment: Alignment.center,
                            //           decoration: BoxDecoration(
                            //             color: Colors.black,
                            //             borderRadius: BorderRadius.circular(7.0),
                            //           ),
                            //           child: const Text(
                            //             'Upload Aadhaar Card',
                            //             style: TextStyle(
                            //               color: Colors.white,
                            //               fontSize: 15.0,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //     horizontalSpaceSmall,
                            //     Text(arrBuyerDetails![index].aadharfileName!),
                            //   ],
                            // ),
                            // verticalSpaceSmall15,
                            // _buyerPanCardNo(index),
                            // verticalSpaceSmall15,
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: [
                            //     Padding(
                            //       padding: const EdgeInsets.only(left: 240.0),
                            //       child: GestureDetector(
                            //         onTap: () async {
                            //           FilePickerResult? result =
                            //               await FilePicker.platform.pickFiles(
                            //             type: FileType.custom,
                            //             allowedExtensions: [
                            //               'jpg',
                            //               'jpeg',
                            //               'png',
                            //               'JPG',
                            //               'JPEG',
                            //               'PNG',
                            //               "pdf"
                            //             ],
                            //           );
                            //           if (result != null) {
                            //             PlatformFile file = result.files.first;
                            //             print("FILE SELECTED");
                            //             print(file.name);
                            //             print(file.bytes);
                            //             print(file.size);
                            //             print(file.extension);
                            //             print(file.path);
                            //             //Uint8List? fileBytes = result.files.first.bytes;
                            //             //String fileName = result.files.first.name;
                            //             //arrayAadharFilesBytes?.add(fileBytes!);

                            //             arrPanFilesUpload?.add(BuyerUploadFiles(
                            //                 name: file.name,
                            //                 index: index,
                            //                 imageData: file));

                            //             arrayPanCardFiles?.add(file);
                            //             arrBuyerDetails![index].panfileName =
                            //                 file.name;
                            //             setState(() {});
                            //           } else {
                            //             // User canceled the picker
                            //           }
                            //         },
                            //         child: Container(
                            //           width: 200,
                            //           height: 40,
                            //           alignment: Alignment.center,
                            //           decoration: BoxDecoration(
                            //             color: Colors.black,
                            //             borderRadius: BorderRadius.circular(7.0),
                            //           ),
                            //           child: const Text(
                            //             'Upload Pan Card',
                            //             style: TextStyle(
                            //               color: Colors.white,
                            //               fontSize: 15.0,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //     horizontalSpaceSmall,
                            //     Text(arrBuyerDetails![index].panfileName!),
                            //   ],
                            // ),
                            // verticalSpaceSmall15,
                            // _buyerAddress(index),
                            verticalSpaceSmall15,
                            // const Divider(height: 1.0, color: Colors.black),
                            const SizedBox(height: 20),
                            Container(
                              // padding: const EdgeInsets.only(left: 60),
                              width: double.maxFinite,
                              child: const Text(
                                "Bank Details",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            // textAndInput(
                            //   controllerText: bankNameControler,
                            //   // isRequired: true,
                            //   title: "Bank Name ",
                            //   hintText: 'Enter Bank Name',
                            //   // validator: (value) {
                            //   //   if (value!.isEmpty) {
                            //   //     return "(Buyer Name Cannot Be Empty)";
                            //   //   }
                            //   // },
                            // ),
                            Row(
                              children: [
                                Container(
                                  // padding: const EdgeInsets.only(left: 60),
                                  width: 230.0,
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'HelveticaNeue'),
                                      children: [
                                        TextSpan(
                                          text: 'Bank Name',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'HelveticaNeue'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  // width: MediaQuery.of(context).size.width * 0.74,
                                  child: TextFormField(
                                    onChanged: ((value) {
                                      widget.arr_buyer_flatlist?[index]
                                          .bankName = value;
                                    }),
                                    style: const TextStyle(fontSize: 13),
                                    controller: TextEditingController(
                                        text: widget.arr_buyer_flatlist?[index]
                                            .bankName),
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        )),
                                        errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.red,
                                        )),
                                        contentPadding:
                                            const EdgeInsets.all(15.0),
                                        hintText: 'Enter Bank Name',
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // textAndInput(
                            //   controllerText: accountHolderControler,
                            //   // isRequired: true,
                            //   title: "Account Holder ",
                            //   hintText: 'Enter Account Holder',
                            //   // validator: (value) {
                            //   //   if (value!.isEmpty) {
                            //   //     return "(Buyer Name Cannot Be Empty)";
                            //   //   }
                            //   // },
                            // ),
                            Row(
                              children: [
                                Container(
                                  // padding: const EdgeInsets.only(left: 60),
                                  width: 230.0,
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'HelveticaNeue'),
                                      children: [
                                        TextSpan(
                                          text: 'Account Holder',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'HelveticaNeue'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  // width: MediaQuery.of(context).size.width * 0.74,
                                  child: TextFormField(
                                    onChanged: ((value) {
                                      widget.arr_buyer_flatlist?[index]
                                          .bankAccountHolderName = value;
                                    }),
                                    style: const TextStyle(fontSize: 13),
                                    controller: TextEditingController(
                                        text: widget.arr_buyer_flatlist?[index]
                                            .bankAccountHolderName),
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        )),
                                        errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.red,
                                        )),
                                        contentPadding:
                                            const EdgeInsets.all(15.0),
                                        hintText: 'Enter Account Holder',
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // const SizedBox(height: 10),
                            // textAndInput(
                            //   controllerText: accountNoControler,
                            //   // isRequired: true,
                            //   title: "Account No. ",
                            //   hintText: 'Enter Account No.',
                            //   // validator: (value) {
                            //   //   if (value!.isEmpty) {
                            //   //     return "(Buyer Name Cannot Be Empty)";
                            //   //   }
                            //   // },
                            // ),
                            Row(
                              children: [
                                Container(
                                  // padding: const EdgeInsets.only(left: 60),
                                  width: 230.0,
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'HelveticaNeue'),
                                      children: [
                                        TextSpan(
                                          text: 'Account No.',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'HelveticaNeue'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  // width: MediaQuery.of(context).size.width * 0.74,
                                  child: TextFormField(
                                    onChanged: ((value) {
                                      widget.arr_buyer_flatlist?[index]
                                          .bankAccountNo = value;
                                    }),
                                    style: const TextStyle(fontSize: 13),
                                    controller: TextEditingController(
                                      text: widget.arr_buyer_flatlist?[index]
                                          .bankAccountNo,
                                    ),
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        )),
                                        errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.red,
                                        )),
                                        contentPadding:
                                            const EdgeInsets.all(15.0),
                                        hintText: 'Enter Account No.',
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // const SizedBox(height: 10),
                            // textAndInput(
                            //   controllerText: ifscCodeControler,
                            //   // isRequired: true,
                            //   title: "IFSC Code ",
                            //   hintText: 'Enter IFSC Code',
                            //   // validator: (value) {
                            //   //   if (value!.isEmpty) {
                            //   //     return "(Buyer Name Cannot Be Empty)";
                            //   //   }
                            //   // },
                            // ),
                            // const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  // padding: const EdgeInsets.only(left: 60),
                                  width: 230.0,
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'HelveticaNeue'),
                                      children: [
                                        TextSpan(
                                          text: 'IFSC Code',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'HelveticaNeue'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  // width: MediaQuery.of(context).size.width * 0.74,
                                  child: TextFormField(
                                    onChanged: ((value) {
                                      widget.arr_buyer_flatlist?[index]
                                          .bankIfsc = value;
                                    }),
                                    style: const TextStyle(fontSize: 13),
                                    controller: TextEditingController(
                                        text: widget.arr_buyer_flatlist?[index]
                                            .bankIfsc),
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        )),
                                        errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.red,
                                        )),
                                        contentPadding:
                                            const EdgeInsets.all(15.0),
                                        hintText: 'Enter IFSC Code',
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // textAndInput(
                            //   controllerText: branchNameControler,
                            //   // isRequired: true,
                            //   title: "Branch Name ",
                            //   hintText: 'Enter Branch Name',
                            //   // validator: (value) {
                            //   //   if (value!.isEmpty) {
                            //   //     return "(Buyer Name Cannot Be Empty)";
                            //   //   }
                            //   // },
                            // ),
                            // const SizedBox(height: 10),

                            Row(
                              children: [
                                Container(
                                  // padding: const EdgeInsets.only(left: 60),
                                  width: 230.0,
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'HelveticaNeue'),
                                      children: [
                                        TextSpan(
                                          text: 'Branch Name',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'HelveticaNeue'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  // width: MediaQuery.of(context).size.width * 0.74,
                                  child: TextFormField(
                                    onChanged: ((value) {
                                      widget.arr_buyer_flatlist?[index]
                                          .bankBranch = value;
                                    }),
                                    style: const TextStyle(fontSize: 13),
                                    controller: TextEditingController(
                                        text: widget.arr_buyer_flatlist?[index]
                                            .bankBranch),
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        )),
                                        errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Colors.red,
                                        )),
                                        contentPadding:
                                            const EdgeInsets.all(15.0),
                                        hintText: 'Enter Branch Name',
                                        border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(7.0)))),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 1.0, color: Colors.black),
                          ]
                        : [
                            verticalSpaceSmall15,
                            _flatNumber(widget
                                .arrSelectedFlatForSaleList?[index]
                                .inventryFlatName),
                            verticalSpaceSmall15,
                            _buyerName(index),
                            verticalSpaceSmall15,
                            _buyerEmail(index),
                            verticalSpaceSmall15,
                            _buyerMobileNumber(index),
                            verticalSpaceSmall15,
                            _buyerAadharCardNo(index),
                            verticalSpaceSmall15,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 240.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'jpg',
                                          'jpeg',
                                          'png',
                                          'JPG',
                                          'JPEG',
                                          'PNG',
                                          "pdf"
                                        ],
                                      );
                                      if (result != null) {
                                        PlatformFile file = result.files.first;
                                        print("FILE SELECTED");
                                        print(file.name);
                                        print(file.bytes);
                                        print(file.size);
                                        print(file.extension);
                                        print(file.path);
                                        //Uint8List? fileBytes = result.files.first.bytes;
                                        //String fileName = result.files.first.name;
                                        //arrayAadharFilesBytes?.add(fileBytes!);

                                        arrAadharFilesUpload?.add(
                                            BuyerUploadFiles(
                                                name: file.name,
                                                index: index,
                                                imageData: file));

                                        arrayAadharFiles?.add(file);
                                        arrBuyerDetails![index].aadharfileName =
                                            file.name;
                                        setState(() {});
                                      } else {
                                        // User canceled the picker
                                      }
                                    },
                                    child: Container(
                                      width: 200,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      child: const Text(
                                        'Upload Aadhaar Card',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Text(arrBuyerDetails![index].aadharfileName!),
                              ],
                            ),
                            verticalSpaceSmall15,
                            _buyerPanCardNo(index),
                            verticalSpaceSmall15,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 240.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'jpg',
                                          'jpeg',
                                          'png',
                                          'JPG',
                                          'JPEG',
                                          'PNG',
                                          "pdf"
                                        ],
                                      );
                                      if (result != null) {
                                        PlatformFile file = result.files.first;
                                        print("FILE SELECTED");
                                        print(file.name);
                                        print(file.bytes);
                                        print(file.size);
                                        print(file.extension);
                                        print(file.path);
                                        //Uint8List? fileBytes = result.files.first.bytes;
                                        //String fileName = result.files.first.name;
                                        //arrayAadharFilesBytes?.add(fileBytes!);

                                        arrPanFilesUpload?.add(BuyerUploadFiles(
                                            name: file.name,
                                            index: index,
                                            imageData: file));

                                        arrayPanCardFiles?.add(file);
                                        arrBuyerDetails![index].panfileName =
                                            file.name;
                                        setState(() {});
                                      } else {
                                        // User canceled the picker
                                      }
                                    },
                                    child: Container(
                                      width: 200,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      child: const Text(
                                        'Upload Pan Card',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                horizontalSpaceSmall,
                                Text(arrBuyerDetails![index].panfileName!),
                              ],
                            ),
                            verticalSpaceSmall15,
                            _buyerAddress(index),
                            verticalSpaceSmall15,
                            // const Divider(height: 1.0, color: Colors.black),
                            const SizedBox(height: 20),
                            Container(
                              // padding: const EdgeInsets.only(left: 60),
                              width: double.maxFinite,
                              child: const Text(
                                "Bank Details",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            textAndInput(
                              controllerText: bankNameControler,
                              // isRequired: true,
                              title: "Bank Name ",
                              hintText: 'Enter Bank Name',
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Buyer Name Cannot Be Empty)";
                              //   }
                              // },
                            ),
                            const SizedBox(height: 20),
                            textAndInput(
                              controllerText: accountHolderControler,
                              // isRequired: true,
                              title: "Account Holder ",
                              hintText: 'Enter Account Holder',
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Buyer Name Cannot Be Empty)";
                              //   }
                              // },
                            ),
                            const SizedBox(height: 20),
                            textAndInput(
                              controllerText: accountNoControler,
                              // isRequired: true,
                              title: "Account No. ",
                              hintText: 'Enter Account No.',
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Buyer Name Cannot Be Empty)";
                              //   }
                              // },
                            ),
                            const SizedBox(height: 20),
                            textAndInput(
                              controllerText: ifscCodeControler,
                              // isRequired: true,
                              title: "IFSC Code ",
                              hintText: 'Enter IFSC Code',
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Buyer Name Cannot Be Empty)";
                              //   }
                              // },
                            ),
                            const SizedBox(height: 20),
                            textAndInput(
                              controllerText: branchNameControler,
                              // isRequired: true,
                              title: "Branch Name ",
                              hintText: 'Enter Branch Name',
                              // validator: (value) {
                              //   if (value!.isEmpty) {
                              //     return "(Buyer Name Cannot Be Empty)";
                              //   }
                              // },
                            ),
                            const Divider(height: 1.0, color: Colors.black),
                          ],
                  ),
                );
              }),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: Row(
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () {
                  var projectId = widget.projectId!;
                  var projectName = widget.projectName!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return PaymentTermsView(
                          gst_percentage: widget.gst_percentage,
                          gst_value: widget.gst_value,
                          arr_buyer_flatlist: widget.arr_buyer_flatlist,
                          towarName: widget.towarName,
                          projectId: projectId,
                          towarId: widget.towarId!,
                          arrAadharFilesUpload: arrAadharFilesUpload,
                          arrPanFilesUpload: arrPanFilesUpload,
                          projectName: projectName,
                          flatNumber: widget.flatNumber,
                          buyerName: widget.buyerName,
                          buyerEmail: widget.buyerEmail,
                          flatArea: widget.flatArea,
                          arrBuyerDetails: arrBuyerDetails,
                          arrSelectedFlatForSaleList:
                              widget.arrSelectedFlatForSaleList,
                          buyerMobileNumber: widget.buyerMobileNumber,
                          strFinishingTypeSelected:
                              widget.strFinishingTypeSelected,
                          strNoOfParking: widget.strNoOfParking,
                          strSalesLeadId: widget.strSalesLeadId,
                          arrSelectedParkingList: widget.arrSelectedParkingList,
                          strPanCardNo: arrBuyerDetails![0].pan!,
                          strAadharCardNo: arrBuyerDetails![0].aadhar!,
                          RatePerSqFt: widget.RatePerSqFt,
                          strFlatValue: widget.strFlatValue,
                          strFlatArea: widget.strFlatArea,
                          strRateSqFt: '${widget.RatePerSqFt}',
                          strGSTValue: widget.strGSTValue,
                          strSDValue: widget.strSDValue,
                          TotalValue: widget.TotalValue,
                          strMarketValue: widget.strMarketValue,
                          strStampDutyFlag: widget.strStampDutyFlag,
                          arrCharges: widget.arrCharges,
                          strBuyerID: widget.strBuyerID,
                          strBrokerIDSelected: widget.strBrokerIDSelected,
                          strBrokerPercentage: widget.strBrokerPercentage,
                          strParkingID: widget.strParkingID,
                          arrayAadharFilesBytes: arrayAadharFiles,
                          arrayPanCardFilesBytes: arrayPanCardFiles,
                          strAddress: arrBuyerDetails![0].address!,
                          flaginvestor: widget.flaginvestor,
                          strRemark: widget.strRemark,
                          fundingType: widget.fundingType,
                          tdsPercentage: widget.tdsPercentage,
                          tdsValue: widget.tdsValue,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: const Text(
                    'SKIP FOR NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  var projectId = widget.projectId!;
                  var projectName = widget.projectName!;
                  if (widget.txtControllerLeaseValueMonthly != null &&
                      widget.txtControllerLeaseValueYearly!.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return SetLeasepaymenttermsview(
                            leaseYear:
                                widget.txtControllerLeaseValueYearly ?? '',
                            leaseMonth:
                                widget.txtControllerLeaseValueMonthly ?? '',
                            gst_percentage: widget.gst_percentage,
                            gst_value: widget.gst_value,
                            tdsPercentage: widget.tdsPercentage,
                            tdsValue: widget.tdsValue,
                            arr_buyer_flatlist: widget.arr_buyer_flatlist,
                            towarName: widget.towarName,
                            projectId: projectId,
                            towarId: widget.towarId!,
                            arrAadharFilesUpload: arrAadharFilesUpload,
                            arrPanFilesUpload: arrPanFilesUpload,
                            projectName: projectName,
                            flatNumber: widget.flatNumber,
                            buyerName: widget.buyerName,
                            buyerEmail: widget.buyerEmail,
                            flatArea: widget.flatArea,
                            arrBuyerDetails: arrBuyerDetails,
                            arrSelectedFlatForSaleList:
                                widget.arrSelectedFlatForSaleList,
                            buyerMobileNumber: widget.buyerMobileNumber,
                            strFinishingTypeSelected:
                                widget.strFinishingTypeSelected,
                            strNoOfParking: widget.strNoOfParking,
                            strSalesLeadId: widget.strSalesLeadId,
                            arrSelectedParkingList:
                                widget.arrSelectedParkingList,
                            strPanCardNo: arrBuyerDetails![0].pan!,
                            strAadharCardNo: arrBuyerDetails?[0].aadhar ?? '',
                            RatePerSqFt: widget.RatePerSqFt,
                            strFlatValue: widget.strFlatValue,
                            strFlatArea: widget.strFlatArea,
                            strRateSqFt: '${widget.RatePerSqFt}',
                            strGSTValue: widget.strGSTValue,
                            strSDValue: widget.strSDValue,
                            TotalValue: widget.TotalValue,
                            strMarketValue: widget.strMarketValue,
                            strStampDutyFlag: widget.strStampDutyFlag,
                            arrCharges: widget.arrCharges,
                            strBuyerID: widget.strBuyerID,
                            strBrokerIDSelected: widget.strBrokerIDSelected,
                            strBrokerPercentage: widget.strBrokerPercentage,
                            strParkingID: widget.strParkingID,
                            arrayAadharFilesBytes: arrayAadharFiles,
                            arrayPanCardFilesBytes: arrayPanCardFiles,
                            strAddress: arrBuyerDetails?[0].address,
                            flaginvestor: widget.flaginvestor,
                            strRemark: widget.strRemark,
                            fundingType: widget.fundingType,
                          );
                        },
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return PaymentTermsView(
                            gst_percentage: widget.gst_percentage,
                            gst_value: widget.gst_value,
                            tdsPercentage: widget.tdsPercentage,
                            tdsValue: widget.tdsValue,
                            arr_buyer_flatlist: widget.arr_buyer_flatlist,
                            towarName: widget.towarName,
                            projectId: projectId,
                            towarId: widget.towarId!,
                            arrAadharFilesUpload: arrAadharFilesUpload,
                            arrPanFilesUpload: arrPanFilesUpload,
                            projectName: projectName,
                            flatNumber: widget.flatNumber,
                            buyerName: widget.buyerName,
                            buyerEmail: widget.buyerEmail,
                            flatArea: widget.flatArea,
                            arrBuyerDetails: arrBuyerDetails,
                            arrSelectedFlatForSaleList:
                                widget.arrSelectedFlatForSaleList,
                            buyerMobileNumber: widget.buyerMobileNumber,
                            strFinishingTypeSelected:
                                widget.strFinishingTypeSelected,
                            strNoOfParking: widget.strNoOfParking,
                            strSalesLeadId: widget.strSalesLeadId,
                            arrSelectedParkingList:
                                widget.arrSelectedParkingList,
                            strPanCardNo: arrBuyerDetails![0].pan!,
                            strAadharCardNo: arrBuyerDetails?[0].aadhar ?? '',
                            RatePerSqFt: widget.RatePerSqFt,
                            strFlatValue: widget.strFlatValue,
                            strFlatArea: widget.strFlatArea,
                            strRateSqFt: '${widget.RatePerSqFt}',
                            strGSTValue: widget.strGSTValue,
                            strSDValue: widget.strSDValue,
                            TotalValue: widget.TotalValue,
                            strMarketValue: widget.strMarketValue,
                            strStampDutyFlag: widget.strStampDutyFlag,
                            arrCharges: widget.arrCharges,
                            strBuyerID: widget.strBuyerID,
                            strBrokerIDSelected: widget.strBrokerIDSelected,
                            strBrokerPercentage: widget.strBrokerPercentage,
                            strParkingID: widget.strParkingID,
                            arrayAadharFilesBytes: arrayAadharFiles,
                            arrayPanCardFilesBytes: arrayPanCardFiles,
                            strAddress: arrBuyerDetails?[0].address,
                            flaginvestor: widget.flaginvestor,
                            strRemark: widget.strRemark,
                            fundingType: widget.fundingType,
                          );
                        },
                      ),
                    );
                  }

                  inspect(widget.arr_buyer_flatlist);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: const Text(
                    'SET PAYMENT TERMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flatNumber(String? flatno) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Flat Number',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 13.0),
              child: Text(
                flatno!,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buyerName(int index) {
    arrtxtControllerName.add(TextEditingController());
    arrtxtControllerName[index].text =
        arrBuyerDetails![index].buyer_name.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Buyer\'s Name',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrBuyerDetails![index].buyer_name.toString(),
                    selection: TextSelection.collapsed(
                        offset: arrBuyerDetails![index].buyer_name!.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Buyer Name',
                ),
                onChanged: (String str) {
                  arrBuyerDetails![index].buyer_name = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buyerEmail(int index) {
    arrtxtControllerEmail.add(TextEditingController());
    arrtxtControllerEmail[index].text =
        arrBuyerDetails![index].emailid.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Email',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrBuyerDetails![index].emailid ?? '',
                    selection: TextSelection.collapsed(
                        offset: arrBuyerDetails![index].emailid?.length ?? 0))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Email Address',
                ),
                onChanged: (String str) {
                  arrBuyerDetails![index].emailid = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buyerMobileNumber(int index) {
    arrtxtControllerMobileNo.add(TextEditingController());
    arrtxtControllerMobileNo[index].text =
        arrBuyerDetails![index].mobile_number.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Mobile Number',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                maxLength: 10,
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrBuyerDetails![index].mobile_number ?? '',
                    selection: TextSelection.collapsed(
                        offset: arrBuyerDetails![index].mobile_number?.length ??
                            0))),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(top: 0.0),
                  border: InputBorder.none,
                  hintText: 'Enter Buyer Mobile Number',
                ),
                onChanged: (String str) {
                  arrBuyerDetails![index].mobile_number = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buyerAadharCardNo(int index) {
    arrtxtControllerAadharCard.add(TextEditingController());
    arrtxtControllerAadharCard[index].text =
        arrBuyerDetails![index].aadhar.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Aadhaar Card No.',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrBuyerDetails![index].aadhar ?? '',
                    selection: TextSelection.collapsed(
                        offset: arrBuyerDetails![index].aadhar?.length ?? 0))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Aadhar Card Number',
                ),
                onChanged: (String str) {
                  arrBuyerDetails![index].aadhar = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buyerPanCardNo(int index) {
    arrtxtControllerPanCard.add(TextEditingController());
    arrtxtControllerPanCard[index].text =
        arrBuyerDetails![index].pan.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Pan Card No.',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 45.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrBuyerDetails![index].pan.toString(),
                    selection: TextSelection.collapsed(
                        offset: arrBuyerDetails![index].pan!.length))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter Pan Card Number',
                ),
                onChanged: (String str) {
                  arrBuyerDetails![index].pan = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buyerAddress(int index) {
    arrtxtControllerAddress.add(TextEditingController());
    arrtxtControllerAddress[index].text =
        arrBuyerDetails![index].address.toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 230.0,
          height: 40.0,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Text('Address',
                style: TextStyle(
                    backgroundColor: Colors.white,
                    fontSize: 15,
                    color: Colors.black)),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Container(
            height: 155.0,
            decoration: BoxDecoration(
                color: kcTextFieldColor,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                controller: TextEditingController.fromValue(TextEditingValue(
                    text: arrBuyerDetails![index].address ?? '',
                    selection: TextSelection.collapsed(
                        offset: arrBuyerDetails![index].address?.length ?? 0))),
                style: const TextStyle(color: Colors.black, fontSize: 15.0),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                  border: InputBorder.none,
                  hintText: 'Enter buyer full address',
                ),
                onChanged: (String str) {
                  arrBuyerDetails![index].address = str;
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget textAndInput({
    required TextEditingController controllerText,
    required String title,
    required String hintText,
    final FormFieldValidator<String>? validator,
    final List<TextInputFormatter>? inputFormatters,
    final int? maxLength,
    int maxLines = 1,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
  }) {
    return Row(
      children: [
        // Container(
        //   padding: const EdgeInsets.only(left: 60),
        //   width: MediaQuery.of(context).size.width * 0.2,
        //   child: Text(
        //     title,
        //     style: const TextStyle(
        //       fontSize: 16,
        //     ),
        //   ),
        // ),
        Container(
          // padding: const EdgeInsets.only(left: 60),
          width: 230.0,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'HelveticaNeue'),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'HelveticaNeue'),
                ),
                if (isRequired == true)
                  const TextSpan(
                    text: "*", // The asterisk
                    style: TextStyle(
                      color: Colors.red, // Color for the asterisk
                    ),
                  ),
              ],
            ),
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          // width: MediaQuery.of(context).size.width * 0.74,
          child: TextFormField(
            onChanged: onChanged,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            validator: validator,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13),
            controller: TextEditingController(),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.grey.shade300,
                )),
                errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.red,
                )),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: hintText,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)))),
          ),
        ),
      ],
    );
  }
}
