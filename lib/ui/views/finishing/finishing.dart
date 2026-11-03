// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stallion/models/exterior_finishing_model.dart';
// import 'package:stallion/models/finishing_flat_listing.dart';
// import 'package:stallion/models/finishing_list_interior.dart';
// import 'package:stallion/models/finishing_listing.dart';
// import 'package:stallion/ui/custom_loading/custom_loading.dart';
// import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
// import 'package:stallion/ui/views/finishing/add_finishing_work.dart';
// import 'package:stallion/ui/views/finishing/add_finishing_work_exterior.dart';
// import 'package:stallion/utils/app_url.dart';

// class Finishing extends StatefulWidget {
//   const Finishing(
//       {Key? key,
//       this.projectId,
//       this.towarId,
//       this.projectName,
//       this.towarName})
//       : super(key: key);
//   final String? projectId;
//   final String? towarId;
//   final String? projectName;
//   final String? towarName;

//   @override
//   State<Finishing> createState() => _FinishingState();
// }

// class _FinishingState extends State<Finishing> {
//   bool isInterior = true;
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   List<FinalResult>? finalResultRes = [];
//   List<FinishingList>? finishingListRes = [];
//   TextEditingController searchControler = TextEditingController();
//   String searchText = '';
//   List<Final>? finalTotalDataExterior = [];
//   List<Final>? finalResultExterior = [];
//   List<FinishingList>? finishingListExterior = [];
//   Future<List<FlatDetailsList>?> getFinishingList() async {
//     try {
//       CustomLoading.progressDialog(isLoading: true, context: context);
//       final SharedPreferences prefs = await _prefs;
//       String? userId = prefs.getString('mobileNo');

//       Map<String, String> data = {
//         "user_id": userId ?? '',
//         "project_id": widget.projectId ?? '',
//         "towar_id": widget.towarId ?? '',
//       };

//       if (kDebugMode) {
//         print(data);
//       }

//       var response =
//           await apiNetworkHandler.post(AppUrl.getFinishingInteriorList, data);

//       if (kDebugMode) {
//         print(response.statusCode);
//       }

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final dataModel = finisingListInteriorFromJson(response.body);
//         if (dataModel.response?.errorCode == "0") {
//           setState(() {
//             // flatDetailsListData = dataModel.response?.flatDetailsList;
//             finalResultRes = dataModel.response?.finalResult;
//             finishingListRes = dataModel.response!.finishingList;
//           });
//         }
//       } else {}
//     } catch (e) {
//       if (kDebugMode) {
//         print('Exception occurred: $e');
//       }
//     } finally {
//       CustomLoading.progressDialog(isLoading: false, context: context);
//     }
//     return null;
//   }

//   Future<List<FlatDetailsList>?> getFinishingExterorList() async {
//     try {
//       // CustomLoading.progressDialog(isLoading: true, context: context);
//       final SharedPreferences prefs = await _prefs;
//       String? userId = prefs.getString('mobileNo');

//       Map<String, String> data = {
//         "user_id": userId ?? '',
//         "project_id": widget.projectId ?? '',
//         "towar_id": widget.towarId ?? '',
//       };

//       if (kDebugMode) {
//         print(data);
//       }

//       var response =
//           await apiNetworkHandler.post(AppUrl.getFinishingExteriorList, data);

