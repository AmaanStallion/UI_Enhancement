import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../utils/api_network_call.dart';
import '../../../../utils/app_url.dart';
import '../../../models/flat_buyer_upload_files.dart';
import '../../../models/flat_buyers_list.dart';
import '../../../models/get_buyer_template.dart';
import '../../../models/get_flat_list_by_project.dart';
import '../../../models/get_sale_booking_preview.dart';
import '../../../models/message_success.dart';

class Bookingleasepreviewview extends StatefulWidget {
  Bookingleasepreviewview(
      {Key? key,
      this.projectName,
      this.strAddress,
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
      this.arrayAadharFilesBytes,
      this.arrayPanCardFilesBytes,
      this.arrayList,
      this.strPaymentTermType,
      this.arrAadharFilesUpload,
      this.arrPanFilesUpload,
      this.arrBuyerDetails,
      this.fundingType,
      this.strRemark,
      this.memberShipform = "0",
      this.member_dob,
      this.spouse_name,
      this.spouse_dob,
      this.child_name_1,
      this.child_1_dob,
      this.child_name_2,
      this.child_2_dob,
      this.wedding_aniversary,
      this.residential_address,
      this.correspndence_address,
      this.exprected_wedding_year,
      this.member_ship_period,
      this.member_aadhar_no,
      this.towarName = "",
      this.arr_buyer_flatlist,
      this.isFromTenant,
      this.flatNumber,
      this.tenent_mahad_area,
      this.tenent_lamp_adjusted,
      this.inventy_parking_number,
      this.tenent_purchase_area,
      this.flat_booking_status,
      this.tenent_id,
      this.gst_amout,
      this.balance_consideration,
      this.tenant_proposed_area,
      this.stampduty,
      this.flat_id,
      this.tenant_exit_area,
      this.tenent_foc_area,
      this.proposed_rate_per_sqft,
      this.proposed_consideration,
      required this.tdsPercentage,
      required this.tdsValue,
      required this.gst_percentage,
      required this.gst_value,
      this.tenureDetailsJson,
      this.leasePaymentTermJson,
      this.totalGrandTotal,
      required this.leaseYear,
      required this.leaseMonth,
      required this.flatStructureType})
      : super(key: key);
  final String? flatStructureType;
  final String? leaseYear;
  final String? leaseMonth;
  final List<FlatBuyerInfo>? arr_buyer_flatlist;
  final String? towarName;
  final String? flatNumber;
  final String? memberShipform;
  final String? projectId;
  final String? strAddress;
  final String? towarId;
  final String? projectName;
  final String? buyerName;
  final String? buyerEmail;
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
  final String? strPaymentTermType;
  final String? fundingType;
  final String? strRemark;
  final String? tdsPercentage;
  final String? tdsValue;
  final String? gst_percentage;
  final String? gst_value;
  final String? tenureDetailsJson;
  final String? leasePaymentTermJson;
  final String? totalGrandTotal;

  List<BuyerListDetail>? arrBuyerDetails;

  List<CustomCharge>? arrCharges;
  List<FlatList>? arrSelectedFlatForSaleList;
  List<ParkingList>? arrSelectedParkingList;
  List<PlatformFile>? arrayAadharFilesBytes;
  List<PlatformFile>? arrayPanCardFilesBytes;

  List<BuyerUploadFiles>? arrAadharFilesUpload;
  List<BuyerUploadFiles>? arrPanFilesUpload;

  List<MasoryList>? arrayList;

  final String? member_dob;
  final String? spouse_name;
  final String? spouse_dob;
  final String? child_name_1;
  final String? child_1_dob;
  final String? child_name_2;
  final String? child_2_dob;
  final String? wedding_aniversary;
  final String? residential_address;
  final String? correspndence_address;
  final String? exprected_wedding_year;
  final String? member_ship_period;
  final String? member_aadhar_no;

  bool? isFromTenant = false;

