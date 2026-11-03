// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stallion/models/get_project_account_management.dart';
// import 'package:stallion/models/get_project_wo_request.dart';
// import 'package:stallion/models/notification_filter.dart';
// import 'package:stallion/models/notification_response.dart';
// import 'package:stallion/models/sales_lead_filter.dart';
// import 'package:stallion/ui/custom_loading/custom_loading.dart';
// import 'package:stallion/ui/views/accountmanagement/accountmanagement.dart';
// import 'package:stallion/ui/views/accountmanagement/worequested.dart';
// import 'package:stallion/ui/views/mycontracts/mycontractdetailview.dart';
// import 'package:stallion/ui/views/permission/permissions.dart';
// import 'package:stallion/ui/views/rccstructure/dpr/daily_progress_report.dart';
// import 'package:stallion/ui/views/salesmanagement/salesmainview.dart';
// import 'package:stallion/ui/views/task_manager/task_details.dart';
// import 'package:stallion/utils/api_network_call.dart';
// import 'package:stallion/utils/app_url.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({
//     super.key,
//     this.projectId,
//     this.towarId,
//     this.projectName,
//     this.towarName,
//     this.userType,
//   });

//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? userType;

//   final String? towarName;

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   NetworkHandler apiNetworkHandler = NetworkHandler();
//   TextEditingController searchController = TextEditingController();
//   String searchText = '';
//   // List<FilterList>? filteredList = [];
//   List<NotificationFillter>? notificationFillter = [];
//   List<NotificationFillterDetail>? filterListData = [];
//   List<NotificationFillterDetail>? leftDrawerData;
//   String searchTermValue = '';
//   List<WoOrderList>? woOrderList = [];
//   int filterListSelected = -1;

//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   List<NotificationList>? notificationListResponse = [];
//   Future<ResponseGetProjectAccountManagement?> fetchNotifications() async {
//     CustomLoading.progressDialog(isLoading: true, context: context);
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');

//     Map<String, String> data = {
//       "user_id": userId ?? '',
//       "user_type": widget.userType ?? '0',
//     };

//     if (kDebugMode) {
//       print(data);
//     }

//     var response = await apiNetworkHandler.post(AppUrl.getNotifications, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = notificationResponseFromJson(response.body);
//       if (kDebugMode) {
//         print(dataModel.response?.errorCode);
//       }
//       if (dataModel.response?.errorCode == "0") {
//         //return dataModel.response;
//         setState(() {
//           notificationListResponse = dataModel.response?.notificationList;
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       CustomLoading.progressDialog(isLoading: false, context: context);

//       return null;
//     }
//     CustomLoading.progressDialog(isLoading: false, context: context);

//     return null;
//   }

//   Future<ResponseGetProjectAccountManagement?> getNotificationFillter() async {
//     // CustomLoading.progressDialog(isLoading: true, context: context);
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');
//     String? loginType = prefs.getString('loginType');

//     Map<String, String> data = {
//       "user_id": userId ?? '',
//       "login_type": loginType ?? '',
//     };

//     if (kDebugMode) {
//       print(data);
//     }

//     var response =
//         await apiNetworkHandler.post(AppUrl.wsGetNotificationFillter, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = notificationFilterFromJson(response.body);
//       if (dataModel.response?.errorCode == "0") {
//         //inspect(invensterFilter);
//         setState(() {
//           leftDrawerData = [];
//           notificationFillter = dataModel.response?.notificationFillter;
//           filterListData = dataModel.response?.notificationFillter?[0].details;
//           // PurpleDetail temp = PurpleDetail(
//           //   id: "0",
//           //   name: dataModel.response?.notificationFillter?[0].name,
//           //   details: [],
//           // );
//           leftDrawerData =
//               dataModel.response?.notificationFillter?[0].details?[0].details;
//           // leftDrawerData?.add(temp);
//           // leftDrawerData = [temp, ...?leftDrawerData];
//           // filterListData = dataModel.response?.filterList;
//           print(filterListData?.length);
//         });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       // CustomLoading.progressDialog(isLoading: false, context: context);

//       return null;
//     }
//     // CustomLoading.progressDialog(isLoading: false, context: context);

//     return null;
//   }

//   List<NotificationFillterDetail>? filteredProjects() {
//     if (searchText.isEmpty) {
//       return filterListData;
//     }
//     return filterListData!.where((project) {
//       return project.name!.toLowerCase().contains(searchText.toLowerCase());
//     }).toList();
//   }

//   List<NotificationFillterDetail> filterSelectedItems(
//       List<NotificationFillterDetail>? items) {
//     if (items == null) {
//       return [];
//     }

//     return items
//         .where(
//             (item) => item.isSelected == true) // Filter for isSelected == true
//         .map((item) => NotificationFillterDetail(
//               id: item.id,
//               name: item.name,
//               isSelected: item.isSelected,
//               details: filterSelectedItems(
//                   item.details), // Recursively filter nested details
//             ))
//         .toList(); // Convert back to a list
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       fetchNotifications();
//       getNotificationFillter();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     String calDateTime({required DateTime dateTime}) {
//       // DateTime dateTime = DateTime.parse(dateTimeString);

