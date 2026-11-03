// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// // import 'package:projectmanagement/fancynode/drag_and_drop.dart';
// // import 'package:projectmanagement/fancynode/flutter_fancy_tree_view.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stallion/models/add_pms_response.dart';
// import 'package:stallion/ui/views/constructionmanagementschedule/models/update_project_pms_info.dart';
// import 'package:stallion/ui/views/constructionmanagementschedule/models/updating_existing_drawer.dart';
// import 'package:stallion/ui/views/constructionmanagementschedule/provider/provider_registration.dart';

// import '../../../../../utils/app_url.dart';
// import '../../../salesmanagement/salesleads/salesLeadDetailPage.dart';
// import '../../fancynode/pms_view/nodee.dart';
// import '../../fancynode/src/tree_controller.dart';
// import '../../models/ws_get_pms_structure.dart';

// class FetchApiProvider extends ChangeNotifier {
//   late ChangeNotifierProviderRef<FetchApiProvider> ref;
//   FetchApiProvider(this.ref);

//   List<Widget> arrWidget = [];
//   List<Node> openDropDown = [];
//   List<PmsStructure>? pmsStructure = [];
//   List<ProjectPmsInfo>? projectPmsInfoResponse = [];
//   DateTime? pmsStartDateFromResponse;
//   DateTime? pmsEndDateFromResponse;
//   late Node root;

//   TreeController<Node> treeController =
//       TreeController(roots: [], childrenProvider: (Node node) => node.children);
//   var intValue = 0;
//   bool flagcalled = true;
//   bool isLoadingFetchShimer = false;
//   bool isLoadingAddPms = false;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   DateTime? _selectedStartDate;
//   DateTime? _selectedEndDate;
//   TextEditingController titleControler = TextEditingController();
//   TextEditingController startDateControler = TextEditingController();
//   TextEditingController endDateControler = TextEditingController();

//   clearEndDate() {
//     endDateControler.clear();
//     _selectedEndDate = null;
//     notifyListeners();
//   }

//   setOpenDropDown(Node data) {
//     openDropDown.add(data);
//     // print(openDropDown.length);
//     // notifyListeners();
//   }

//   removeOpenDropDown(Node data) {
//     openDropDown.remove(data);
//     // add(data);
//     // notifyListeners();
//     // print(openDropDown.length);
//   }

//   void fetchExampleTree(Node node, List<PmsStructure>? structure) {
//     for (int i = 0; i < structure!.length; i++) {
//       structure[i].expand = true;
//       final child = Node(
//           id: int.parse(structure[i].mstPmsId!),
//           expandnode: false,
//           dict: structure[i])
//         ..parent1 = node;
//       node.children1.add(child);
//       fetchExampleTree(child, structure[i].details);
//     }
//   }

//   void findRecursiveTrueFalseList(List<Node> list, bool flag) {
//     for (int i = 0; i < list.length; i++) {
//       list[i].dict!.expand = flag;
//       if (list[i].children1.isNotEmpty) {
//         findRecursiveTrueFalseList(list[i].children1, flag);
//       }
//     }
//   }

//   void findRecursiveTrueFalse(Node list, bool flag) {
//     for (int i = 0; i < list.children1.length; i++) {
//       list.children1[i].dict!.expand = flag;
//       // ref.read(fetchApiProvider).removeOpenDropDown(list.children1[i]);
//       treeController.collapse(list.children1[i]);

//       if (flag == false) {
//         if (list.children1[i].children1.isNotEmpty) {
//           // setOpenDropDown(list.children1[i]);
//           findRecursiveTrueFalseList(list.children1[i].children1, flag);
//         }
//       }
//     }
//     notifyListeners();
//   }

//   Future<ResponseProjectSchedule?> fetchRecords({
//     required String projectId,
//     required String towarId,
//   }) async {
//     // isLoadingFetchShimer = true;
//     setLoadingFetchRecord(true);
//     Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');
//     Map<String, String> data = {
//       "user_id": userId ?? '',
//       "project_id": projectId,
//       "towar_id": towarId,
//     };

//     if (kDebugMode) {
//       print(data);
//     }

//     var response = await apiNetworkHandler.post(AppUrl.wsgetpmsstructure, data);
//     if (kDebugMode) {
//       print(response.statusCode);
//     }
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       arrWidget = [];
//       final dataModel = projectScheduleFromJson(response.body);
//       if (dataModel.response?.errorCode == "0") {
//         //return dataModel.response;
//         projectPmsInfoResponse = dataModel.response?.projectPmsInfo;
//         pmsStructure = dataModel.response?.pmsStructure;
//         pmsEndDateFromResponse = dataModel.response?.pmsEndDate;
//         pmsStartDateFromResponse = dataModel.response?.pmsStartDate;
//         root = Node(id: -1);
//         // inspect(openDropDown);

//         for (int i = 0; i < pmsStructure!.length; i++) {
//           pmsStructure![i].expand = true;
//           final child = Node(
//               id: int.parse(pmsStructure![i].mstPmsId!),
//               expandnode: true,
//               dict: pmsStructure![i]);
//           fetchExampleTree(child..parent1 = root, pmsStructure![i].details);

//           root.children1.add(child);
//         }
//         // treeController = TreeController<Node>(
//         //   roots: root.children,
//         //   childrenProvider: (Node node) => node.children,
//         //   parentProvider: (Node node) => node.parent,
//         // );

//         treeController.roots = root.children;
//         treeController.childrenProvider = (Node node) => node.children;
//         treeController.parentProvider = (Node node) => node.parent;
//         intValue = root.children.length;
//         flagcalled = true;
//         if (dataModel.response?.defaultFlag == "1") {
//           treeController.expandAll();

//           // notifyListeners();
//         }
//         // notifyListeners();
//         // arrWidget = [];
//         // Future.delayed(const Duration(seconds: 1), () {
//         //   print('One second has passed.'); // Prints after 1 second.
//         //   // inspect(treeController);
//         //   // for (int k = 0; k < openDropDown.length; k++) {
//         //   //   print('-------------${openDropDown[k].dict?.pmsCategoryName}');
//         //   //   // treeController.toggleExpansion(openDropDown[k]);
//         //   //   treeController.toggleExpansion(openDropDown[k]);
//         //   // }
//         //   findrec({required Iterable<Node> list11}) {
//         //     for (var element in list11) {
//         //       for (int k = 0; k < openDropDown.length; k++) {
//         //         // print(element.dict?.pmsCategoryName);
//         //         if (openDropDown[k].dict?.mstPmsId == element.dict?.mstPmsId) {
//         //           print(
//         //               '${element.dict?.pmsCategoryName} -----------------  true');
//         //           treeController.expand(element);
//         //           findRecursiveTrueFalse(element, true);
//         //         }

//         //         if (element.children.length != 0) {
//         //           findrec(list11: element.children1);
//         //         }
//         //       }
//         //     }
//         //   }

//         //   findrec(list11: treeController.roots);
//         //   //  root.children1);
//         //   // }
//         // treeController.expandAll();

//         // Future.delayed(const Duration(seconds: 15), () {
//         //   treeController.rebuild();
//         // });
//         // notifyListeners();
//         setLoadingFetchRecord(false);
//         // });
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.body);
//       }
//       return null;
//     }
//     return null;
//   }

//   findRecAndAdd({
//     required Node currNode,
//     required Iterable<Node> list11,
//     required List<PmsStructure>? addedPmsList,
//     required String onSelectedPmsid,
//     required List<PmsStructure>? changeData,
//   }) {
//     for (var element in list11) {
//       for (int k = 0; k > changeData!.length; k++) {
//         if (changeData?[k].mstPmsId == element.dict?.mstPmsId) {
//           element.dict?.pmsStartDate = changeData?[k].pmsStartDate;
//           element.dict?.pmsEndDate = changeData?[k].pmsEndDate;
//           // element.dict?.pmsStartDate = res.changeData?[k].pmsStartDate;
//           // notifyListeners();
//         }
//       }
//       // for (int k = 0; k < openDropDown.length; k++) {
//       // print(element.dict?.pmsCategoryName);
//       if (onSelectedPmsid == element.dict?.mstPmsId) {
//         element.dict?.expand = true;
//         // print('${element.dict?.pmsCategoryName} -----------------  true');

//         addedPmsList?[0].expand = true;
//         final child = Node(
//             id: int.parse(addedPmsList?[0].mstPmsId ?? ''),
//             expandnode: false,
//             dict: addedPmsList?[0]);
//         child.parent?.children1 = element.parent!.children1;
//         child.parent1 = element;
//         element.children1.add(child);

//         // ref.read(fetchApiProvider).fetchExampleTree(
//         //     child
//         //       ..parent1 = ref.read(fetchApiProvider).root,
//         //     res?.addedPmsList?[0].details);

//         // ref
//         //     .read(fetchApiProvider)
//         //     .root
//         //     .children1
//         //     .add(child);
//         // treeController.roots = root.children;
//         // treeController.childrenProvider = (Node node) => node.children;
//         // treeController.parentProvider = (Node node) => node.parent;
//         // intValue = root.children.length;
//         // treeController.toggleExpansion(currNode);
//         // treeController.expand(currNode);
//         notifyListeners();
//         treeController.rebuild();
//         //   treeController.expand(element);
//         //   findRecursiveTrueFalse(element, true);
//       }

//       if (element.children.length != 0) {
//         findRecAndAdd(
//           list11: element.children1,
//           addedPmsList: addedPmsList,
//           onSelectedPmsid: onSelectedPmsid,
//           changeData: changeData,
//           currNode: currNode,
//         );
//       }
//       // }
//     }
//   }