//       if (kDebugMode) {
//         print(response.statusCode);
//       }

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final dataModel = finishingExteriorFromJson(response.body);
//         if (dataModel.response?.errorCode == "0") {
//           setState(() {
//             finalTotalDataExterior = dataModel.response?.finalTotalData;
//             finalResultExterior = dataModel.response?.finalResult;
//             finishingListExterior = dataModel.response?.finishingList;
//           });
//         }
//       } else {}
//     } catch (e) {
//       if (kDebugMode) {
//         print('Exception occurred: $e');
//       }
//     } finally {
//       // CustomLoading.progressDialog(isLoading: false, context: context);
//     }
//     return null;
//   }

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       getFinishingList();
//       getFinishingExterorList();
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//             widget.towarName!.isNotEmpty
//                 ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
//                 : widget.projectName!.toUpperCase(),
//             style:
//                 const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.maybePop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           // mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               decoration: const BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                       child: InkWell(
//                     onTap: () {
//                       setState(() {
//                         getFinishingList();
//                         getFinishingExterorList();
//                         isInterior = true;
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       color: isInterior ? Colors.black : Colors.transparent,
//                       child: Text(
//                         "Interior",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: isInterior ? Colors.white : Colors.black,
//                         ),
//                       ),
//                     ),
//                   )),
//                   Expanded(
//                       child: InkWell(
//                     onTap: () {
//                       setState(() {
//                         isInterior = false;
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       color: isInterior ? Colors.transparent : Colors.black,
//                       child: Text(
//                         "Exterior",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: isInterior ? Colors.black : Colors.white,
//                         ),
//                       ),
//                     ),
//                   )),
//                 ],
//               ),
//             ),
//             // const SizedBox(height: 50),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//               child: TextFormField(
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return "(Title Cannot Be Empty)";
//                   }
//                 },
//                 controller: searchControler,
//                 onChanged: (value) {
//                   setState(() {
//                     searchText = value;
//                   });
//                 },
//                 style: const TextStyle(color: Colors.black, fontSize: 13.0),
//                 decoration: const InputDecoration(
//                   contentPadding: EdgeInsets.all(12.0),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(50)),
//                       borderSide: BorderSide(color: Colors.black)),
//                   hintText: 'Please Enter Title',
//                   hintStyle: TextStyle(
//                     color: Color.fromARGB(255, 116, 116, 116),
//                     fontSize: 13.0,
//                     fontWeight: FontWeight.w200,
//                     fontFamily: 'HelveticaNeue',
//                   ),
//                   // suffixIcon: Icon(
//                   //   Icons.calendar_month_outlined,
//                   // ),
//                 ),
//               ),
//             ),
//             isInterior
//                 ? Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Column(
//                         children: [
//                           for (int i = 0; i < finalResultRes!.length; i++)
//                             Column(
//                               children: [
//                                 if (i == 0)
//                                   Container(
//                                     width: 70,
//                                     height: 64,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 10),
//                                     decoration: BoxDecoration(
//                                         color: Colors.black,
//                                         border:
//                                             Border.all(color: Colors.black38)),
//                                     // padding: const EdgeInsets.all(30),
//                                     // margin: const EdgeInsets.only(right: 20),
//                                     child: const Center(
//                                       child: Text(
//                                         "Title / Flat",
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 Container(
//                                   // padding: const EdgeInsets.all(30),
//                                   width: 70,
//                                   height: 70,
//                                   // margin:
//                                   //     const EdgeInsets.only(right: 20, bottom: 20),
//                                   decoration: const BoxDecoration(
//                                     // borderRadius: BorderRadius.circular(6),
//                                     // border: Border.all(color: Colors.black12),
//                                     color: Colors.black,
//                                     // border: Border.all(
//                                     //   color: Colors.white,
//                                     // ),

//                                     border: Border(
//                                       top: BorderSide(
//                                         color: Colors.white70,
//                                       ),
//                                     ),
//                                   ),

//                                   child: Center(
//                                     child: Text(
//                                       finalResultRes?[i].floorData ?? '',
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 // if (i == 4)
//                                 //   Container(
//                                 //     width: 110,
//                                 //     height: 100,
//                                 //     // padding: const EdgeInsets.all(30),
//                                 //     // margin:
//                                 //     // const EdgeInsets.only(right: 20, bottom: 20),
//                                 //     decoration: BoxDecoration(
//                                 //         color: Colors.black12,
//                                 //         // borderRadius: BorderRadius.circular(6),
//                                 //         border: Border.all(color: Colors.black12)),
//                                 //     child: const Center(
//                                 //       child: Text(
//                                 //         "Total:",
//                                 //         // textAlign: TextAlign.center,
//                                 //         style: TextStyle(
//                                 //           fontSize: 20,
//                                 //           fontWeight: FontWeight.w600,
//                                 //         ),
//                                 //       ),
//                                 //     ),
//                                 //   ),
//                               ],
//                             ),
//                         ],
//                       ),
//                       Expanded(
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               for (int k = 0; k < finalResultRes!.length; k++)
//                                 Row(
//                                   children: [
//                                     for (int j = 0;
//                                         j < finishingListRes!.length;
//                                         j++)
//                                       Column(
//                                         children: [
//                                           if (k == 0)
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 8),
//                                               width: 90,
//                                               height: 64,
//                                               decoration: BoxDecoration(
//                                                   color: ((finishingListRes?[j]
//                                                                   .gradeName)!
//                                                               .toLowerCase()
//                                                               .contains(searchText
//                                                                   .toLowerCase()) &&
//                                                           searchText.isNotEmpty)
//                                                       ? Colors.grey[200]
//                                                       : Colors.black,
//                                                   border: Border.all(
//                                                     color: Colors.white70,
//                                                   )),
//                                               // padding: const EdgeInsets.all(30),
//                                               // margin: const EdgeInsets.only(right: 20),
//                                               child: Center(
//                                                 child: Text(
//                                                   finishingListRes?[j]
//                                                           .gradeName ??
//                                                       '',
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: ((finishingListRes?[
//                                                                         j]
//                                                                     .gradeName)!
//                                                                 .toLowerCase()
//                                                                 .contains(searchText
//                                                                     .toLowerCase()) &&
//                                                             searchText
//                                                                 .isNotEmpty)
//                                                         ? Colors.black
//                                                         : Colors.white,
//                                                     // overflow: TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           InkWell(
//                                             onTap: () {
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (_) {
//                                                     return AddFinishingWork(
//                                                       finishingDetails:
//                                                           finalResultRes?[k]
//                                                               .finishingDetails?[j],
//                                                       floorName:
//                                                           finalResultRes?[k]
//                                                               .floorData,
//                                                       floorId:
//                                                           finalResultRes?[k]
//                                                               .floorId,
//                                                       // flatDetailsListSelected:
//                                                       //     widget.flatDetailsListSelected,
//                                                       // finishingListData:
//                                                       //     finishingListData?[index],
//                                                       projectId:
//                                                           widget.projectId,
//                                                       towarId: widget.towarId!,
//                                                       projectName:
//                                                           widget.projectName,
//                                                       towarName:
//                                                           widget.towarName!,
//                                                       // slabName: "Internal Paint (R-101)",
//                                                     );
//                                                   },
//                                                 ),
//                                               ).then((value) =>
//                                                   getFinishingList());
//                                             },
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                   color: k ==
//                                                           finalResultRes!
//                                                                   .length -
//                                                               1
//                                                       ? Colors.black
//                                                       : ((finishingListRes?[j]
//                                                                       .gradeName)!
//                                                                   .toLowerCase()
//                                                                   .contains(
//                                                                       searchText
//                                                                           .toLowerCase()) &&
//                                                               searchText
//                                                                   .isNotEmpty)
//                                                           ? Colors.grey[200]
//                                                           : Colors.transparent,
//                                                   // color:
//                                                   //     k == finalResultRes!.length - 1
//                                                   //         ? Colors.black
//                                                   //         : Colors.transparent,
//                                                   // borderRadius:
//                                                   //     BorderRadius.circular(6),
//                                                   border: Border(
//                                                     right: BorderSide(
//                                                         color: k ==
//                                                                 finalResultRes!
//                                                                         .length -
//                                                                     1
//                                                             ? Colors.white70
//                                                             : Colors.black12),
//                                                     bottom: BorderSide(
//                                                         color: k ==
//                                                                 finalResultRes!
//                                                                         .length -
//                                                                     1
//                                                             ? Colors.white70
//                                                             : Colors.black12),
//                                                   )),
//                                               // padding: const EdgeInsets.all(30),
//                                               width: 90,
//                                               height: 70,
//                                               // margin: const EdgeInsets.only(
//                                               //     right: 20, bottom: 20),
//                                               child: Column(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   Center(
//                                                     child: Text(
//                                                       '${double.parse(finalResultRes?[k].finishingDetails?[j].consumeQty ?? '0').toStringAsFixed(2)} / ${finalResultRes?[k].finishingDetails?[j].finishingQty}',
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontSize: 15,
//                                                         fontWeight:
//                                                             FontWeight.w400,
//                                                         color: k ==
//                                                                 finalResultRes!
//                                                                         .length -
//                                                                     1
//                                                             ? Colors.white
//                                                             : Colors.black,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 8),
//                                                   Container(
//                                                     width: 50,
//                                                     height: 3,
//                                                     decoration: BoxDecoration(
//                                                       color: finalResultRes?[k]
//                                                                   .finishingDetails?[
//                                                                       j]
//                                                                   .consumeQty ==
//                                                               '0'
//                                                           ? Colors.red
//                                                           : finalResultRes?[k]
//                                                                       .finishingDetails?[
//                                                                           j]
//                                                                       .consumeQty ==
//                                                                   finalResultRes?[
//                                                                           k]
//                                                                       .finishingDetails?[
//                                                                           j]
//                                                                       .finishingQty
//                                                               ? Colors.green
//                                                               : Colors.yellow,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               12),
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                           // if (k == finalResultRes!.length - 1)
//                                           //   Container(
//                                           //     decoration: const BoxDecoration(
//                                           //         // borderRadius:
//                                           //         //     BorderRadius.circular(6),
//                                           //         // border: Border.all(
//                                           //         //     color: Colors.black12)
//                                           //         border: Border(
//                                           //       left:
//                                           //           BorderSide(color: Colors.black38),
//                                           //       bottom:
//                                           //           BorderSide(color: Colors.black12),
//                                           //     )),
//                                           //     // padding: const EdgeInsets.all(30),
//                                           //     width: 110,
//                                           //     height: 100,
//                                           //     // margin: const EdgeInsets.only(
//                                           //     //     right: 20, bottom: 20),
//                                           //     child: const Center(
//                                           //       child: Text(
//                                           //         "10050",
//                                           //         textAlign: TextAlign.center,
//                                           //         style: TextStyle(
//                                           //           fontSize: 20,
//                                           //           fontWeight: FontWeight.w600,
//                                           //         ),
//                                           //       ),
//                                           //     ),
//                                           //   ),
//                                         ],
//                                       ),
//                                   ],
//                                 ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   )
//                 : SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         Column(
//                           children: [
//                             // if (k == 0)
//                             Container(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 8),
//                               width: 100,
//                               height: 64,
//                               decoration: BoxDecoration(
//                                   color: Colors.black,
//                                   border: Border.all(
//                                     color: Colors.white70,
//                                   )),
//                               child: const Center(
//                                 child: Text(
//                                   // '100' ?? '',
//                                   'Title',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               decoration: const BoxDecoration(
//                                   color: Colors.transparent,
//                                   border: Border(
//                                     right: BorderSide(color: Colors.black12),
//                                     bottom: BorderSide(color: Colors.black12),
//                                   )),
//                               width: 100,
//                               height: 70,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   const Center(
//                                     child: Text(
//                                       '',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w400,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Container(
//                                     width: 50,
//                                     height: 3,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             for (int g = 0;
//                                 g < finalResultExterior!.length;
//                                 g++)
//                               Column(
//                                 children: [
//                                   // if (k == 0)
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8),
//                                     width: 100,
//                                     height: 64,
//                                     decoration: BoxDecoration(
//                                         color:
//                                             // ((finishingListRes?[j].gradeName)!
//                                             //             .toLowerCase()
//                                             //             .contains(
//                                             //                 searchText.toLowerCase()) &&
//                                             //         searchText.isNotEmpty)
//                                             //     ? Colors.grey[200]
//                                             // :
//                                             Colors.black,
//                                         border:
//                                             Border.all(color: Colors.white70)),
//                                     // padding: const EdgeInsets.all(30),
//                                     // margin: const EdgeInsets.only(right: 20),
//                                     child: Center(
//                                       child: Text(
//                                         // '100' ?? '',
//                                         finalResultExterior?[g].gradeName ?? '',
//                                         textAlign: TextAlign.center,
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600,
//                                           color:
//                                               // ((finishingListRes?[j].gradeName)!
//                                               //             .toLowerCase()
//                                               //             .contains(
//                                               //                 searchText.toLowerCase()) &&
//                                               //         searchText.isNotEmpty)
//                                               //     ? Colors.black
//                                               //     :
//                                               Colors.white,
//                                           // overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   InkWell(
//                                     onTap: () {
//                                       // Navigator.push(
//                                       //   context,
//                                       //   MaterialPageRoute(
//                                       //     builder: (_) {
//                                       //       return AddFinishingWorkExterior(
//                                       //         finishingDetails:
//                                       //             finalResultExterior?[g],
//                                       //         floorId: '0',
//                                       //         // flatDetailsListSelected:
//                                       //         //     widget.flatDetailsListSelected, finishingListExterior
//                                       //         // finishingListData:
//                                       //         //     finishingListData?[index],
//                                       //         projectId: widget.projectId,
//                                       //         towarId: widget.towarId!,
//                                       //         projectName: widget.projectName,
//                                       //         towarName: widget.towarName!,
//                                       //         // slabName: "Internal Paint (R-101)",
//                                       //       );
//                                       //     },
//                                       //   ),
//                                       // ).then(
//                                       //     (value) => getFinishingExterorList());
//                                     },
//                                     child: Container(
//                                       decoration: const BoxDecoration(
//                                           color:
//                                               // k == finalResultRes!.length - 1
//                                               //     ? Colors.black
//                                               //     : ((finishingListRes?[j].gradeName)!
//                                               //                 .toLowerCase()
//                                               //                 .contains(searchText
//                                               //                     .toLowerCase()) &&
//                                               //             searchText.isNotEmpty)
//                                               //         ? Colors.grey[200]
//                                               //         :
//                                               Colors.transparent,
//                                           // color:
//                                           //     k == finalResultRes!.length - 1
//                                           //         ? Colors.black
//                                           //         : Colors.transparent,
//                                           // borderRadius:
//                                           //     BorderRadius.circular(6),
//                                           border: Border(
//                                             right: BorderSide(
//                                                 color:
//                                                     // k == finalResultRes!.length - 1
//                                                     //     ? Colors.white70
//                                                     //     :
//                                                     Colors.black12),
//                                             bottom: BorderSide(
//                                                 color:
//                                                     // k == finalResultRes!.length - 1
//                                                     //     ? Colors.white70
//                                                     //     :
//                                                     Colors.black12),
//                                           )),
//                                       // padding: const EdgeInsets.all(30),
//                                       width: 100,
//                                       height: 70,
//                                       // margin: const EdgeInsets.only(
//                                       //     right: 20, bottom: 20),
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Center(
//                                             child: Text(
//                                               // '100/0',
//                                               '${finalResultExterior?[g].consumeQty} / ${finalResultExterior?[g].finishingQty}',
//                                               textAlign: TextAlign.center,
//                                               style: const TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.w400,
//                                                 color:
//                                                     // k == finalResultRes!.length - 1
//                                                     //     ? Colors.white
//                                                     //     :
//                                                     Colors.black,
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Container(
//                                             width: 50,
//                                             height: 3,
//                                             decoration: BoxDecoration(
//                                               color: finalResultExterior?[g]
//                                                           .consumeQty ==
//                                                       '0'
//                                                   ? Colors.red
//                                                   : finalResultExterior?[g]
//                                                               .consumeQty ==
//                                                           finalResultExterior?[
//                                                                   g]
//                                                               .finishingQty
//                                                       ? Colors.green
//                                                       : Colors.yellow,
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   // if (k == finalResultRes!.length - 1)
//                                   //   Container(
//                                   //     decoration: const BoxDecoration(
//                                   //         // borderRadius:
//                                   //         //     BorderRadius.circular(6),
//                                   //         // border: Border.all(
//                                   //         //     color: Colors.black12)
//                                   //         border: Border(
//                                   //       left:
//                                   //           BorderSide(color: Colors.black38),
//                                   //       bottom:
//                                   //           BorderSide(color: Colors.black12),
//                                   //     )),
//                                   //     // padding: const EdgeInsets.all(30),
//                                   //     width: 110,
//                                   //     height: 100,
//                                   //     // margin: const EdgeInsets.only(
//                                   //     //     right: 20, bottom: 20),
//                                   //     child: const Center(
//                                   //       child: Text(
//                                   //         "10050",
//                                   //         textAlign: TextAlign.center,
//                                   //         style: TextStyle(
//                                   //           fontSize: 20,
//                                   //           fontWeight: FontWeight.w600,
//                                   //         ),
//                                   //       ),
//                                   //     ),
//                                   //   ),
//                                 ],
//                               ),
//                           ],
//                         )
//                       ],
//                     ),
//                   )
//             // Expanded(
//             //   child: ListView.separated(
//             //     shrinkWrap: true,
//             //     itemCount: 4,
//             //     itemBuilder: (context, index) {
//             //       return Row(
//             //         children: [
//             //           const SizedBox(width: 40),
//             //           const Icon(Icons.check_circle_outline_sharp,
//             //               color: Colors.green),
//             //           const SizedBox(width: 10),
//             //           const SizedBox(
//             //             width: 140,
//             //             child: Text(
//             //               "R:201",
//             //               // textAlign: TextAlign.center,
//             //               style: TextStyle(
//             //                 fontSize: 20,
//             //                 fontWeight: FontWeight.w600,
//             //               ),
//             //             ),
//             //           ),
//             //           Expanded(
//             //               child: SingleChildScrollView(
//             //             scrollDirection: Axis.horizontal,
//             //             child: Row(
//             //               children: [
//             //                 for (int i = 0; i < 20; i++)
//             //                   InkWell(
//             //                     onTap: () {
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(
//             //     builder: (_) {
//             //       return AddFinishingWork(
//             //         // flatDetailsListSelected:
//             //         //     widget.flatDetailsListSelected,
//             //         // finishingListData:
//             //         //     finishingListData?[index],
//             //         projectId: widget.projectId,
//             //         towarId: widget.towarId!,
//             //         projectName: widget.projectName,
//             //         towarName: widget.towarName!,
//             //         // slabName: "Internal Paint (R-101)",
//             //       );
//             //     },
//             //   ),
//             // );
//             //                     },
//             //                     child: Container(
//             //                       padding: const EdgeInsets.all(30),
//             //                       margin: const EdgeInsets.only(right: 20),
//             //                       decoration: BoxDecoration(
//             //                           border: Border.all(color: Colors.black)),
//             //                       child: const Column(
//             //                         children: [
//             //                           Text(
//             //                             "data",
//             //                             style: TextStyle(
//             //                               fontSize: 18,
//             //                               fontWeight: FontWeight.w600,
//             //                             ),
//             //                           ),
//             //                           Text(
//             //                             "10/50",
//             //                             style: TextStyle(fontSize: 16),
//             //                           ),
//             //                         ],
//             //                       ),
//             //                     ),
//             //                   )
//             //               ],
//             //             ),
//             //           )),
//             //           const SizedBox(width: 100)
//             //         ],
//             //       );
//             //     },
//             //     separatorBuilder: (context, index) => Container(
//             //       padding: const EdgeInsets.symmetric(vertical: 20),
//             //       child: const Divider(color: Colors.grey),
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