//       DateTime currentTime = DateTime.now();
//       Duration difference = currentTime.difference(dateTime);
//       if (difference.inHours < 24) {
//         if (difference.inHours < 1) {
//           if (difference.inMinutes < 1) {
//             return 'Less than 1 minute ago';
//           } else {
//             int minutesAgo = difference.inMinutes;
//             return '$minutesAgo minutes ago';
//           }
//         } else {
//           int hoursAgo = difference.inHours;
//           return '$hoursAgo hours ago';
//         }
//       } else {
//         int daysAgo = difference.inDays;
//         return '$daysAgo days ago';
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text('NOTIFICATIONS',
//             style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
//         // leading: IconButton(
//         //   icon: const Icon(Icons.arrow_back, color: Colors.white),
//         //   onPressed: () {
//         //     Navigator.maybePop(context);
//         //   },
//         // ),
//         actions: [
//           // if (widget.flagRedirect! != 'Verified' &&
//           //     widget.flagRedirect! != 'Assigned')
//           // if (widget.flagRedirect! != 'Verified')
//           InkWell(
//             onTap: () {
//               searchController.clear();
//               setState(() {
//                 searchText = '';
//               });
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return StatefulBuilder(
//                       builder: (context, setState1) {
//                         return AlertDialog(
//                             elevation: 0,
//                             shadowColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(
//                                   8), // Set radius to zero
//                             ),
//                             titlePadding:
//                                 const EdgeInsets.symmetric(vertical: 0),
//                             actionsPadding: const EdgeInsets.only(bottom: 0),
//                             contentPadding:
//                                 const EdgeInsets.symmetric(horizontal: 0),
//                             actionsAlignment: MainAxisAlignment.center,
//                             title: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 5),
//                               decoration: const BoxDecoration(
//                                   color: Colors.black,
//                                   borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(8),
//                                       topRight: Radius.circular(8))),
//                               child: const Text(
//                                 "FILTER",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             actions: <Widget>[
//                               Row(
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       searchController.clear();
//                                       setState(() {
//                                         searchText = "";
//                                       });
//                                       // for (FilterList filter
//                                       //     in filterListData!) {
//                                       //   filter.ct = 0;
//                                       //   for (Detail detail in filter.details!) {
//                                       //     setState1(() {
//                                       //       detail.isSelected = false;
//                                       //     });
//                                       //   }
//                                       // }
//                                       setState1(() {
//                                         // offset = '0';

//                                         // filteredList = [];
//                                         searchTermValue = '';
//                                         // rccBookingHistory = [];
//                                       });

//                                       // filteredList = [];
//                                       woOrderList = [];

//                                       // fetchProjectWoRequested();
//                                       // Navigator.of(context).pop();
//                                     },
//                                     child: Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           0.3,
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 4),
//                                       decoration: const BoxDecoration(
//                                           color: Colors.black,
//                                           border: Border(
//                                               right: BorderSide(
//                                                   color: Colors.white)),
//                                           borderRadius: BorderRadius.only(
//                                               bottomLeft: Radius.circular(8))),
//                                       child: const Text(
//                                         "RESET",
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.white,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                   InkWell(
//                                     onTap: () {
//                                       // Navigator.of(context).pop();

//                                       // filteredList = [];

//                                       // Filter the data
//                                       // for (FilterList filter
//                                       //     in filterListData!) {
//                                       //   List<Detail>? details = [];
//                                       //   for (Detail detail in filter.details!) {
//                                       //     if (detail.isSelected == true) {
//                                       //       details.add(detail);
//                                       //     }
//                                       //   }
//                                       //   // Add filtered details to the filteredList
//                                       //   filteredList?.add(FilterList(
//                                       //     name: filter.name,
//                                       //     id: filter.id,
//                                       //     details: details,
//                                       //   ));
//                                       // }

//                                       // print(jsonEncode(filteredList));

//                                       setState1(() {
//                                         // offset = '0';
//                                         searchTermValue = '';
//                                         woOrderList = [];
//                                         // rccBookingHistory = [];
//                                       });
//                                       // fetchProjectWoRequested()
//                                       //     .then((value) => {
//                                       //           Navigator.of(context).pop(),
//                                       //         });
//                                       // inspect(filteredProjects());
//                                       // print(jsonEncode(filteredProjects()));
//                                       final selectedItems =
//                                           filterSelectedItems(leftDrawerData);
//                                       // Now you can print or send this in an API
//                                       print(jsonEncode(selectedItems));
//                                     },
//                                     child: Container(
//                                       width: MediaQuery.of(context).size.width *
//                                           0.3,
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 4),
//                                       decoration: const BoxDecoration(
//                                           color: Colors.black,
//                                           borderRadius: BorderRadius.only(
//                                               bottomRight: Radius.circular(8))),
//                                       child: const Text(
//                                         "APPLY FILTER",
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.white,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ],
//                             content: StatefulBuilder(builder:
//                                 (BuildContext context1, StateSetter setState) {
//                               return SizedBox(
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.6,
//                                 width: MediaQuery.of(context).size.width * 0.6,
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                           height: MediaQuery.of(context1)
//                                                   .size
//                                                   .height *
//                                               0.6,
//                                           width: MediaQuery.of(context1)
//                                                   .size
//                                                   .width *
//                                               0.2,
//                                           color: Colors.grey.shade300,
//                                           // color: Colors.amber,
//                                           child: SingleChildScrollView(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 InkWell(
//                                                   onTap: () {
//                                                     setState1(() {
//                                                       searchText = "";
//                                                       searchController.clear();
//                                                       filterListData =
//                                                           notificationFillter?[
//                                                                   0]
//                                                               .details;
//                                                       filterListSelected = -1;
//                                                       //   searchText = '';
//                                                       //   searchController
//                                                       //       .clear();
//                                                     });
//                                                   },
//                                                   child: Container(
//                                                     width:
//                                                         MediaQuery.of(context1)
//                                                                 .size
//                                                                 .width *
//                                                             0.2,
//                                                     // color: Colors.white,
//                                                     decoration: BoxDecoration(
//                                                       color: -1 ==
//                                                               filterListSelected
//                                                           ? Colors.white
//                                                           : Colors.transparent,
//                                                       // border: Border.all(
//                                                       //     color: Colors.black),
//                                                     ),
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                         vertical: 14,
//                                                         horizontal: 40),
//                                                     child: Row(
//                                                       children: [
//                                                         Text(
//                                                           '${notificationFillter?[0].name}',
//                                                           style:
//                                                               const TextStyle(
//                                                             fontSize: 16,
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                           ),
//                                                         ),
//                                                         // if (filterListData![i]
//                                                         //         .ct >
//                                                         //     0)
//                                                         //   Padding(
//                                                         //     padding:
//                                                         //         const EdgeInsets
//                                                         //             .only(
//                                                         //             left:
//                                                         //                 7.0),
//                                                         //     child: Container(
//                                                         //       height: 5,
//                                                         //       width: 5,
//                                                         //       decoration: BoxDecoration(
//                                                         //           borderRadius:
//                                                         //               BorderRadius.circular(
//                                                         //                   100),
//                                                         //           color: Colors
//                                                         //               .black),
//                                                         //     ),
//                                                         //   )
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 for (int i = 0;
//                                                     i < leftDrawerData!.length;
//                                                     i++)
//                                                   InkWell(
//                                                     onTap: () {
//                                                       setState1(() {
//                                                         searchText = "";
//                                                         searchController
//                                                             .clear();
//                                                         filterListData =
//                                                             leftDrawerData?[i]
//                                                                 .details;
//                                                         //                                                 notificationFillter = dataModel.response?.notificationFillter;
//                                                         // filterListData = dataModel.response?.notificationFillter?[0].details;
//                                                         filterListSelected = i;
//                                                         //   searchText = '';
//                                                         //   searchController
//                                                         //       .clear();
//                                                       });
//                                                     },
//                                                     child: Container(
//                                                       width: MediaQuery.of(
//                                                                   context1)
//                                                               .size
//                                                               .width *
//                                                           0.2,
//                                                       // color: Colors.white,
//                                                       decoration: BoxDecoration(
//                                                         color: i ==
//                                                                 filterListSelected
//                                                             ? Colors.white
//                                                             : Colors
//                                                                 .transparent,
//                                                         // border: Border.all(
//                                                         //     color:
//                                                         //         Colors.black),
//                                                       ),
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           vertical: 14,
//                                                           horizontal: 40),
//                                                       child: Row(
//                                                         children: [
//                                                           Text(
//                                                             '${leftDrawerData?[i].name}',
//                                                             style:
//                                                                 const TextStyle(
//                                                               fontSize: 16,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                             ),
//                                                           ),
//                                                           if (leftDrawerData?[i]
//                                                                   .ct !=
//                                                               0)
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .only(
//                                                                       left:
//                                                                           7.0),
//                                                               child: Container(
//                                                                 height: 5,
//                                                                 width: 5,
//                                                                 decoration: BoxDecoration(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             100),
//                                                                     color: Colors
//                                                                         .black),
//                                                               ),
//                                                             )
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   )
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           // height: 300,
//                                           // width: 455,
//                                           height: MediaQuery.of(context1)
//                                                   .size
//                                                   .height *
//                                               0.6,
//                                           width: MediaQuery.of(context1)
//                                                   .size
//                                                   .width *
//                                               0.4,
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: [
//                                               const SizedBox(height: 8),
//                                               Container(
//                                                 height: 36,
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 40),
//                                                 child: TextFormField(
//                                                   controller: searchController,
//                                                   onChanged: (value) {
//                                                     setState(() {
//                                                       // filteredProjects();
//                                                       searchText = value;
//                                                     });
//                                                   },
//                                                   style: const TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 13.0),
//                                                   decoration:
//                                                       const InputDecoration(
//                                                     prefixIcon: Icon(
//                                                       Icons.search,
//                                                       size: 22,
//                                                     ),
//                                                     contentPadding:
//                                                         EdgeInsets.only(
//                                                             bottom: 0,
//                                                             left: 12),
//                                                     // border: OutlineInputBorder(
//                                                     //   borderSide: BorderSide(color: Colors.transparent),
//                                                     // ),
//                                                     border: OutlineInputBorder(
//                                                       borderRadius:
//                                                           BorderRadius.all(
//                                                               Radius.circular(
//                                                                   8.0)),
//                                                     ),
//                                                     hintText: 'Search',
//                                                     hintStyle: TextStyle(
//                                                       color: Color.fromARGB(
//                                                           255, 116, 116, 116),
//                                                       fontSize: 13.0,
//                                                       fontWeight:
//                                                           FontWeight.w200,
//                                                       fontFamily:
//                                                           'HelveticaNeue',
//                                                     ),
//                                                     // suffixIcon: Icon(
//                                                     //   Icons.calendar_month_outlined,
//                                                     // ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               // const SizedBox(
//                                               //   height: 10,
//                                               // ),
//                                               Divider(
//                                                   color: Colors.grey.shade300),
//                                               //      height: 300,
//                                               // width: 282,
//                                               // color: Colors.cyan,
//                                               SizedBox(
//                                                 // height: 240,
//                                                 height: (MediaQuery.of(context1)
//                                                             .size
//                                                             .height *
//                                                         0.6) -
//                                                     62,
//                                                 // width: 482,
//                                                 // color: Colors.cyan,
//                                                 child: SingleChildScrollView(
//                                                   child: Column(
//                                                     children: [
//                                                       for (int k = 0;
//                                                           k <
//                                                               filteredProjects()!
//                                                                   .length;
//                                                           k++)
//                                                         InkWell(
//                                                           onTap: () {
//                                                             setState1(() {
//                                                               if (filteredProjects()?[
//                                                                           k]
//                                                                       .id ==
//                                                                   "0") {
//                                                                 // if (filterListSelected ==
//                                                                 //     -1) {
//                                                                 //   leftDrawerData =
//                                                                 //       filteredProjects()?[
//                                                                 //               k]
//                                                                 //           .details;
//                                                                 // }

//                                                                 // leftDrawerData![
//                                                                 //         filterListSelected]
//                                                                 //     .ct++;
//                                                                 filteredProjects()?[
//                                                                             k]
//                                                                         .isSelected =
//                                                                     filteredProjects()?[k].isSelected ==
//                                                                             false
//                                                                         ? true
//                                                                         : false;
//                                                                 if (filteredProjects()?[
//                                                                             k]
//                                                                         .isSelected ==
//                                                                     true) {
//                                                                   for (int p =
//                                                                           1;
//                                                                       p <
//                                                                           filteredProjects()!
//                                                                               .length;
//                                                                       p++) {
//                                                                     filteredProjects()?[p]
//                                                                             .isSelected =
//                                                                         false;
//                                                                   }
//                                                                 }
//                                                                 // filterListData?[
//                                                                 //             k]
//                                                                 //         .isSelected =
//                                                                 //     true;
//                                                               } else {
//                                                                 if (filteredProjects()?[0]
//                                                                             .id ==
//                                                                         "0" &&
//                                                                     filteredProjects()?[0]
//                                                                             .isSelected ==
//                                                                         true) {
//                                                                   filteredProjects()?[
//                                                                               0]
//                                                                           .isSelected =
//                                                                       false;
//                                                                 }
//                                                                 // if (filterListSelected ==
//                                                                 //     -1) {
//                                                                 //   leftDrawerData =
//                                                                 //       filteredProjects()?[
//                                                                 //               k]
//                                                                 //           .details;
//                                                                 // }
//                                                                 filteredProjects()?[
//                                                                             k]
//                                                                         .isSelected =
//                                                                     filteredProjects()?[k].isSelected ==
//                                                                             false
//                                                                         ? true
//                                                                         : false;
//                                                               }

//                                                               if (filterListSelected ==
//                                                                   -1) {
//                                                                 print(filteredProjects()?[
//                                                                         0]
//                                                                     .isSelected);
//                                                                 // if (filteredProjects()?[
//                                                                 //             0]
//                                                                 //         .isSelected ==
//                                                                 //     true) {
//                                                                 if (k == 0) {
//                                                                   leftDrawerData =
//                                                                       notificationFillter?[
//                                                                               0]
//                                                                           .details?[
//                                                                               0]
//                                                                           .details;
//                                                                   //     //     filteredProjects()?[
//                                                                   //     //             0]
//                                                                   //     //         .details;
//                                                                   //     filterListData?[
//                                                                   //             k]
//                                                                   //         .details?[
//                                                                   //             0]
//                                                                   //         .details;
//                                                                   // inspect(filterListData?[
//                                                                   //         0]
//                                                                   //     .details?[
//                                                                   //         0]
//                                                                   //     .details);
//                                                                   inspect(notificationFillter?[
//                                                                           0]
//                                                                       .details?[
//                                                                           0]
//                                                                       .details);
//                                                                 } else {
//                                                                   // leftDrawerData =
//                                                                   //     [
//                                                                   //   ...?leftDrawerData,
//                                                                   //   ...?filteredProjects()?[
//                                                                   //           k]
//                                                                   //       .details
//                                                                   // ];
//                                                                   leftDrawerData
//                                                                       ?.clear();
//                                                                   for (int q =
//                                                                           0;
//                                                                       q <
//                                                                           filteredProjects()!
//                                                                               .length;
//                                                                       q++) {
//                                                                     if (filteredProjects()![q]
//                                                                             .isSelected ==
//                                                                         true) {
//                                                                       print(filteredProjects()![
//                                                                               q]
//                                                                           .name);
//                                                                       leftDrawerData =
//                                                                           [
//                                                                         ...?leftDrawerData,
//                                                                         ...?filteredProjects()?[q]
//                                                                             .details
//                                                                       ];
//                                                                     }
//                                                                   }
//                                                                 }

//                                                                 List<NotificationFillterDetail>?
//                                                                     uniqueArray =
//                                                                     [];

//                                                                 for (NotificationFillterDetail item
//                                                                     in leftDrawerData!) {
//                                                                   String? name =
//                                                                       item.name;

//                                                                   if (name !=
//                                                                       null) {
//                                                                     bool
//                                                                         alreadyExists =
//                                                                         uniqueArray.any((element) =>
//                                                                             element.name ==
//                                                                             name);

//                                                                     if (!alreadyExists) {
//                                                                       uniqueArray
//                                                                           .add(
//                                                                               item);
//                                                                     }
//                                                                   }
//                                                                 }
//                                                                 leftDrawerData =
//                                                                     uniqueArray;
//                                                                 // }

//                                                                 // print(leftDrawerData![
//                                                                 //         filterListSelected]
//                                                                 //     .name);
//                                                                 // dataModel.response?.notificationFillter?[0].details?[0].details
//                                                                 //   // if (filterListSelected == 0) {
//                                                                 //   //   bool? temp = filterListData![filterListSelected].details![k].isSelected;
//                                                                 //   //   filterListData?[filterListSelected].ct = temp == true ? 0 : 1;
//                                                                 //   //   for (int p = 0; p < filteredProjects()!.length; p++) {
//                                                                 //   //     filterListData![filterListSelected].details?[p].isSelected = false;
//                                                                 //   //   }

//                                                                 //   //   filterListData![filterListSelected].details?[k].isSelected = temp == true ? false : true;
//                                                                 //   //   // filterListData![filterListSelected]
//                                                                 //   //   //     .details?[
//                                                                 //   //   //         k]
//                                                                 //   //   //     .isSelected = filterListData![filterListSelected].details?[k].isSelected ==
//                                                                 //   //   //         false
//                                                                 //   //   //     ? true
//                                                                 //   //   //     : false;
//                                                                 //   // } else {
//                                                                 //   if (filteredProjects()?[
//                                                                 //               k]
//                                                                 //           .isSelected ==
//                                                                 //       false) {
//                                                                 //     filterListData?[
//                                                                 //             filterListSelected]
//                                                                 //         .ct = filterListData![
//                                                                 //                 filterListSelected]
//                                                                 //             .ct +
//                                                                 //         1;
//                                                                 //   } else {
//                                                                 //     filterListData?[
//                                                                 //             filterListSelected]
//                                                                 //         .ct = filterListData![
//                                                                 //                 filterListSelected]
//                                                                 //             .ct -
//                                                                 //         1;
//                                                                 //   }
//                                                               }
//                                                             });
//                                                           },
//                                                           child: Container(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         40,
//                                                                     vertical:
//                                                                         5),
//                                                             child: Row(
//                                                               children: [
//                                                                 Icon(filteredProjects()?[k]
//                                                                             .isSelected ==
//                                                                         true
//                                                                     ? Icons
//                                                                         .check_box_rounded
//                                                                     : Icons
//                                                                         .check_box_outline_blank_outlined),
//                                                                 const SizedBox(
//                                                                     width: 10),
//                                                                 Text(
//                                                                   filteredProjects()?[
//                                                                               k]
//                                                                           .name ??
//                                                                       '',
//                                                                   style:
//                                                                       const TextStyle(
//                                                                     fontSize:
//                                                                         16,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w400,
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               );
//                             }));
//                       },
//                     );
//                   });
//             },
//             child: Container(
//               child: //filteredList?.length != 0
//                   false
//                       ? Container(
//                           color: Colors.white,
//                           padding: const EdgeInsets.all(4),
//                           child: Image.asset(
//                             'images/projectmanagement/filter-sort-icon.png',
//                             height: 20,
//                           ),
//                         )
//                       : Image.asset(
//                           'images/projectmanagement/filter_black.png',
//                           height: 20,
//                         ),
//             ),
//           ),