//   List<DupliacateDataPms>? pmsStructureForDuplicating;
//   findRecToGetSingleDimensionArray(
//       {required Iterable<Node> list11,
//       required PmsStructure currSelectedNode}) {
//     for (var element in list11) {
//       // print(
//       //     '${element.dict?.pmsCategoryName} --------- ${pmsStructureForDuplicating?.length}');
//       // pmsStructureForDuplicating?.add(element.dict ?? PmsStructure());
//       pmsStructureForDuplicating = [
//         ...pmsStructureForDuplicating ?? [],
//         // element.dict!
//         DupliacateDataPms(
//           pms_color_code: element.dict?.pms_color_code,
//           mstPmsId: element.dict?.mstPmsId,
//           pmsCategoryName: element.dict?.pmsCategoryName,
//           parentIdFk: element.dict?.parentIdFk,
//           pmsOrderNo: element.dict?.pmsOrderNo,
//           pmsColorCode: element.dict?.pms_color_code,
//           pmsStartDate: element.dict?.pmsStartDate == DateTime(2000)
//               ? null
//               : element.dict?.pmsStartDate,
//           pmsEndDate: element.dict?.pmsEndDate == DateTime(2101)
//               ? null
//               : element.dict?.pmsEndDate,
//           totalDays: element.dict?.pmsTotalDays,
//           maxDate: element.dict?.maxDate,
//           minDate: element.dict?.minDate,
//           projectPmsIdFk: element.dict?.projectPmsIdFk,
//         )
//       ];
//       // for (int k = 0; k < openDropDown.length; k++) {
//       // print(element.dict?.pmsCategoryName);
//       // if (openDropDown[k].dict?.mstPmsId == element.dict?.mstPmsId) {
//       //   print(
//       //       '${element.dict?.pmsCategoryName} -----------------  true');
//       //   treeController.expand(element);
//       //   findRecursiveTrueFalse(element, true);
//       // }

//       if (element.children.length != 0) {
//         findRecToGetSingleDimensionArray(
//             list11: element.children1, currSelectedNode: currSelectedNode);
//       }

//       // }
//     }
//     // pmsStructureForDuplicating = [
//     //   ...pmsStructureForDuplicating ?? [],
//     //   // element.dict!
//     //   DupliacateDataPms(
//     //     mstPmsId: currSelectedNode.mstPmsId,
//     //     pmsCategoryName: currSelectedNode.pmsCategoryName,
//     //     parentIdFk: currSelectedNode.parentIdFk,
//     //     pmsOrderNo: currSelectedNode.pmsOrderNo,
//     //     pmsColorCode: currSelectedNode.pms_color_code,
//     //   )
//     // ];
//     // notifyListeners();
//   }

//   setLoadingFetchRecord(bool val) {
//     isLoadingFetchShimer = val;
//     notifyListeners();
//   }

//   Future<UpdateExistingDrawerResponse?> updateExistingPmsApi({
//     required String parentId,
//     required String title,
//     required String remark,
//     required DateTime startDate,
//     required DateTime endtDate,
//     required String mstpmsid,
//     required String projectId,
//     required String towarId,
//     Node? currNode,
//   }) async {
//     Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//     String temmmm = json.encode(pmsStructureForDuplicating);
//     // print(temmmm);
//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');
//     String formatDate(DateTime dateTime) {
//       // Format the DateTime as "yyyy-MM-dd" (e.g., "2023-09-01")
//       if (dateTime == DateTime(2101) || dateTime == DateTime(2000)) {
//         return "";
//       } else {
//         return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
//       }
//     }

//     String formatDateTime(DateTime data) {
//       return DateFormat('yyyy-MM-dd HH:mm:ss').format(data);
//     }

//     Map<String, String> data = {
//       "user_id": userId ?? '',
//       "mst_pms_id": mstpmsid,
//       "project_id": projectId,
//       "towar_id": towarId,
//       "parent_id": parentId,
//       "start_date": formatDate(pmsStructureForDuplicating?[0].pmsStartDate ??
//           startDate), //formatDate(startDate),
//       "end_date": formatDate(pmsStructureForDuplicating?[0].pmsEndDate ??
//           endtDate), //formatDate(endtDate),
//       // "pms_name": title,
//       "remark": remark,
//       "store_date": formatDateTime(DateTime.now()),
//       "work_order_id":
//           ref.read(homeProvider).workOrderListSelected?.workOrderId ?? "0",
//       "pms_progress": (ref.read(homeProvider).workCompletePercentageValue * 100)
//           .toStringAsFixed(2),
//       "pms_child_update": temmmm,
//       "check_status": ref.read(homeProvider).checkboxValue.toString(),
//     };

//     var response = await apiNetworkHandler.post(AppUrl.wssetpmsstructure, data);
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = updateExistingDrawerFromJson(response.body);
//       if (dataModel.response?.errorCode == "0") {
//         pmsStartDateFromResponse = dataModel.response?.pmsStartDate;
//         pmsEndDateFromResponse = dataModel.response?.pmsEndDate;
//         // fetchRecords(projectId: projectId, towarId: towarId);
//         if (currNode != null) {
//           findrec({required Iterable<Node> list11}) {
//             for (var element in list11) {
//               // for (int k = 0; k < openDropDown.length; k++) {
//               // print(element.dict?.pmsCategoryName);
//               if (currNode!.dict?.mstPmsId == element.dict?.mstPmsId) {
//                 element.dict?.pmsCategoryName = title;
//                 element.dict?.pmsStartDate = startDate;
//                 element.dict?.pmsEndDate = endtDate;
//                 // notifyListeners();
//                 print(
//                     '${element.dict?.pmsCategoryName} -----------------  true++++++++++++++');

//                 // treeController.expand(element);
//                 // findRecursiveTrueFalse(element, true);
//               }

//               if (element.children.length != 0) {
//                 findrec(list11: element.children1);
//               }
//               // }
//             }
//           }

//           findrec(list11: treeController.roots);
//         }
//         // print("********************");

// // update date with drawer dates for current node and its children
//         testtt(Iterable<Node> dataa) {
//           for (var element in dataa) {
//             for (int i = 0; i < pmsStructureForDuplicating!.length; i++) {
//               if (pmsStructureForDuplicating?[i].mstPmsId ==
//                   element.dict?.mstPmsId) {
//                 print(
//                     '${element.dict?.pmsCategoryName}  ${pmsStructureForDuplicating?[i].pmsStartDate} ${pmsStructureForDuplicating?[i].pmsEndDate} --------------- updated');
//                 element.dict?.pmsStartDate =
//                     pmsStructureForDuplicating?[i].pmsStartDate;
//                 element.dict?.pmsEndDate =
//                     pmsStructureForDuplicating?[i].pmsEndDate;
//                 element.dict?.pmsTotalDays =
//                     pmsStructureForDuplicating?[i].totalDays;
//                 element.dict?.minDate = pmsStructureForDuplicating?[i].minDate;
//                 element.dict?.maxDate = pmsStructureForDuplicating?[i].maxDate;
//                 element.dict?.pmsCategoryName =
//                     pmsStructureForDuplicating?[i].pmsCategoryName;
//                 notifyListeners();
//               }
//             }

//             if (element.children.length != 0) {
//               testtt(element.children1);
//             }
//           }
//         }

//         ref.read(homeProvider).curNodeDrawerData?.dict?.pmsStartDate =
//             pmsStructureForDuplicating?[0].pmsStartDate;
//         // // notifyListeners();
//         testtt(ref.read(homeProvider).curNodeDrawerData!.children);
//         // inspect(treeController);

//         Node? tempNode;
//         for (var element in treeController.roots) {
//           if (element.dict?.mstPmsId ==
//               dataModel.response?.changeData?[0].mstPmsId) {
//             tempNode = element;
//             print("-------breaking---------------");
//             break;
//           }
//         }
//         updatingdataFromRes(Iterable<Node> dataa) {
//           for (var element1 in dataa) {
//             for (int i = 0; i < dataModel.response!.changeData!.length; i++) {
//               print(
//                   '${element1.dict?.pmsCategoryName} ${dataModel.response!.changeData?[i].pmsCategoryName} --------------- updated from res before');
//               if (dataModel.response!.changeData?[i].mstPmsId ==
//                   element1.dict?.mstPmsId) {
//                 print(
//                     '${element1.dict?.pmsCategoryName} --------------- updated from res');
//                 element1.dict?.pmsStartDate =
//                     dataModel.response!.changeData?[i].pmsStartDate;
//                 element1.dict?.pmsEndDate =
//                     dataModel.response!.changeData?[i].pmsEndDate;
//                 element1.dict?.pmsTotalDays =
//                     dataModel.response!.changeData?[i].pmsTotalDays;
//                 element1.dict?.consumePercentage =
//                     dataModel.response!.changeData?[i].consumePercentage;
//                 element1.dict?.minDate =
//                     dataModel.response!.changeData?[i].minDate;
//                 element1.dict?.maxDate =
//                     dataModel.response!.changeData?[i].maxDate;
//                 // notifyListeners();
//               }
//             }

//             if (element1.children.length != 0) {
//               testtt(element1.children1);
//             }
//           }
//         }

//         print(
//             '${mstpmsid}*/*/*//* ${dataModel.response!.addedPmsList?[0].mstPmsId}');
//         if (ref.read(homeProvider).curNodeDrawerData != null &&
//             ref.read(homeProvider).curNodeDrawerData?.dict?.mstPmsId ==
//                 dataModel.response!.addedPmsList?[0].mstPmsId) {
//           ref.read(homeProvider).curNodeDrawerData?.dict?.consumePercentage =
//               dataModel.response!.addedPmsList?[0].consumePercentage;
//           ref.read(homeProvider).curNodeDrawerData?.dict?.remarkList =
//               dataModel.response!.addedPmsList?[0].remarkList;

//           ref.read(homeProvider).curNodeDrawerData?.dict?.workOrderDetails =
//               dataModel.response!.addedPmsList?[0].workOrderDetails;
//           ref.read(homeProvider).curNodeDrawerData?.dict?.pmsCategoryName =
//               dataModel.response!.addedPmsList?[0].pmsCategoryName;
//           ref.read(homeProvider).curNodeDrawerData?.dict?.checkStatus =
//               dataModel.response!.addedPmsList?[0].checkStatus;
//           // notifyListeners();
//         }
//         if (tempNode != null) {
//           updatingdataFromRes(tempNode.children);
//           if (tempNode.dict?.mstPmsId ==
//               dataModel.response!.changeData?[0].mstPmsId) {
//             tempNode.dict?.pmsStartDate =
//                 dataModel.response!.changeData?[0].pmsStartDate;
//             tempNode.dict?.pmsEndDate =
//                 dataModel.response!.changeData?[0].pmsEndDate;
//             tempNode.dict?.pmsTotalDays =
//                 dataModel.response!.changeData?[0].pmsTotalDays;
//             tempNode.dict?.consumePercentage =
//                 dataModel.response!.changeData?[0].consumePercentage;
//             tempNode.dict?.minDate = dataModel.response!.changeData?[0].minDate;
//             tempNode.dict?.maxDate = dataModel.response!.changeData?[0].maxDate;
//             tempNode.dict?.workOrderDetails =
//                 dataModel.response!.changeData?[0].workOrderDetails;
//             // tempNode.dict?.re =
//             // dataModel.response!.changeData?[0].workOrderDetails;
//             // tempNode.dict?.remarkList =
//             //     dataModel.response!.changeData?[0].remarkList;
//           }
//         }
//         notifyListeners();
//         return dataModel.response;
//       }
//     } else {
//       return null;
//     }
//   }

