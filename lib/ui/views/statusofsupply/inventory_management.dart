// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stallion/models/project_inventory_list.dart';
// import 'package:stallion/ui/custom_loading/custom_loading.dart';
// import 'package:stallion/ui/shared/ui_helpers.dart';
// import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
// import 'package:stallion/utils/app_url.dart';
// import 'package:calendar_date_picker2/calendar_date_picker2.dart'
//     show
//         CalendarDatePicker2,
//         CalendarDatePicker2Config,
//         CalendarDatePicker2Type;
// import 'package:flutter/material.dart';

// class InventoryManagement extends StatefulWidget {
//   const InventoryManagement({
//     super.key,
//     this.projectId,
//     this.towarId,
//     this.projectName,
//     this.poId,
//     this.towarName,
//   });

//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? poId;
//   final String? towarName;

//   @override
//   State<InventoryManagement> createState() => _InventoryManagementState();
// }

// class _InventoryManagementState extends State<InventoryManagement> {
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   List<ProjectInventoryListDatum>? dataProjectInventoryList = [];
//   List<ProjectInventoryListDatum>? filteredInventoryList =
//       []; // For filtered results

//   String? inventryTotalPoValue = '';
//   String? inventryTotalStockInValue = '';
//   TextEditingController searchController = TextEditingController();
//   DateTime? selectedStartDate;
//   DateTime? selectedEndDate;

//   Future<dynamic?> getInventoryManagementList({
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     CustomLoading.progressDialog(isLoading: true, context: context);
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     Map<String, String> data = {
//       "user_id": userId ?? '', // 0 TO Create new
//       "project_id": widget.projectId!,
//       "towar_id": widget.towarId ?? '',
//       if (startDate != null)
//         "start_date": DateFormat('yyyy-MM-dd').format(startDate),
//       if (endDate != null)
//         "end_date": DateFormat('yyyy-MM-dd')
//             .format(endDate.add(const Duration(days: 1))),
//     };

//     if (kDebugMode) {
//       print(data);
//     }

//     var response =
//         await apiNetworkHandler.post(AppUrl.projectInventoryList, data);

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = customerArchitectCertificateFromJson(response.body);

//       if (dataModel.response?.errorCode == "0") {
//         setState(() {
//           dataProjectInventoryList = dataModel.response?.data;
//           filteredInventoryList =
//               dataModel.response?.data; // Initialize filtered list

//           inventryTotalPoValue = dataModel.response?.inventryTotalPoValue;
//           inventryTotalStockInValue =
//               dataModel.response?.inventryTotalStockInValue;
//         });
//       } else {}
//     }
//     CustomLoading.progressDialog(isLoading: false, context: context);

//     return null;
//   }

//   void filterSearchResults(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         filteredInventoryList = dataProjectInventoryList;
//       });
//     } else {
//       setState(() {
//         filteredInventoryList = dataProjectInventoryList
//             ?.where((item) =>
//                 item.gradeName?.toLowerCase().contains(query.toLowerCase()) ??
//                 false)
//             .toList();
//       });
//     }
//   }

//   Future<void> selectDateRange(BuildContext context) async {
//     final DateTimeRange? pickedRange = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//       initialDateRange: selectedStartDate != null && selectedEndDate != null
//           ? DateTimeRange(start: selectedStartDate!, end: selectedEndDate!)
//           : null,
//     );

//     if (pickedRange != null) {
//       setState(() {
//         selectedStartDate = pickedRange.start;
//         selectedEndDate = pickedRange.end;
//       });

//       // Fetch data with date filter
//       getInventoryManagementList(
//         startDate: pickedRange.start,
//         endDate: pickedRange.end,
//       );
//     }
//   }

//   void clearFilters() {
//     setState(() {
//       searchController.clear();
//       selectedStartDate = null;
//       selectedEndDate = null;
//       filteredInventoryList = dataProjectInventoryList;
//     });
//     getInventoryManagementList();
//   }

//   // Future<void> openCustomDateRangePicker() async {
//   //   final results = await showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (_) => _DateRangePickerModal(
//   //       initialStart: selectedStartDate,
//   //       initialEnd: selectedEndDate,
//   //     ),
//   //   );

//   //   if (results != null && results is List<DateTime?>) {
//   //     setState(() {
//   //       selectedStartDate = results[0];
//   //       selectedEndDate = results[1];
//   //     });

//   //     getInventoryManagementList(
//   //       startDate: selectedStartDate,
//   //       endDate: selectedEndDate,
//   //     );
//   //   }
//   // }
//   Future<void> openDesktopDateRangePicker() async {
//     // if (!isDesktop) return; // prevent opening on mobile

//     final result = await showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) {
//         return Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(
//               maxWidth: 650,
//               maxHeight: 520,
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: _DesktopDateRangeDialog(
//                 initialStart: selectedStartDate,
//                 initialEnd: selectedEndDate,
//               ),
//             ),
//           ),
//         );
//       },
//     );

//     if (result != null && result is List<DateTime?>) {
//       setState(() {
//         selectedStartDate = result[0];
//         selectedEndDate = result[1];
//       });

//       getInventoryManagementList(
//         startDate: selectedStartDate,
//         endDate: selectedEndDate,
//       );
//     }
//   }

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       getInventoryManagementList();
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.black,
//         ),
//         height: 50,
//         child: Row(
//           children: [
//             Container(
//               width: MediaQuery.of(context).size.width * 0.5,
//               decoration: BoxDecoration(
//                 border: Border(
//                   right: BorderSide(color: Colors.grey.shade400, width: 1),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Remaining Value",
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white),
//                   ),
//                   Text(
//                     "₹$inventryTotalPoValue",
//                     style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.5,
//               child: Column(
//                 children: [
//                   const Text(
//                     "Total Inventory Value",
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white),
//                   ),
//                   Text(
//                     "₹$inventryTotalStockInValue",
//                     style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         elevation: 0,
//         title: Text(
//             widget.towarName == ""
//                 ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
//                 : widget.projectName!.toUpperCase(),
//             style:
//                 const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
//         // leading: widget.navigationFlag! == 'SideMenu'
//         //     ? const SizedBox()
//         //     : IconButton(
//         //         icon: const Icon(Icons.arrow_back, color: Colors.white),
//         //         onPressed: () {
//         //           Navigator.maybePop(context);
//         //         },
//         //       ),
//       ),
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(height: 12),
//           const Text(
//             'RAW MATERIAL INVENTORY',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Divider(),
//           const SizedBox(height: 12),