//           const SizedBox(width: 40)
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             ListView.separated(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: notificationListResponse?.length ?? 0,
//               itemBuilder: (context, index) {
//                 NotificationList tempp = notificationListResponse![index];

//                 return InkWell(
//                   onTap: () {
//                     if (tempp.notificationType == 'generatedpr') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return DailyProgressReport(
//                               projectId: tempp.projectId,
//                               towarId: tempp.response?.towarId,
//                               projectName: tempp.projectName,
//                               towarName: tempp.projectLocation,
//                               title: tempp.response?.slabNo,
//                               slabId: tempp.response?.slabId,
//                             );
//                           },
//                         ),
//                       );
//                     } else if (tempp.notificationType == 'rccpoassign' ||
//                         tempp.notificationType == 'rccverifyorder' ||
//                         tempp.notificationType == 'work_order_list') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return AccountManagementView(
//                                 projectId: tempp.projectId,
//                                 towarId: tempp.response?['towarId'] ?? '',
//                                 projectName: tempp.projectName,
//                                 towarName: tempp.projectLocation ?? '',
//                                 navigationFlag: 'Project');
//                           },
//                         ),
//                       );
//                     } else if (tempp.notificationType == 'salemanagement' ||
//                         tempp.notificationType == 'Payment-type') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return SalesManagementView(
//                                 projectId: tempp.projectId,
//                                 towarId: tempp.response?.towarId,
//                                 projectName: tempp.projectName,
//                                 towarName: tempp.projectLocation!,
//                                 navigationFlag: 'Project');
//                           },
//                         ),
//                       );
//                     } else if (tempp.notificationType == 'createdmetting') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return TaskDetailsScreen(
//                               userTask: tempp.response!.userTask![0],
//                               projectId: tempp.projectId,
//                               towarId: tempp.response?.towarId,
//                               projectName: tempp.projectName,
//                               towarName: tempp.projectLocation!,
//                             );
//                           },
//                         ),
//                       );
//                     } else if (tempp.notificationType == 'permisson') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return Permissions(
//                               projectId: tempp.projectId,
//                               towarId: tempp.response.isEmpty
//                                   ? ""
//                                   : tempp.response!['towarId'].toString(),
//                               projectName: tempp.projectName,
//                               towarName: tempp.projectLocation,
//                             );
//                           },
//                         ),
//                       );
//                     } else if (tempp.notificationType == 'wo-ceritify-work') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return MyContractsDetailView(
//                               projectId: tempp.projectId,
//                               towarId: tempp.response.isEmpty
//                                   ? ""
//                                   : tempp.response!['towarId'].toString(),
//                               projectName: tempp.projectName,
//                               // gradeId: widget.gradeId!,
//                               // companyId: data.mstCompanyId,
//                               workorderId: tempp.response.isEmpty
//                                   ? ""
//                                   : tempp.response!['wo_order_id'].toString(),
//                               workId: tempp.response.isEmpty
//                                   ? ""
//                                   : tempp.response!['wo_order_no'].toString(),
//                               contractorName: tempp.projectLocation,
//                             );
//                           },
//                         ),
//                       );
//                     } else if (tempp.notificationType == 'wo_issued') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return WoRequestedView(
//                               projectId: tempp.projectId,
//                               towarId: widget.towarId,
//                               projectName: tempp.projectName,
//                               flagRedirect: 'Issued',
//                             );
//                           },
//                         ),
//                       );
//                     } else if (tempp.notificationType == 'wo_authenticate') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return WoRequestedView(
//                                 projectId: tempp.projectId,
//                                 towarId: widget.towarId,
//                                 projectName: tempp.projectName,
//                                 flagRedirect: 'Requested'); //Assigned
//                           },
//                         ),
//                       );
//                     } else if (tempp.notificationType == 'wo_assigned') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) {
//                             return WoRequestedView(
//                                 projectId: tempp.projectId,
//                                 towarId: widget.towarId,
//                                 projectName: tempp.projectName,
//                                 flagRedirect: 'Assigned'); //Assigned
//                           },
//                         ),
//                       );
//                     }
//                   },
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         tempp.msg ?? '',
//                         textAlign: TextAlign.left,
//                         style:
//                             const TextStyle(color: Colors.black, fontSize: 16),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 40),
//                         width: double.maxFinite,
//                         child: Text(
//                           calDateTime(
//                               dateTime: tempp.createdAt ?? DateTime.now()),
//                           style: const TextStyle(fontSize: 16),
//                           textAlign: TextAlign.right,
//                         ),
//                       )
//                     ],
//                   ),
//                 );
//               },
//               separatorBuilder: (context, index) => const Divider(
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

///////////////////
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_project_account_management.dart';
import 'package:stallion/models/get_project_wo_request.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/notification_filter.dart';
import 'package:stallion/models/notification_response.dart';
import 'package:stallion/models/sales_lead_filter.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/accountmanagement/accountmanagement.dart';
import 'package:stallion/ui/views/accountmanagement/worequested.dart';
import 'package:stallion/ui/views/mycontracts/mycontractdetailview.dart';
import 'package:stallion/ui/views/permission/permissions.dart';
import 'package:stallion/ui/views/rccstructure/dpr/daily_progress_report.dart';
import 'package:stallion/ui/views/salesmanagement/salesmainview.dart';
import 'package:stallion/ui/views/task_manager/task_details.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.userType,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? userType;

  final String? towarName;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NetworkHandler apiNetworkHandler = NetworkHandler();
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  // List<FilterList>? filteredList = [];
  List<NotificationFillter>? notificationFillter = [];
  List<NotificationFillter>? filterListData = [];
  int leftDrawerIndex = 0;
  // List<NotificationFillterDetail>? leftDrawerData;
  String searchTermValue = '';
  // List<WoOrderList>? woOrderList = [];
  int filterListSelected = -1;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<NotificationList>? notificationListResponse = [];
  Future<ResponseGetProjectAccountManagement?> fetchNotifications() async {
    CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '',
      "user_type": widget.userType ?? '0',
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.getNotifications, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = notificationResponseFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        setState(() {
          notificationListResponse = dataModel.response?.notificationList;
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      CustomLoading.progressDialog(isLoading: false, context: context);

      return null;
    }
    CustomLoading.progressDialog(isLoading: false, context: context);

    return null;
  }

  Future<ResponseGetProjectAccountManagement?> getNotificationFillter() async {
    // CustomLoading.progressDialog(isLoading: true, context: context);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginType = prefs.getString('loginType');

    Map<String, String> data = {
      "user_id": userId ?? '',
      "login_type": loginType ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.wsGetNotificationFillter, data);
    if (kDebugMode) {
      print(response.statusCode);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = notificationFilterFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        //inspect(invensterFilter);
        setState(() {
          // leftDrawerData = [];
          notificationFillter = dataModel.response?.notificationFillter;
          // filterListData = dataModel.response?.notificationFillter?[0].details;

          //left work
          // leftDrawerData =
          //     dataModel.response?.notificationFillter?[0].details?[0].details;
          // leftDrawerData?.add(temp);
          // leftDrawerData = [temp, ...?leftDrawerData];
          // filterListData = dataModel.response?.filterList;
          print(filterListData?.length);
        });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      // CustomLoading.progressDialog(isLoading: false, context: context);

      return null;
    }
    // CustomLoading.progressDialog(isLoading: false, context: context);

    return null;
  }

  List<NotificationFillter>? filteredProjects() {
    if (searchText.isEmpty) {
      return filterListData;
    }
    return filterListData!.where((project) {
      return project.name!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  List<NotificationFillter> filterSelectedItems(
      List<NotificationFillter>? items) {
    if (items == null) {
      return [];
    }

    return items
        .where(
            (item) => item.isSelected == true) // Filter for isSelected == true
        .map((item) => NotificationFillter(
              id: item.id,
              name: item.name,
              isSelected: item.isSelected,
              details: filterSelectedItems(
                  item.details), // Recursively filter nested details
            ))
        .toList(); // Convert back to a list
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchNotifications();
      getNotificationFillter();
    });
  }

  @override
  Widget build(BuildContext context) {
    String calDateTime({required DateTime dateTime}) {
      // DateTime dateTime = DateTime.parse(dateTimeString);

      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(dateTime);
      if (difference.inHours < 24) {
        if (difference.inHours < 1) {
          if (difference.inMinutes < 1) {
            return 'Less than 1 minute ago';
          } else {
            int minutesAgo = difference.inMinutes;
            return '$minutesAgo minutes ago';
          }
        } else {
          int hoursAgo = difference.inHours;
          return '$hoursAgo hours ago';
        }
      } else {
        int daysAgo = difference.inDays;
        return '$daysAgo days ago';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('NOTIFICATIONS',
            style: TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () {
        //     Navigator.maybePop(context);
        //   },
        // ),
        actions: [
          // if (widget.flagRedirect! != 'Verified' &&
          //     widget.flagRedirect! != 'Assigned')
          // if (widget.flagRedirect! != 'Verified')
          InkWell(
            onTap: () {
              searchController.clear();
              setState(() {
                searchText = '';
              });
              showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState1) {
                        return AlertDialog(
                            elevation: 0,
                            shadowColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Set radius to zero
                            ),
                            titlePadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            actionsPadding: const EdgeInsets.only(bottom: 0),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            actionsAlignment: MainAxisAlignment.center,
                            title: Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8))),
                              child: const Text(
                                "FILTER",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            actions: <Widget>[
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      searchController.clear();
                                      setState(() {
                                        searchText = "";
                                      });
                                      // for (FilterList filter
                                      //     in filterListData!) {
                                      //   filter.ct = 0;
                                      //   for (Detail detail in filter.details!) {
                                      //     setState1(() {
                                      //       detail.isSelected = false;
                                      //     });
                                      //   }
                                      // }
                                      setState1(() {
                                        // offset = '0';

                                        // filteredList = [];
                                        searchTermValue = '';
                                        // rccBookingHistory = [];
                                      });

                                      // filteredList = [];
                                      // woOrderList = [];

                                      // fetchProjectWoRequested();
                                      // Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: const BoxDecoration(
                                          color: Colors.black,
                                          border: Border(
                                              right: BorderSide(
                                                  color: Colors.white)),
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(8))),
                                      child: const Text(
                                        "RESET",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // Navigator.of(context).pop();

                                      // filteredList = [];

                                      // Filter the data
                                      // for (FilterList filter
                                      //     in filterListData!) {
                                      //   List<Detail>? details = [];
                                      //   for (Detail detail in filter.details!) {
                                      //     if (detail.isSelected == true) {
                                      //       details.add(detail);
                                      //     }
                                      //   }
                                      //   // Add filtered details to the filteredList
                                      //   filteredList?.add(FilterList(
                                      //     name: filter.name,
                                      //     id: filter.id,
                                      //     details: details,
                                      //   ));
                                      // }

                                      // print(jsonEncode(filteredList));

                                      setState1(() {
                                        // offset = '0';
                                        searchTermValue = '';
                                        // woOrderList = [];
                                        // rccBookingHistory = [];
                                      });
                                      // fetchProjectWoRequested()
                                      //     .then((value) => {
                                      //           Navigator.of(context).pop(),
                                      //         });
                                      // inspect(filteredProjects());
                                      // print(jsonEncode(filteredProjects()));
                                      // final selectedItems =
                                      //     filterSelectedItems(leftDrawerData);
                                      // // Now you can print or send this in an API
                                      // print(jsonEncode(selectedItems));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(8))),
                                      child: const Text(
                                        "APPLY FILTER",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                            content: StatefulBuilder(builder:
                                (BuildContext context1, StateSetter setState) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context1)
                                                  .size
                                                  .height *
                                              0.6,
                                          width: MediaQuery.of(context1)
                                                  .size
                                                  .width *
                                              0.2,
                                          color: Colors.grey.shade300,
                                          // color: Colors.amber,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //   InkWell(
                                                //     onTap: () {
                                                //       setState1(() {
                                                //         searchText = "";
                                                //         searchController.clear();
                                                //         filterListData =
                                                //             notificationFillter?[
                                                //                     0]
                                                //                 .details;
                                                //         filterListSelected = -1;
                                                //         //   searchText = '';
                                                //         //   searchController
                                                //         //       .clear();
                                                //       });
                                                //     },
                                                //     child: Container(
                                                //       width:
                                                //           MediaQuery.of(context1)
                                                //                   .size
                                                //                   .width *
                                                //               0.2,
                                                //       // color: Colors.white,
                                                //       decoration: BoxDecoration(
                                                //         color: -1 ==
                                                //                 filterListSelected
                                                //             ? Colors.white
                                                //             : Colors.transparent,
                                                //         // border: Border.all(
                                                //         //     color: Colors.black),
                                                //       ),
                                                //       padding: const EdgeInsets
                                                //           .symmetric(
                                                //           vertical: 14,
                                                //           horizontal: 40),
                                                //       child: Row(
                                                //         children: [
                                                //           Text(
                                                //             '${notificationFillter?[0].name}',
                                                //             style:
                                                //                 const TextStyle(
                                                //               fontSize: 16,
                                                //               fontWeight:
                                                //                   FontWeight.w600,
                                                //             ),
                                                //           ),
                                                //           // if (filterListData![i]
                                                //           //         .ct >
                                                //           //     0)
                                                //           //   Padding(
                                                //           //     padding:
                                                //           //         const EdgeInsets
                                                //           //             .only(
                                                //           //             left:
                                                //           //                 7.0),
                                                //           //     child: Container(
                                                //           //       height: 5,
                                                //           //       width: 5,
                                                //           //       decoration: BoxDecoration(
                                                //           //           borderRadius:
                                                //           //               BorderRadius.circular(
                                                //           //                   100),
                                                //           //           color: Colors
                                                //           //               .black),
                                                //           //     ),
                                                //           //   )
                                                //         ],
                                                //       ),
                                                //     ),
                                                //   ),
                                                for (int i = 0;
                                                    i <
                                                        notificationFillter![0]
                                                            .details![
                                                                leftDrawerIndex]
                                                            .details!
                                                            .length;
                                                    i++)
                                                  InkWell(
                                                    onTap: () {
                                                      setState1(() {
                                                        searchText = "";
                                                        searchController
                                                            .clear();
                                                        // filterListData =
                                                        //     leftDrawerData?[i]
                                                        //         .details;
                                                        //                                                 notificationFillter = dataModel.response?.notificationFillter;
                                                        // filterListData = dataModel.response?.notificationFillter?[0].details;
                                                        filterListSelected = i;
                                                        //   searchText = '';
                                                        //   searchController
                                                        //       .clear();
                                                      });
                                                    },
                                                    child: Container(
                                                      width: MediaQuery.of(
                                                                  context1)
                                                              .size
                                                              .width *
                                                          0.2,
                                                      // color: Colors.white,
                                                      decoration: BoxDecoration(
                                                        color: i ==
                                                                filterListSelected
                                                            ? Colors.white
                                                            : Colors
                                                                .transparent,
                                                        // border: Border.all(
                                                        //     color:
                                                        //         Colors.black),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 14,
                                                          horizontal: 40),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            '${notificationFillter![0].details![0].details?[i].name}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          // if (leftDrawerData?[i]
                                                          //         .ct !=
                                                          //     0)
                                                          // Padding(
                                                          //   padding:
                                                          //       const EdgeInsets
                                                          //           .only(
                                                          //           left:
                                                          //               7.0),
                                                          //   child: Container(
                                                          //     height: 5,
                                                          //     width: 5,
                                                          //     decoration: BoxDecoration(
                                                          //         borderRadius:
                                                          //             BorderRadius.circular(
                                                          //                 100),
                                                          //         color: Colors
                                                          //             .black),
                                                          //   ),
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          // height: 300,
                                          // width: 455,
                                          height: MediaQuery.of(context1)
                                                  .size
                                                  .height *
                                              0.6,
                                          width: MediaQuery.of(context1)
                                                  .size
                                                  .width *
                                              0.4,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              Container(
                                                height: 36,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 40),
                                                child: TextFormField(
                                                  controller: searchController,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      // filteredProjects();
                                                      searchText = value;
                                                    });
                                                  },
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13.0),
                                                  decoration:
                                                      const InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.search,
                                                      size: 22,
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 0,
                                                            left: 12),
                                                    // border: OutlineInputBorder(
                                                    //   borderSide: BorderSide(color: Colors.transparent),
                                                    // ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8.0)),
                                                    ),
                                                    hintText: 'Search',
                                                    hintStyle: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 116, 116, 116),
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w200,
                                                      fontFamily:
                                                          'HelveticaNeue',
                                                    ),
                                                    // suffixIcon: Icon(
                                                    //   Icons.calendar_month_outlined,
                                                    // ),
                                                  ),
                                                ),
                                              ),
                                              // const SizedBox(
                                              //   height: 10,
                                              // ),
                                              Divider(
                                                  color: Colors.grey.shade300),
                                              //      height: 300,
                                              // width: 282,
                                              // color: Colors.cyan,
                                              SizedBox(
                                                // height: 240,
                                                height: (MediaQuery.of(context1)
                                                            .size
                                                            .height *
                                                        0.6) -
                                                    62,
                                                // width: 482,
                                                // color: Colors.cyan,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      for (int k = 0;
                                                          k <
                                                              notificationFillter![
                                                                      0]
                                                                  .details!
                                                                  .length;
                                                          k++)
                                                        InkWell(
                                                          onTap: () {
                                                            setState1(() {
                                                              leftDrawerIndex =
                                                                  k;
                                                            });
                                                            // setState1(() {
                                                            //   if (filteredProjects()?[
                                                            //               k]
                                                            //           .id ==
                                                            //       "0") {
                                                            //     // if (filterListSelected ==
                                                            //     //     -1) {
                                                            //     //   leftDrawerData =
                                                            //     //       filteredProjects()?[
                                                            //     //               k]
                                                            //     //           .details;
                                                            //     // }

                                                            //     // leftDrawerData![
                                                            //     //         filterListSelected]
                                                            //     //     .ct++;
                                                            //     filteredProjects()?[
                                                            //                 k]
                                                            //             .isSelected =
                                                            //         filteredProjects()?[k]
                                                            //                     .isSelected ==
                                                            //                 false
                                                            //             ? true
                                                            //             : false;
                                                            //     if (filteredProjects()?[
                                                            //                 k]
                                                            //             .isSelected ==
                                                            //         true) {
                                                            //       for (int p = 1;
                                                            //           p <
                                                            //               filteredProjects()!
                                                            //                   .length;
                                                            //           p++) {
                                                            //         filteredProjects()?[
                                                            //                     p]
                                                            //                 .isSelected =
                                                            //             false;
                                                            //       }
                                                            //     }
                                                            //     // filterListData?[
                                                            //     //             k]
                                                            //     //         .isSelected =
                                                            //     //     true;
                                                            //   } else {
                                                            //     if (filteredProjects()?[
                                                            //                     0]
                                                            //                 .id ==
                                                            //             "0" &&
                                                            //         filteredProjects()?[
                                                            //                     0]
                                                            //                 .isSelected ==
                                                            //             true) {
                                                            //       filteredProjects()?[
                                                            //                   0]
                                                            //               .isSelected =
                                                            //           false;
                                                            //     }
                                                            //     // if (filterListSelected ==
                                                            //     //     -1) {
                                                            //     //   leftDrawerData =
                                                            //     //       filteredProjects()?[
                                                            //     //               k]
                                                            //     //           .details;
                                                            //     // }
                                                            //     filteredProjects()?[
                                                            //                 k]
                                                            //             .isSelected =
                                                            //         filteredProjects()?[k]
                                                            //                     .isSelected ==
                                                            //                 false
                                                            //             ? true
                                                            //             : false;
                                                            //   }

                                                            //   if (filterListSelected ==
                                                            //       -1) {
                                                            //     print(filteredProjects()?[
                                                            //             0]
                                                            //         .isSelected);
                                                            //     // if (filteredProjects()?[
                                                            //     //             0]
                                                            //     //         .isSelected ==
                                                            //     //     true) {
                                                            //     if (k == 0) {
                                                            //       leftDrawerData =
                                                            //           notificationFillter?[
                                                            //                   0]
                                                            //               .details?[
                                                            //                   0]
                                                            //               .details;
                                                            //       //     //     filteredProjects()?[
                                                            //       //     //             0]
                                                            //       //     //         .details;
                                                            //       //     filterListData?[
                                                            //       //             k]
                                                            //       //         .details?[
                                                            //       //             0]
                                                            //       //         .details;
                                                            //       // inspect(filterListData?[
                                                            //       //         0]
                                                            //       //     .details?[
                                                            //       //         0]
                                                            //       //     .details);
                                                            //       inspect(notificationFillter?[
                                                            //               0]
                                                            //           .details?[0]
                                                            //           .details);
                                                            //     } else {
                                                            //       // leftDrawerData =
                                                            //       //     [
                                                            //       //   ...?leftDrawerData,
                                                            //       //   ...?filteredProjects()?[
                                                            //       //           k]
                                                            //       //       .details
                                                            //       // ];
                                                            //       leftDrawerData
                                                            //           ?.clear();
                                                            //       for (int q = 0;
                                                            //           q <
                                                            //               filteredProjects()!
                                                            //                   .length;
                                                            //           q++) {
                                                            //         if (filteredProjects()![
                                                            //                     q]
                                                            //                 .isSelected ==
                                                            //             true) {
                                                            //           print(filteredProjects()![
                                                            //                   q]
                                                            //               .name);
                                                            //           leftDrawerData =
                                                            //               [
                                                            //             ...?leftDrawerData,
                                                            //             ...?filteredProjects()?[
                                                            //                     q]
                                                            //                 .details
                                                            //           ];
                                                            //         }
                                                            //       }
                                                            //     }

                                                            //     List<NotificationFillterDetail>?
                                                            //         uniqueArray =
                                                            //         [];

                                                            //     for (NotificationFillterDetail item
                                                            //         in leftDrawerData!) {
                                                            //       String? name =
                                                            //           item.name;

                                                            //       if (name !=
                                                            //           null) {
                                                            //         bool
                                                            //             alreadyExists =
                                                            //             uniqueArray.any((element) =>
                                                            //                 element
                                                            //                     .name ==
                                                            //                 name);

                                                            //         if (!alreadyExists) {
                                                            //           uniqueArray
                                                            //               .add(
                                                            //                   item);
                                                            //         }
                                                            //       }
                                                            //     }
                                                            //     leftDrawerData =
                                                            //         uniqueArray;
                                                            //     // }

                                                            //     // print(leftDrawerData![
                                                            //     //         filterListSelected]
                                                            //     //     .name);
                                                            //     // dataModel.response?.notificationFillter?[0].details?[0].details
                                                            //     //   // if (filterListSelected == 0) {
                                                            //     //   //   bool? temp = filterListData![filterListSelected].details![k].isSelected;
                                                            //     //   //   filterListData?[filterListSelected].ct = temp == true ? 0 : 1;
                                                            //     //   //   for (int p = 0; p < filteredProjects()!.length; p++) {
                                                            //     //   //     filterListData![filterListSelected].details?[p].isSelected = false;
                                                            //     //   //   }

                                                            //     //   //   filterListData![filterListSelected].details?[k].isSelected = temp == true ? false : true;
                                                            //     //   //   // filterListData![filterListSelected]
                                                            //     //   //   //     .details?[
                                                            //     //   //   //         k]
                                                            //     //   //   //     .isSelected = filterListData![filterListSelected].details?[k].isSelected ==
                                                            //     //   //   //         false
                                                            //     //   //   //     ? true
                                                            //     //   //   //     : false;
                                                            //     //   // } else {
                                                            //     //   if (filteredProjects()?[
                                                            //     //               k]
                                                            //     //           .isSelected ==
                                                            //     //       false) {
                                                            //     //     filterListData?[
                                                            //     //             filterListSelected]
                                                            //     //         .ct = filterListData![
                                                            //     //                 filterListSelected]
                                                            //     //             .ct +
                                                            //     //         1;
                                                            //     //   } else {
                                                            //     //     filterListData?[
                                                            //     //             filterListSelected]
                                                            //     //         .ct = filterListData![
                                                            //     //                 filterListSelected]
                                                            //     //             .ct -
                                                            //     //         1;
                                                            //     //   }
                                                            //   }
                                                            // });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        40,
                                                                    vertical:
                                                                        5),
                                                            child: Row(
                                                              children: [
                                                                // Icon(notificationFillter![0]
                                                                //             .details?[
                                                                //                 k]
                                                                //             .isSelected ==
                                                                //         true
                                                                //     ? Icons
                                                                //         .check_box_rounded
                                                                //     : Icons
                                                                //         .check_box_outline_blank_outlined),
                                                                // const SizedBox(
                                                                //     width: 10),
                                                                Text(
                                                                  '''notificationFillter![0].details?[k].name''' ??
                                                                      '',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }));
                      },
                    );
                  });
            },
            child: Container(
              child: //filteredList?.length != 0
                  false
                      ? Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            'images/projectmanagement/filter-sort-icon.png',
                            height: 20,
                          ),
                        )
                      : Image.asset(
                          'images/projectmanagement/filter_black.png',
                          height: 20,
                        ),
            ),
          ),

          const SizedBox(width: 40)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: notificationListResponse?.length ?? 0,
              itemBuilder: (context, index) {
                NotificationList tempp = notificationListResponse![index];

                return InkWell(
                  onTap: () {
                    if (tempp.notificationType == 'generatedpr') {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return DailyProgressReport(
                      //         projectId: tempp.projectId,
                      //         towarId: tempp.response?.towarId,
                      //         projectName: tempp.projectName,
                      //         towarName: tempp.projectLocation,
                      //         title: tempp.response?.slabNo,
                      //         slabId: tempp.response?.slabId,
                      //       );
                      //     },
                      //   ),
                      // );
                      Navigator.of(context).pushNamed(
                        '/dailyProgressReportScreen',
                        arguments: NotificationArgs(
                          projectId: tempp.projectId,
                          projectName: tempp.projectName,
                          towarName: tempp.projectLocation,
                          response: NotificationResponseData(
                            towarId: tempp.response?.towarId,
                            slabNo: tempp.response?.slabNo,
                            slabId: tempp.response?.slabId,
                          ),
                        ),
                      );
                    } else if (tempp.notificationType == 'rccpoassign' ||
                        tempp.notificationType == 'rccverifyorder' ||
                        tempp.notificationType == 'work_order_list') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return AccountManagementView(
                                projectId: tempp.projectId,
                                towarId: tempp.response?.towarId,
                                projectName: tempp.projectName,
                                towarName: tempp.projectLocation ?? '',
                                navigationFlag: 'Project');
                          },
                        ),
                      );
                    } else if (tempp.notificationType == 'salemanagement' ||
                        tempp.notificationType == 'Payment-type') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return SalesManagementView(
                                projectId: tempp.projectId,
                                towarId: tempp.response?.towarId,
                                projectName: tempp.projectName,
                                towarName: tempp.projectLocation!,
                                navigationFlag: 'Project');
                          },
                        ),
                      );
                    } else if (tempp.notificationType == 'createdmetting') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return TaskDetailsScreen(
                              userTask: tempp.response!.userTask![0],
                              projectId: tempp.projectId,
                              towarId: tempp.response?.towarId,
                              projectName: tempp.projectName,
                              towarName: tempp.projectLocation!,
                            );
                          },
                        ),
                      );
                    } else if (tempp.notificationType == 'permisson') {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return Permissions(
                      //         projectId: tempp.projectId,
                      //         towarId: tempp.response!.towarId,
                      //         projectName: tempp.projectName,
                      //         towarName: tempp.projectLocation,
                      //       );
                      //     },
                      //   ),
                      // );
                      Navigator.of(context).pushNamed(
                        '/permissions',
                        arguments: NotificationArgs(
                          projectId: widget.projectId,
                          // towarId: widget.towarId,
                          projectName: widget.projectName,
                          // towarName: widget.towarName,
                          towarName: widget.towarName,

                          response: NotificationResponseData(
                            towarId: widget.towarId,
                          ),
                        ),
                      );
                    } else if (tempp.notificationType == 'wo-ceritify-work') {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return MyContractsDetailView(
                      //         projectId: tempp.projectId,
                      //         towarId: tempp.response?.towarId ?? '',
                      //         projectName: tempp.projectName,
                      //         // gradeId: widget.gradeId!,
                      //         // companyId: data.mstCompanyId,
                      //         workorderId: tempp.response!.woOrderId,
                      //         workId: tempp.response!.woOrderNo,
                      //         contractorName: tempp.projectLocation,
                      //       );
                      //     },
                      //   ),
                      // );
                      Navigator.of(context).pushNamed(
                        '/myContractsDetailViewScreen',
                        arguments: NotificationArgs(
                          projectId: tempp.projectId,
                          projectName: tempp.projectName,
                          towarName: widget.towarName,
                          response: NotificationResponseData(
                            towarId: tempp.response?.towarId,
                            woOrderId: tempp.response!.woOrderId,
                            woOrderNo: tempp.response!.woOrderNo,
                            // assignToId: assignToId ?? '',
                          ),
                        ),
                      );
                    } else if (tempp.notificationType == 'wo_issued') {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return WoRequestedView(
                      //         assignToId: '',
                      //         projectId: tempp.projectId,
                      //         towarId: widget.towarId,
                      //         projectName: tempp.projectName,
                      //         flagRedirect: 'Issued',
                      //       );
                      //     },
                      //   ),
                      // );
                      Navigator.of(context).pushNamed(
                        '/woRequestedViewScreen',
                        arguments: NotificationArgs(
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          towarName: widget.towarName,
                          response: NotificationResponseData(
                            assignToId: '',
                            flagRedirect: 'Issued',
                            towarId: widget.towarId,
                          ),
                        ),
                      );
                    } else if (tempp.notificationType == 'wo_authenticate') {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return WoRequestedView(
                      //           assignToId: '',
                      //           projectId: tempp.projectId,
                      //           towarId: widget.towarId,
                      //           projectName: tempp.projectName,
                      //           flagRedirect: 'Requested'); //Assigned
                      //     },
                      //   ),
                      // );
                      Navigator.of(context).pushNamed(
                        '/woRequestedViewScreen',
                        arguments: NotificationArgs(
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          towarName: widget.towarName,
                          response: NotificationResponseData(
                            assignToId: '',
                            flagRedirect: 'Requested',
                            towarId: widget.towarId,
                          ),
                        ),
                      );
                    } else if (tempp.notificationType == 'wo_assigned') {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) {
                      //       return WoRequestedView(
                      //           assignToId: '',
                      //           projectId: tempp.projectId,
                      //           towarId: widget.towarId,
                      //           projectName: tempp.projectName,
                      //           flagRedirect: 'Assigned'); //Assigned
                      //     },
                      //   ),
                      // );
                      Navigator.of(context).pushNamed(
                        '/woRequestedViewScreen',
                        arguments: NotificationArgs(
                          projectId: widget.projectId,
                          projectName: widget.projectName,
                          towarName: widget.towarName,
                          response: NotificationResponseData(
                            assignToId: '',
                            flagRedirect: 'Assigned',
                            towarId: widget.towarId,
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tempp.msg ?? '',
                        textAlign: TextAlign.left,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        width: double.maxFinite,
                        child: Text(
                          calDateTime(
                              dateTime: tempp.createdAt ?? DateTime.now()),
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
