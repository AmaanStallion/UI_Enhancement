import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/add_pms_response.dart';
import 'package:stallion/models/projectPmsStructureMove.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/models/delete_pms_response.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/models/duplicatePmsResponse.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/models/updating_existing_drawer.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/provider/home_provider/fetch_api_provider.dart';
import '../../fancynode/pms_view/nodee.dart';
import '../../../../../utils/api_network_call.dart';
import '../../../../../utils/app_url.dart';
import '../../models/ws_get_pms_structure.dart';
import '../../provider/provider_registration.dart';
import '../src/folder_button.dart';
import '../src/tree_controller.dart';
import '../src/tree_indentation.dart';

// add these Intent classes near top-level in the file
class MoveUpIntent extends Intent {
  const MoveUpIntent();
}

class MoveDownIntent extends Intent {
  const MoveDownIntent();
}

class TreeTile extends ConsumerStatefulWidget {
  const TreeTile(
      {super.key,
      required this.entry,
      this.onFolderPressed,
      this.scroll,
      this.decoration,
      this.showIndentation = true,
      this.controller,
      // required this.fetchRecords,
      this.flag,
      required this.projectId,
      required this.towarId});
  final ScrollController? controller;
  final ScrollPhysics? scroll;
  final TreeEntry<Node> entry;
  final VoidCallback? onFolderPressed;
  final Decoration? decoration;
  final bool showIndentation;
  final bool? flag;
  final String projectId;
  final String towarId;

  @override
  ConsumerState<TreeTile> createState() => _TreeTileState();
}

NetworkHandler apiNetworkHandler = NetworkHandler();

class _TreeTileState extends ConsumerState<TreeTile> {
  FocusNode _focusNode = FocusNode(); // for keyboard handling

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoadUpdate = false;
  bool isDragOver = false; // Add this for drag over state
  bool isDragging = false; // track active drag for this tile

  String pmsRccMasnoryType =
      '0'; // '0' for rcc and '1' for masnory $ '2 for both
  // bool isDragOver = false; // Add this for drag over state

  bool isRccSelected = false;
  bool isMasonrySelected = false;

  Future<ResponseAddPmsResponse?> addNewPms({
    required String parentId,
    required String title,
    required DateTime? startDate,
    required DateTime? endtDate,
    required String remark,
  }) async {
    String formatDate(DateTime dateTime) {
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    }

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId,
      "towar_id": widget.towarId,
      "parent_id": parentId,
      "start_date": startDate == null ? '' : formatDate(startDate),
      "end_date": endtDate == null ? '' : formatDate(endtDate),
      "pms_name": title,
      "remark": remark,
      "pms_child_update": "[]",
      "updatedPmsListTemp": '[]',
    };

    var response = await apiNetworkHandler.post(AppUrl.wssetpmsstructure, data);
    print('ws-set-pms-structure ---- ${data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = addPmsResponseFromJson(response.body);
      ref.read(fetchApiProvider).pmsStartDateFromResponse =
          dataModel.response?.pmsStartDate;
      ref.read(fetchApiProvider).pmsEndDateFromResponse =
          dataModel.response?.pmsEndDate;

      Node? tempNode;
      for (var element in ref.read(fetchApiProvider).treeController.roots) {
        if (element.dict?.mstPmsId ==
            dataModel.response?.changeData?[0].mstPmsId) {
          tempNode = element;
          break;
        }
      }
      updatingdataFromRes(Iterable<Node> dataa) {
        for (var element1 in dataa) {
          for (int i = 0; i < dataModel.response!.changeData!.length; i++) {
            if (dataModel.response!.changeData?[i].mstPmsId ==
                element1.dict?.mstPmsId) {
              // print(
              //     '${element1.dict?.pmsCategoryName} --------------- updated from res');
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
              element1.dict?.checkStatus =
                  dataModel.response!.changeData?[i].checkStatus;
              // notifyListeners();
              setState(() {
                isLoadUpdate = true;
              });
            }
          }

          if (element1.children.length != 0) {
            updatingdataFromRes(element1.children1);
          }
        }
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
          tempNode.dict?.maxDate = dataModel.response!.changeData?[0].maxDate;
          tempNode.dict?.minDate = dataModel.response!.changeData?[0].minDate;
          tempNode.dict?.checkStatus =
              dataModel.response!.changeData?[0].checkStatus;
        }
      }
      // if (dataModel.response?.errorCode == "0") {
      // fetchRecords();
      // widget.fetchRecords();
      // ref.read(fetchApiProvider).fetchRecords(
      //       projectId: widget.projectId,
      //       towarId: widget.towarId,
      //     );
      return dataModel.response;
      // }
    } else {
      return null;
    }
  }

  // Add these methods to _TreeTileState class

  Future<ProjectPmsStructureMoveResponse?> projectPmsStructureMove({
    required String mstPmsId,
    required String pmsPosition,
    required String pmsParentId,
  }) async {
    //final SharedPreferences prefs = await _prefs;
    //String? userId = prefs.getString('mobileNo');

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '',
      // "project_id": widget.projectId,
      // "towar_id": widget.towarId,
      "mst_pms_id": mstPmsId,
      "pms_position": pmsPosition,
      "pms_parent_id": pmsParentId
    };

    var response =
        await apiNetworkHandler.post(AppUrl.projectPmsStructureMove, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectPmsStructureMoveFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      // log("Move Successful");
      return dataModel.response;
      // }

      //   return dataModel.response;
      //   // }
      // } else {
      //   return null;
    } else {
      return null;
    }
  }

  // void moveNodeUp() {
  //   final parent = widget.entry.node.parent1;
  //   inspect('parent print ${(parent?.id)}');
  //   if (parent != null) {
  //     final index = parent.children1.indexOf(widget.entry.node);
  //     print(
  //         'index print ${index - 1} ${parent.children1[index].dict?.mstPmsId}'); //widget.entry.node.dict!.pmsCategoryName
  //     projectPmsStructureMove(
  //         mstPmsId: parent.children1[index].dict?.mstPmsId ?? '',
  //         pmsPosition: (index - 1).toString(),
  //         pmsParentId: parent?.id.toString() ?? '');
  //     if (index > 0) {
  //       setState(() {
  //         final temp = parent.children1[index];
  //         parent.children1[index] = parent.children1[index - 1];
  //         parent.children1[index - 1] = temp;
  //       });
  //       ref.read(fetchApiProvider).treeController.rebuild();
  //       // Force right-side UI to refresh
  //       ref.read(fetchApiProvider).notifyListeners();
  //       // Additional rebuild to ensure UI catches up
  //       Future.delayed(const Duration(milliseconds: 10), () {
  //         if (mounted) {
  //           setState(() {});
  //         }
  //       });
  //     }
  //   }
  // }

  // void moveNodeDown() {
  //   final parent = widget.entry.node.parent1;
  //   if (parent != null) {
  //     final index = parent.children1.indexOf(widget.entry.node);
  //     projectPmsStructureMove(
  //         mstPmsId: parent.children1[index].dict?.mstPmsId ?? '',
  //         pmsPosition: (index + 1).toString(),
  //         pmsParentId: parent?.id.toString() ?? '');
  //     if (index < parent.children1.length - 1) {
  //       setState(() {
  //         final temp = parent.children1[index];
  //         parent.children1[index] = parent.children1[index + 1];
  //         parent.children1[index + 1] = temp;
  //       });
  //       ref.read(fetchApiProvider).treeController.rebuild();
  //       // Force right-side UI to refresh
  //       ref.read(fetchApiProvider).notifyListeners();
  //       // Additional rebuild to ensure UI catches up
  //       Future.delayed(const Duration(milliseconds: 10), () {
  //         if (mounted) {
  //           setState(() {});
  //         }
  //       });
  //     }
  //   }
  // }

  // void moveNodeUp() {
  //   final parent = widget.entry.node.parent1;
  //   inspect('parent print ${(parent?.id)}');
  //   if (parent != null) {
  //     final index = parent.children1.indexOf(widget.entry.node);
  //     print(
  //         'index print ${index - 1} ${parent.children1[index].dict?.mstPmsId}');

  //     // Store original positions for undo
  //     final originalNode = parent.children1[index];
  //     final swapNode = parent.children1[index - 1];

  //     if (index > 0) {
  //       // Optimistically update UI first
  //       setState(() {
  //         final temp = parent.children1[index];
  //         parent.children1[index] = parent.children1[index - 1];
  //         parent.children1[index - 1] = temp;
  //       });
  //       ref.read(fetchApiProvider).treeController.rebuild();
  //       ref.read(fetchApiProvider).notifyListeners();

  //       // Call API and handle response
  //       projectPmsStructureMove(
  //         mstPmsId: 'originalNode.dict?.mstPmsId' ?? '',
  //         pmsPosition: (index - 1).toString(),
  //         pmsParentId: parent?.id.toString() ?? '',
  //       ).then((response) {
  //         if (response?.errorCode != "0") {
  //           // API failed - undo the move
  //           setState(() {
  //             parent.children1[index - 1] = originalNode;
  //             parent.children1[index] = swapNode;
  //           });
  //           ref.read(fetchApiProvider).treeController.rebuild();
  //           ref.read(fetchApiProvider).notifyListeners();

  //           // Show error toast
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: const Text('Failed to move item. Please try again.'),
  //               backgroundColor: Colors.red,
  //               duration: const Duration(seconds: 3),
  //             ),
  //           );
  //         } else {
  //           // Success - update UI
  //           Future.delayed(const Duration(milliseconds: 10), () {
  //             if (mounted) {
  //               setState(() {});
  //             }
  //           });
  //         }
  //       }).catchError((error) {
  //         // Exception occurred - undo the move
  //         setState(() {
  //           parent.children1[index - 1] = originalNode;
  //           parent.children1[index] = swapNode;
  //         });
  //         ref.read(fetchApiProvider).treeController.rebuild();
  //         ref.read(fetchApiProvider).notifyListeners();

  //         // Show error toast
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Error: ${error.toString()}'),
  //             backgroundColor: Colors.red,
  //             duration: const Duration(seconds: 3),
  //           ),
  //         );
  //       });
  //     }
  //   }
  // }