//   deleteNode(String currNodeToDelete) {
//     print("----------in deleet");
//     findrec(list11: treeController.roots, currNodeToDelete: currNodeToDelete);
//     // Iterable<Node> filteredNodes =
//     //     removeNodeRecursively(treeController.roots, currNodeToDelete);
//     // inspect(filteredNodes);
//     // for (var element in filteredNodes) {
//     //   print(element.dict?.pmsCategoryName);
//     // }
//     // treeController.roots = filteredNodes;
//     // notifyListeners();
//   }

//   findrec({required Iterable<Node> list11, required String currNodeToDelete}) {
//     for (var element in list11) {
//       Iterable<Node> updatedNodes = element.children.where((node) {
//         print(node.dict?.pmsCategoryName);
//         return node.dict?.mstPmsId != currNodeToDelete;
//       });
//       // element.children.reduce((value, element) => null)
//       // inspect(updatedNodes);
//       // updatedNodes.reduce((value, element) => null)

//       // treeController.roots = updatedNodes;

//       print("aaa-----------");
//       notifyListeners();

//       if (element.children.length != 0) {
//         findrec(list11: element.children1, currNodeToDelete: currNodeToDelete);
//       }
//     }
//     // }
//   }

//   // Iterable<Node> removeNodeRecursively(Iterable<Node> nodes, String targetId) {
//   //   return nodes.expand((node) {
//   //     if (node.dict?.mstPmsId == targetId) {
//   //       return removeNodeRecursively(node.children, targetId);
//   //     } else {
//   //       return [
//   //         Node(
//   //             id: node.id,
//   //             children: removeNodeRecursively(node.children, targetId))
//   //       ];
//   //     }
//   //   });
//   // }

//   Future<ResponseAddPmsResponse?> addNewPms({
//     required String projectId,
//     required String towarId,
//     required String parentId,
//     required String title,
//     required DateTime startDate,
//     required DateTime endtDate,
//   }) async {
//     String formatDate(DateTime dateTime) {
//       return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
//     }

//     Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');
//     Map<String, String> data = {
//       "user_id": userId ?? '',
//       "project_id": projectId,
//       "towar_id": towarId,
//       "parent_id": parentId,
//       "start_date": formatDate(startDate),
//       "end_date": formatDate(endtDate),
//       "pms_name": title,
//     };

//     var response = await apiNetworkHandler.post(AppUrl.wssetpmsstructure, data);

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = addPmsResponseFromJson(response.body);
//       // fetchRecords(
//       //   projectId: projectId,
//       //   towarId: towarId,
//       // );
//       return dataModel.response;
//     } else {
//       return null;
//     }
//   }

//   Future<UpdateProjectPmsInfoResponse?> updatePmsDetails({
//     required String projectId,
//     required String towarId,
//     // required String parentId,
//     required String title,
//     required DateTime pmsStartDate,
//     required DateTime pmsEndDate,
//     required String projectPmsId,
//   }) async {
//     String formatDate(DateTime dateTime) {
//       return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
//     }

//     Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

//     final SharedPreferences prefs = await _prefs;
//     String? userId = prefs.getString('mobileNo');
//     Map<String, String> data = {
//       "user_id": userId ?? '',
//       // "parent_id": parentId,
//       // "start_date": formatDate(startDate),
//       // "end_date": formatDate(endtDate),
//       "project_id": projectId,
//       "towar_id": towarId,
//       "project_pms_id": projectPmsId,
//       "project_pms_name": title,
//       "pms_start_date": formatDate(pmsStartDate),
//       "pms_end_date": formatDate(pmsEndDate),
//     };

//     var response =
//         await apiNetworkHandler.post(AppUrl.wssetprojectpmsinfo, data);

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final dataModel = updateProjectPmsInfoFromJson(response.body);

//       // fetchRecords(
//       //   projectId: projectId,
//       //   towarId: towarId,
//       // );
//       return dataModel.response;
//     } else {
//       return null;
//     }
//   }

//   Future<void> _selectStartDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedStartDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _selectedStartDate) {
//       _selectedStartDate = picked;
//       startDateControler.text =
//           DateFormat('dd/MM/yyyy').format(_selectedStartDate!);
//     }
//   }

//   Future<void> _selectEndDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedStartDate ?? DateTime.now(),
//       firstDate: _selectedStartDate ?? DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _selectedEndDate) {
//       _selectedEndDate = picked;
//       endDateControler.text =
//           DateFormat('dd/MM/yyyy').format(_selectedEndDate!);
//     }
//   }

//   addNewPmsModal({
//     required BuildContext context,
//     required String projectId,
//     required String towarId,
//     // required Node addNode,
//   }) {
//     titleControler.clear();
//     startDateControler.clear();
//     endDateControler.clear();
//     _selectedStartDate = null;
//     _selectedEndDate = null;
//     return showDialog<void>(
//         barrierDismissible: true,
//         context: context,
//         builder: (context) {
//           // return StatefulBuilder(builder: (context, setState) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8), // Set radius to zero
//             ),
//             titlePadding: const EdgeInsets.symmetric(vertical: 10),
//             actionsPadding: const EdgeInsets.only(bottom: 10),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//             actionsAlignment: MainAxisAlignment.center,
//             title: const Text(
//               "CREATE NEW PARENT",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             actions: [
//               InkWell(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Container(
//                   width: 250,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(7)),
//                   child: const Text(
//                     "CLOSE",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () async {
//                   if (!isLoadingAddPms && _formKey.currentState!.validate()) {
//                     // setState(() {
//                     isLoadingAddPms = true;
//                     // });
//                     ResponseAddPmsResponse? res = await addNewPms(
//                       parentId: '0',
//                       title: titleControler.text,
//                       startDate: _selectedStartDate!,
//                       endtDate: _selectedEndDate!,
//                       projectId: projectId,
//                       towarId: towarId,
//                     );

//                     if (res?.errorCode == "0") {
//                       // setState(() {
//                       isLoadingAddPms = false;
//                       pmsEndDateFromResponse = res?.pmsEndDate;
//                       pmsStartDateFromResponse = res?.pmsStartDate;
//                       // treeController.roots
//                       // Node tempNode = Node(
//                       //     dict: res?.addedPmsList?[0],
//                       //     id: (int.parse(
//                       //         res?.addedPmsList?[0].mstPmsId ?? '')));
//                       // Iterable<Node> etstttt = treeController.roots;
//                       // etstttt.
//                       // for (var element in filteredNodes) {
//                       //   print(element.dict?.pmsCategoryName);
//                       // }

//                       res?.addedPmsList?[0].expand = true;
//                       final child = Node(
//                           id: int.parse(res?.addedPmsList?[0].mstPmsId ?? ''),
//                           expandnode: false,
//                           dict: res?.addedPmsList?[0]);
//                       fetchExampleTree(
//                           child..parent1 = root, res?.addedPmsList?[0].details);

//                       root.children1.add(child);
//                       treeController.roots = root.children;
//                       treeController.childrenProvider =
//                           (Node node) => node.children;
//                       treeController.parentProvider =
//                           (Node node) => node.parent;
//                       intValue = root.children.length;
//                       notifyListeners();
//                       treeController.rebuild();
//                       // });
//                       // ignore: use_build_context_synchronously
//                       Navigator.of(context).pop();
//                     } else {
//                       // setState(() {
//                       isLoadingAddPms = false;
//                       // });
//                       // ignore: use_build_context_synchronously
//                       Navigator.of(context).pop();
//                     }
//                   }
//                 },
//                 child: Container(
//                   width: 250,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(7)),
//                   child: isLoadingAddPms
//                       ? const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(),
//                             ),
//                           ],
//                         )
//                       : const Text(
//                           'ADD',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                 ),
//               ),
//             ],
//             content: SizedBox(
//               width: 500,
//               height: 244,
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return "(Title Cannot Be Empty)";
//                           }
//                         },
//                         controller: titleControler,
//                         style: const TextStyle(
//                             color: Colors.black, fontSize: 13.0),
//                         decoration: const InputDecoration(
//                           contentPadding: EdgeInsets.all(12.0),
//                           border: OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.black)),
//                           hintText: 'Please Enter Title',
//                           hintStyle: TextStyle(
//                             color: Color.fromARGB(255, 116, 116, 116),
//                             fontSize: 13.0,
//                             fontWeight: FontWeight.w200,
//                             fontFamily: 'HelveticaNeue',
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 14),
//                       InkWell(
//                         onTap: () {
//                           clearEndDate();
//                           _selectStartDate(context);
//                         },
//                         child: TextFormField(
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "(Start Date Cannot Be Empty)";
//                             }
//                           },
//                           enabled: false,
//                           readOnly: true,
//                           controller: startDateControler,
//                           style: const TextStyle(
//                               color: Colors.black, fontSize: 13.0),
//                           decoration: const InputDecoration(
//                               contentPadding: EdgeInsets.all(12.0),
//                               border: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.black)),
//                               hintText: 'Select Start Date',
//                               hintStyle: TextStyle(
//                                 color: Color.fromARGB(255, 116, 116, 116),
//                                 fontSize: 13.0,
//                                 fontWeight: FontWeight.w200,
//                                 fontFamily: 'HelveticaNeue',
//                               ),
//                               suffixIcon: Icon(
//                                 Icons.calendar_month_outlined,
//                               )),
//                         ),
//                       ),
//                       const SizedBox(height: 14),
//                       InkWell(
//                         onTap: () {
//                           _selectEndDate(context);
//                         },
//                         child: TextFormField(
//                           validator: (value) {
//                             if (startDateControler.text.isEmpty) {
//                               return "(Please Select Start Date First)";
//                             } else if (value!.isEmpty) {
//                               return "(End Date Cannot Be Empty)";
//                             }
//                           },
//                           enabled: false,
//                           readOnly: true,
//                           controller: endDateControler,
//                           style: const TextStyle(
//                               color: Colors.black, fontSize: 13.0),
//                           decoration: const InputDecoration(
//                               contentPadding: EdgeInsets.all(12.0),
//                               border: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.black)),
//                               hintText: 'Select End Date',
//                               hintStyle: TextStyle(
//                                 color: Color.fromARGB(255, 116, 116, 116),
//                                 fontSize: 13.0,
//                                 fontWeight: FontWeight.w200,
//                                 fontFamily: 'HelveticaNeue',
//                               ),
//                               suffixIcon: Icon(
//                                 Icons.calendar_month_outlined,
//                               )),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//           // });
//         });
//   }