//           // Search and Filter Bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Column(
//               children: [
//                 // Search field
//                 TextField(
//                   controller: searchController,
//                   onChanged: filterSearchResults,
//                   decoration: InputDecoration(
//                     hintText: 'Search by Raw Material',
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: searchController.text.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () {
//                               searchController.clear();
//                               filterSearchResults('');
//                             },
//                           )
//                         : null,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // Date filter and Clear buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: InkWell(
//                         onTap: openDesktopDateRangePicker,

//                         // onTap: () => selectDateRange(context),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 10),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(Icons.calendar_today, size: 18),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   selectedStartDate == null
//                                       ? 'Select Date Range'
//                                       : '${DateFormat('dd-MM-yyyy').format(selectedStartDate!)} to ${DateFormat('dd-MM-yyyy').format(selectedEndDate!)}',
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(fontSize: 12),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     InkWell(
//                       onTap: clearFilters,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text(
//                           'Clear',
//                           style: TextStyle(fontSize: 12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 6),

//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 241, 241, 241),
//               borderRadius: BorderRadius.circular(8),
//               border:
//                   Border.all(color: const Color.fromARGB(255, 162, 162, 162)),
//             ),
//             // color: const Color.fromARGB(255, 241, 241, 241),
//             width: MediaQuery.of(context).size.width * 0.22 * 4 + 40,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   // color: Colors.amber,
//                   width: MediaQuery.of(context).size.width * 0.22,
//                   child: const Text(
//                     'Raw Material',
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 SizedBox(
//                   // color: Colors.cyan,
//                   width: MediaQuery.of(context).size.width * 0.22,
//                   child: const Text(
//                     'Stock In',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 SizedBox(
//                   // color: Colors.amber,
//                   width: MediaQuery.of(context).size.width * 0.22,
//                   child: const Text(
//                     'Stock Out',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 SizedBox(
//                   // color: Colors.cyan,
//                   width: MediaQuery.of(context).size.width * 0.22,
//                   child: const Text(
//                     'Remaining',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 const Icon(
//                   Icons.keyboard_arrow_down_rounded,
//                   color: Colors.transparent,
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 // children: [
//                 //   for (int index = 0;
//                 //       index < (dataProjectInventoryList?.length ?? 0);
//                 //       index++)
//                 children: [
//                   if ((filteredInventoryList?.isEmpty ?? true))
//                     Container(
//                       padding: const EdgeInsets.all(40),
//                       child: const Text(
//                         'No inventory found',
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                     )
//                   else
//                     for (int index = 0;
//                         index < (filteredInventoryList?.length ?? 0);
//                         index++)
//                       GestureDetector(
//                         onTap: () {
//                           if (dataProjectInventoryList?[index].isCollapse ==
//                               "0") {
//                             setState(() {
//                               // dataProjectInventoryList?[index].isCollapse = "1";
//                               filteredInventoryList?[index].isCollapse = "1";
//                             });
//                           } else {
//                             setState(() {
//                               // dataProjectInventoryList?[index].isCollapse = "0";
//                               filteredInventoryList?[index].isCollapse = "1";
//                             });
//                           }
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 20),
//                           decoration: BoxDecoration(
//                             // color: const Color.fromARGB(255, 241, 241, 241),
//                             color: Colors
//                                 .white, // optional, makes shadow more visible
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey
//                                     .withOpacity(0.3), // shadow color
//                                 spreadRadius: 2, // how much the shadow spreads
//                                 blurRadius: 6, // how soft the shadow looks
//                                 offset: const Offset(0, 3), // position: x, y
//                               ),
//                             ],

//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                                 color:
//                                     const Color.fromARGB(255, 162, 162, 162)),
//                           ),
//                           // color: const Color.fromARGB(255, 241, 241, 241),
//                           width:
//                               MediaQuery.of(context).size.width * 0.22 * 4 + 40,
//                           child: Container(
//                             // decoration: BoxDecoration(
//                             // borderRadius: BorderRadius.circular(8),
//                             // border: Border.all(color: Colors.black),
//                             // ),
//                             // color: const Color.fromARGB(255, 241, 241, 241),
//                             // margin: const EdgeInsets.symmetric(vertical: 10),
//                             child: Column(
//                               // crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 10,
//                                     // horizontal: 20,
//                                   ),
//                                   // width: double.maxFinite,
//                                   // decoration: BoxDecoration(
//                                   //   color: const Color.fromARGB(
//                                   //       255, 241, 241, 241),
//                                   //   borderRadius: BorderRadius.circular(8),
//                                   //   // border: Border.all(color: Colors.black),
//                                   // ),
//                                   child:
//                                       // Row(
//                                       //   children: [
//                                       //     Text(
//                                       // dataProjectInventoryList?[index]
//                                       //         .gradeName ??
//                                       //     '',
//                                       //       style: const TextStyle(
//                                       //           color: Colors.black,
//                                       //           fontSize: 18,
//                                       //           fontWeight: FontWeight.w600),
//                                       //     ),
//                                       //     const Spacer(),
//                                       // Icon(dataProjectInventoryList?[index]
//                                       //             .isCollapse ==
//                                       //         "1"
//                                       //     ? Icons.keyboard_arrow_up_rounded
//                                       //     : Icons.keyboard_arrow_down_rounded)
//                                       //   ],
//                                       // ),
//                                       Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       SizedBox(
//                                         // color: Colors.amber,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.22,
//                                         child: Text(
//                                           dataProjectInventoryList?[index]
//                                                   .gradeName ??
//                                               '',
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         // color: Colors.cyan,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.22,
//                                         child: Text(
//                                           dataProjectInventoryList?[index]
//                                                   .totalQuantity!
//                                                   .toStringAsFixed(2) ??
//                                               '',
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         // color: Colors.amber,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.22,
//                                         child: Text(
//                                           dataProjectInventoryList?[index]
//                                                   .totalConsum!
//                                                   .toStringAsFixed(2) ??
//                                               '',
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         // color: Colors.cyan,
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.22,
//                                         child: Text(
//                                           dataProjectInventoryList?[index]
//                                                   .totalRemaing
//                                                   .toStringAsFixed(2) ??
//                                               '',
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600),
//                                         ),
//                                       ),
//                                       Icon(dataProjectInventoryList?[index]
//                                                   .isCollapse ==
//                                               "1"
//                                           ? Icons.keyboard_arrow_up_rounded
//                                           : Icons.keyboard_arrow_down_rounded)
//                                     ],
//                                   ),
//                                 ),