  String? tenent_mahad_area;
  String? tenent_lamp_adjusted;
  String? inventy_parking_number;
  String? tenent_purchase_area;
  String? flat_booking_status;
  String? tenent_id;
  String? gst_amout;
  String? balance_consideration;
  String? tenant_proposed_area;
  String? stampduty;
  String? flat_id;
  String? tenant_exit_area;
  String? tenent_foc_area;
  String? proposed_rate_per_sqft;
  String? proposed_consideration;

  @override
  State<Bookingleasepreviewview> createState() =>
      _BookingleasepreviewviewState();
}

class _BookingleasepreviewviewState extends State<Bookingleasepreviewview> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  String? filePath = '';
  String? fileName = '';
  bool isZoomed = false;

  String? kLocalExamplePage = '';

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late PdfViewerController _pdfViewerController;

  late BuildContext dialogContext;

  Future<ResponseWebgetSalePreview?> wsSaleBookingPreview() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    print('ArrayList');

    var funding = "0";
    if (widget.fundingType! == "Self Funding") {
      funding = "0";
    } else {
      funding = "1";
    }
    print('FundingType--');
    print(widget.fundingType!);

    print(jsonEncode(widget.arrayList).toString());

    // if (widget.isFromTenant == true) {
    //   data = {
    //     "flat_area": widget.strFlatArea ?? '',
    //     "towar_id": widget.towarId ?? '',
    //     "tenent_mahad_area": widget.tenent_mahad_area ?? '',
    //     "tenent_lamp_adjusted": widget.tenent_lamp_adjusted ?? '',
    //     "payment_term_json": jsonEncode(widget.arrayList).toString(),
    //     "inventy_parking_number": widget.inventy_parking_number ?? '',
    //     'no_of_park': widget.inventy_parking_number ?? '',
    //     "tenent_purchase_area": widget.tenent_purchase_area ?? '',
    //     "flat_booking_status": widget.flat_booking_status ?? '',
    //     "flat_value": widget.strFlatValue ?? '',
    //     // "gst_value": widget.gst_amout ?? '',
    //     "tenent_id": widget.tenent_id ?? '',
    //     "gst_amout": widget.gst_amout ?? '',
    //     "project_id": widget.projectId ?? '',
    //     "balance_consideration": widget.balance_consideration ?? '',
    //     "tenant_proposed_area": widget.tenant_proposed_area ?? '',
    //     "stampduty": widget.stampduty ?? '',
    //     "user_id": userId ?? '',
    //     "rate_put": widget.RatePerSqFt?.toStringAsFixed(2) ?? '',
    //     "sd_value": widget.strSDValue ?? '',
    //     "payment_term_type": widget.strPaymentTermType ?? '',
    //     "flatList": jsonEncode(widget.arrSelectedFlatForSaleList).toString(),
    //     "remark": widget.strRemark == null ? '' : widget.strRemark ?? '',
    //     "total_value": widget.TotalValue ?? '',
    //     "tenant_exit_area": widget.tenant_exit_area ?? '',
    //     "tenent_foc_area": widget.tenent_foc_area ?? '',
    //     "proposed_consideration": widget.proposed_consideration ?? '',
    //     "flat_id": widget.flat_id ?? '',
    //     "proposed_rate_per_sqft": widget.proposed_rate_per_sqft ?? '',
    //     "fluter": "1",
    //     "tds_value": widget.tdsValue ?? '',
    //     "tds_percentage": widget.tdsPercentage ?? '',
    //     "gst_percentage": widget.gst_percentage ?? '',
    //     "gst_value": widget.gst_value ?? '',
    //   };
    // } else {
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId ?? '',
      "buyer_name": widget.buyerName ?? '',
      "flat_area": widget.strFlatArea ?? '',
      "rate_put": widget.RatePerSqFt?.toStringAsFixed(2) ?? '',
      "flat_value": widget.strFlatValue ?? '',
      "brokerage_value": '0',
      "sd_value": widget.strSDValue ?? '',
      // "gst_value": widget.strGSTValue ?? '',
      // "total_value": widget.TotalValue ?? '',
      "finshing_type":
          widget.strFinishingTypeSelected == "Finished" ? "2" : '1',
      //  ??
      //     jsonEncode(widget.arrayList).toString(),
      "buyer_email": widget.buyerEmail ?? "",
      "buyer_number": widget.buyerMobileNumber ?? '',
      "podium_id": widget.strParkingID ?? '',
      "no_of_park": widget.strNoOfParking ?? '',
      "flatList": jsonEncode(widget.arrSelectedFlatForSaleList).toString(),
      "customer_charges": jsonEncode(widget.arrCharges).toString(),
      "flat_booking_status": "0",
      "flag_investor": widget.flaginvestor ?? '',
      "aadhar_no": widget.strAadharCardNo ?? '',
      "pan_no": widget.strPanCardNo ?? '',
      "flat_buyer_id": widget.strBuyerID ?? '',
      "parkinglist": jsonEncode(widget.arrSelectedParkingList).toString(),
      "address": widget.strAddress ?? '',
      "broker_id": widget.strBrokerIDSelected ?? '',
      "broker_percentage": widget.strBrokerPercentage ?? '',
      "towar_id": widget.towarId ?? '',
      "flat_market_value": widget.strMarketValue ?? '',
      "flag_stump_cal": widget.strStampDutyFlag ?? '',
      "lead_id": widget.strSalesLeadId ?? '',
      "payment_term_type": widget.strPaymentTermType ?? '',
      "flat_remark": widget.strRemark == null ? '' : widget.strRemark ?? '',
      "flat_booking_remark":
          widget.strRemark == null ? '' : widget.strRemark ?? '',
      "flat_funding_type": funding,
      "fluter": "1",
      "member_ship_period": widget.member_ship_period ?? '',
      "exprected_wedding_year": widget.exprected_wedding_year ?? '',
      "arr_buyer_flatlist": jsonEncode(widget.arr_buyer_flatlist),
      "tds_value": widget.tdsValue ?? '',
      "tds_percentage": widget.tdsPercentage ?? '',
      "gst_percentage": widget.gst_percentage ?? '',
      "gst_value": widget.gst_value ?? '',
      "tenure_details": widget.tenureDetailsJson ?? '',
      "payment_term_json": widget.leasePaymentTermJson ?? '',
      "total_value": widget.totalGrandTotal ?? '',
      "lease_year": widget.leaseYear ?? '',
      "lease_month": widget.leaseMonth ?? '',
      "flat_structure_type": widget.flatStructureType ?? '',
    };
    // }

    if (kDebugMode) {
      print('+data');
      print(data);
    }
    var response =
        await apiNetworkHandler.post(AppUrl.wsTemplateFlatLeaseBefore, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = webgetSalePreviewFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response!);
      }
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          fileName = dataModel.response?.fileName;
          filePath =
              '${dataModel.response?.filePath}/${dataModel.response?.fileName}';

          kLocalExamplePage = dataModel.response?.beforeSellTemplate?.content!;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  submitSaleBooking() async {
    //for multipartrequest
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.wssetflatleasebook));

    //for token
    request.headers.addAll({"Authorization": "Bearer token"});

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    var funding = "0";
    if (widget.fundingType! == "Self Funding") {
      funding = "0";
    } else {
      funding = "1";
    }

    print('BuyerId = ${widget.strBuyerID!}');

    //for image and videos and files
    request.fields["user_id"] = userId!;
    request.fields["project_id"] = widget.projectId!;
    request.fields["buyer_name"] = widget.buyerName!;
    request.fields["flat_area"] = widget.strFlatArea!;
    request.fields["rate_put"] = widget.RatePerSqFt!.toStringAsFixed(2);
    request.fields["flat_value"] = widget.strFlatValue!;
    request.fields["brokerage_value"] = '0';
    request.fields["sd_value"] = widget.strSDValue!;
    request.fields["gst_value"] = widget.strGSTValue!;
    // request.fields["total_value"] = widget.TotalValue!;
    request.fields["finshing_type"] =
        widget.strFinishingTypeSelected == "Finished" ? "2" : '1';
    request.fields["payment_term_json"] = jsonEncode(widget.arrayList);
    request.fields["buyer_email"] = widget.buyerEmail!;
    request.fields["buyer_number"] = widget.buyerMobileNumber!;
    request.fields["podium_id"] = widget.strParkingID!;
    request.fields["no_of_park"] = widget.strNoOfParking ?? '';
    request.fields["flatList"] = jsonEncode(widget.arrSelectedFlatForSaleList!);
    request.fields["customer_charges"] = jsonEncode(widget.arrCharges!);
    request.fields["flat_booking_status"] = "0";
    request.fields["flag_investor"] = widget.flaginvestor!;
    request.fields["aadhar_no"] = widget.strAadharCardNo!;
    request.fields["pan_no"] = widget.strPanCardNo!;
    request.fields["flat_buyer_id"] = widget.strBuyerID!;
    request.fields["parkinglist"] = jsonEncode(widget.arrSelectedParkingList!);
    request.fields["address"] = widget.strAddress ?? '';
    request.fields["broker_id"] = widget.strBrokerIDSelected!;
    request.fields["broker_percentage"] = widget.strBrokerPercentage!;
    request.fields["towar_id"] = widget.towarId!;
    request.fields["flat_market_value"] = widget.strMarketValue!;
    request.fields["flag_stump_cal"] = widget.strStampDutyFlag!;
    request.fields["lead_id"] = widget.strSalesLeadId ?? '';
    request.fields["payment_term_type"] = widget.strPaymentTermType ?? '';
    request.fields["flat_remark"] = widget.strRemark ?? '';
    request.fields["flat_booking_remark"] = widget.strRemark ?? '';
    request.fields["flat_funding_type"] = funding;
    request.fields["member_ship_period"] = widget.member_ship_period ?? '';
    request.fields["exprected_wedding_year"] =
        widget.exprected_wedding_year ?? '';
    request.fields["arr_buyer_flatlist"] =
        jsonEncode(widget.arr_buyer_flatlist);
    request.fields["gst_percentage"] = widget.gst_percentage ?? '';

    request.fields["tenure_details"] = widget.tenureDetailsJson ?? '';
    request.fields["gst_value"] = widget.gst_value ?? '';
    request.fields["payment_term_json"] = widget.leasePaymentTermJson ?? '';
    request.fields["total_value"] = widget.totalGrandTotal ?? '';
    request.fields["lease_year"] = widget.leaseYear ?? '';
    request.fields["lease_month"] = widget.leaseMonth ?? '';
    request.fields["flat_structure_type"] = widget.flatStructureType ?? '';

    //for (int i = 0; i < widget.arrayPanCardFilesBytes!.length; i++) {
    print("FILE UPLOAD PAN------------");
    print(request.fields);
    for (int i = 0; i < widget.arrPanFilesUpload!.length; i++) {
      PlatformFile file = widget.arrPanFilesUpload![i].imageData!;
      print("FILE UPLOAD PAN");
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      request.files.add(await http.MultipartFile.fromPath(
          "pan_image_${widget.arrPanFilesUpload![i].index!}",
          file.path.toString()));
    }

    //for (int i = 0; i < widget.arrayAadharFilesBytes!.length; i++) {
    for (int i = 0; i < widget.arrAadharFilesUpload!.length; i++) {
      PlatformFile file = widget.arrAadharFilesUpload![i].imageData!;
      print("FILE UPLOAD AASHAR");
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      request.files.add(await http.MultipartFile.fromPath(
          "aadhar_image_${widget.arrAadharFilesUpload![i].index!}",
          file.path.toString()));
    }

    //for completeing the request
    var response = await request.send();

    //for getting and decoding the response into json format
    var responsed = await http.Response.fromStream(response);
    final responseData = json.decode(responsed.body);
    if (kDebugMode) {
      print(responseData);
    }
    if (response.statusCode == 200) {
      Future.delayed(Duration.zero).then((_) {
        Navigator.pop(dialogContext);
        showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
                  title: const Text(''),
                  content: const Text('Successfully Sent For Approval',
                      style: TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 17.0)),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          fixedSize: const Size.fromWidth(100),
                          padding: const EdgeInsets.all(10),
                          textStyle: const TextStyle(color: Colors.white)),
                      child: const Text('CLOSE',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                              color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ));
      });
    } else {
      if (kDebugMode) {
        Navigator.pop(dialogContext);
        print("ERROR");
      }
    }
  }

  late String _projId;
  late String _projName;
  @override
  void initState() {
    print(widget.tenureDetailsJson);
    print(widget.leasePaymentTermJson);
    super.initState();
    _pdfViewerController = PdfViewerController();

    _projId = widget.projectId!;
    _projName = widget.projectName!;
    if (widget.flaginvestor! != '0') {
      for (int i = 0; i < widget.arrSelectedFlatForSaleList!.length; i++) {
        widget.arrSelectedFlatForSaleList![i].buyer_name =
            widget.arrBuyerDetails?[i].buyer_name;
        widget.arrSelectedFlatForSaleList![i].mobile_number =
            widget.arrBuyerDetails?[i].mobile_number;
        widget.arrSelectedFlatForSaleList![i].emailid =
            widget.arrBuyerDetails?[i].emailid;
        widget.arrSelectedFlatForSaleList?[i].address =
            widget.arrBuyerDetails?[i].address;
        widget.arrSelectedFlatForSaleList![i].pan =
            widget.arrBuyerDetails?[i].pan!;
        widget.arrSelectedFlatForSaleList?[i].aadhar =
            widget.arrBuyerDetails?[i].aadhar;
      }
    }
    print('FlatListForSale');
    // print(widget.arrSelectedFlatForSaleList!);
    wsSaleBookingPreview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}  (SALES PREVIEW)'
                : '${widget.projectName!.toUpperCase()} (SALES PREVIEW)',

            // '${widget.projectName!.toUpperCase()} - SALES PREVIEW',
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.download, color: Colors.white),
          //   onPressed: () {
          //     //shareFile(widget.fileName);
          //     //Save single pdf file
          //     _launchURL();
          //   },
          // ),
          // const SizedBox(
          //   width: 20,
          // ),
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white, size: 35),
            onPressed: () {
              setState(() {
                isZoomed = !isZoomed;
              });
              // _pdfViewerController.zoomLevel = 2;
            },
          ),
          const SizedBox(width: 30),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white, size: 35),
            onPressed: () {
              setState(() {
                isZoomed = !isZoomed;
              });
              // _pdfViewerController.zoomLevel = 0;
            },
          ),
          const SizedBox(width: 50)
        ],
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          //context.loaderOverlay.show();
          //webServiceForSaleBooking();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              dialogContext = context;
              return
                  // const Center(
                  //   child: SizedBox(
                  //     height: 200,
                  //     width: 200,
                  //     child: Dialog(
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           verticalSpaceSmall,
                  //           CircularProgressIndicator(),
                  //           verticalSpaceSmall,
                  //           Text("Loading"),
                  //           verticalSpaceSmall,
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // );
                  Container(
                color:
                    Colors.transparent, //Colors.black.withOpacity(bgOpacity),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 64,
                      child: OverflowBox(
                        minHeight: 100,
                        maxHeight: 100,
                        child: Lottie.asset(
                          'assets/animation/running2.json',
                          // 'assets/animation/chatbotfinallotiie.json',
                          repeat: true,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

          submitSaleBooking();
        },
        child: Container(
          height: 40,
          color: Colors.black,
          child: const Center(
            child: Text(
              "SET PAYMENT TERMS & BOOK",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      body: filePath != ''
          ? Center(
              child: Container(
                width: isZoomed ? 940 : 700,
                child: SfPdfViewer.network(
                  onDocumentLoaded: (details) {
                    if (fileName?.trim() != '') {
                      // RemoveTempFile()
                      //     .removeRecentTempFile(fileName: fileName ?? '');
                    }
                  },
                  initialZoomLevel: 0.75,
                  enableDoubleTapZooming: true,
                  filePath ?? '',
                  // 'https://skrite.com/stallion-build-test//media/backend/images/temporary-docs/20240307025504.pdf',
                  key: _pdfViewerKey,
                  controller: _pdfViewerController,
                  // pageLayoutMode:
                  //     PdfPageLayoutMode.single, // Ensures proper layout
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