//   // updateTemplateWarningModal({
//   //   required BuildContext context,
//   // }) {
//   //   return
//   // }

//   updatePmsInfoModal({
//     required BuildContext context,
//     required String projectId,
//     required String towarId,
//     // required Node addNode,
//   }) {
//     titleControler.text = projectPmsInfoResponse?[0].projectPmsName ?? '';

//     _selectedStartDate = projectPmsInfoResponse?[0].projectPmsStartDate;
//     startDateControler.text =
//         DateFormat('dd/MM/yyyy').format(_selectedStartDate!);
//     _selectedEndDate = projectPmsInfoResponse?[0].projectPmsEndDate;
//     endDateControler.text = DateFormat('dd/MM/yyyy')
//         .format(_selectedEndDate!); // titleControler.clear();
//     //
//     // startDateControler.clear();
//     // endDateControler.clear();
//     // _selectedStartDate = null;
//     // _selectedEndDate = null;
//     return showDialog<void>(
//         barrierDismissible: true,
//         context: context,
//         builder: (context) {
//           // return StatefulBuilder(builder: (context, setState) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8), // Set radius to zero
//             ),
//             titlePadding: const EdgeInsets.symmetric(vertical: 10),
//             actionsPadding: const EdgeInsets.only(bottom: 10),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//             actionsAlignment: MainAxisAlignment.center,
//             title: const Text(
//               "UPDATE",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             actions: [
//               InkWell(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Container(
//                   width: 250,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(7)),
//                   child: const Text(
//                     "CLOSE",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () async {
//                   if (!isLoadingAddPms && _formKey.currentState!.validate()) {
//                     //   // setState(() {
//                     //   isLoadingAddPms = true;
//                     //   // });
//                     Navigator.of(context).pop();
//                     UpdateProjectPmsInfoResponse? res = await updatePmsDetails(
//                       title: titleControler.text,
//                       pmsStartDate: _selectedStartDate!,
//                       pmsEndDate: _selectedEndDate!,
//                       projectId: projectId,
//                       towarId: towarId,
//                       projectPmsId:
//                           projectPmsInfoResponse?[0].mstProjectPmsId ?? '',
//                     );

//                     if (res?.errorCode == "0") {
//                       pmsEndDateFromResponse = res?.pmsEndDate;
//                       pmsStartDateFromResponse = res?.pmsStartDate;
//                       projectPmsInfoResponse?[0].projectPmsStartDate =
//                           res?.pmsStartDate;
//                       projectPmsInfoResponse?[0].projectPmsEndDate =
//                           res?.pmsEndDate;
//                       projectPmsInfoResponse?[0].projectPmsName =
//                           titleControler.text;

//                       notifyListeners();
//                     }
//                     //     // setState(() {
//                     //     isLoadingAddPms = false;
//                     //     pmsEndDateFromResponse = res?.pmsEndDate;
//                     //     pmsStartDateFromResponse = res?.pmsStartDate;
//                     //     // treeController.roots
//                     //     // Node tempNode = Node(
//                     //     //     dict: res?.addedPmsList?[0],
//                     //     //     id: (int.parse(
//                     //     //         res?.addedPmsList?[0].mstPmsId ?? '')));
//                     //     // Iterable<Node> etstttt = treeController.roots;
//                     //     // etstttt.
//                     //     // for (var element in filteredNodes) {
//                     //     //   print(element.dict?.pmsCategoryName);
//                     //     // }

//                     //     res?.addedPmsList?[0].expand = true;
//                     //     final child = Node(
//                     //         id: int.parse(res?.addedPmsList?[0].mstPmsId ?? ''),
//                     //         expandnode: false,
//                     //         dict: res?.addedPmsList?[0]);
//                     //     fetchExampleTree(
//                     //         child..parent1 = root, res?.addedPmsList?[0].details);

//                     //     root.children1.add(child);
//                     //     treeController.roots = root.children;
//                     //     treeController.childrenProvider =
//                     //         (Node node) => node.children;
//                     //     treeController.parentProvider =
//                     //         (Node node) => node.parent;
//                     //     intValue = root.children.length;
//                     //     notifyListeners();
//                     //     treeController.rebuild();
//                     //     // });
//                     //     // ignore: use_build_context_synchronously
//                     //     Navigator.of(context).pop();
//                     //   } else {
//                     //     // setState(() {
//                     //     isLoadingAddPms = false;
//                     //     // });
//                     //     // ignore: use_build_context_synchronously
//                     //     Navigator.of(context).pop();
//                     //   }
//                   }
//                 },
//                 child: Container(
//                   width: 250,
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(7)),
//                   child: isLoadingAddPms
//                       ? const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(),
//                             ),
//                           ],
//                         )
//                       : const Text(
//                           'UPDATE',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                 ),
//               ),
//             ],
//             content: SizedBox(
//               width: 500,
//               height: 244,
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return "(Title Cannot Be Empty)";
//                           }
//                         },
//                         controller: titleControler,
//                         style: const TextStyle(
//                             color: Colors.black, fontSize: 13.0),
//                         decoration: const InputDecoration(
//                           contentPadding: EdgeInsets.all(12.0),
//                           border: OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.black)),
//                           hintText: 'Please Enter Title',
//                           hintStyle: TextStyle(
//                             color: Color.fromARGB(255, 116, 116, 116),
//                             fontSize: 13.0,
//                             fontWeight: FontWeight.w200,
//                             fontFamily: 'HelveticaNeue',
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 14),
//                       InkWell(
//                         onTap: () async {
//                           // clearEndDate();
//                           // _selectStartDate(context);
//                           // _selectedEndDate = null;
//                           final DateTime? picked = await showDatePicker(
//                             context: context,
//                             initialDate: _selectedStartDate ?? DateTime.now(),
//                             firstDate: DateTime(2000),
//                             lastDate: _selectedEndDate == null
//                                 ? DateTime(2101)
//                                 : _selectedEndDate!,
//                           );
//                           if (picked != null && picked != _selectedStartDate) {
//                             _selectedStartDate = picked;
//                             startDateControler.text = DateFormat('dd/MM/yyyy')
//                                 .format(_selectedStartDate!);
//                           }
//                         },
//                         child: TextFormField(
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "(Start Date Cannot Be Empty)";
//                             }
//                           },
//                           enabled: false,
//                           readOnly: true,
//                           controller: startDateControler,
//                           style: const TextStyle(
//                               color: Colors.black, fontSize: 13.0),
//                           decoration: const InputDecoration(
//                               contentPadding: EdgeInsets.all(12.0),
//                               border: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.black)),
//                               hintText: 'Select Start Date',
//                               hintStyle: TextStyle(
//                                 color: Color.fromARGB(255, 116, 116, 116),
//                                 fontSize: 13.0,
//                                 fontWeight: FontWeight.w200,
//                                 fontFamily: 'HelveticaNeue',
//                               ),
//                               suffixIcon: Icon(
//                                 Icons.calendar_month_outlined,
//                               )),
//                         ),
//                       ),
//                       const SizedBox(height: 14),
//                       InkWell(
//                         onTap: () async {
//                           // _selectEndDate(context);

//                           DateTime startDateCal() {
//                             if (_selectedStartDate == null) {
//                               return DateTime.now();
//                             } else {
//                               if (DateTime.now()
//                                   .isBefore(_selectedStartDate!)) {
//                                 return _selectedStartDate!;
//                               } else {
//                                 return DateTime.now();
//                               }
//                             }
//                           }

//                           final DateTime? picked = await showDatePicker(
//                             context: context,
//                             initialDate: startDateCal(),
//                             //  DateTime
//                             //     .now(), //_selectedEndDate ?? DateTime.now(),
//                             firstDate: _selectedStartDate == null
//                                 ? DateTime(2000)
//                                 : _selectedStartDate!,
//                             lastDate: DateTime(2101),
//                           );
//                           if (picked != null && picked != _selectedEndDate) {
//                             _selectedEndDate = picked;
//                             endDateControler.text = DateFormat('dd/MM/yyyy')
//                                 .format(_selectedEndDate!);
//                           }
//                         },
//                         child: TextFormField(
//                           validator: (value) {
//                             if (startDateControler.text.isEmpty) {
//                               return "(Please Select Start Date First)";
//                             } else if (value!.isEmpty) {
//                               return "(End Date Cannot Be Empty)";
//                             }
//                           },
//                           enabled: false,
//                           readOnly: true,
//                           controller: endDateControler,
//                           style: const TextStyle(
//                               color: Colors.black, fontSize: 13.0),
//                           decoration: const InputDecoration(
//                               contentPadding: EdgeInsets.all(12.0),
//                               border: OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.black)),
//                               hintText: 'Select End Date',
//                               hintStyle: TextStyle(
//                                 color: Color.fromARGB(255, 116, 116, 116),
//                                 fontSize: 13.0,
//                                 fontWeight: FontWeight.w200,
//                                 fontFamily: 'HelveticaNeue',
//                               ),
//                               suffixIcon: Icon(
//                                 Icons.calendar_month_outlined,
//                               )),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//           // });
//         });
//   }
// }

// class DupliacateDataPms {
//   String? mstPmsId;
//   String? pmsCategoryName;
//   String? parentIdFk;
//   String? pmsOrderNo;
//   String? pmsColorCode;
//   DateTime? pmsStartDate;
//   DateTime? pmsEndDate;
//   DateTime? minDate;
//   DateTime? maxDate;
//   String? projectPmsIdFk;
//   String? totalDays;
//   TextEditingController? textController1;
//   String? pms_color_code;

//   DupliacateDataPms({
//     required this.mstPmsId,
//     required this.pmsCategoryName,
//     required this.parentIdFk,
//     required this.pmsOrderNo,
//     required this.pmsColorCode,
//     required this.pmsStartDate,
//     required this.pmsEndDate,
//     required this.totalDays,
//     this.textController1,
//     required this.maxDate,
//     required this.minDate,
//     required this.projectPmsIdFk,
//     required this.pms_color_code,
//   });

