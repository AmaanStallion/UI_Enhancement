import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stallion/models/flat_buyer_upload_files.dart';
import 'package:stallion/models/flat_buyers_list.dart';
import 'package:stallion/models/get_broker_details.dart';
import 'package:stallion/models/get_buyer_template.dart';
import 'package:stallion/models/get_flat_list_by_project.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/salesmanagement/bookingleasepreviewview.dart';

class SetLeasepaymenttermsview extends StatefulWidget {
  SetLeasepaymenttermsview({
    Key? key,
    this.projectName,
    this.memberShipform = "0",
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
    this.arrAadharFilesUpload,
    this.arrPanFilesUpload,
    this.arrBuyerDetails,
    this.strAddress,
    this.fundingType,
    this.strRemark,
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
    required this.tdsPercentage,
    required this.tdsValue,
    this.flatNumber,
    required this.gst_percentage,
    required this.gst_value,
    required this.leaseYear,
    required this.leaseMonth,
  }) : super(key: key);
  final String leaseYear;
  final String leaseMonth;
  final List<FlatBuyerInfo>? arr_buyer_flatlist;

  final String? towarName;
  final String? flatNumber;
  final String? memberShipform;
  final String? projectId;
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
  final String? strAddress;
  List<CustomCharge>? arrCharges;
  List<FlatList>? arrSelectedFlatForSaleList;
  List<ParkingList>? arrSelectedParkingList;
  List<PlatformFile>? arrayAadharFilesBytes;
  List<PlatformFile>? arrayPanCardFilesBytes;
  final String? fundingType;
  final String? strRemark;

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
  final String? tdsPercentage;
  final String? tdsValue;
  final String? gst_percentage;
  final String? gst_value;

  // "member_dob": txtMemberDOBControler.text,
  // "spouse_name": _txtControllerSpouseName.text,
  // "spouse_dob": txtSpouseDOB.text,
  // "child_name_1": _txtControllerChild1Name.text,
  // "child_1_dob": txtChild1DOB.text,
  // "child_name_2": _txtControllerChild2Name.text,
  // "child_2_dob": txtChild2DOB.text,
  // "wedding_aniversary": txtAniversaryDOB.text,
  // "residential_address": _txtControllerResidentialAddress.text,
  // "correspndence_address": _txtControllerCorrespondenceAddress.text,
  // "exprected_wedding_year": _txtControllerExpectedWeddingYear.text,
  // "member_ship_period": _txtControllerMembershipPeriod.text,
  // "member_aadhar_no": _txtControllerAadharNo.text,

  List<BuyerUploadFiles>? arrAadharFilesUpload;
  List<BuyerUploadFiles>? arrPanFilesUpload;

  List<BuyerListDetail>? arrBuyerDetails;

  @override
  State<SetLeasepaymenttermsview> createState() =>
      _SetLeasepaymenttermsviewState();
}

class _SetLeasepaymenttermsviewState extends State<SetLeasepaymenttermsview> {
  String selectedYear = '';
  final List<String> predefinedYears = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  // Tenure variables
  DateTime? startDate;
  Map<int, String> yearIncrements = {};
  String durationUnit = 'Monthly'; // 'Monthly' or 'Yearly'
  bool tenureSet = false;