// ...existing code...
  void moveNodeUp() {
    final parent = widget.entry.node.parent1;
    if (parent != null) {
      final index = parent.children1.indexOf(widget.entry.node);
      print('parent print ${(parent?.id)} index ${index}');

      // Store original positions for undo
      final originalNode = parent.children1[index];
      final swapNode = parent.children1[index - 1];

      if (index > 0) {
        // Optimistically update UI first (swap)
        setState(() {
          final temp = parent.children1[index];
          parent.children1[index] = parent.children1[index - 1];
          parent.children1[index - 1] = temp;
        });
        ref.read(fetchApiProvider).treeController.rebuild();
        ref.read(fetchApiProvider).notifyListeners();

        // Call API and handle response
        projectPmsStructureMove(
          mstPmsId: originalNode.dict?.mstPmsId ?? '',
          pmsPosition: (index - 1).toString(),
          pmsParentId:
              parent.id.toString() == '-1' ? '0' : parent.id.toString(),
        ).then((response) {
          // If API failed or returned non-zero error, undo the optimistic swap
          if (response == null || response.errorCode != "0") {
            print("undoing move due to API failure");
            setState(() {
              // correct undo: put swapNode back at index-1 and originalNode back at index
              parent.children1[index - 1] = swapNode;
              parent.children1[index] = originalNode;
            });
            ref.read(fetchApiProvider).treeController.rebuild();
            ref.read(fetchApiProvider).notifyListeners();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to move item. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            // Success - ensure UI final state
            Future.delayed(const Duration(milliseconds: 10), () {
              if (mounted) setState(() {});
            });
          }
        }).catchError((error) {
          // Exception occurred - undo the move
          setState(() {
            parent.children1[index - 1] = swapNode;
            parent.children1[index] = originalNode;
          });
          ref.read(fetchApiProvider).treeController.rebuild();
          ref.read(fetchApiProvider).notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        });
      }
    }
  }

  void moveNodeDown() {
    final parent = widget.entry.node.parent1;
    if (parent != null) {
      final index = parent.children1.indexOf(widget.entry.node);

      // Store original positions for undo
      final originalNode = parent.children1[index];
      final swapNode = parent.children1[index + 1];

      if (index < parent.children1.length - 1) {
        // Optimistically update UI first (swap)
        setState(() {
          final temp = parent.children1[index];
          parent.children1[index] = parent.children1[index + 1];
          parent.children1[index + 1] = temp;
        });
        ref.read(fetchApiProvider).treeController.rebuild();
        ref.read(fetchApiProvider).notifyListeners();

        // Call API and handle response
        projectPmsStructureMove(
          mstPmsId: originalNode.dict?.mstPmsId ?? '',
          pmsPosition: (index + 1).toString(),
          // pmsParentId: parent?.id.toString() ?? '',
          pmsParentId:
              parent.id.toString() == '-1' ? '0' : parent.id.toString(),
        ).then((response) {
          if (response == null || response.errorCode != "0") {
            // API failed - undo the move (restore original order)
            setState(() {
              // correct undo: put originalNode back at index and swapNode back at index+1
              parent.children1[index] = originalNode;
              parent.children1[index + 1] = swapNode;
            });
            ref.read(fetchApiProvider).treeController.rebuild();
            ref.read(fetchApiProvider).notifyListeners();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to move item. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            // Success - ensure UI final state
            Future.delayed(const Duration(milliseconds: 10), () {
              if (mounted) setState(() {});
            });
          }
        }).catchError((error) {
          // Exception occurred - undo the move
          setState(() {
            parent.children1[index] = originalNode;
            parent.children1[index + 1] = swapNode;
          });
          ref.read(fetchApiProvider).treeController.rebuild();
          ref.read(fetchApiProvider).notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        });
      }
    }
  }