//   factory DupliacateDataPms.fromJson(Map<String, dynamic> json) =>
//       DupliacateDataPms(
//         mstPmsId: json["mstPmsId"],
//         pms_color_code: json["pms_color_code"],
//         pmsCategoryName: json["pmsCategoryName"],
//         parentIdFk: json["parentIdFk"],
//         pmsOrderNo: json["pmsOrderNo"],
//         pmsColorCode: json["pmsColorCode"],
//         totalDays: json["totalDays"],
//         textController1: TextEditingController(),
//         pmsStartDate: json["pmsStartDate"] == '' || json["pmsStartDate"] == null
//             ? DateTime(2000)
//             : DateTime.parse(json["pmsStartDate"]),
//         pmsEndDate: json["pmsEndDate"] == '' || json["pmsEndDate"] == null
//             ? DateTime(2101)
//             : DateTime.parse(json["pmsEndDate"]),
//         maxDate: json["maxDate"] == ''
//             ? DateTime(2000)
//             : DateTime.parse(json["maxDate"]),
//         minDate: json["minDate"] == ''
//             ? DateTime(2101)
//             : DateTime.parse(json["minDate"]),
//         projectPmsIdFk: json["projectPmsIdFk"],
//       );

//   Map<String, dynamic> toJson() {
//     return {
//       "pms_color_code": pms_color_code,
//       'mstPmsId': mstPmsId,
//       'pmsCategoryName': pmsCategoryName,
//       'parentIdFk': parentIdFk,
//       'pmsOrderNo': pmsOrderNo,
//       'pmsColorCode': pmsColorCode,
//       'pmsStartDate': pmsStartDate == null || pmsStartDate == DateTime(2000)
//           ? ""
//           : "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
//       'pmsEndDate': pmsEndDate == null || pmsEndDate == DateTime(2101)
//           ? ""
//           : "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
//       'maxDate': maxDate == null || maxDate == DateTime(2000)
//           ? ""
//           : "${maxDate!.year.toString().padLeft(4, '0')}-${maxDate!.month.toString().padLeft(2, '0')}-${maxDate!.day.toString().padLeft(2, '0')}",
//       'minDate': minDate == null || minDate == DateTime(2101)
//           ? ""
//           : "${minDate!.year.toString().padLeft(4, '0')}-${minDate!.month.toString().padLeft(2, '0')}-${minDate!.day.toString().padLeft(2, '0')}",
//       'projectPmsIdFk': projectPmsIdFk,
//     };
//   }
// }
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// import 'package:projectmanagement/fancynode/drag_and_drop.dart';
// import 'package:projectmanagement/fancynode/flutter_fancy_tree_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/add_pms_response.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/models/update_project_pms_info.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/models/updating_existing_drawer.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/provider/provider_registration.dart';

import '../../../../../utils/app_url.dart';
import '../../../salesmanagement/salesleads/salesLeadDetailPage.dart';
import '../../fancynode/pms_view/nodee.dart';
import '../../fancynode/src/tree_controller.dart';
import '../../models/ws_get_pms_structure.dart';

class FetchApiProvider extends ChangeNotifier {
  late ChangeNotifierProviderRef<FetchApiProvider> ref;
  FetchApiProvider(this.ref);

  List<Widget> arrWidget = [];
  List<Node> openDropDown = [];
  List<PmsStructure>? pmsStructure = [];
  List<ProjectPmsInfo>? projectPmsInfoResponse = [];
  DateTime? pmsStartDateFromResponse;
  DateTime? pmsEndDateFromResponse;
  late Node root;

  TreeController<Node> treeController =
      TreeController(roots: [], childrenProvider: (Node node) => node.children);
  var intValue = 0;
  bool flagcalled = true;
  bool isLoadingFetchShimer = false;
  bool isLoadingAddPms = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TextEditingController titleControler = TextEditingController();
  TextEditingController startDateControler = TextEditingController();
  TextEditingController endDateControler = TextEditingController();

  clearEndDate() {
    endDateControler.clear();
    _selectedEndDate = null;
    notifyListeners();
  }

  setOpenDropDown(Node data) {
    openDropDown.add(data);
    // print(openDropDown.length);
    // notifyListeners();
  }

  removeOpenDropDown(Node data) {
    openDropDown.remove(data);
    // add(data);
    // notifyListeners();
    // print(openDropDown.length);
  }

  void fetchExampleTree(Node node, List<PmsStructure>? structure) {
    for (int i = 0; i < structure!.length; i++) {
      structure[i].expand = true;
      final child = Node(
          id: int.parse(structure[i].mstPmsId!),
          expandnode: false,
          dict: structure[i])
        ..parent1 = node;
      node.children1.add(child);
      fetchExampleTree(child, structure[i].details);
    }
  }

  void findRecursiveTrueFalseList(List<Node> list, bool flag) {
    for (int i = 0; i < list.length; i++) {
      list[i].dict!.expand = flag;
      if (list[i].children1.isNotEmpty) {
        findRecursiveTrueFalseList(list[i].children1, flag);
      }
    }
  }

  void findRecursiveTrueFalse(Node list, bool flag) {
    for (int i = 0; i < list.children1.length; i++) {
      list.children1[i].dict!.expand = flag;
      // ref.read(fetchApiProvider).removeOpenDropDown(list.children1[i]);
      treeController.collapse(list.children1[i]);

      if (flag == false) {
        if (list.children1[i].children1.isNotEmpty) {
          // setOpenDropDown(list.children1[i]);
          findRecursiveTrueFalseList(list.children1[i].children1, flag);
        }
      }
    }
    notifyListeners();
  }

  Future<ResponseProjectSchedule?> fetchRecords({
    required String projectId,
    required String towarId,
  }) async {
    // isLoadingFetchShimer = true;
    setLoadingFetchRecord(true);
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": projectId,
      "towar_id": towarId,
    };

    if (kDebugMode) {
      print(data);
    }