  void _showTenureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TenureDialog(
          selectedYear: selectedYear,
          startDate: startDate,
          yearIncrements: yearIncrements,
          durationUnit: durationUnit,
          onTenureSaved: (start, increments, unit) {
            setState(() {
              startDate = start;
              yearIncrements = increments;
              durationUnit = unit;
              tenureSet = true;
            });
          },
        );
      },
    );
  }

  Future<void> _showYearSelectionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context1, setState1) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            titlePadding: const EdgeInsets.symmetric(vertical: 0),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsAlignment: MainAxisAlignment.center,
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                "Select Tenure",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: <Widget>[
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _showCustomYearDialog();
                    },
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          // bottomRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Custom',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 1),
                  InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          // bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
            content: SizedBox(
              height: 300,
              width: 400,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: predefinedYears.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 0.5,
                ),
                itemBuilder: (context, index) {
                  final year = predefinedYears[index];
                  final int y = int.tryParse(year) ?? 0;

                  return ListTile(
                    title: Text(
                      '$y ${y == 1 ? 'Year' : 'Years'}',
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      setState(() {
                        selectedYear = year;
                        tenureSet = false;
                        startDate = null;
                        yearIncrements = {};
                      });
                      Navigator.pop(dialogContext);
                    },
                  );
                },
              ),
              // child: SingleChildScrollView(
              //   child:
              //   Column(
              //     children: [
              //       // ...predefinedYears.map((year) {
              //       //   final int y = int.tryParse(year) ?? 0;
              //       //   return ListTile(

              //       //     title: Text(
              //       //       '$y ${y == 1 ? 'Year' : 'Years'}',
              //       //       textAlign: TextAlign.center,
              //       //     ),
              //       //     onTap: () {
              //       //       setState(() {
              //       //         selectedYear = year;
              //       //         tenureSet = false;
              //       //         startDate = null;
              //       //         yearIncrements = {};
              //       //       });
              //       //       Navigator.pop(dialogContext);
              //       //     },
              //       //   );
              //       // }).toList(),
              //       // const Divider(),
              //       // ListTile(
              //       //   title: const Text('Custom'),
              //       //   onTap: () {
              //       //     Navigator.pop(dialogContext);
              //       //     _showCustomYearDialog();
              //       //   },
              //       // ),
              //     ],
              //   ),
              // ),
            ),
          );
        });
      },
    );
  }

  Future<void> _showCustomYearDialog() async {
    final TextEditingController customController = TextEditingController();
    String? errorText;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context1, setState1) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            titlePadding: const EdgeInsets.symmetric(vertical: 0),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsAlignment: MainAxisAlignment.center,
            backgroundColor: Colors.white,
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                "Enter Custom Year",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: <Widget>[
              // TextButton(
              //   onPressed: () {
              //     Navigator.pop(dialogContext);
              //   },
              //   child: const Text('Cancel'),
              // ),
              // TextButton(
              //   onPressed: () {
              //     final value = int.tryParse(customController.text.trim());
              //     if (value == null || value <= 0) {
              //       setState1(() {
              //         errorText = 'Please enter a valid year';
              //       });
              //       return;
              //     }
              //     setState(() {
              //       selectedYear = value.toString();
              //       tenureSet = false;
              //       startDate = null;
              //       yearIncrements = {};
              //     });
              //     Navigator.pop(dialogContext);
              //   },
              //   child: const Text('Save'),
              // ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          // bottomRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 1),
                  InkWell(
                    onTap: () {
                      final value = int.tryParse(customController.text.trim());
                      if (value == null || value <= 0) {
                        setState1(() {
                          errorText = 'Please enter a valid year';
                        });
                        return;
                      }
                      setState(() {
                        selectedYear = value.toString();
                        tenureSet = false;
                        startDate = null;
                        yearIncrements = {};
                      });
                      Navigator.pop(dialogContext);
                    },
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                          // bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
            content: SizedBox(
              width: 400,
              height: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TextField(
                  //   controller: customController,
                  //   keyboardType: TextInputType.number,
                  //   decoration: InputDecoration(
                  //     labelText: 'Years',
                  //     errorText: errorText,
                  //   ),
                  // ),
                  Container(
                    height: 45.0,
                    decoration: BoxDecoration(
                        color: kcTextFieldColor,
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: customController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 15.0),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 18.0),
                          border: InputBorder.none,
                          hintText: 'Enter Years',
                        ),
                        // onChanged: (String str) {
                        //   widget.arr_buyer_flatlist?[index].pan = str;
                        // },
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  DateTime _addOneMonth(DateTime date) {
    int y = date.year;
    int m = date.month + 1;
    if (m > 12) {
      m = 1;
      y++;
    }
    final int maxDay = DateTime(y, m + 1 > 12 ? 1 : m + 1, 0).day;
    return DateTime(y, m, date.day > maxDay ? maxDay : date.day);
  }

  List<Map<String, dynamic>> _generateLeaseSchedule() {
    final List<Map<String, dynamic>> schedule = [];
    if (startDate == null || selectedYear.isEmpty) return schedule;

    double baseAmount = double.tryParse(widget.TotalValue ?? '0') ?? 0;
    final double gstRate = double.tryParse(widget.gst_percentage ?? '5') ?? 5;
    final int totalYears = int.parse(selectedYear);

    if (durationUnit == 'Monthly') {
      double currentYearlyAmount = baseAmount;
      DateTime currentDate = startDate!;
      int overallMonth = 1;

      for (int year = 1; year <= totalYears; year++) {
        if (year > 1) {
          final double pct = double.tryParse(yearIncrements[year] ?? '0') ?? 0;
          currentYearlyAmount = currentYearlyAmount * (1 + pct / 100);
        }
        final double monthlyAmount = currentYearlyAmount / 12;
        final double gstAmount = monthlyAmount * gstRate / 100;
        final double grandTotal = monthlyAmount + gstAmount;

        for (int m = 1; m <= 12; m++) {
          final DateTime nextDate = _addOneMonth(currentDate);
          String monthLabel;
          if (year > 1 && m == 1) {
            final double pct =
                double.tryParse(yearIncrements[year] ?? '0') ?? 0;
            monthLabel =
                '${_getOrdinal(overallMonth)} (${pct.toStringAsFixed(0)}%)';
          } else {
            monthLabel = '${_getOrdinal(overallMonth)}';
          }
          schedule.add({
            'yearLabel': monthLabel,
            'dateRange':
                '${_formatDate(currentDate)} - ${_formatDate(nextDate)}',
            'amount': monthlyAmount,
            'gst': gstAmount,
            'grandTotal': grandTotal,
          });
          currentDate = nextDate;
          overallMonth++;
        }
      }
    } else {
      double currentAmount = baseAmount;
      DateTime currentDate = startDate!;

      for (int year = 1; year <= totalYears; year++) {
        if (year > 1) {
          final double pct = double.tryParse(yearIncrements[year] ?? '0') ?? 0;
          currentAmount = currentAmount * (1 + pct / 100);
        }
        final DateTime nextDate = DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
        );
        String yearLabel;
        if (year > 1) {
          final double pct = double.tryParse(yearIncrements[year] ?? '0') ?? 0;
          yearLabel = '${_getOrdinal(year)} (${pct.toStringAsFixed(0)}%)';
        } else {
          yearLabel = '${_getOrdinal(year)}';
        }
        final double gstAmount = currentAmount * gstRate / 100;
        final double grandTotal = currentAmount + gstAmount;
        schedule.add({
          'yearLabel': yearLabel,
          'dateRange':
              '${_formatDate(currentDate)} -\n${_formatDate(nextDate)}',
          'amount': currentAmount,
          'gst': gstAmount,
          'grandTotal': grandTotal,
        });
        currentDate = nextDate;
      }
    }
    return schedule;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final y = date.year.toString().substring(2);
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} $y';
  }

  String _getOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  String _getBannerText() {
    if (yearIncrements.isEmpty) return '';
    final String pct2 = yearIncrements[2] ?? '0';
    final bool hasMore = (int.tryParse(selectedYear) ?? 1) > 2;
    return '$pct2% Increment - 2nd year ($durationUnit)${hasMore ? ' & more' : ''}';
  }

  double _getTotalScheduleValue() {
    if (!tenureSet) return double.tryParse(widget.TotalValue ?? '0') ?? 0;
    double total = 0;
    for (final row in _generateLeaseSchedule()) {
      total += (row['amount'] as double);
    }
    return total;
  }

  String _formatINR(double value) {
    final f = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    return f.format(value);
  }

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _buildApiPaymentTermJson() {
    if (startDate == null || selectedYear.isEmpty) return '[]';
    final double baseAmount = double.tryParse(widget.TotalValue ?? '0') ?? 0;
    final double gstRate = double.tryParse(widget.gst_percentage ?? '5') ?? 5;
    final int totalYears = int.parse(selectedYear);
    final List<Map<String, String>> list = [];

    if (durationUnit == 'Monthly') {
      double currentYearlyAmount = baseAmount;
      DateTime currentDate = startDate!;
      int overallMonth = 1;
      for (int year = 1; year <= totalYears; year++) {
        double pct = 0;
        if (year > 1) {
          pct = double.tryParse(yearIncrements[year] ?? '0') ?? 0;
          currentYearlyAmount = currentYearlyAmount * (1 + pct / 100);
        }
        final double monthlyAmount = currentYearlyAmount / 12;
        final double gstAmount = monthlyAmount * gstRate / 100;
        final double grandTotal = monthlyAmount + gstAmount;
        for (int m = 1; m <= 12; m++) {
          final DateTime nextDate = _addOneMonth(currentDate);
          list.add({
            'amount': monthlyAmount.toStringAsFixed(0),
            'start_date': _isoDate(currentDate),
            'end_date': _isoDate(nextDate),
            'date_range':
                '${_formatDate(currentDate)} - ${_formatDate(nextDate)}',
            'gst_amount': gstAmount.toStringAsFixed(0),
            'increment_percentage':
                (m == 1 && year > 1) ? pct.toStringAsFixed(0) : '0',
            'year_or_month': '$overallMonth',
            'grand_total': grandTotal.toStringAsFixed(0),
          });
          currentDate = nextDate;
          overallMonth++;
        }
      }
    } else {
      double currentAmount = baseAmount;
      DateTime currentDate = startDate!;
      for (int year = 1; year <= totalYears; year++) {
        double pct = 0;
        if (year > 1) {
          pct = double.tryParse(yearIncrements[year] ?? '0') ?? 0;
          currentAmount = currentAmount * (1 + pct / 100);
        }
        final DateTime nextDate = DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
        );
        final double gstAmount = currentAmount * gstRate / 100;
        final double grandTotal = currentAmount + gstAmount;
        list.add({
          'amount': currentAmount.toStringAsFixed(0),
          'start_date': _isoDate(currentDate),
          'end_date': _isoDate(nextDate),
          'date_range':
              '${_formatDate(currentDate)} - ${_formatDate(nextDate)}',
          'gst_amount': gstAmount.toStringAsFixed(0),
          'increment_percentage': year > 1 ? pct.toStringAsFixed(0) : '0',
          'year_or_month': '$year',
          'grand_total': grandTotal.toStringAsFixed(0),
        });
        currentDate = nextDate;
      }
    }
    return jsonEncode(list);
  }

  @override
  Widget build(BuildContext context) {
    final schedule =
        tenureSet ? _generateLeaseSchedule() : <Map<String, dynamic>>[];
    final double totalValue = _getTotalScheduleValue();
    final String gstLabel = widget.gst_percentage ?? '5';

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
          style: const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          if (kDebugMode) {
            print('NEXT PAGE');
          }
          // List<MasoryList>? arrActualListSent = [];
          // for (var i = 0; i < arrayList!.length; i++) {
          //   var title = arrayList![i].payment_percentage.toString();
          //   if (title != '' && title != '0') {
          //     arrActualListSent.add(arrayList![i]);
          //   }
          // }
          // if (kDebugMode) {
          //   print('----arrActualListSent-----');
          //   print(arrActualListSent);
          // }

          var projectId = widget.projectId!;
          var projectName = widget.projectName!;
          print('----------------');
          print(jsonEncode(widget.arr_buyer_flatlist));

          // Build tenure_details JSON to send to the API
          String tenureDetailsJson = '';
          if (tenureSet && startDate != null && selectedYear.isNotEmpty) {
            final int totalYears = int.parse(selectedYear);
            final DateTime endDate = DateTime(
              startDate!.year + totalYears,
              startDate!.month,
              startDate!.day,
            );
            final String leaseDurationType =
                durationUnit == 'Monthly' ? '1' : '2';
            final List<Map<String, String>> incrementsList = [];
            for (int y = 2; y <= totalYears; y++) {
              incrementsList.add({
                'year': '$y',
                'percentage': yearIncrements[y] ?? '0',
              });
            }
            tenureDetailsJson = jsonEncode({
              'tenure_selected': '$selectedYear Years',
              'lease_duration_type': leaseDurationType,
              'start_date': _isoDate(startDate!),
              'end_date': _isoDate(endDate),
              'increments': incrementsList,
            });
          }

          // Build payment_term_json structured array to send to the API
          final String leasePaymentTermJson = _buildApiPaymentTermJson();

          // Compute grand total across all schedule rows
          double totalGrandTotal = 0;
          for (final row in _generateLeaseSchedule()) {
            totalGrandTotal += row['amount'] as double;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return Bookingleasepreviewview(
                  flatStructureType: durationUnit == 'Monthly' ? '1' : '2',
                  leaseMonth: widget.leaseMonth,
                  leaseYear: widget.leaseYear,
                  gst_percentage: widget.gst_percentage,
                  gst_value: widget.gst_value,
                  tdsPercentage: widget.tdsPercentage,
                  tdsValue: widget.tdsValue,
                  arr_buyer_flatlist: widget.arr_buyer_flatlist,
                  towarName: widget.towarName,
                  member_dob: widget.member_dob ?? '',
                  spouse_name: widget.spouse_name ?? '',
                  spouse_dob: widget.spouse_dob ?? '',
                  child_name_1: widget.child_name_1 ?? '',
                  child_1_dob: widget.child_1_dob ?? '',
                  child_name_2: widget.child_name_2 ?? '',
                  child_2_dob: widget.child_2_dob ?? '',
                  wedding_aniversary: widget.wedding_aniversary ?? '',
                  residential_address: widget.residential_address ?? '',
                  correspndence_address: widget.correspndence_address ?? '',
                  exprected_wedding_year: widget.exprected_wedding_year ?? '',
                  member_ship_period: widget.member_ship_period ?? '',
                  member_aadhar_no: widget.member_aadhar_no ?? '',
                  memberShipform: widget.memberShipform,
                  projectId: projectId,
                  towarId: widget.towarId!,
                  arrAadharFilesUpload: widget.arrAadharFilesUpload,
                  arrPanFilesUpload: widget.arrPanFilesUpload,
                  projectName: projectName,
                  flatNumber: widget.flatNumber,
                  arrBuyerDetails: widget.arrBuyerDetails,
                  buyerName: widget.buyerName,
                  buyerEmail: widget.buyerEmail,
                  strAddress: widget.strAddress,
                  flatArea: widget.flatArea,
                  arrSelectedFlatForSaleList: widget.arrSelectedFlatForSaleList,
                  buyerMobileNumber: widget.buyerMobileNumber,
                  strFinishingTypeSelected: widget.strFinishingTypeSelected,
                  strNoOfParking: widget.strNoOfParking,
                  strSalesLeadId: widget.strSalesLeadId,
                  arrSelectedParkingList: widget.arrSelectedParkingList,
                  strPanCardNo: widget.strPanCardNo,
                  strAadharCardNo: widget.strAadharCardNo,
                  RatePerSqFt: widget.RatePerSqFt,
                  strFlatValue: widget.strFlatValue,
                  strFlatArea: widget.strFlatArea,
                  strRateSqFt: widget.strRateSqFt,
                  strGSTValue: widget.strGSTValue,
                  strSDValue: widget.strSDValue,
                  TotalValue: widget.TotalValue,
                  strMarketValue: widget.strMarketValue,
                  // strPaymentTermType: flagSelectedTab == 'Custom' ? '0' : '1',
                  strStampDutyFlag: widget.strStampDutyFlag,
                  arrCharges: widget.arrCharges,
                  strBuyerID: widget.strBuyerID,
                  strBrokerIDSelected: widget.strBrokerIDSelected,
                  strBrokerPercentage: widget.strBrokerPercentage,
                  strParkingID: widget.strParkingID,
                  // arrayList: arrActualListSent,
                  arrayAadharFilesBytes: widget.arrayAadharFilesBytes,
                  arrayPanCardFilesBytes: widget.arrayPanCardFilesBytes,
                  strRemark: widget.strRemark!,
                  fundingType: widget.fundingType,
                  flaginvestor: widget.flaginvestor,
                  tenureDetailsJson: tenureDetailsJson,
                  leasePaymentTermJson: leasePaymentTermJson,
                  totalGrandTotal: totalGrandTotal.toStringAsFixed(0),
                );
              },
            ),
          ).then((value) => {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.black,
          child: const Text(
            'PREVIEW BOOKING',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5.0, 10.0, 5.0, 10.0),
              child: Text(
                'SET PAYMENT TERMS (LEASE)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(height: 1.0, thickness: 0.5, color: Colors.black),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('FLAT AREA', style: boldText),
                          verticalSpaceSmall,
                          Text(
                            '${widget.strFlatArea}',
                            style: boldText13,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 1.0,
                    thickness: 0.5,
                    indent: 8.0,
                    endIndent: 8.0,
                    color: Colors.black54,
                  ),
                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(10.0),
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Text('Payment Type', style: normalText14GreyColor),
                  //         verticalSpaceSmall,
                  //         Text(durationUnit, style: boldText13),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const VerticalDivider(
                  //   width: 1.0,
                  //   thickness: 0.5,
                  //   indent: 8.0,
                  //   endIndent: 8.0,
                  //   color: Colors.black54,
                  // ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('TOTAL VALUE', style: boldText),
                          verticalSpaceTiny,
                          Text(
                            '${_formatINR(totalValue)}',
                            style: boldText13,
                          ),
                          const Text('(Excl. G.S.T)', style: normalText12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0, thickness: 0.5, color: Colors.black),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Lease Tenure (Years):',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  // const Spacer(),
                  SizedBox(width: 32),
                  InkWell(
                    onTap: _showYearSelectionDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedYear.isEmpty
                                ? 'Select Duration'
                                : '$selectedYear ${selectedYear == '1' ? 'Year' : 'Years'}',
                            style: TextStyle(
                              color: selectedYear.isEmpty
                                  ? Colors.black54
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1.0, thickness: 0.5, color: Colors.black),
            const SizedBox(height: 14),
            if (selectedYear.isNotEmpty && !tenureSet)
              GestureDetector(
                onTap: _showTenureDialog,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Set Tenure Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            if (tenureSet) ...[
              Container(
                width: 280,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getBannerText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const Divider(height: 1.0, thickness: 0.5, color: Colors.black),
              // const SizedBox(height: 8),
              _buildScheduleTable(schedule, gstLabel),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTable(
      List<Map<String, dynamic>> schedule, String gstLabel) {
    print(schedule);
    double totalAmount = 0;
    double totalGst = 0;
    double totalGrandTotal = 0;
    for (final row in schedule) {
      totalAmount += row['amount'] as double;
      totalGst += row['gst'] as double;
      totalGrandTotal += row['grandTotal'] as double;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Table(
        border: const TableBorder(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide.none,
          // verticalInside: BorderSide.none,
          horizontalInside: BorderSide(color: Colors.black26, width: 0.5),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.8),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.8),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
            children: [
              // _tableCell(durationUnit == 'Monthly' ? 'Month' : 'Year',
              //     isHeader: true),
              _tableCell(
                durationUnit == 'Monthly' ? 'Month' : 'Year',
                isHeader: true,
                showRightDivider: true,
              ),

              _tableCell('Date Range', isHeader: true, showRightDivider: true),
              _tableCell(durationUnit == 'Monthly' ? 'Monthly' : 'Yearly',
                  isHeader: true, showRightDivider: true),
              _tableCell('G.S.T ($gstLabel%)',
                  isHeader: true, showRightDivider: true),
              _tableCell('Grand Total', isHeader: true),
            ],
          ),
          ...schedule.map(
            (row) => TableRow(  
              children: [
                _tableCell(row['yearLabel'] as String, showRightDivider: true),
                _tableCell(row['dateRange'] as String, showRightDivider: true),
                _tableCell(_formatINR(row['amount'] as double),
                    showRightDivider: true),
                _tableCell(_formatINR(row['gst'] as double),
                    showRightDivider: true),
                _tableCell(_formatINR(row['grandTotal'] as double)),
              ],
            ),
          ),
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFEEEEEE)),
            children: [
              _tableCell('Total', isHeader: true, showRightDivider: true),
              _tableCell('', isHeader: true, showRightDivider: true),
              _tableCell(_formatINR(totalAmount),
                  isHeader: true, showRightDivider: true),
              _tableCell(_formatINR(totalGst),
                  isHeader: true, showRightDivider: true),
              _tableCell(_formatINR(totalGrandTotal), isHeader: true),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _tableCell(String text, {bool isHeader = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  //     child: Text(
  //       text,
  //       textAlign: TextAlign.center,
  //       style: TextStyle(
  //         fontSize: 12,
  //         fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
  //       ),
  //     ),
  //   );
  // }
  Widget _tableCell(
    String text, {
    bool isHeader = false,
    bool showRightDivider = false,
  }) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        if (showRightDivider)
          Positioned(
            top: 6, // 👈 adjust gap from top
            bottom: 6, // 👈 adjust gap from bottom
            right: 0,
            child: Container(
              width: 0.5,
              color: Colors.black45,
            ),
          ),
      ],
    );
  }
}

class YearSelectionDialog extends StatefulWidget {
  final List<String> predefinedYears;
  final String selectedYear;
  final Function(String) onYearSelected;

  const YearSelectionDialog({
    Key? key,
    required this.predefinedYears,
    required this.selectedYear,
    required this.onYearSelected,
  }) : super(key: key);

  @override
  State<YearSelectionDialog> createState() => _YearSelectionDialogState();
}

class _YearSelectionDialogState extends State<YearSelectionDialog> {
  late String tempSelectedYear;

  @override
  void initState() {
    super.initState();
    tempSelectedYear = widget.selectedYear;
  }

  void _showAddCustomYearDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCustomYearDialog(
          onCustomYearAdded: (customYear) {
            setState(() {
              tempSelectedYear = customYear;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Set radius to zero
      ),
      titlePadding: const EdgeInsets.symmetric(vertical: 0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      actionsAlignment: MainAxisAlignment.center,
      // title: const Text('Select Lease Payment Terms'),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: const Text(
          "Select Lease Payment Terms",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Predefined Options:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Column(
              children: widget.predefinedYears.map((year) {
                return RadioListTile<String>(
                  title: Text('$year Year${int.parse(year) > 1 ? 's' : ''}'),
                  value: year,
                  groupValue: tempSelectedYear,
                  onChanged: (String? value) {
                    setState(() {
                      tempSelectedYear = value ?? '';
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                const Text(
                  'Custom Options:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12.0),
                ElevatedButton.icon(
                  onPressed: _showAddCustomYearDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Custom'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (!widget.predefinedYears.contains(tempSelectedYear) &&
                tempSelectedYear.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: RadioListTile<String>(
                  title: Text(
                      '${tempSelectedYear} Year${int.parse(tempSelectedYear) > 1 ? 's' : ''} (Custom)'),
                  value: tempSelectedYear,
                  groupValue: tempSelectedYear,
                  onChanged: null,
                  contentPadding: EdgeInsets.zero,
                  tileColor: Colors.green[50],
                ),
              ),
          ],
        ),
      ),
      actions: [
        // TextButton(
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        //   child: const Text('Cancel'),
        // ),
        // ElevatedButton(
        //   onPressed: () {
        //     widget.onYearSelected(tempSelectedYear);
        //     Navigator.of(context).pop();
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.green,
        //     foregroundColor: Colors.white,
        //   ),
        //   child: const Text('Submit'),
        // ),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            widget.onYearSelected(tempSelectedYear);
            Navigator.of(context).pop();
          },
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Text(
              'Submit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class AddCustomYearDialog extends StatefulWidget {
  final Function(String) onCustomYearAdded;

  const AddCustomYearDialog({
    Key? key,
    required this.onCustomYearAdded,
  }) : super(key: key);

  @override
  State<AddCustomYearDialog> createState() => _AddCustomYearDialogState();
}

class _AddCustomYearDialogState extends State<AddCustomYearDialog> {
  final TextEditingController _customYearController = TextEditingController();

  @override
  void dispose() {
    _customYearController.dispose();
    super.dispose();
  }

  void _submitCustomYear() {
    final customYear = _customYearController.text.trim();

    if (customYear.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a year')),
      );
      return;
    }

    if (int.tryParse(customYear) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }

    widget.onCustomYearAdded(customYear);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Year'),
      content: TextField(
        controller: _customYearController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Enter Year',
          hintText: 'e.g., 25',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.all(12.0),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: _submitCustomYear,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class TenureDialog extends StatefulWidget {
  final String selectedYear;
  final DateTime? startDate;
  final Map<int, String> yearIncrements;
  final String durationUnit;
  final Function(DateTime, Map<int, String>, String) onTenureSaved;

  const TenureDialog({
    Key? key,
    required this.selectedYear,
    this.startDate,
    required this.yearIncrements,
    required this.durationUnit,
    required this.onTenureSaved,
  }) : super(key: key);

  @override
  State<TenureDialog> createState() => _TenureDialogState();
}

class _TenureDialogState extends State<TenureDialog> {
  DateTime? tempStartDate;
  late String tempDurationUnit;
  late Map<int, TextEditingController> incrementControllers;

  @override
  void initState() {
    super.initState();
    tempStartDate = widget.startDate;
    tempDurationUnit = widget.durationUnit;
    final int years = int.parse(widget.selectedYear);
    incrementControllers = {};
    for (int y = 2; y <= years; y++) {
      incrementControllers[y] =
          TextEditingController(text: widget.yearIncrements[y] ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in incrementControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _ordinal(int n) {
    if (n == 2) return '2nd';
    if (n == 3) return '3rd';
    return '${n}th';
  }

  DateTime? get _endDate {
    if (tempStartDate == null) return null;
    final int years = int.parse(widget.selectedYear);
    return DateTime(
        tempStartDate!.year + years, tempStartDate!.month, tempStartDate!.day);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tempStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => tempStartDate = picked);
    }
  }

  void _save() {
    if (tempStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }
    final Map<int, String> increments = {};
    for (final entry in incrementControllers.entries) {
      increments[entry.key] = entry.value.text;
    }
    widget.onTenureSaved(tempStartDate!, increments, tempDurationUnit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final int years = int.parse(widget.selectedYear);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // title: Container(
      //   width: 400,
      //   padding: const EdgeInsets.symmetric(vertical: 14),
      //   decoration: const BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(12),
      //       topRight: Radius.circular(12),
      //     ),
      //   ),
      //   child: const Text(
      //     'Set Tenure Details',
      //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //     textAlign: TextAlign.center,
      //   ),
      // ),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: const Text(
          "Set Tenure Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: Container(
        height: 380,
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected year
              Row(
                children: [
                  const Text('Selected Lease Year : ',
                      style: TextStyle(fontSize: 14)),
                  Text(
                    '$years ${years == 1 ? 'Year' : 'Years'}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Start Date
              Row(
                children: [
                  const SizedBox(
                    width: 90,
                    child: Text('Start Date :', style: TextStyle(fontSize: 14)),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectStartDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDate(tempStartDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: tempStartDate == null
                                ? Colors.black38
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // End Date (read-only, auto-calculated)
              Row(
                children: [
                  const SizedBox(
                    width: 90,
                    child: Text('End Date :', style: TextStyle(fontSize: 14)),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDate(_endDate),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              _endDate == null ? Colors.black38 : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Increments per year
              const Text(
                'Increments (Year - %):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...List.generate(years - 1, (i) {
                final int yearNum = i + 2;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_ordinal(yearNum)} Year',
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: incrementControllers[yearNum],
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: '%',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: Colors.black38),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: Colors.black26),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              // Duration toggle
              Row(
                children: [
                  const Text('Duration :', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => setState(() => tempDurationUnit = 'Monthly'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: tempDurationUnit == 'Monthly'
                            ? Colors.black
                            : Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Monthly',
                        style: TextStyle(
                          color: tempDurationUnit == 'Monthly'
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => tempDurationUnit = 'Yearly'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: tempDurationUnit == 'Yearly'
                            ? Colors.black
                            : Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Yearly',
                        style: TextStyle(
                          color: tempDurationUnit == 'Yearly'
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