//                                 // if (dataProjectInventoryList?[index].isCollapse ==
//                                 //     "1")
//                                 //   Container(
//                                 //       padding:
//                                 //           EdgeInsets.symmetric(horizontal: 10),
//                                 //       child: Divider()),
//                                 //   Container(
//                                 //     decoration: BoxDecoration(
//                                 //       color: const Color.fromARGB(
//                                 //           255, 241, 241, 241),
//                                 //       borderRadius: BorderRadius.circular(8),
//                                 //       // border: Border.all(color: Colors.black),
//                                 //     ),
//                                 //     padding: EdgeInsets.symmetric(vertical: 6),
//                                 //     margin: EdgeInsets.symmetric(horizontal: 4),
//                                 //     child: Row(
//                                 //       mainAxisAlignment: MainAxisAlignment.center,
//                                 //       children: [
//                                 //         Container(
//                                 //           // color: Colors.amber,
//                                 //           decoration: BoxDecoration(
//                                 //             border: Border(
//                                 //               right: BorderSide(
//                                 //                   color: Colors.grey.shade400,
//                                 //                   width: 1),
//                                 //             ),
//                                 //           ),
//                                 //           width:
//                                 //               MediaQuery.of(context).size.width *
//                                 //                   0.22,
//                                 //           child: Text(
//                                 //             'Raw Material',
//                                 //             style: TextStyle(
//                                 //                 color: Colors.black,
//                                 //                 fontSize: 16,
//                                 //                 fontWeight: FontWeight.w600),
//                                 //           ),
//                                 //         ),
//                                 //         Container(
//                                 //           // color: Colors.cyan,
//                                 //           decoration: BoxDecoration(
//                                 //             border: Border(
//                                 //               right: BorderSide(
//                                 //                   color: Colors.grey.shade400,
//                                 //                   width: 1),
//                                 //             ),
//                                 //           ),
//                                 //           width:
//                                 //               MediaQuery.of(context).size.width *
//                                 //                   0.22,
//                                 //           child: Text(
//                                 //             'Stock In',
//                                 //             textAlign: TextAlign.center,
//                                 //             style: TextStyle(
//                                 //                 color: Colors.black,
//                                 //                 fontSize: 16,
//                                 //                 fontWeight: FontWeight.w600),
//                                 //           ),
//                                 //         ),
//                                 //         Container(
//                                 //           // color: Colors.amber,
//                                 //           decoration: BoxDecoration(
//                                 //             border: Border(
//                                 //               right: BorderSide(
//                                 //                   color: Colors.grey.shade400,
//                                 //                   width: 1),
//                                 //             ),
//                                 //           ),
//                                 //           width:
//                                 //               MediaQuery.of(context).size.width *
//                                 //                   0.22,
//                                 //           child: Text(
//                                 //             'Stock Out',
//                                 //             textAlign: TextAlign.center,
//                                 //             style: TextStyle(
//                                 //                 color: Colors.black,
//                                 //                 fontSize: 16,
//                                 //                 fontWeight: FontWeight.w600),
//                                 //           ),
//                                 //         ),
//                                 //         Container(
//                                 //           // color: Colors.cyan,
//                                 //           width:
//                                 //               MediaQuery.of(context).size.width *
//                                 //                   0.22,
//                                 //           child: Text(
//                                 //             'Remaining',
//                                 //             textAlign: TextAlign.center,
//                                 //             style: TextStyle(
//                                 //                 color: Colors.black,
//                                 //                 fontSize: 16,
//                                 //                 fontWeight: FontWeight.w600),
//                                 //           ),
//                                 //         ),
//                                 //         Icon(
//                                 //           Icons.keyboard_arrow_down_rounded,
//                                 //           color: Colors.transparent,
//                                 //         )
//                                 //       ],
//                                 //     ),
//                                 //   ),
//                                 if (dataProjectInventoryList?[index]
//                                         .isCollapse ==
//                                     "1")
//                                   Container(
//                                       decoration: BoxDecoration(
//                                           color: const Color.fromARGB(
//                                               255, 241, 241, 241),
//                                           border: Border(
//                                               top: BorderSide(
//                                                   color: Colors.grey.shade400,
//                                                   width: 1))),
//                                       height: 10),
//                                 for (int i = 0;
//                                     i <
//                                         dataProjectInventoryList![index]
//                                             .description!
//                                             .length;
//                                     i++)
//                                   if (dataProjectInventoryList?[index]
//                                           .isCollapse ==
//                                       "1")
//                                     Container(
//                                       color: const Color.fromARGB(
//                                           255, 241, 241, 241),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Container(
//                                             // color: Colors.amber,
//                                             decoration: BoxDecoration(
//                                               border: Border(
//                                                 // bottom: BorderSide(
//                                                 //     color: Colors.grey.shade400,
//                                                 //     width: 1),
//                                                 right: BorderSide(
//                                                     color: Colors.grey.shade300,
//                                                     width: 1),
//                                               ),
//                                             ),
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 0.22,
//                                             child: Text(
//                                               dataProjectInventoryList![index]
//                                                       .description![i]
//                                                       .gradTypeName ??
//                                                   '',
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                           ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 20),
//                                             decoration: BoxDecoration(
//                                               // color: Colors.cyan,
//                                               border: Border(
//                                                 // bottom: BorderSide(
//                                                 //     color: Colors.grey.shade400,
//                                                 //     width: 1),
//                                                 right: BorderSide(
//                                                     color: Colors.grey.shade300,
//                                                     width: 1),
//                                               ),
//                                             ),
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 0.22,
//                                             child: Text(
//                                               dataProjectInventoryList![index]
//                                                   .description![i]
//                                                   .totalQuantity!
//                                                   .toStringAsFixed(2),
//                                               textAlign: TextAlign.center,
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                           ),
//                                           Container(
//                                             // color: Colors.amber,
//                                             decoration: BoxDecoration(
//                                               border: Border(
//                                                 // bottom: BorderSide(
//                                                 //     color: Colors.grey.shade400,
//                                                 //     width: 1),
//                                                 right: BorderSide(
//                                                   color: Colors.grey.shade300,
//                                                 ),
//                                               ),
//                                             ),
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 0.22,
//                                             child: Text(
//                                               dataProjectInventoryList![index]
//                                                   .description![i]
//                                                   .totalConsum!
//                                                   .toStringAsFixed(2),
//                                               textAlign: TextAlign.center,
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                           ),
//                                           Container(
//                                             decoration: const BoxDecoration(
//                                               border: Border(
//                                                   // bottom: BorderSide(
//                                                   //     color: Colors.grey.shade400,
//                                                   //     width: 1),
//                                                   // right: BorderSide(
//                                                   //     color: Colors.grey.shade400,
//                                                   //     width: 1),
//                                                   ),
//                                             ),
//                                             // color: Colors.cyan,
//                                             width: MediaQuery.of(context)
//                                                     .size
//                                                     .width *
//                                                 0.22,
//                                             child: Text(
//                                               dataProjectInventoryList![index]
//                                                   .description![i]
//                                                   .totalRemaing!
//                                                   .toStringAsFixed(2),
//                                               textAlign: TextAlign.center,
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                           ),
//                                           const Icon(
//                                             Icons.keyboard_arrow_down_rounded,
//                                             color: Colors.transparent,
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                 if (dataProjectInventoryList?[index]
//                                         .isCollapse ==
//                                     "1")
//                                   Container(
//                                     color: const Color.fromARGB(
//                                         255, 241, 241, 241),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           // color: Colors.amber,
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               0.44,
//                                           child: Text(
//                                             // 'Stock In Value : ₹${dataProjectInventoryList![index].totalStockInValue}',
//                                             'Stock In Value : ${currencyFormat.format(double.parse(dataProjectInventoryList![index].totalStockInValue.toStringAsFixed(2)))}',

//                                             textAlign: TextAlign.center,
//                                             style: const TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w700),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           // color: Colors.cyan,
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               0.44,
//                                           child: Text(
//                                             // 'Remaining Stock Value : ₹${dataProjectInventoryList![index].totalPoValue}',
//                                             'Remaining Stock Value : ${currencyFormat.format(double.parse(dataProjectInventoryList![index].totalPoValue.toStringAsFixed(2)))}',

//                                             textAlign: TextAlign.center,
//                                             style: const TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w700),
//                                           ),
//                                         ),
//                                         const Icon(
//                                           Icons.keyboard_arrow_down_rounded,
//                                           color: Colors.transparent,
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DesktopDateRangeDialog extends StatefulWidget {
//   final DateTime? initialStart;
//   final DateTime? initialEnd;

//   const _DesktopDateRangeDialog({
//     required this.initialStart,
//     required this.initialEnd,
//   });

//   @override
//   State<_DesktopDateRangeDialog> createState() =>
//       _DesktopDateRangeDialogState();
// }

// class _DesktopDateRangeDialogState extends State<_DesktopDateRangeDialog> {
//   List<DateTime?> range = [];

//   @override
//   void initState() {
//     super.initState();
//     range = [widget.initialStart, widget.initialEnd];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       insetPadding: const EdgeInsets.all(20),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Date Range Picker",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: CalendarDatePicker2(
//                 config: CalendarDatePicker2Config(
//                   calendarType: CalendarDatePicker2Type.range,
//                   selectedRangeHighlightColor: Colors.purple.shade200,
//                   // selectedRangeBackgroundColor: Colors.purple.shade200,
//                   selectedDayHighlightColor: Colors.purple,
//                   selectedDayTextStyle: const TextStyle(color: Colors.white),
//                 ),
//                 value: range,
//                 onValueChanged: (values) => setState(() => range = values),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple.shade100,
//                       foregroundColor: Colors.purple,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: const Text("Cancel"),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.pop(context, range),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: const Text("Apply"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/project_inventory_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart'
    show
        CalendarDatePicker2,
        CalendarDatePicker2Config,
        CalendarDatePicker2Type;
import 'package:flutter/material.dart';

class InventoryManagement extends StatefulWidget {
  const InventoryManagement({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.poId,
    this.towarName,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? poId;
  final String? towarName;

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<ProjectInventoryListDatum>? dataProjectInventoryList = [];
  List<ProjectInventoryListDatum>? filteredInventoryList =
      []; // For filtered results

  String? inventryTotalPoValue = '';
  String? inventryTotalStockInValue = '';
  TextEditingController searchController = TextEditingController();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  Future<dynamic?> getInventoryManagementList({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '', // 0 TO Create new
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
      if (startDate != null)
        "start_date": DateFormat('yyyy-MM-dd').format(startDate),
      if (endDate != null)
        "end_date": DateFormat('yyyy-MM-dd')
            .format(endDate.add(const Duration(days: 1))),
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.projectInventoryList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = customerArchitectCertificateFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        setState(() {
          dataProjectInventoryList = dataModel.response?.data;
          filteredInventoryList =
              dataModel.response?.data; // Initialize filtered list

          inventryTotalPoValue = dataModel.response?.inventryTotalPoValue;
          inventryTotalStockInValue =
              dataModel.response?.inventryTotalStockInValue;

          if (searchController.text.isNotEmpty) {
            filterSearchResults(searchController.text);
          }
        });
      } else {}
    }
    CustomLoading.progressDialog(isLoading: false, context: context);

    return null;
  }

  void filterSearchResults(String query) {
    print(query);
    inspect(dataProjectInventoryList);
    if (query.isEmpty) {
      setState(() {
        filteredInventoryList = dataProjectInventoryList;
      });
    } else {
      setState(() {
        filteredInventoryList = dataProjectInventoryList
            ?.where((item) =>
                item.gradeName?.toLowerCase().contains(query.toLowerCase()) ??
                false)
            .toList();
        inspect(filteredInventoryList);
      });
    }
  }

  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: selectedStartDate != null && selectedEndDate != null
          ? DateTimeRange(start: selectedStartDate!, end: selectedEndDate!)
          : null,
    );

    if (pickedRange != null) {
      setState(() {
        selectedStartDate = pickedRange.start;
        selectedEndDate = pickedRange.end;
      });

      // Fetch data with date filter
      getInventoryManagementList(
        startDate: pickedRange.start,
        endDate: pickedRange.end,
      );
    }
  }

  void clearFilters() {
    setState(() {
      searchController.clear();
      selectedStartDate = null;
      selectedEndDate = null;
      filteredInventoryList = dataProjectInventoryList;
    });
    getInventoryManagementList();
  }

  // Future<void> openCustomDateRangePicker() async {
  //   final results = await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => _DateRangePickerModal(
  //       initialStart: selectedStartDate,
  //       initialEnd: selectedEndDate,
  //     ),
  //   );

  //   if (results != null && results is List<DateTime?>) {
  //     setState(() {
  //       selectedStartDate = results[0];
  //       selectedEndDate = results[1];
  //     });

  //     getInventoryManagementList(
  //       startDate: selectedStartDate,
  //       endDate: selectedEndDate,
  //     );
  //   }
  // }
  Future<void> openDesktopDateRangePicker() async {
    // if (!isDesktop) return; // prevent opening on mobile

    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
              maxHeight: 520,
            ),
            child: Material(
              color: Colors.transparent,
              child: _DesktopDateRangeDialog(
                initialStart: selectedStartDate,
                initialEnd: selectedEndDate,
              ),
            ),
          ),
        );
      },
    );

    if (result != null && result is List<DateTime?>) {
      setState(() {
        selectedStartDate = result[0];
        selectedEndDate = result[1];
      });

      getInventoryManagementList(
        startDate: selectedStartDate,
        endDate: selectedEndDate,
      );
    }
  }

  DateTime? _selectedFormDate;
  DateTime? _selectedToDate;

  final TextEditingController fromDateControler = TextEditingController();
  final TextEditingController toDateControler = TextEditingController();

  /// FROM DATE PICKER
  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFormDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _selectedFormDate = picked;
        fromDateControler.text = DateFormat('dd-MM-yyyy').format(picked);

        // Clear To Date if it is before From Date
        if (_selectedToDate != null && _selectedToDate!.isBefore(picked)) {
          _selectedToDate = null;
          toDateControler.clear();
        }
      });
    }
  }

  /// TO DATE PICKER
  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedToDate ?? _selectedFormDate ?? DateTime.now(),
      firstDate: _selectedFormDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _selectedToDate = picked;
        toDateControler.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  /// RESET
  void _resetFilters() {
    setState(() {
      _selectedFormDate = null;
      _selectedToDate = null;
      fromDateControler.clear();
      toDateControler.clear();
    });
  }

  /// SUBMIT
  void _submitFilters() {
    if (_selectedFormDate != null && _selectedToDate != null) {
      // Your API call or filter logic
      debugPrint("From: $_selectedFormDate");
      debugPrint("To: $_selectedToDate");
      getInventoryManagementList(
        startDate: _selectedFormDate,
        endDate: _selectedToDate,
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getInventoryManagementList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        height: 50,
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Remaining Value",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  Text(
                    "₹$inventryTotalPoValue",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                children: [
                  const Text(
                    "Total Inventory Value",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  Text(
                    "₹$inventryTotalStockInValue",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
            widget.towarName == ""
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        // leading: widget.navigationFlag! == 'SideMenu'
        //     ? const SizedBox()
        //     : IconButton(
        //         icon: const Icon(Icons.arrow_back, color: Colors.white),
        //         onPressed: () {
        //           Navigator.maybePop(context);
        //         },
        //       ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text(
            'RAW MATERIAL INVENTORY',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 12),

          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Search field
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearchResults,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 184, 184, 184)),
                      ),
                      // Border when enabled but not focused
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 184, 184, 184)),
                      ),

                      // Border when focused
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 184, 184, 184),
                            width: 2),
                      ),
                      hintText: 'Search by Raw Material',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                filterSearchResults('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Date filter and Clear buttons
                // Row(
                //   children: [
                //     Expanded(
                //       child: InkWell(
                //         onTap: openDesktopDateRangePicker,

                //         // onTap: () => selectDateRange(context),
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(
                //               horizontal: 12, vertical: 10),
                //           decoration: BoxDecoration(
                //             border: Border.all(color: Colors.grey),
                //             borderRadius: BorderRadius.circular(8),
                //           ),
                //           child: Row(
                //             children: [
                //               const Icon(Icons.calendar_today, size: 18),
                //               const SizedBox(width: 8),
                //               Expanded(
                //                 child: Text(
                //                   selectedStartDate == null
                //                       ? 'Select Date Range'
                //                       : '${DateFormat('dd-MM-yyyy').format(selectedStartDate!)} to ${DateFormat('dd-MM-yyyy').format(selectedEndDate!)}',
                //                   overflow: TextOverflow.ellipsis,
                //                   style: const TextStyle(fontSize: 12),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 8),
                //     InkWell(
                //       onTap: clearFilters,
                //       child: Container(
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 12, vertical: 10),
                //         decoration: BoxDecoration(
                //           color: Colors.grey[300],
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         child: const Text(
                //           'Clear',
                //           style: TextStyle(fontSize: 12),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Form(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 40),

                        const Text(
                          "From",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 12),

                        /// FROM DATE FIELD
                        Expanded(
                          child: TextFormField(
                            onTap: () => _selectFromDate(context),
                            controller: fromDateControler,
                            readOnly: true,
                            // enabled: false,
                            decoration: const InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(color: Colors.black),
                              suffixIcon: Icon(Icons.calendar_month_outlined),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),
                        const Text(
                          "To",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 12),

                        /// TO DATE FIELD
                        Expanded(
                          child: TextFormField(
                            onTap: () => _selectToDate(context),
                            controller: toDateControler,
                            // enabled: false,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(color: Colors.black),
                              suffixIcon: Icon(Icons.calendar_month_outlined),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        /// SUBMIT BUTTON
                        OutlinedButton(
                          onPressed: _submitFilters,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black45),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),

                        const SizedBox(width: 20),

                        /// RESET BUTTON
                        OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black45),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),

                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),

            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 241, 241, 241),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: const Color.fromARGB(255, 162, 162, 162)),
            ),
            // color: const Color.fromARGB(255, 241, 241, 241),
            width: MediaQuery.of(context).size.width * 0.22 * 4 + 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  // color: Colors.amber,
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: const Text(
                    'Raw Material',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  // color: Colors.cyan,
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: const Text(
                    'Stock In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  // color: Colors.amber,
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: const Text(
                    'Stock Out',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  // color: Colors.cyan,
                  width: MediaQuery.of(context).size.width * 0.22,
                  child: const Text(
                    'Remaining',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.transparent,
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // children: [
                //   for (int index = 0;
                //       index < (dataProjectInventoryList?.length ?? 0);
                //       index++)
                children: [
                  if ((filteredInventoryList?.isEmpty ?? true))
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: const Text(
                        'No inventory found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  else
                    for (int index = 0;
                        index < (filteredInventoryList?.length ?? 0);
                        index++)
                      GestureDetector(
                        onTap: () {
                          if (dataProjectInventoryList?[index].isCollapse ==
                              "0") {
                            setState(() {
                              // dataProjectInventoryList?[index].isCollapse = "1";
                              filteredInventoryList?[index].isCollapse = "1";
                            });
                          } else {
                            setState(() {
                              // dataProjectInventoryList?[index].isCollapse = "0";
                              filteredInventoryList?[index].isCollapse = "1";
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            // color: const Color.fromARGB(255, 241, 241, 241),
                            color: Colors
                                .white, // optional, makes shadow more visible
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.3), // shadow color
                                spreadRadius: 2, // how much the shadow spreads
                                blurRadius: 6, // how soft the shadow looks
                                offset: const Offset(0, 3), // position: x, y
                              ),
                            ],

                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 162, 162, 162)),
                          ),
                          // color: const Color.fromARGB(255, 241, 241, 241),
                          width:
                              MediaQuery.of(context).size.width * 0.22 * 4 + 40,
                          child: Container(
                            // decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(8),
                            // border: Border.all(color: Colors.black),
                            // ),
                            // color: const Color.fromARGB(255, 241, 241, 241),
                            // margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    // horizontal: 20,
                                  ),
                                  // width: double.maxFinite,
                                  // decoration: BoxDecoration(
                                  //   color: const Color.fromARGB(
                                  //       255, 241, 241, 241),
                                  //   borderRadius: BorderRadius.circular(8),
                                  //   // border: Border.all(color: Colors.black),
                                  // ),
                                  child:
                                      // Row(
                                      //   children: [
                                      //     Text(
                                      // dataProjectInventoryList?[index]
                                      //         .gradeName ??
                                      //     '',
                                      //       style: const TextStyle(
                                      //           color: Colors.black,
                                      //           fontSize: 18,
                                      //           fontWeight: FontWeight.w600),
                                      //     ),
                                      //     const Spacer(),
                                      // Icon(dataProjectInventoryList?[index]
                                      //             .isCollapse ==
                                      //         "1"
                                      //     ? Icons.keyboard_arrow_up_rounded
                                      //     : Icons.keyboard_arrow_down_rounded)
                                      //   ],
                                      // ),
                                      Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        // color: Colors.amber,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        child: Text(
                                          filteredInventoryList?[index]
                                                  .gradeName ??
                                              '',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(
                                        // color: Colors.cyan,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        child: Text(
                                          filteredInventoryList?[index]
                                                  .totalQuantity!
                                                  .toStringAsFixed(2) ??
                                              '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(
                                        // color: Colors.amber,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        child: Text(
                                          filteredInventoryList?[index]
                                                  .totalConsum!
                                                  .toStringAsFixed(2) ??
                                              '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(
                                        // color: Colors.cyan,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.22,
                                        child: Text(
                                          filteredInventoryList?[index]
                                                  .totalRemaing
                                                  .toStringAsFixed(2) ??
                                              '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Icon(filteredInventoryList?[index]
                                                  .isCollapse ==
                                              "1"
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded)
                                    ],
                                  ),
                                ),

                                // if (dataProjectInventoryList?[index].isCollapse ==
                                //     "1")
                                //   Container(
                                //       padding:
                                //           EdgeInsets.symmetric(horizontal: 10),
                                //       child: Divider()),
                                //   Container(
                                //     decoration: BoxDecoration(
                                //       color: const Color.fromARGB(
                                //           255, 241, 241, 241),
                                //       borderRadius: BorderRadius.circular(8),
                                //       // border: Border.all(color: Colors.black),
                                //     ),
                                //     padding: EdgeInsets.symmetric(vertical: 6),
                                //     margin: EdgeInsets.symmetric(horizontal: 4),
                                //     child: Row(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       children: [
                                //         Container(
                                //           // color: Colors.amber,
                                //           decoration: BoxDecoration(
                                //             border: Border(
                                //               right: BorderSide(
                                //                   color: Colors.grey.shade400,
                                //                   width: 1),
                                //             ),
                                //           ),
                                //           width:
                                //               MediaQuery.of(context).size.width *
                                //                   0.22,
                                //           child: Text(
                                //             'Raw Material',
                                //             style: TextStyle(
                                //                 color: Colors.black,
                                //                 fontSize: 16,
                                //                 fontWeight: FontWeight.w600),
                                //           ),
                                //         ),
                                //         Container(
                                //           // color: Colors.cyan,
                                //           decoration: BoxDecoration(
                                //             border: Border(
                                //               right: BorderSide(
                                //                   color: Colors.grey.shade400,
                                //                   width: 1),
                                //             ),
                                //           ),
                                //           width:
                                //               MediaQuery.of(context).size.width *
                                //                   0.22,
                                //           child: Text(
                                //             'Stock In',
                                //             textAlign: TextAlign.center,
                                //             style: TextStyle(
                                //                 color: Colors.black,
                                //                 fontSize: 16,
                                //                 fontWeight: FontWeight.w600),
                                //           ),
                                //         ),
                                //         Container(
                                //           // color: Colors.amber,
                                //           decoration: BoxDecoration(
                                //             border: Border(
                                //               right: BorderSide(
                                //                   color: Colors.grey.shade400,
                                //                   width: 1),
                                //             ),
                                //           ),
                                //           width:
                                //               MediaQuery.of(context).size.width *
                                //                   0.22,
                                //           child: Text(
                                //             'Stock Out',
                                //             textAlign: TextAlign.center,
                                //             style: TextStyle(
                                //                 color: Colors.black,
                                //                 fontSize: 16,
                                //                 fontWeight: FontWeight.w600),
                                //           ),
                                //         ),
                                //         Container(
                                //           // color: Colors.cyan,
                                //           width:
                                //               MediaQuery.of(context).size.width *
                                //                   0.22,
                                //           child: Text(
                                //             'Remaining',
                                //             textAlign: TextAlign.center,
                                //             style: TextStyle(
                                //                 color: Colors.black,
                                //                 fontSize: 16,
                                //                 fontWeight: FontWeight.w600),
                                //           ),
                                //         ),
                                //         Icon(
                                //           Icons.keyboard_arrow_down_rounded,
                                //           color: Colors.transparent,
                                //         )
                                //       ],
                                //     ),
                                //   ),
                                if (dataProjectInventoryList?[index]
                                        .isCollapse ==
                                    "1")
                                  Container(
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 241, 241, 241),
                                          border: Border(
                                              top: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 1))),
                                      height: 10),
                                for (int i = 0;
                                    i <
                                        dataProjectInventoryList![index]
                                            .description!
                                            .length;
                                    i++)
                                  if (dataProjectInventoryList?[index]
                                          .isCollapse ==
                                      "1")
                                    Container(
                                      color: const Color.fromARGB(
                                          255, 241, 241, 241),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            // color: Colors.amber,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                // bottom: BorderSide(
                                                //     color: Colors.grey.shade400,
                                                //     width: 1),
                                                right: BorderSide(
                                                    color: Colors.grey.shade300,
                                                    width: 1),
                                              ),
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.22,
                                            child: Text(
                                              dataProjectInventoryList![index]
                                                      .description![i]
                                                      .gradTypeName ??
                                                  '',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              // color: Colors.cyan,
                                              border: Border(
                                                // bottom: BorderSide(
                                                //     color: Colors.grey.shade400,
                                                //     width: 1),
                                                right: BorderSide(
                                                    color: Colors.grey.shade300,
                                                    width: 1),
                                              ),
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.22,
                                            child: Text(
                                              dataProjectInventoryList![index]
                                                  .description![i]
                                                  .totalQuantity!
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Container(
                                            // color: Colors.amber,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                // bottom: BorderSide(
                                                //     color: Colors.grey.shade400,
                                                //     width: 1),
                                                right: BorderSide(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.22,
                                            child: Text(
                                              dataProjectInventoryList![index]
                                                  .description![i]
                                                  .totalConsum!
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                  // bottom: BorderSide(
                                                  //     color: Colors.grey.shade400,
                                                  //     width: 1),
                                                  // right: BorderSide(
                                                  //     color: Colors.grey.shade400,
                                                  //     width: 1),
                                                  ),
                                            ),
                                            // color: Colors.cyan,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.22,
                                            child: Text(
                                              dataProjectInventoryList![index]
                                                  .description![i]
                                                  .totalRemaing!
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.transparent,
                                          )
                                        ],
                                      ),
                                    ),
                                if (dataProjectInventoryList?[index]
                                        .isCollapse ==
                                    "1")
                                  Container(
                                    color: const Color.fromARGB(
                                        255, 241, 241, 241),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          // color: Colors.amber,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.44,
                                          child: Text(
                                            // 'Stock In Value : ₹${dataProjectInventoryList![index].totalStockInValue}',
                                            'Stock In Value : ${currencyFormat.format(double.parse(dataProjectInventoryList![index].totalStockInValue.toStringAsFixed(2)))}',

                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        SizedBox(
                                          // color: Colors.cyan,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.44,
                                          child: Text(
                                            // 'Remaining Stock Value : ₹${dataProjectInventoryList![index].totalPoValue}',
                                            'Remaining Stock Value : ${currencyFormat.format(double.parse(dataProjectInventoryList![index].totalPoValue.toStringAsFixed(2)))}',

                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.transparent,
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopDateRangeDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const _DesktopDateRangeDialog({
    required this.initialStart,
    required this.initialEnd,
  });

  @override
  State<_DesktopDateRangeDialog> createState() =>
      _DesktopDateRangeDialogState();
}

class _DesktopDateRangeDialogState extends State<_DesktopDateRangeDialog> {
  List<DateTime?> range = [];

  @override
  void initState() {
    super.initState();
    range = [widget.initialStart, widget.initialEnd];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Date Range Picker",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CalendarDatePicker2(
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.range,
                  selectedRangeHighlightColor: Colors.purple.shade200,
                  // selectedRangeBackgroundColor: Colors.purple.shade200,
                  selectedDayHighlightColor: Colors.purple,
                  selectedDayTextStyle: const TextStyle(color: Colors.white),
                ),
                value: range,
                onValueChanged: (values) => setState(() => range = values),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      foregroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, range),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