    var response = await apiNetworkHandler.post(AppUrl.wsgetpmsstructure, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      arrWidget = [];
      final dataModel = projectScheduleFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        //return dataModel.response;
        projectPmsInfoResponse = dataModel.response?.projectPmsInfo;
        pmsStructure = dataModel.response?.pmsStructure;
        inspect(pmsStructure);
        pmsEndDateFromResponse = dataModel.response?.pmsEndDate;
        pmsStartDateFromResponse = dataModel.response?.pmsStartDate;
        root = Node(id: -1);
        // inspect(openDropDown);

        for (int i = 0; i < pmsStructure!.length; i++) {
          pmsStructure![i].expand = true;
          final child = Node(
              id: int.parse(pmsStructure![i].mstPmsId!),
              expandnode: true,
              dict: pmsStructure![i]);
          fetchExampleTree(child..parent1 = root, pmsStructure![i].details);

          root.children1.add(child);
        }
        // treeController = TreeController<Node>(
        //   roots: root.children,
        //   childrenProvider: (Node node) => node.children,
        //   parentProvider: (Node node) => node.parent,
        // );

        treeController.roots = root.children;
        treeController.childrenProvider = (Node node) => node.children;
        treeController.parentProvider = (Node node) => node.parent;
        intValue = root.children.length;
        flagcalled = true;
        if (dataModel.response?.defaultFlag == "1") {
          treeController.expandAll();

          // notifyListeners();
        }
        // notifyListeners();
        // arrWidget = [];
        // Future.delayed(const Duration(seconds: 1), () {
        //   print('One second has passed.'); // Prints after 1 second.
        //   // inspect(treeController);
        //   // for (int k = 0; k < openDropDown.length; k++) {
        //   //   print('-------------${openDropDown[k].dict?.pmsCategoryName}');
        //   //   // treeController.toggleExpansion(openDropDown[k]);
        //   //   treeController.toggleExpansion(openDropDown[k]);
        //   // }
        //   findrec({required Iterable<Node> list11}) {
        //     for (var element in list11) {
        //       for (int k = 0; k < openDropDown.length; k++) {
        //         // print(element.dict?.pmsCategoryName);
        //         if (openDropDown[k].dict?.mstPmsId == element.dict?.mstPmsId) {
        //           print(
        //               '${element.dict?.pmsCategoryName} -----------------  true');
        //           treeController.expand(element);
        //           findRecursiveTrueFalse(element, true);
        //         }

        //         if (element.children.length != 0) {
        //           findrec(list11: element.children1);
        //         }
        //       }
        //     }
        //   }

        //   findrec(list11: treeController.roots);
        //   //  root.children1);
        //   // }
        // treeController.expandAll();

        // Future.delayed(const Duration(seconds: 15), () {
        //   treeController.rebuild();
        // });
        // notifyListeners();
        setLoadingFetchRecord(false);
        // });
      }
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      return null;
    }
    return null;
  }

  findRecAndAdd({
    required Node currNode,
    required Iterable<Node> list11,
    required List<PmsStructure>? addedPmsList,
    required String onSelectedPmsid,
    required List<PmsStructure>? changeData,
  }) {
    for (var element in list11) {
      for (int k = 0; k > changeData!.length; k++) {
        if (changeData?[k].mstPmsId == element.dict?.mstPmsId) {
          element.dict?.pmsStartDate = changeData?[k].pmsStartDate;
          element.dict?.pmsEndDate = changeData?[k].pmsEndDate;
          // element.dict?.pmsStartDate = res.changeData?[k].pmsStartDate;
          // notifyListeners();
        }
      }
      // for (int k = 0; k < openDropDown.length; k++) {
      // print(element.dict?.pmsCategoryName);
      if (onSelectedPmsid == element.dict?.mstPmsId) {
        element.dict?.expand = true;
        // print('${element.dict?.pmsCategoryName} -----------------  true');

        addedPmsList?[0].expand = true;
        final child = Node(
            id: int.parse(addedPmsList?[0].mstPmsId ?? ''),
            expandnode: false,
            dict: addedPmsList?[0]);
        child.parent?.children1 = element.parent!.children1;
        child.parent1 = element;
        element.children1.add(child);

        // ref.read(fetchApiProvider).fetchExampleTree(
        //     child
        //       ..parent1 = ref.read(fetchApiProvider).root,
        //     res?.addedPmsList?[0].details);

        // ref
        //     .read(fetchApiProvider)
        //     .root
        //     .children1
        //     .add(child);
        // treeController.roots = root.children;
        // treeController.childrenProvider = (Node node) => node.children;
        // treeController.parentProvider = (Node node) => node.parent;
        // intValue = root.children.length;
        // treeController.toggleExpansion(currNode);
        // treeController.expand(currNode);
        notifyListeners();
        treeController.rebuild();
        //   treeController.expand(element);
        //   findRecursiveTrueFalse(element, true);
      }

      if (element.children.length != 0) {
        findRecAndAdd(
          list11: element.children1,
          addedPmsList: addedPmsList,
          onSelectedPmsid: onSelectedPmsid,
          changeData: changeData,
          currNode: currNode,
        );
      }
      // }
    }
  }

  List<PmsStructure>? pmsStructureForUpdateExistingDrawer;
  List<DupliacateDataPms>? pmsStructureForDuplicating;
  findRecToGetSingleDimensionArray(
      {required Iterable<Node> list11,
      required PmsStructure currSelectedNode}) {
    for (var element in list11) {
      // print(
      //     '${element.dict?.pmsCategoryName} --------- ${pmsStructureForDuplicating?.length}');
      // pmsStructureForDuplicating?.add(element.dict ?? PmsStructure());
      pmsStructureForDuplicating = [
        ...pmsStructureForDuplicating ?? [],
        // element.dict!
        DupliacateDataPms(
          pms_color_code: element.dict?.pms_color_code,
          mstPmsId: element.dict?.mstPmsId,
          pmsCategoryName: element.dict?.pmsCategoryName,
          parentIdFk: element.dict?.parentIdFk,
          pmsOrderNo: element.dict?.pmsOrderNo,
          pmsColorCode: element.dict?.pms_color_code,
          pmsStartDate: element.dict?.pmsStartDate == DateTime(2000)
              ? null
              : element.dict?.pmsStartDate,
          pmsEndDate: element.dict?.pmsEndDate == DateTime(2101)
              ? null
              : element.dict?.pmsEndDate,
          totalDays: element.dict?.pmsTotalDays,
          maxDate: element.dict?.maxDate,
          minDate: element.dict?.minDate,
          projectPmsIdFk: element.dict?.projectPmsIdFk,
          parentStartDate: element.dict?.parentStartDate,
          //  element.parent?.dict?.parentStartDate,
        )
      ];
      // for (int k = 0; k < openDropDown.length; k++) {
      // print(element.dict?.pmsCategoryName);
      // if (openDropDown[k].dict?.mstPmsId == element.dict?.mstPmsId) {
      //   print(
      //       '${element.dict?.pmsCategoryName} -----------------  true');
      //   treeController.expand(element);
      //   findRecursiveTrueFalse(element, true);
      // }

      if (element.children.length != 0) {
        findRecToGetSingleDimensionArray(
            list11: element.children1, currSelectedNode: currSelectedNode);
      }

      // }
    }
    // pmsStructureForDuplicating = [
    //   ...pmsStructureForDuplicating ?? [],
    //   // element.dict!
    //   DupliacateDataPms(
    //     mstPmsId: currSelectedNode.mstPmsId,
    //     pmsCategoryName: currSelectedNode.pmsCategoryName,
    //     parentIdFk: currSelectedNode.parentIdFk,
    //     pmsOrderNo: currSelectedNode.pmsOrderNo,
    //     pmsColorCode: currSelectedNode.pms_color_code,
    //   )
    // ];
    // notifyListeners();
  }

  setLoadingFetchRecord(bool val) {
    isLoadingFetchShimer = val;
    notifyListeners();
  }

  Future<UpdateExistingDrawerResponse?> updateExistingPmsApi({
    required String parentId,
    required String title,
    required String remark,
    required DateTime startDate,
    required DateTime endtDate, // <- spelling as in your code
    required String mstpmsid,
    required String projectId,
    required String towarId,
    String? updatedPmsListTemp,
    Node? currNode,
  }) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    inspect(pmsStructureForDuplicating);
    // String temmmm = json.encode(pmsStructureForDuplicating);
    final temmmm =
        jsonEncode(pmsStructureForDuplicating?.map((e) => e.toJson()).toList());
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    String formatDate(DateTime dateTime) {
      if (dateTime == DateTime(2101) || dateTime == DateTime(2000)) {
        return "";
      } else {
        return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
      }
    }

    String formatDateTime(DateTime data) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(data);
    }

    // ---------- NEW: compute end-date delta before API call ----------
    // We'll use the currently selected node as the "current node".
    final Node? current = ref.read(homeProvider).curNodeDrawerData ?? currNode;
    final DateTime? oldEnd =
        current?.dict?.pmsEndDate ?? pmsStructureForDuplicating?[0].pmsEndDate;

    // Use the requested (new) end date coming into this method
    final DateTime newEndCandidate =
        pmsStructureForDuplicating?[0].pmsEndDate ?? endtDate;

    final int endDeltaDays =
        (oldEnd != null) ? newEndCandidate.difference(oldEnd).inDays : 0;

    Map<String, String> data = {
      "user_id": userId ?? '',
      "mst_pms_id": mstpmsid,
      "project_id": projectId,
      "towar_id": towarId,
      "parent_id": parentId,
      "start_date":
          formatDate(pmsStructureForDuplicating?[0].pmsStartDate ?? startDate),
      "end_date":
          formatDate(pmsStructureForDuplicating?[0].pmsEndDate ?? endtDate),
      "remark": remark,
      "store_date": formatDateTime(DateTime.now()),
      "work_order_id":
          ref.read(homeProvider).workOrderListSelected?.workOrderId ?? "0",
      "pms_progress": (ref.read(homeProvider).workCompletePercentageValue * 100)
          .toStringAsFixed(2),
      "pms_child_update": temmmm,
      "check_status": ref.read(homeProvider).checkboxValue.toString(),
      "updatedPmsListTemp": updatedPmsListTemp ?? '',
    };

    var response = await apiNetworkHandler.post(AppUrl.wssetpmsstructure, data);
    print('ws-set-pms-structure  :  ${data}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = updateExistingDrawerFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        pmsStartDateFromResponse = dataModel.response?.pmsStartDate;
        pmsEndDateFromResponse = dataModel.response?.pmsEndDate;

        // ---------- keep local tree in sync with title + dates for the edited node ----------
        if (currNode != null) {
          findrec({required Iterable<Node> list11}) {
            for (var element in list11) {
              if (currNode.dict?.mstPmsId == element.dict?.mstPmsId) {
                element.dict?.pmsCategoryName = title;
                element.dict?.pmsStartDate = startDate;
                element.dict?.pmsEndDate = endtDate;
                print('${element.dict?.pmsCategoryName} ----- true');
              }
              if (element.children.isNotEmpty) {
                findrec(list11: element.children1);
              }
            }
          }

          findrec(list11: treeController.roots);
        }

        // ---------- apply local changes from pmsStructureForDuplicating ----------

        // Snapshot old start/end dates for all nodes so we can report what changed.

        testtt(Iterable<Node> dataa) {
          for (var element in dataa) {
            for (int i = 0; i < pmsStructureForDuplicating!.length; i++) {
              if (pmsStructureForDuplicating?[i].mstPmsId ==
                  element.dict?.mstPmsId) {
                element.dict?.pmsStartDate =
                    pmsStructureForDuplicating?[i].pmsStartDate;
                element.dict?.pmsEndDate =
                    pmsStructureForDuplicating?[i].pmsEndDate;
                element.dict?.pmsTotalDays =
                    pmsStructureForDuplicating?[i].totalDays;
                element.dict?.minDate = pmsStructureForDuplicating?[i].minDate;
                element.dict?.maxDate = pmsStructureForDuplicating?[i].maxDate;
                element.dict?.pmsCategoryName =
                    pmsStructureForDuplicating?[i].pmsCategoryName;
                notifyListeners();
              }
            }
            if (element.children.isNotEmpty) {
              testtt(element.children1);
            }
          }
        }

        // ---------- make sure we update BOTH start and end for the current node ----------
        ref.read(homeProvider).curNodeDrawerData?.dict?.pmsStartDate =
            pmsStructureForDuplicating?[0].pmsStartDate;
        ref.read(homeProvider).curNodeDrawerData?.dict?.pmsEndDate =
            pmsStructureForDuplicating?[0].pmsEndDate; // <-- added

        testtt(ref.read(homeProvider).curNodeDrawerData?.children ?? const []);

        // ---------- server-driven updates ----------
        Node? tempNode;
        for (var element in treeController.roots) {
          if (element.dict?.mstPmsId ==
              dataModel.response?.changeData?[0].mstPmsId) {
            tempNode = element;
            break;
          }
        }

        updatingdataFromRes(Iterable<Node> dataa) {
          for (var element1 in dataa) {
            for (int i = 0; i < dataModel.response!.changeData!.length; i++) {
              if (dataModel.response!.changeData?[i].parentIdFk == parentId) {
                print(
                    'champ---${dataModel.response!.changeData?[i].pmsCategoryName} --${dataModel.response!.changeData?[i].mstPmsId} == ${element1.dict?.mstPmsId}');
              }

              if (dataModel.response!.changeData?[i].mstPmsId ==
                  element1.dict?.mstPmsId) {
                element1.dict?.pmsCategoryName =
                    dataModel.response!.changeData?[i].pmsCategoryName;
                element1.dict?.pmsStartDate =
                    dataModel.response!.changeData?[i].pmsStartDate;
                element1.dict?.pmsEndDate =
                    dataModel.response!.changeData?[i].pmsEndDate;
                element1.dict?.pmsTotalDays =
                    dataModel.response!.changeData?[i].pmsTotalDays;
                element1.dict?.consumePercentage =
                    dataModel.response!.changeData?[i].consumePercentage;
                element1.dict?.minDate =
                    dataModel.response!.changeData?[i].minDate;
                element1.dict?.maxDate =
                    dataModel.response!.changeData?[i].maxDate;
                element1.dict?.cmsOriginalEndDate =
                    dataModel.response!.changeData?[i].cmsOriginalEndDate;
                element1.dict?.cmsOriginalStartDate =
                    dataModel.response!.changeData?[i].cmsOriginalStartDate;
              }
            }
            if (element1.children.isNotEmpty) {
              updatingdataFromRes(element1.children1); // <-- fixed (was testtt)
            }
          }
        }

        if (ref.read(homeProvider).curNodeDrawerData != null &&
            ref.read(homeProvider).curNodeDrawerData?.dict?.mstPmsId ==
                dataModel.response!.addedPmsList?[0].mstPmsId) {
          ref.read(homeProvider).curNodeDrawerData?.dict?.consumePercentage =
              dataModel.response!.addedPmsList?[0].consumePercentage;
          ref.read(homeProvider).curNodeDrawerData?.dict?.remarkList =
              dataModel.response!.addedPmsList?[0].remarkList;
          ref.read(homeProvider).curNodeDrawerData?.dict?.workOrderDetails =
              dataModel.response!.addedPmsList?[0].workOrderDetails;
          ref.read(homeProvider).curNodeDrawerData?.dict?.pmsCategoryName =
              dataModel.response!.addedPmsList?[0].pmsCategoryName;
          ref.read(homeProvider).curNodeDrawerData?.dict?.checkStatus =
              dataModel.response!.addedPmsList?[0].checkStatus;
        }

        if (tempNode != null) {
          updatingdataFromRes(tempNode.children);
          if (tempNode.dict?.mstPmsId ==
              dataModel.response!.changeData?[0].mstPmsId) {
            tempNode.dict?.pmsStartDate =
                dataModel.response!.changeData?[0].pmsStartDate;
            tempNode.dict?.pmsEndDate =
                dataModel.response!.changeData?[0].pmsEndDate;
            tempNode.dict?.pmsTotalDays =
                dataModel.response!.changeData?[0].pmsTotalDays;
            tempNode.dict?.consumePercentage =
                dataModel.response!.changeData?[0].consumePercentage;
            tempNode.dict?.minDate = dataModel.response!.changeData?[0].minDate;
            tempNode.dict?.maxDate = dataModel.response!.changeData?[0].maxDate;
            tempNode.dict?.workOrderDetails =
                dataModel.response!.changeData?[0].workOrderDetails;
          }
        }

        notifyListeners();
        return dataModel.response;
      }
    }
    return null;
  }

  deleteNode(String currNodeToDelete) {
    print("----------in deleet");
    findrec(list11: treeController.roots, currNodeToDelete: currNodeToDelete);
    // Iterable<Node> filteredNodes =
    //     removeNodeRecursively(treeController.roots, currNodeToDelete);
    // inspect(filteredNodes);
    // for (var element in filteredNodes) {
    //   print(element.dict?.pmsCategoryName);
    // }
    // treeController.roots = filteredNodes;
    // notifyListeners();
  }

  findrec({required Iterable<Node> list11, required String currNodeToDelete}) {
    for (var element in list11) {
      Iterable<Node> updatedNodes = element.children.where((node) {
        print(node.dict?.pmsCategoryName);
        return node.dict?.mstPmsId != currNodeToDelete;
      });
      // element.children.reduce((value, element) => null)
      // inspect(updatedNodes);
      // updatedNodes.reduce((value, element) => null)

      // treeController.roots = updatedNodes;

      print("aaa-----------");
      notifyListeners();

      if (element.children.length != 0) {
        findrec(list11: element.children1, currNodeToDelete: currNodeToDelete);
      }
    }
    // }
  }

  // Iterable<Node> removeNodeRecursively(Iterable<Node> nodes, String targetId) {
  //   return nodes.expand((node) {
  //     if (node.dict?.mstPmsId == targetId) {
  //       return removeNodeRecursively(node.children, targetId);
  //     } else {
  //       return [
  //         Node(
  //             id: node.id,
  //             children: removeNodeRecursively(node.children, targetId))
  //       ];
  //     }
  //   });
  // }

  Future<ResponseAddPmsResponse?> addNewPms({
    required String projectId,
    required String towarId,
    required String parentId,
    required String title,
    required DateTime? startDate,
    required DateTime? endtDate,
  }) async {
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": projectId,
      "towar_id": towarId,
      "parent_id": parentId,
      "start_date": startDate == null ? '' : formatDate(startDate),
      "end_date": endtDate == null ? '' : formatDate(endtDate),
      "pms_name": title,
    };

    var response = await apiNetworkHandler.post(AppUrl.wssetpmsstructure, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = addPmsResponseFromJson(response.body);
      // fetchRecords(
      //   projectId: projectId,
      //   towarId: towarId,
      // );
      return dataModel.response;
    } else {
      return null;
    }
  }

  Future<UpdateProjectPmsInfoResponse?> updatePmsDetails({
    required String projectId,
    required String towarId,
    // required String parentId,
    required String title,
    required DateTime pmsStartDate,
    required DateTime pmsEndDate,
    required String projectPmsId,
  }) async {
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      // "parent_id": parentId,
      // "start_date": formatDate(startDate),
      // "end_date": formatDate(endtDate),
      "project_id": projectId,
      "towar_id": towarId,
      "project_pms_id": projectPmsId,
      "project_pms_name": title,
      "pms_start_date": formatDate(pmsStartDate),
      "pms_end_date": formatDate(pmsEndDate),
    };

    var response =
        await apiNetworkHandler.post(AppUrl.wssetprojectpmsinfo, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = updateProjectPmsInfoFromJson(response.body);

      // fetchRecords(
      //   projectId: projectId,
      //   towarId: towarId,
      // );
      return dataModel.response;
    } else {
      return null;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedStartDate) {
      _selectedStartDate = picked;
      startDateControler.text =
          DateFormat('dd/MM/yyyy').format(_selectedStartDate!);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: _selectedStartDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedEndDate) {
      _selectedEndDate = picked;
      endDateControler.text =
          DateFormat('dd/MM/yyyy').format(_selectedEndDate!);
    }
  }

  addNewPmsModal({
    required BuildContext context,
    required String projectId,
    required String towarId,
    // required Node addNode,
  }) {
    titleControler.clear();
    startDateControler.clear();
    endDateControler.clear();
    _selectedStartDate = null;
    _selectedEndDate = null;
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          // return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Set radius to zero
            ),
            titlePadding: const EdgeInsets.symmetric(vertical: 10),
            actionsPadding: const EdgeInsets.only(bottom: 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsAlignment: MainAxisAlignment.center,
            title: const Text(
              "CREATE NEW PARENT",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Text(
                    "CLOSE",
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
                onTap: () async {
                  if (!isLoadingAddPms
                      // && _formKey.currentState!.validate()
                      ) {
                    // setState(() {
                    isLoadingAddPms = true;
                    // });
                    ResponseAddPmsResponse? res = await addNewPms(
                      parentId: '0',
                      title: titleControler.text,
                      startDate: _selectedStartDate,
                      endtDate: _selectedEndDate,
                      projectId: projectId,
                      towarId: towarId,
                    );

                    if (res?.errorCode == "0") {
                      // setState(() {
                      isLoadingAddPms = false;
                      pmsEndDateFromResponse = res?.pmsEndDate;
                      pmsStartDateFromResponse = res?.pmsStartDate;
                      // treeController.roots
                      // Node tempNode = Node(
                      //     dict: res?.addedPmsList?[0],
                      //     id: (int.parse(
                      //         res?.addedPmsList?[0].mstPmsId ?? '')));
                      // Iterable<Node> etstttt = treeController.roots;
                      // etstttt.
                      // for (var element in filteredNodes) {
                      //   print(element.dict?.pmsCategoryName);
                      // }

                      res?.addedPmsList?[0].expand = true;
                      final child = Node(
                          id: int.parse(res?.addedPmsList?[0].mstPmsId ?? ''),
                          expandnode: false,
                          dict: res?.addedPmsList?[0]);
                      fetchExampleTree(
                          child..parent1 = root, res?.addedPmsList?[0].details);

                      root.children1.add(child);
                      treeController.roots = root.children;
                      treeController.childrenProvider =
                          (Node node) => node.children;
                      treeController.parentProvider =
                          (Node node) => node.parent;
                      intValue = root.children.length;
                      notifyListeners();
                      treeController.rebuild();
                      // });
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    } else {
                      // setState(() {
                      isLoadingAddPms = false;
                      // });
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
                  child: isLoadingAddPms
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        )
                      : const Text(
                          'ADD',
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
            content: SizedBox(
              width: 500,
              height: 244,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "(Title Cannot Be Empty)";
                          }
                        },
                        controller: titleControler,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 13.0),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: 'Please Enter Title',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 116, 116, 116),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'HelveticaNeue',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () {
                          clearEndDate();
                          _selectStartDate(context);
                        },
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "(Start Date Cannot Be Empty)";
                            }
                          },
                          enabled: false,
                          readOnly: true,
                          controller: startDateControler,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Select Start Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                              )),
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () {
                          _selectEndDate(context);
                        },
                        child: TextFormField(
                          validator: (value) {
                            if (startDateControler.text.isEmpty) {
                              return "(Please Select Start Date First)";
                            } else if (value!.isEmpty) {
                              return "(End Date Cannot Be Empty)";
                            }
                          },
                          enabled: false,
                          readOnly: true,
                          controller: endDateControler,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Select End Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          // });
        });
  }

  // updateTemplateWarningModal({
  //   required BuildContext context,
  // }) {
  //   return
  // }

  updatePmsInfoModal({
    required BuildContext context,
    required String projectId,
    required String towarId,
    // required Node addNode,
  }) {
    titleControler.text = projectPmsInfoResponse?[0].projectPmsName ?? '';

    _selectedStartDate = projectPmsInfoResponse?[0].projectPmsStartDate;
    startDateControler.text =
        DateFormat('dd/MM/yyyy').format(_selectedStartDate!);
    _selectedEndDate = projectPmsInfoResponse?[0].projectPmsEndDate;
    endDateControler.text = DateFormat('dd/MM/yyyy')
        .format(_selectedEndDate!); // titleControler.clear();
    //
    // startDateControler.clear();
    // endDateControler.clear();
    // _selectedStartDate = null;
    // _selectedEndDate = null;
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          // return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Set radius to zero
            ),
            titlePadding: const EdgeInsets.symmetric(vertical: 10),
            actionsPadding: const EdgeInsets.only(bottom: 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsAlignment: MainAxisAlignment.center,
            title: const Text(
              "UPDATE",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Text(
                    "CLOSE",
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
                onTap: () async {
                  if (!isLoadingAddPms && _formKey.currentState!.validate()) {
                    //   // setState(() {
                    //   isLoadingAddPms = true;
                    //   // });
                    Navigator.of(context).pop();
                    UpdateProjectPmsInfoResponse? res = await updatePmsDetails(
                      title: titleControler.text,
                      pmsStartDate: _selectedStartDate!,
                      pmsEndDate: _selectedEndDate!,
                      projectId: projectId,
                      towarId: towarId,
                      projectPmsId:
                          projectPmsInfoResponse?[0].mstProjectPmsId ?? '',
                    );

                    if (res?.errorCode == "0") {
                      pmsEndDateFromResponse = res?.pmsEndDate;
                      pmsStartDateFromResponse = res?.pmsStartDate;
                      projectPmsInfoResponse?[0].projectPmsStartDate =
                          res?.pmsStartDate;
                      projectPmsInfoResponse?[0].projectPmsEndDate =
                          res?.pmsEndDate;
                      projectPmsInfoResponse?[0].projectPmsName =
                          titleControler.text;

                      notifyListeners();
                    }
                    //     // setState(() {
                    //     isLoadingAddPms = false;
                    //     pmsEndDateFromResponse = res?.pmsEndDate;
                    //     pmsStartDateFromResponse = res?.pmsStartDate;
                    //     // treeController.roots
                    //     // Node tempNode = Node(
                    //     //     dict: res?.addedPmsList?[0],
                    //     //     id: (int.parse(
                    //     //         res?.addedPmsList?[0].mstPmsId ?? '')));
                    //     // Iterable<Node> etstttt = treeController.roots;
                    //     // etstttt.
                    //     // for (var element in filteredNodes) {
                    //     //   print(element.dict?.pmsCategoryName);
                    //     // }

                    //     res?.addedPmsList?[0].expand = true;
                    //     final child = Node(
                    //         id: int.parse(res?.addedPmsList?[0].mstPmsId ?? ''),
                    //         expandnode: false,
                    //         dict: res?.addedPmsList?[0]);
                    //     fetchExampleTree(
                    //         child..parent1 = root, res?.addedPmsList?[0].details);

                    //     root.children1.add(child);
                    //     treeController.roots = root.children;
                    //     treeController.childrenProvider =
                    //         (Node node) => node.children;
                    //     treeController.parentProvider =
                    //         (Node node) => node.parent;
                    //     intValue = root.children.length;
                    //     notifyListeners();
                    //     treeController.rebuild();
                    //     // });
                    //     // ignore: use_build_context_synchronously
                    //     Navigator.of(context).pop();
                    //   } else {
                    //     // setState(() {
                    //     isLoadingAddPms = false;
                    //     // });
                    //     // ignore: use_build_context_synchronously
                    //     Navigator.of(context).pop();
                    //   }
                  }
                },
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7)),
                  child: isLoadingAddPms
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        )
                      : const Text(
                          'UPDATE',
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
            content: SizedBox(
              width: 500,
              height: 244,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "(Title Cannot Be Empty)";
                          }
                        },
                        controller: titleControler,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 13.0),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          hintText: 'Please Enter Title',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 116, 116, 116),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'HelveticaNeue',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          // clearEndDate();
                          // _selectStartDate(context);
                          // _selectedEndDate = null;
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedStartDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: _selectedEndDate == null
                                ? DateTime(2101)
                                : _selectedEndDate!,
                          );
                          if (picked != null && picked != _selectedStartDate) {
                            _selectedStartDate = picked;
                            startDateControler.text = DateFormat('dd/MM/yyyy')
                                .format(_selectedStartDate!);
                          }
                        },
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "(Start Date Cannot Be Empty)";
                            }
                          },
                          enabled: false,
                          readOnly: true,
                          controller: startDateControler,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Select Start Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                              )),
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () async {
                          // _selectEndDate(context);

                          DateTime startDateCal() {
                            if (_selectedStartDate == null) {
                              return DateTime.now();
                            } else {
                              if (DateTime.now()
                                  .isBefore(_selectedStartDate!)) {
                                return _selectedStartDate!;
                              } else {
                                return DateTime.now();
                              }
                            }
                          }

                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDateCal(),
                            //  DateTime
                            //     .now(), //_selectedEndDate ?? DateTime.now(),
                            firstDate: _selectedStartDate == null
                                ? DateTime(2000)
                                : _selectedStartDate!,
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != _selectedEndDate) {
                            _selectedEndDate = picked;
                            endDateControler.text = DateFormat('dd/MM/yyyy')
                                .format(_selectedEndDate!);
                          }
                        },
                        child: TextFormField(
                          validator: (value) {
                            if (startDateControler.text.isEmpty) {
                              return "(Please Select Start Date First)";
                            } else if (value!.isEmpty) {
                              return "(End Date Cannot Be Empty)";
                            }
                          },
                          enabled: false,
                          readOnly: true,
                          controller: endDateControler,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(12.0),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Select End Date',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 116, 116, 116),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'HelveticaNeue',
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          // });
        });
  }
}