// ...existing code...  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<ResponseAddPmsResponse?> syncPms({
    required String parentId,
    // required String title,
    // required DateTime startDate,
    // required DateTime endtDate,
    required String projectPmsId,
  }) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId,
      "towar_id": widget.towarId,
      "parent_id": parentId,
      // "pms_name": title,
      "project_pms_id": projectPmsId,
      "pms_rcc_masnory_type":
          pmsRccMasnoryType, //pms_rcc_masnory_type:'0' for rcc and '1' for masnory
    };
    print(data);

    var response = await apiNetworkHandler.post(AppUrl.cmsRccSync, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pop();
      ref.read(fetchApiProvider).fetchRecords(
            projectId: widget.projectId,
            towarId: widget.towarId,
          );
      // final dataModel = addPmsResponseFromJson(response.body);

      // return dataModel.response;
    } else {
      return null;
    }
  }

  Future<ResponseDeletePmsResponse?> deleteExistingPms({
    required String mstPmsId,
  }) async {
    //final SharedPreferences prefs = await _prefs;
    //String? userId = prefs.getString('mobileNo');

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId,
      "towar_id": widget.towarId,
      "mst_pms_id": mstPmsId
    };

    var response =
        await apiNetworkHandler.post(AppUrl.wsdeletepmsstructure, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = deletePmsResponseFromJson(response.body);
      // if (dataModel.response?.errorCode == "0") {
      // fetchRecords();
      // widget.fetchRecords();
      // ref.read(fetchApiProvider).fetchRecords(
      //       projectId: widget.projectId,
      //       towarId: widget.towarId,
      //     );
      ref.read(fetchApiProvider).deleteNode(mstPmsId);

      Node? tempNode;
      if (dataModel.response?.changeData?.length != 0) {
        for (var element in ref.read(fetchApiProvider).treeController.roots) {
          if (element.dict?.mstPmsId ==
              dataModel.response?.changeData?[0].mstPmsId) {
            tempNode = element;
            // print("-------breaking---------------");
            break;
          }
        }
      }
      updatingdataFromRes(Iterable<Node> dataa) {
        for (var element1 in dataa) {
          for (int i = 0; i < dataModel.response!.changeData!.length; i++) {
            if (dataModel.response!.changeData?[i].mstPmsId ==
                element1.dict?.mstPmsId) {
              // print(
              //     '${element1.dict?.pmsCategoryName} --------------- updated from res');
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
              // notifyListeners();
              setState(() {
                isLoadUpdate = true;
              });
            }
          }

          if (element1.children.length != 0) {
            updatingdataFromRes(element1.children1);
          }
        }
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
          tempNode.dict?.maxDate = dataModel.response!.changeData?[0].maxDate;
          tempNode.dict?.minDate = dataModel.response!.changeData?[0].minDate;
        }
      }

      return dataModel.response;
      // }
    } else {
      return null;
    }
  }

  // Future<CreateNewPmsResponse?> updateExistingPmsApi({
  //   required String parentId,
  //   required String title,
  //   required DateTime startDate,
  //   required DateTime endtDate,
  //   required String mstpmsid,
  // }) async {
  //   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  //   final SharedPreferences prefs = await _prefs;
  //   String? userId = prefs.getString('mobileNo');
  //   String formatDate(DateTime dateTime) {
  //     // Format the DateTime as "yyyy-MM-dd" (e.g., "2023-09-01")
  //     return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  //   }

  //   Map<String, String> data = {
  //     "user_id": userId ?? '',
  //     "mst_pms_id": mstpmsid,
  //     "project_id": widget.projectId,
  //     "towar_id": widget.towarId,
  //     "parent_id": parentId,
  //     "start_date": formatDate(startDate),
  //     "end_date": formatDate(endtDate),
  //     "pms_name": title,
  //   };

  //   var response = await apiNetworkHandler.post(AppUrl.wssetpmsstructure, data);

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final dataModel = createNewPmsFromJson(response.body);
  //     // if (dataModel.response?.errorCode == "0") {
  //     // widget.fetchRecords();
  //     return dataModel.response;
  //     // }
  //   } else {
  //     return null;
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TextEditingController titleControler = TextEditingController();
  TextEditingController remarkControler = TextEditingController();

  TextEditingController startDateControler = TextEditingController();
  TextEditingController endDateControler = TextEditingController();

  clearEndDate() {
    setState(() {
      _selectedEndDate = null;
      endDateControler.clear();
    });
  }

  clearAllDates() {
    setState(() {
      _selectedEndDate = null;
      endDateControler.clear();
      _selectedStartDate = null;
      startDateControler.clear();
    });
  }

  Future<void> _selectStartDate({
    required BuildContext context,
    required DateTime startDateRes,
    required DateTime endDateRes,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: startDateRes, // DateTime(2000),
      lastDate: endDateRes, //DateTime(2101),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        startDateControler.text =
            DateFormat('dd/MM/yyyy').format(_selectedStartDate!);
      });
    }
  }

  Future<void> _selectEndDate({
    required BuildContext context,
    required DateTime startDateRes,
    required DateTime endDateRes,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ??
          _selectedStartDate ??
          DateTime.now(), //DateTime.now(),
      firstDate: _selectedStartDate ?? startDateRes, // DateTime(2000),
      lastDate: endDateRes, //DateTime(2101),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        endDateControler.text =
            DateFormat('dd/MM/yyyy').format(_selectedEndDate!);
      });
    }
  }

  addNewPmsModal() {
    // setState(() {
    //   if (widget.entry.node.dict!.pmsStartDate == DateTime(2000)) {
    //     _selectedStartDate = DateTime.now();
    //     // startDateControler.text =
    //     //     DateFormat('dd/MM/yyyy').format(DateTime.now());
    //   } else {
    //     _selectedStartDate = widget.entry.node.dict!.pmsStartDate;
    //     // startDateControler.text =
    //     //     DateFormat('dd/MM/yyyy').format(currentPmsStructure.pmsStartDate!);
    //   }

    //   if (widget.entry.node.dict!.pmsEndDate == DateTime(2101)) {
    //     // endDateControler.text = DateFormat('dd/MM/yyyy')
    //     //     .format(DateTime.now().add(Duration(days: 1)));
    //     _selectedEndDate = DateTime.now().add(Duration(days: 1));
    //   } else {
    //     // endDateControler.text =
    //     //     DateFormat('dd/MM/yyyy').format(currentPmsStructure.pmsEndDate!);
    //     // _selectedEndDate = widget.entry.node.dict!.pmsEndDate;
    //   }
    // });
    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                'ADD TO ${widget.entry.node.dict?.pmsCategoryName?.toUpperCase()}',
                style: const TextStyle(
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
                    child: const Center(
                      child: Text(
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
                ),
                InkWell(
                  onTap: () async {
                    if (!isLoadingAddPms
                        // && _formKey.currentState!.validate()
                        // (titleControler.text.isNotEmpty &&
                        //     startDateControler.text.isNotEmpty &&
                        //     endDateControler.text.isNotEmpty)
                        ) {
                      // print(titleControler.text.isEmpty);
                      setState(() {
                        isLoadingAddPms = true;
                      });
                      ResponseAddPmsResponse? res = await addNewPms(
                        parentId: widget.entry.node.dict?.mstPmsId ?? '',
                        title: titleControler.text,
                        startDate: _selectedStartDate,
                        endtDate: _selectedEndDate,
                        remark: remarkControler.text,
                      );

                      if (res?.errorCode == "0") {
                        // ref
                        //     .read(fetchApiProvider)
                        //     .setOpenDropDown(widget.entry.node);

                        ref.read(fetchApiProvider).findRecAndAdd(
                              currNode: widget.entry.node,
                              list11: ref
                                  .read(fetchApiProvider)
                                  .treeController
                                  .roots,
                              addedPmsList: res?.addedPmsList,
                              onSelectedPmsid:
                                  widget.entry.node.dict?.mstPmsId ?? '',
                              changeData: res?.changeData,
                            );
                        ref
                            .read(fetchApiProvider)
                            .treeController
                            .expand(widget.entry.node);
                        // final child = Node(
                        //     id: int.parse(res?.addedPmsList?[0].mstPmsId ?? ''),
                        //     expandnode: false,
                        //     dict: res?.addedPmsList?[0]);

                        // widget.entry.node.children1.add(child);
                        // // ref
                        // //     .read(fetchApiProvider)
                        // //     .treeController
                        // //     .expand(widget.entry.node);
                        // ref.read(fetchApiProvider).treeController.rebuild();
                        // res?.addedPmsList?[0].expand = true;
                        // final child = Node(
                        //     id: int.parse(res?.addedPmsList?[0].mstPmsId ?? ''),
                        //     expandnode: false,
                        //     dict: res?.addedPmsList?[0]);
                        // ref.read(fetchApiProvider).fetchExampleTree(
                        //     child..parent1 = ref.read(fetchApiProvider).root,
                        //     res?.addedPmsList?[0].details);

                        // ref.read(fetchApiProvider).root.children1.add(child);
                        // ref.read(fetchApiProvider).treeController.roots =
                        //     ref.read(fetchApiProvider).root.children;
                        // ref
                        //     .read(fetchApiProvider)
                        //     .treeController
                        //     .childrenProvider = (Node node) => node.children;
                        // ref
                        //     .read(fetchApiProvider)
                        //     .treeController
                        //     .parentProvider = (Node node) => node.parent;
                        // ref.read(fetchApiProvider).intValue =
                        //     ref.read(fetchApiProvider).root.children.length;
                        // // notifyListeners();
                        // ref.read(fetchApiProvider).treeController.rebuild();

                        setState(() {
                          isLoadingAddPms = false;
                        });
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          isLoadingAddPms = false;
                        });
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
                        : const Center(
                            child: Text(
                              "ADD",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),
              ],
              content: SizedBox(
                width: 500,
                height: 264,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.entry.node.dict?.pmsStartDate !=
                                DateTime(2000) &&
                            widget.entry.node.dict?.pmsEndDate !=
                                DateTime(2101))
                          Text(
                            '*${widget.entry.node.dict?.pmsCategoryName} - ${DateFormat('dd/MM/yyyy').format(widget.entry.node.dict?.pmsStartDate ?? DateTime.now())} to ${DateFormat('dd/MM/yyyy').format(widget.entry.node.dict?.pmsEndDate ?? DateTime.now())}*',
                            style: const TextStyle(
                              fontSize: 14,
                              // fontWeight: FontWeight.w600,
                              // color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 8),
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
                            // suffixIcon: Icon(
                            //   Icons.calendar_month_outlined,
                            // ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () {
                            clearEndDate();
                            _selectStartDate(
                              startDateRes: DateTime(2000),
                              context: context,
                              endDateRes: DateTime(2101),
                            );
                          },
                          child: TextFormField(
                            // validator: (value) {
                            //   if (value!.isEmpty) {
                            //     return "(Start Date Cannot Be Empty)";
                            //   }
                            // },
                            enabled: false,
                            readOnly: true,
                            controller: startDateControler,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
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
                            _selectEndDate(
                              startDateRes: DateTime(2000),
                              context: context,
                              endDateRes: DateTime(2101),
                            );
                          },
                          child: TextFormField(
                            // validator: (value) {
                            //   if (value!.isEmpty) {
                            //     return "(End Date Cannot Be Empty)";
                            //   }
                            // },
                            enabled: false,
                            readOnly: true,
                            controller: endDateControler,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 13.0),
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
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
                        const SizedBox(
                          height: 14,
                        ),
                        TextFormField(
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "(Remark Cannot Be Empty)";
                          //   }
                          // },
                          controller: remarkControler,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: 'Please Enter Remark',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                            // suffixIcon: Icon(
                            //   Icons.calendar_month_outlined,
                            // ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  editExistingPmsModal({required PmsStructure currentPmsStructure}) {
    setState(() {
      // inspect(currentPmsStructure
      //     .remarkList?[currentPmsStructure.remarkList!.length - 1]);
      if (currentPmsStructure.remarkList?.length != 0) {
        remarkControler.text = currentPmsStructure
                .remarkList?[currentPmsStructure.remarkList!.length - 1]
                .transPmsRemark ??
            '';
      }

      titleControler.text = currentPmsStructure.pmsCategoryName ?? '';

      if (currentPmsStructure.pmsStartDate == DateTime(2000)) {
        _selectedStartDate = DateTime.now();
        startDateControler.text =
            DateFormat('dd/MM/yyyy').format(DateTime.now());
      } else {
        _selectedStartDate = currentPmsStructure.pmsStartDate;
        startDateControler.text =
            DateFormat('dd/MM/yyyy').format(currentPmsStructure.pmsStartDate!);
      }

      if (currentPmsStructure.pmsEndDate == DateTime(2101)) {
        endDateControler.text = DateFormat('dd/MM/yyyy')
            .format(DateTime.now().add(const Duration(days: 1)));
        _selectedEndDate = DateTime.now().add(const Duration(days: 1));
      } else {
        endDateControler.text =
            DateFormat('dd/MM/yyyy').format(currentPmsStructure.pmsEndDate!);
        _selectedEndDate = currentPmsStructure.pmsEndDate;
      }
    });

    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                'EDITING ${widget.entry.node.dict?.pmsCategoryName?.toUpperCase()}',
                style: const TextStyle(
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
                    child: const Center(
                      child: Text(
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
                ),
                InkWell(
                  onTap: () async {
                    if (!isLoadingAddPms && _formKey.currentState!.validate()
                        // (titleControler.text.isNotEmpty &&
                        //     startDateControler.text.isNotEmpty &&
                        //     endDateControler.text.isNotEmpty)
                        ) {
                      setState(() {
                        isLoadingAddPms = true;
                      });
                      UpdateExistingDrawerResponse? res = await ref
                          .read(fetchApiProvider)
                          .updateExistingPmsApi(
                            // parentId: widget.entry.node.dict?.mstPmsId ?? '',
                            mstpmsid: widget.entry.node.dict?.mstPmsId ?? '',
                            parentId: widget.entry.node.dict?.parentIdFk ?? '',
                            title: titleControler.text,
                            remark: remarkControler.text,
                            startDate: _selectedStartDate!,
                            endtDate: _selectedEndDate!,
                            projectId: widget.projectId,
                            towarId: widget.towarId,
                            currNode: widget.entry.node,
                          );

                      if (res?.errorCode == "0") {
                        setState(() {
                          isLoadingAddPms = false;
                        });
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          isLoadingAddPms = false;
                        });
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
                        : const Center(
                            child: Text(
                              "UPDATE",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),
              ],
              content: SizedBox(
                width: 500,
                height: 280,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (widget.entry.node.dict?.parent_start_date != null)
                        //   Text(
                        //     '*Date cannot exceed more than ${DateFormat('dd/MM/yyyy').format(widget.entry.node.dict?.parent_end_date ?? DateTime.now())} for ${widget.entry.node.dict?.pmsCategoryName}*',
                        //     style: const TextStyle(
                        //       fontSize: 14,
                        //       color: Colors.red,
                        //     ),
                        //     textAlign: TextAlign.start,
                        //   ),
                        // SizedBox(height: 8),
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
                            // suffixIcon: Icon(
                            //   Icons.calendar_month_outlined,
                            // ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () {
                            _selectStartDate(
                              startDateRes: DateTime(2000),
                              context: context,
                              endDateRes: DateTime(2101),
                            );
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
                                    borderSide:
                                        BorderSide(color: Colors.black)),
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
                            // print('EndDate');
                            _selectEndDate(
                              startDateRes: widget
                                          .entry.node.dict?.parentStartDate ==
                                      null
                                  ? DateTime(2000)
                                  : widget.entry.node.dict!.parentStartDate!,
                              context: context,
                              endDateRes: widget
                                          .entry.node.dict?.parent_end_date ==
                                      null
                                  ? DateTime(2101)
                                  : widget.entry.node.dict!.parent_end_date!,
                            );
                          },
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
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
                                    borderSide:
                                        BorderSide(color: Colors.black)),
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
                        const SizedBox(
                          height: 14,
                        ),
                        TextFormField(
                          // validator: (value) {
                          //   if (value!.isEmpty) {
                          //     return "(Remark Cannot Be Empty)";
                          //   }
                          // },
                          controller: remarkControler,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13.0),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: 'Please Enter Remark',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 116, 116, 116),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'HelveticaNeue',
                            ),
                            // suffixIcon: Icon(
                            //   Icons.calendar_month_outlined,
                            // ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  deleteExistingPmsModal({required PmsStructure currentPmsStructure}) {
    // setState(() {
    //   titleControler.text = currentPmsStructure.pmsCategoryName ?? '';
    //   startDateControler.text =
    //       DateFormat('yyyy/M/d').format(currentPmsStructure.pmsStartDate!);
    //   _selectedStartDate = currentPmsStructure.pmsStartDate;
    //   endDateControler.text =
    //       DateFormat('yyyy/M/d').format(currentPmsStructure.pmsEndDate!);
    //   _selectedEndDate = currentPmsStructure.pmsEndDate;
    // });

    return showDialog<void>(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          String deleteChildName() {
            if (ref
                    .watch(fetchApiProvider)
                    .pmsStructureForDuplicating
                    ?.length ==
                1) {
              return "";
            } else {
              String temp = ', As it will Affect all your Sub-Categories, "';
              for (int i = 1;
                  i <
                      ref
                          .watch(fetchApiProvider)
                          .pmsStructureForDuplicating!
                          .length;
                  i++) {
                temp =
                    '$temp${i == 1 ? "" : ", "}${ref.watch(fetchApiProvider).pmsStructureForDuplicating?[i].pmsCategoryName ?? ''}';
              }
              return temp;
            }
          }

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 10),
              actionsPadding: const EdgeInsets.only(bottom: 10),
              contentPadding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                "DELETE",
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
                  onTap: () {
                    setState(() {
                      isLoadingAddPms = true;
                    });
                    // print(currentPmsStructure.mstPmsId);
                    deleteExistingPms(
                            mstPmsId: currentPmsStructure.mstPmsId ?? '')
                        .then((value) {
                      setState(() {
                        widget.entry.parent?.node.children1
                            .remove(widget.entry.node);
                        Iterable<Node> filteredNodes = ref
                            .read(fetchApiProvider)
                            .treeController
                            .roots
                            .where((Node node) =>
                                node.dict?.mstPmsId !=
                                currentPmsStructure.mstPmsId);
                        ref.read(fetchApiProvider).treeController.roots =
                            filteredNodes;
                        ref.read(fetchApiProvider).treeController.rebuild();
                        isLoadingAddPms = false;

                        for (var element in ref
                            .read(fetchApiProvider)
                            .treeController
                            .roots) {
                          if (currentPmsStructure.mstPmsId ==
                              element.dict?.parentIdFk) {}
                        }
                      });
                      Navigator.of(context).pop();
                    });
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
                            "DELETE",
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
                // height: 150,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // 'Are you Sure you Want to Delete "${ref.watch(fetchApiProvider).pmsStructureForDuplicating?[0].pmsCategoryName}"${deleteChildName()}',
                        'Are you Sure, You Want to Delete "${ref.watch(fetchApiProvider).pmsStructureForDuplicating?[0].pmsCategoryName}" as It Will Affect All your Sub-Categories.',

                        // 'Are you sure you want to delete ',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18),
                        // children: <TextSpan>[
                        //   TextSpan(
                        //     text: currentPmsStructure.pmsCategoryName,
                        //     style: const TextStyle(
                        //         color: Colors.blueAccent, fontSize: 18),
                        //   )
                        // ]
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  bool isLoadingAddPms = false;

  bool isHover = false;
  bool isLoad = true;

  Future<ResponseDuplicatePmsResponse?> duplicateCurrentPms({
    // required String parentId,
    // required String title,
    // required DateTime startDate,
    // required DateTime endtDate,
    required String pmsStructure,
  }) async {
    // String formatDate(DateTime dateTime) {
    //   return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    // }

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    Map<String, String> data = {
      "user_id": userId ?? '',
      "project_id": widget.projectId,
      "towar_id": widget.towarId,
      // "parent_id": parentId,
      // "start_date": formatDate(startDate),
      // "end_date": formatDate(endtDate),
      "pms_structure": pmsStructure,
      // "remark": remark,
    };

    var response =
        await apiNetworkHandler.post(AppUrl.wssetduplicateStructure, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = duplicatePmsResponseFromJson(response.body);

      Node? root = Node(id: -1);
      if (dataModel.response?.errorCode == "0") {
        for (int i = 0; i < dataModel.response!.finalData!.length; i++) {
          // setState(() {
          dataModel.response!.finalData![i].expand = true;
          final child = Node(
              id: int.parse(dataModel.response!.finalData![i].mstPmsId!),
              expandnode: false,
              dict: dataModel.response!.finalData![i]);
          ref.read(fetchApiProvider).fetchExampleTree(
              child..parent1 = root, dataModel.response!.finalData![i].details);

          child.parent?.children1 = widget.entry.node.parent!.children1;

          widget.entry.node.parent?.children1.add(child);

          // ref.read(fetchApiProvider).treeController.childrenProvider =
          //     (Node node) => node.children;
          // ref.read(fetchApiProvider).treeController.parentProvider =
          //     (Node node) => node.parent;

          ref.read(fetchApiProvider).notifyListeners();
          // });
        }
        ref.read(fetchApiProvider).treeController.rebuild();
      }
      setState(() {
        isLoad = false;
      });
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final IndentGuide indentGuide = DefaultIndentGuide.of(context);
    // String hexColor = widget.entry.node.dict!.pms_color_code!;
    Color color = Color(int.parse(
            '0xFF${(widget.entry.node.dict!.pms_color_code)?.replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
        .withOpacity(0.8);
    // darken(
    //     Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000));

    // Widget content = widget.entry.node.dict!.mstPmsId != "0"
    //     ?

    // Wrap the main content with Draggable and DragTarget
    // add helper for lightweight feedback
    Widget _dragFeedback() {
      return Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Color(int.parse(
                      '0xFF${(widget.entry.node.dict!.pms_color_code!).replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                  .withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(blurRadius: 4, color: Colors.black26)
              ],
            ),
            child: Text(
              widget.entry.node.dict?.pmsCategoryName ?? 'Item',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }

    Widget content = DragTarget<Node>(
      // onWillAccept: (data) {
      //   setState(() {
      //     isDragOver = true;
      //   });
      //   return data != null &&
      //       data.dict?.mstPmsId != widget.entry.node.dict?.mstPmsId;
      // },
      // onLeave: (_) {
      //   setState(() {
      //     isDragOver = false;
      //   });
      // },

      // onWillAccept: (data) {
      //   setState(() {
      //     isDragOver = true;
      //   });
      //   return data != null &&
      //       data.dict?.mstPmsId != widget.entry.node.dict?.mstPmsId;
      // },
      // onLeave: (_) {
      //   setState(() {
      //     isDragOver = false;
      //   });
      // },
      // onAccept: (Node data) {
      //   if (data != widget.entry.node) {
      //     final parent = widget.entry.node.parent1;
      //     if (parent != null) {
      //       setState(() {
      //         parent.children1.remove(data);
      //         int newIndex = parent.children1.indexOf(widget.entry.node);
      //         parent.children1.insert(newIndex, data);
      //       });
      //       ref.read(fetchApiProvider).treeController.rebuild();
      //     }
      //   }
      // },
      onWillAccept: (data) {
        // highlight target while dragging
        setState(() => isDragOver = true);

        if (data == null) return false;

        // only accept if dragged node and target node share the same parent
        // and it's not the same node (prevents self-drop)
        final bool sameParent = data.parent1 == widget.entry.node.parent1;
        final bool notSameNode =
            data.dict?.mstPmsId != widget.entry.node.dict?.mstPmsId;

        return sameParent && notSameNode;
      },
      onLeave: (_) => setState(() => isDragOver = false),
      onAccept: (Node data) {
        // clear highlight FIRST
        setState(() => isDragOver = false);

        // ensure it's a sibling move (same parent)
        final parent = widget.entry.node.parent1;
        if (data == widget.entry.node || parent == null) return;
        if (data.parent1 != parent) return; // extra guard

        setState(() {
          parent.children1.remove(data);
          final int newIndex = parent.children1.indexOf(widget.entry.node);
          parent.children1.insert(newIndex, data);
        });

        // Final rebuild to remove any visual artifacts
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            ref.read(fetchApiProvider).treeController.rebuild();
          }
        });
      },
      // onAccept: (Node data) {
      //   if (data != widget.entry.node) {
      //     final parent = widget.entry.node.parent1;
      //     if (parent != null) {
      //       setState(() {
      //         parent.children1.remove(data);
      //         int newIndex = parent.children1.indexOf(widget.entry.node);
      //         parent.children1.insert(newIndex, data);
      //       });
      //       ref.read(fetchApiProvider).treeController.rebuild();
      //     }
      //   }
      // },

      builder: (context, candidateData, rejectedData) {
        // return Draggable<Node>(
        //   data: widget.entry.node,
        //   // feedback: Material(
        //   //   child: Container(
        //   //     padding: const EdgeInsets.all(8.0),
        //   //     decoration: BoxDecoration(
        //   //       color: Color(int.parse(
        //   //               '0xFF${(widget.entry.node.dict!.pms_color_code!).replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
        //   //           .withOpacity(0.7),
        //   //       borderRadius: BorderRadius.circular(4),
        //   //     ),
        //   //     child: Text(
        //   //       widget.entry.node.dict!.pmsCategoryName ?? 'Item',
        //   //       style: const TextStyle(color: Colors.white),
        //   //     ),
        //   //   ),
        //   // ),
        //   // childWhenDragging: Opacity(
        //   //   opacity: 0.5,
        //   //   child: _buildNodeContent(),
        //   // ),
        //   // child: _buildNodeContent(),
        //   child: _buildNodeContent(), // Replace with your actual widget
        //   feedback: Material(
        //     child: _buildNodeContent(), // Replace with your actual widget
        //   ),
        //   childWhenDragging: Container(), // Placeholder while dragging
        // );

        return Draggable<Node>(
          data: widget.entry.node,
          maxSimultaneousDrags: 1,
          feedback: _dragFeedback(),
          // hide original while dragging
          childWhenDragging: const SizedBox.shrink(),

          child: _buildNodeContent(),
          affinity: Axis.vertical, // ensure vertical drag

          onDragStarted: () {
            setState(() {
              isDragging = true;
              isDragOver = false;
            });
            // ensure whole tree redraw to avoid stale UI
            ref.read(fetchApiProvider).treeController.rebuild();
          },
          onDragCompleted: () {
            setState(() {
              isDragging = false;
              isDragOver = false;
            });
            ref.read(fetchApiProvider).treeController.rebuild();
          },
          onDraggableCanceled: (_, __) {
            // not accepted by any DragTarget -> clear flags and rebuild
            setState(() {
              isDragging = false;
              isDragOver = false;
            });
            ref.read(fetchApiProvider).treeController.rebuild();

            // Defensive: some desktop builds can leave the overlay visible;
            // force another rebuild shortly after to remove any lingering overlay.
            Future.delayed(const Duration(milliseconds: 80), () {
              if (mounted) {
                setState(() {
                  isDragging = false;
                  isDragOver = false;
                });
                ref.read(fetchApiProvider).treeController.rebuild();
              }
            });
          },

          onDragEnd: (_) {
            // ensure flags cleared for any end case
            setState(() {
              isDragging = false;
              isDragOver = false;
            });
            ref.read(fetchApiProvider).treeController.rebuild();
          },
        );
      },
    );
    if (isDragOver) {
      content = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: content,
      );
    } else {
      // Ensure no lingering decoration
      content = content;
    }

    if (widget.decoration != null) {
      content = DecoratedBox(
        decoration: widget.decoration!,
        child: content,
      );
    }

    if (widget.showIndentation) {
      return TreeIndentation(
        entry: widget.entry,
        child: content,
      );
    }
    if (widget.decoration != null) {
      content = DecoratedBox(
        decoration: widget.decoration!,
        child: content,
      );
    }

    if (widget.showIndentation) {
      return TreeIndentation(
        entry: widget.entry,
        child: content,
      );
    }

    return content;
  }

  // Extract the main node UI into a separate method
  Widget _buildNodeContent() {
    final parent = widget.entry.node.parent1;
    final int index = parent?.children1.indexOf(widget.entry.node) ?? -1;
    final bool canMoveUp = parent != null && index > 0;
    final bool canMoveDown =
        parent != null && index >= 0 && index < (parent.children1.length - 1);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const MoveUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const MoveDownIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          MoveUpIntent: CallbackAction<MoveUpIntent>(
            onInvoke: (intent) {
              if (canMoveUp) moveNodeUp();
              return null;
            },
          ),
          MoveDownIntent: CallbackAction<MoveDownIntent>(
            onInvoke: (intent) {
              if (canMoveDown) moveNodeDown();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          child: InkWell(
            onHover: (val) {
              setState(() {
                isHover = val;
              });
            },
            onTap: () {
              // ensure this tile receives keyboard focus so its Shortcuts/Actions work
              if (!_focusNode.hasFocus) _focusNode.requestFocus();
              widget.onFolderPressed?.call();
            },
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ...existing folder button code...
                  widget.entry.node.children1.length > 0
                      ? FolderButton(
                          openedIcon: Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                      '0xFF${(widget.entry.node.dict!.pms_color_code!).replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                                  .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black54,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ),
                          closedIcon: Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                      '0xFF${(widget.entry.node.dict!.pms_color_code!).replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                                  .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black54,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ),
                          icon: Icon(
                            Icons.article,
                            color: Color(int.parse(
                                '0xFF${(widget.entry.node.dict!.pms_color_code!).replaceAll(RegExp('[^A-Za-z0-9]'), '')}')),
                            size: 24,
                          ),
                          isOpen: widget.entry.node.isLeaf
                              ? null
                              : widget.entry.isExpanded,
                          onPressed: widget.onFolderPressed,
                          hoverColor: Colors.transparent,
                        )
                      : widget.entry.node.children1.length == 0 &&
                              widget.entry.node.dict?.parentIdFk == "0"
                          ? Container(
                              margin: const EdgeInsets.only(left: 8),
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Color(int.parse(
                                          '0xFF${(widget.entry.node.dict!.pms_color_code!).replaceAll(RegExp('[^A-Za-z0-9]'), '')}'))
                                      .withOpacity(0.8),
                                  border: Border.all(color: Colors.black45)),
                            )
                          : const SizedBox.shrink(),
                  Padding(
                    padding: widget.entry.node.dict!.details!.length > 0
                        ? const EdgeInsets.only(left: 0.0)
                        : const EdgeInsets.only(left: 10.0),
                    child: Text(widget.entry.node.dict!.pmsCategoryName!),
                  ),
                  isHover == true
                      ? Row(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: PopupMenuButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                                position: PopupMenuPosition.under,
                                onSelected: (value) {
                                  // your logic
                                },
                                itemBuilder: (BuildContext bc) {
                                  return [
                                    // Move Up
                                    // PopupMenuItem(
                                    //   onTap: moveNodeUp,
                                    //   value: '',
                                    //   child: const Row(
                                    //     children: [
                                    //       Icon(Icons.arrow_upward, size: 20),
                                    //       SizedBox(width: 10),
                                    //       Text("MOVE UP"),
                                    //     ],
                                    //   ),
                                    // ),
                                    // // Move Down
                                    // PopupMenuItem(
                                    //   onTap: moveNodeDown,
                                    //   value: '',
                                    //   child: const Row(
                                    //     children: [
                                    //       Icon(Icons.arrow_downward, size: 20),
                                    //       SizedBox(width: 10),
                                    //       Text("MOVE DOWN"),
                                    //     ],
                                    //   ),
                                    // ),
                                    PopupMenuItem(
                                      value: '',
                                      child: Column(
                                        children: [
                                          Text(widget.entry.node.dict!
                                              .pmsCategoryName!),
                                          const Divider(),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      onTap: () {
                                        clearAllDates();
                                        addNewPmsModal().then((value) {
                                          startDateControler.clear();
                                          endDateControler.clear();
                                          titleControler.clear();
                                          remarkControler.clear();
                                        });
                                      },
                                      value: '',
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline_rounded,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("ADD"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: '',
                                      onTap: () {
                                        if (widget.entry.node.parent1?.dict
                                                    ?.details !=
                                                null
                                            //     ||
                                            // widget.entry.node.parent1?.dict
                                            //     ?.details?.isNotEmpty
                                            ) {
                                          print(
                                              '++++ ${widget.entry.node.parent1?.dict?.details?.length} -> ${index}');

                                          List<PmsStructure>? tempppp = [];
                                          for (int i = index;
                                              i <
                                                  widget.entry.node.parent1!
                                                      .dict!.details!.length;
                                              i++) {
                                            if (i != index) {
                                              tempppp.add(widget.entry.node
                                                  .parent1!.dict!.details![i]);
                                            }
                                          }
                                          ref
                                                  .read(fetchApiProvider)
                                                  .pmsStructureForUpdateExistingDrawer =
                                              tempppp;
                                          // widget.entry.node.parent1?.dict
                                          //     ?.details;
                                          inspect(widget.entry.node.parent1);
                                        }
                                        ref
                                            .read(fetchApiProvider)
                                            .pmsStructureForDuplicating
                                            ?.clear();
                                        ref
                                            .read(fetchApiProvider)
                                            .pmsStructureForDuplicating = [
                                          ...ref
                                                  .read(fetchApiProvider)
                                                  .pmsStructureForDuplicating ??
                                              [],
                                          DupliacateDataPms(
                                              mstPmsId: widget
                                                  .entry.node.dict!.mstPmsId,
                                              pmsCategoryName: widget.entry.node
                                                  .dict!.pmsCategoryName,
                                              parentIdFk: widget
                                                  .entry.node.dict!.parentIdFk,
                                              pmsOrderNo: widget
                                                  .entry.node.dict!.pmsOrderNo,
                                              pmsColorCode: widget.entry.node
                                                  .dict!.pms_color_code,
                                              pmsStartDate: widget.entry.node
                                                  .dict!.pmsStartDate,
                                              pmsEndDate: widget
                                                  .entry.node.dict!.pmsEndDate,
                                              totalDays: widget.entry.node.dict!
                                                  .pmsTotalDays,
                                              maxDate: widget
                                                  .entry.node.dict!.maxDate,
                                              minDate: widget
                                                  .entry.node.dict!.minDate,
                                              projectPmsIdFk: widget.entry.node
                                                  .dict!.projectPmsIdFk,
                                              pms_color_code: widget.entry.node
                                                  .dict!.pms_color_code,
                                              parentStartDate: widget.entry.node
                                                  .dict!.parentStartDate)
                                        ];

                                        ref
                                            .read(fetchApiProvider)
                                            .findRecToGetSingleDimensionArray(
                                              list11:
                                                  widget.entry.node.children,
                                              currSelectedNode:
                                                  widget.entry.node.dict!,
                                            );

                                        // String temmmm = json.encode(ref
                                        //     .watch(fetchApiProvider)
                                        //     .pmsStructureForDuplicating);
                                        // print(temmmm);

                                        Scaffold.of(context).openEndDrawer();
                                        // captureAndSaveAsPdf();
                                        ref
                                            .read(homeProvider)
                                            .setSelectedStartDateDrawer(
                                              data: widget.entry.node.dict!,
                                              startdata: widget.entry.node.dict!
                                                      .pmsStartDate ??
                                                  DateTime.now(),
                                              enddata: widget
                                                  .entry.node.dict!.pmsEndDate!,
                                              drawerTitle1: widget.entry.node
                                                      .dict?.pmsCategoryName ??
                                                  '',
                                              isClickedStartDate: widget.entry
                                                  .node.dict!.pmsStartDate!,
                                              isClickedEndDate: widget
                                                  .entry.node.dict!.pmsEndDate!,
                                              curNode: widget.entry.node,
                                            );
                                        // editExistingPmsModal(
                                        //         currentPmsStructure:
                                        //             widget.entry.node.dict!)
                                        //     .then((value) {
                                        //   startDateControler.clear();
                                        //   endDateControler.clear();
                                        //   titleControler.clear();
                                        // });
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("EDIT"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: '',
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.delete_forever_sharp,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("DELETE"),
                                        ],
                                      ),
                                      onTap: () {
                                        ref
                                            .read(fetchApiProvider)
                                            .pmsStructureForDuplicating
                                            ?.clear();
                                        ref
                                            .read(fetchApiProvider)
                                            .pmsStructureForDuplicating = [
                                          ...ref
                                                  .read(fetchApiProvider)
                                                  .pmsStructureForDuplicating ??
                                              [],
                                          // element.dict!
                                          DupliacateDataPms(
                                            pms_color_code: widget.entry.node
                                                .dict!.pms_color_code,
                                            mstPmsId: widget
                                                .entry.node.dict!.mstPmsId,
                                            pmsCategoryName: widget.entry.node
                                                .dict!.pmsCategoryName,
                                            parentIdFk: widget
                                                .entry.node.dict!.parentIdFk,
                                            pmsOrderNo: widget
                                                .entry.node.dict!.pmsOrderNo,
                                            pmsColorCode: widget.entry.node
                                                .dict!.pms_color_code,
                                            pmsStartDate: widget
                                                .entry.node.dict!.pmsStartDate!,
                                            pmsEndDate: widget
                                                .entry.node.dict!.pmsEndDate,
                                            totalDays: widget
                                                .entry.node.dict!.pmsTotalDays,
                                            maxDate:
                                                widget.entry.node.dict!.maxDate,
                                            minDate:
                                                widget.entry.node.dict!.minDate,
                                            projectPmsIdFk: widget.entry.node
                                                .dict!.projectPmsIdFk,
                                            parentStartDate: widget.entry.node
                                                .dict!.parentStartDate,
                                          )
                                        ];

                                        ref
                                            .read(fetchApiProvider)
                                            .findRecToGetSingleDimensionArray(
                                              list11:
                                                  widget.entry.node.children,
                                              currSelectedNode:
                                                  widget.entry.node.dict!,
                                            );
                                        // setState(() {
                                        //   isLoad = true;
                                        // String temmmm = json.encode(ref
                                        //     .watch(fetchApiProvider)
                                        //     .pmsStructureForDuplicating);
                                        // print(temmmm);
                                        // duplicateCurrentPms(pmsStructure: temmmm);
                                        // });

                                        deleteExistingPmsModal(
                                            currentPmsStructure:
                                                widget.entry.node.dict!);
                                      },
                                    ),
                                    PopupMenuItem(
                                      value: '',
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .control_point_duplicate_outlined,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text("CREATE DUPLICATE"),
                                        ],
                                      ),
                                      onTap: () {
                                        ref
                                            .read(fetchApiProvider)
                                            .pmsStructureForDuplicating
                                            ?.clear();
                                        ref
                                            .read(fetchApiProvider)
                                            .pmsStructureForDuplicating = [
                                          ...ref
                                                  .read(fetchApiProvider)
                                                  .pmsStructureForDuplicating ??
                                              [],
                                          // element.dict!
                                          DupliacateDataPms(
                                            pms_color_code: widget.entry.node
                                                .dict!.pms_color_code,
                                            mstPmsId: widget
                                                .entry.node.dict!.mstPmsId,
                                            pmsCategoryName: widget.entry.node
                                                .dict!.pmsCategoryName,
                                            parentIdFk: widget
                                                .entry.node.dict!.parentIdFk,
                                            pmsOrderNo: widget
                                                .entry.node.dict!.pmsOrderNo,
                                            pmsColorCode: widget.entry.node
                                                .dict!.pms_color_code,
                                            pmsStartDate: widget
                                                .entry.node.dict!.pmsStartDate!,
                                            pmsEndDate: widget
                                                .entry.node.dict!.pmsEndDate,
                                            totalDays: widget
                                                .entry.node.dict!.pmsTotalDays,
                                            maxDate:
                                                widget.entry.node.dict!.maxDate,
                                            minDate:
                                                widget.entry.node.dict!.minDate,
                                            projectPmsIdFk: widget.entry.node
                                                .dict!.projectPmsIdFk,
                                            parentStartDate: widget.entry.node
                                                .dict!.parentStartDate,
                                          )
                                        ];

                                        ref
                                            .read(fetchApiProvider)
                                            .findRecToGetSingleDimensionArray(
                                              list11:
                                                  widget.entry.node.children!,
                                              currSelectedNode:
                                                  widget.entry.node.dict!,
                                            );
                                        setState(() {
                                          isLoad = true;
                                          String temmmm = json.encode(ref
                                              .watch(fetchApiProvider)
                                              .pmsStructureForDuplicating);
                                          // print(temmmm);
                                          duplicateCurrentPms(
                                              pmsStructure: temmmm);
                                        });

                                        // for (int j = 0;
                                        //     j <
                                        //         widget
                                        //             .entry.node.parent1!.children1.length;
                                        //     j++) {
                                        //   if (widget.entry.node.dict?.pmsCategoryName ==
                                        //       widget.entry.node.parent1!.children1[j].dict
                                        //           ?.pmsCategoryName) {
                                        //     print(
                                        //         'array matched---- ${widget.entry.node.parent1!.children1[j].dict?.pmsCategoryName}');
                                        //   }
                                        // }
                                      },
                                    )
                                  ];
                                },
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                print(widget.entry.node.dict!.pmsCategoryName);
                                print(widget.entry.node.dict!.rccSlabSync);
                                print(widget
                                    .entry.node.dict!.projectSlabMasnoryType);
                                setState(() {
                                  //                                   if (isRccSelected &&
                                  // isMasonrySelected) {
                                  if (widget.entry.node.dict!.rccSlabSync ==
                                          "1" &&
                                      widget.entry.node.dict!
                                              .projectSlabMasnoryType ==
                                          '0') {
                                    isRccSelected = true;
                                  } else if (widget
                                              .entry.node.dict!.rccSlabSync ==
                                          "1" &&
                                      widget.entry.node.dict!
                                              .projectSlabMasnoryType ==
                                          '1') {
                                    isMasonrySelected = true;
                                  } else if (widget
                                              .entry.node.dict!.rccSlabSync ==
                                          "1" &&
                                      widget.entry.node.dict!
                                              .projectSlabMasnoryType ==
                                          '2') {
                                    isMasonrySelected = true;
                                    isRccSelected = true;
                                  }
                                });

                                showDialog<void>(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                          builder: (context, setState1) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // Set radius to zero
                                          ),
                                          titlePadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 20),
                                          actionsPadding: const EdgeInsets.only(
                                              bottom: 10, left: 10, right: 10),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          actionsAlignment:
                                              MainAxisAlignment.center,
                                          title: Text(
                                            "Are you sure, \nYou want to Sync ${widget.entry.node.dict!.pmsCategoryName} with R.C.C Structure's Slab & Estimated Dates?\nOnce Synced. Current Changes will be Replaced.",
                                            // "You are about to Delete the Template.\nThis change will impact on your scheduling for the current project if you have made any.\nDo you still want to proceed and Delete the Template?",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          // content: Container(
                                          //   height: 100,
                                          //   child: Column(
                                          //     children: [
                                          //       const Divider(),
                                          //       InkWell(
                                          //         onTap: () {
                                          //           setState1(() {
                                          //             pmsRccMasnoryType = '0';
                                          //           });
                                          //         },
                                          //         child: Row(
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment
                                          //                   .spaceBetween,
                                          //           crossAxisAlignment:
                                          //               CrossAxisAlignment
                                          //                   .center,
                                          //           children: [
                                          //             Column(
                                          //               mainAxisAlignment:
                                          //                   MainAxisAlignment
                                          //                       .start,
                                          //               crossAxisAlignment:
                                          //                   CrossAxisAlignment
                                          //                       .start,
                                          //               children: [
                                          //                 Text(
                                          //                   'RCC'!,
                                          //                   style: const TextStyle(
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .normal,
                                          //                       fontSize: 16.0,
                                          //                       color: Colors
                                          //                           .black),
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //             pmsRccMasnoryType == '0'
                                          //                 ? const Icon(
                                          //                     Icons
                                          //                         .circle_rounded,
                                          //                     size: 25,
                                          //                     color:
                                          //                         Colors.green,
                                          //                   )
                                          //                 : const Icon(
                                          //                     Icons
                                          //                         .circle_outlined,
                                          //                     size: 25,
                                          //                     color:
                                          //                         Colors.grey,
                                          //                   ),
                                          //           ],
                                          //         ),
                                          //       ),
                                          //       InkWell(
                                          //         onTap: () {
                                          //           setState1(() {
                                          //             pmsRccMasnoryType = '1';
                                          //           });
                                          //         },
                                          //         child: Row(
                                          //           mainAxisAlignment:
                                          //               MainAxisAlignment
                                          //                   .spaceBetween,
                                          //           crossAxisAlignment:
                                          //               CrossAxisAlignment
                                          //                   .center,
                                          //           children: [
                                          //             const Column(
                                          //               mainAxisAlignment:
                                          //                   MainAxisAlignment
                                          //                       .start,
                                          //               crossAxisAlignment:
                                          //                   CrossAxisAlignment
                                          //                       .start,
                                          //               children: [
                                          //                 Text(
                                          //                   'Masonry',
                                          //                   style: TextStyle(
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .normal,
                                          //                       fontSize: 16.0,
                                          //                       color: Colors
                                          //                           .black),
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //             pmsRccMasnoryType == '1'
                                          //                 ? const Icon(
                                          //                     Icons
                                          //                         .circle_rounded,
                                          //                     size: 25,
                                          //                     color:
                                          //                         Colors.green,
                                          //                   )
                                          //                 : const Icon(
                                          //                     Icons
                                          //                         .circle_outlined,
                                          //                     size: 25,
                                          //                     color:
                                          //                         Colors.grey,
                                          //                   ),
                                          //           ],
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),

                                          content: Container(
                                            height: 120,
                                            child: Column(
                                              children: [
                                                const Divider(),
                                                InkWell(
                                                  onTap: () {
                                                    setState1(() {
                                                      isRccSelected =
                                                          !isRccSelected;
                                                      // Update pmsRccMasnoryType based on selections
                                                      if (isRccSelected &&
                                                          isMasonrySelected) {
                                                        pmsRccMasnoryType = '2';
                                                      } else if (isRccSelected) {
                                                        pmsRccMasnoryType = '0';
                                                      } else if (isMasonrySelected) {
                                                        pmsRccMasnoryType = '1';
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'RCC',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 16.0,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      ),
                                                      isRccSelected
                                                          ? const Icon(
                                                              Icons.check_box,
                                                              size: 25,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : const Icon(
                                                              Icons
                                                                  .check_box_outline_blank,
                                                              size: 25,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                InkWell(
                                                  onTap: () {
                                                    setState1(() {
                                                      isMasonrySelected =
                                                          !isMasonrySelected;
                                                      // Update pmsRccMasnoryType based on selections
                                                      if (isRccSelected &&
                                                          isMasonrySelected) {
                                                        pmsRccMasnoryType = '2';
                                                      } else if (isRccSelected) {
                                                        pmsRccMasnoryType = '0';
                                                      } else if (isMasonrySelected) {
                                                        pmsRccMasnoryType = '1';
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Masonry',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 16.0,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      ),
                                                      isMasonrySelected
                                                          ? const Icon(
                                                              Icons.check_box,
                                                              size: 25,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : const Icon(
                                                              Icons
                                                                  .check_box_outline_blank,
                                                              size: 25,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                width: 250,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: const Text(
                                                  "No",
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
                                                syncPms(
                                                    parentId: widget.entry.node
                                                            .dict?.mstPmsId ??
                                                        '',
                                                    // startDate: _selectedStartDate!,
                                                    // endtDate: _selectedEndDate!,
                                                    projectPmsId: ref
                                                            .read(
                                                                fetchApiProvider)
                                                            .projectPmsInfoResponse?[
                                                                0]
                                                            .mstProjectPmsId ??
                                                        ''
                                                    // widget.entry.node.dict!.mstPmsId,
                                                    );
                                                // Navigator.of(context).pop();
                                                // deleteProjectPms(
                                                //     projectPmsId:
                                                //         projectPmsDetailsResponse?[k]
                                                //                 .mstProjectPmsId ??
                                                //             '');
                                                // getProjectPms(
                                                //     projectId:
                                                //         widget.projectId,
                                                //     towarId: widget.towarId);
                                              },
                                              child: Container(
                                                width: 250,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: const Text(
                                                  'Yes',
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
                                        );
                                      });
                                    });
                              },
                              child: const Tooltip(
                                message: 'Sync',
                                waitDuration: Duration(milliseconds: 250),
                                showDuration: Duration(seconds: 2),
                                preferBelow: false,
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Icon(Icons.sync),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: canMoveUp ? moveNodeUp : null,
                              child: Tooltip(
                                message: canMoveUp ? 'Shuffle Up' : 'Top item',
                                waitDuration: const Duration(milliseconds: 250),
                                showDuration: const Duration(seconds: 2),
                                preferBelow: false,
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Icon(Icons.arrow_upward,
                                      size: 14,
                                      color: canMoveUp
                                          ? Colors.black
                                          : Colors.grey[400]),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: canMoveDown ? moveNodeDown : null,
                              child: Tooltip(
                                message:
                                    canMoveDown ? 'Shuffle Down' : 'Last item',
                                waitDuration: const Duration(milliseconds: 250),
                                showDuration: const Duration(seconds: 2),
                                preferBelow: false,
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Icon(Icons.arrow_downward,
                                      size: 14,
                                      color: canMoveDown
                                          ? Colors.black
                                          : Colors.grey[400]),
                                ),
                              ),
                            ),
                            // SizedBox(width: 30),
                            InkWell(
                              onTap: canMoveDown ? moveNodeDown : null,
                              child: Tooltip(
                                message:
                                    'The Estimated dates once changed in RCC module will be auto-linked here. However if completed dates are changed\nthen you will need to manually sync and previous changes will be lost.',
                                waitDuration: const Duration(milliseconds: 250),
                                showDuration: const Duration(seconds: 2),
                                preferBelow: false,
                                child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Icon(Icons.info_outline,
                                      size: 14,
                                      color: canMoveDown
                                          ? Colors.black
                                          : Colors.grey[400]),
                                ),
                              ),
                            )
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