class DupliacateDataPms {
  String? mstPmsId;
  String? pmsCategoryName;
  String? parentIdFk;
  String? pmsOrderNo;
  String? pmsColorCode;
  DateTime? pmsStartDate;
  DateTime? pmsEndDate;
  DateTime? minDate;
  DateTime? maxDate;
  String? projectPmsIdFk;
  String? totalDays;
  String? totalDaysTemp; // for calculations only

  TextEditingController? textController1;
  String? pms_color_code;
  DateTime? parentStartDate;

  DupliacateDataPms({
    required this.mstPmsId,
    required this.pmsCategoryName,
    required this.parentIdFk,
    required this.pmsOrderNo,
    required this.pmsColorCode,
    required this.pmsStartDate,
    required this.pmsEndDate,
    required this.totalDays,
    this.textController1,
    required this.maxDate,
    required this.minDate,
    required this.projectPmsIdFk,
    required this.pms_color_code,
    required this.parentStartDate,
  }) {
    // ✅ COPY VALUE (not linked)
    totalDaysTemp = totalDays;
  }

  // factory DupliacateDataPms.fromJson(Map<String, dynamic> json) =>
  //     DupliacateDataPms(
  //       mstPmsId: json["mstPmsId"],
  //       pms_color_code: json["pms_color_code"],
  //       pmsCategoryName: json["pmsCategoryName"],
  //       parentIdFk: json["parentIdFk"],
  //       pmsOrderNo: json["pmsOrderNo"],
  //       pmsColorCode: json["pmsColorCode"],
  //       totalDays: json["totalDays"],
  //       textController1: TextEditingController(),
  //       pmsStartDate: json["pmsStartDate"] == '' || json["pmsStartDate"] == null
  //           ? DateTime(2000)
  //           : DateTime.parse(json["pmsStartDate"]),
  //       pmsEndDate: json["pmsEndDate"] == '' || json["pmsEndDate"] == null
  //           ? DateTime(2101)
  //           : DateTime.parse(json["pmsEndDate"]),
  //       maxDate: json["maxDate"] == ''
  //           ? DateTime(2000)
  //           : DateTime.parse(json["maxDate"]),
  //       minDate: json["minDate"] == ''
  //           ? DateTime(2101)
  //           : DateTime.parse(json["minDate"]),
  //       projectPmsIdFk: json["projectPmsIdFk"],
  //       // parentStartDate: json["parent_start_date"],
  //       parentStartDate:
  //           json["parentStartDate"] == "" || json["parentStartDate"] == null
  //               ? null
  //               : DateTime.parse(json["parentStartDate"]),
  //     );

  factory DupliacateDataPms.fromJson(Map<String, dynamic> json) {
    final data = DupliacateDataPms(
      mstPmsId: json["mstPmsId"],
      pms_color_code: json["pms_color_code"],
      pmsCategoryName: json["pmsCategoryName"],
      parentIdFk: json["parentIdFk"],
      pmsOrderNo: json["pmsOrderNo"],
      pmsColorCode: json["pmsColorCode"],
      totalDays: json["totalDays"],
      textController1: TextEditingController(),
      pmsStartDate: json["pmsStartDate"] == '' || json["pmsStartDate"] == null
          ? DateTime(2000)
          : DateTime.parse(json["pmsStartDate"]),
      pmsEndDate: json["pmsEndDate"] == '' || json["pmsEndDate"] == null
          ? DateTime(2101)
          : DateTime.parse(json["pmsEndDate"]),
      maxDate: json["maxDate"] == ''
          ? DateTime(2000)
          : DateTime.parse(json["maxDate"]),
      minDate: json["minDate"] == ''
          ? DateTime(2101)
          : DateTime.parse(json["minDate"]),
      projectPmsIdFk: json["projectPmsIdFk"],
      parentStartDate:
          json["parentStartDate"] == "" || json["parentStartDate"] == null
              ? null
              : DateTime.parse(json["parentStartDate"]),
    );

    // ✅ COPY AGAIN (safety for factory)
    data.totalDaysTemp = data.totalDays;

    return data;
  }

  Map<String, dynamic> toJson() {
    return {
      "pms_color_code": pms_color_code,
      'mstPmsId': mstPmsId,
      'pmsCategoryName': pmsCategoryName,
      'parentIdFk': parentIdFk,
      'pmsOrderNo': pmsOrderNo,
      'pmsColorCode': pmsColorCode,
      'pmsStartDate': pmsStartDate == null || pmsStartDate == DateTime(2000)
          ? ""
          : "${pmsStartDate!.year.toString().padLeft(4, '0')}-${pmsStartDate!.month.toString().padLeft(2, '0')}-${pmsStartDate!.day.toString().padLeft(2, '0')}",
      'pmsEndDate': pmsEndDate == null || pmsEndDate == DateTime(2101)
          ? ""
          : "${pmsEndDate!.year.toString().padLeft(4, '0')}-${pmsEndDate!.month.toString().padLeft(2, '0')}-${pmsEndDate!.day.toString().padLeft(2, '0')}",
      'maxDate': maxDate == null || maxDate == DateTime(2000)
          ? ""
          : "${maxDate!.year.toString().padLeft(4, '0')}-${maxDate!.month.toString().padLeft(2, '0')}-${maxDate!.day.toString().padLeft(2, '0')}",
      'minDate': minDate == null || minDate == DateTime(2101)
          ? ""
          : "${minDate!.year.toString().padLeft(4, '0')}-${minDate!.month.toString().padLeft(2, '0')}-${minDate!.day.toString().padLeft(2, '0')}",
      'projectPmsIdFk': projectPmsIdFk,
      // "parent_start_date": parentStartDate,
      'parentStartDate': parentStartDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(parentStartDate!),

      // "parentStartDate":
      //     "${parentStartDate?.year.toString().padLeft(4, '0')}-${parentStartDate?.month.toString().padLeft(2, '0')}-${parentStartDate?.day.toString().padLeft(2, '0')}",
    };
  }
}
