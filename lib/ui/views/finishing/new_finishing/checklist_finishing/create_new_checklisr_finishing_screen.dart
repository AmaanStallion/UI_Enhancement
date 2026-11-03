import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/get_all_check_list.dart';
import 'package:stallion/models/projectSlabCheckList.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CreateNewFinishingCheckList extends StatefulWidget {
  const CreateNewFinishingCheckList({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.slabId,
    this.title,
    this.project_slab_check_id,
    required this.slabCheckDocument,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;
  final String? project_slab_check_id;
  final List<SlabCheckDocument>? slabCheckDocument;

  @override
  State<CreateNewFinishingCheckList> createState() => _CreateCheckListState();
}

class _CreateCheckListState extends State<CreateNewFinishingCheckList> {
  List<PlatformFile> arrayFiles = [];
  List<Uint8List?> arrayFilesBytes = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<SlabCheckList>? slabCheckListResponse;
  String projectSlabCheckIdResponse = "";
  TextEditingController addnoteController = TextEditingController();

  // void updateSlabCheckList(SlabCheckListResponse response) {
  //   // Step 1: Disable elements in slabCheckList where checkFlag == "1" or "2"
  //   for (SlabCheckList slab in response.slabCheckList ?? []) {
  //     for (ListElement item in slab.list ?? []) {
  //       if (item.checkFlag == "1" || item.checkFlag == "2") {
  //         print(item.name);
  //         item.disabled = true;
  //       }
  //     }
  //   }

  //   // Step 2: Replace matching items from slabCheckListEdited into slabCheckList
  //   for (SlabCheckList editedSlab in response.slabCheckListEdited ?? []) {
  //     var matchingSlab = response.slabCheckList?.firstWhere(
  //       (slab) => slab.id == editedSlab.id,
  //       orElse: () => SlabCheckList(),
  //     );

  //     if (matchingSlab != null && matchingSlab.id != null) {
  //       for (ListElement editedItem in editedSlab.list ?? []) {
  //         var matchingItem = matchingSlab.list?.firstWhere(
  //           (item) => item.id == editedItem.id,
  //           orElse: () => ListElement(),
  //         );

  //         if (matchingItem != null && matchingItem.id != null) {
  //           // Replace checkFlag and checkRemark with edited values
  //           matchingItem.checkFlag = editedItem.checkFlag;
  //           matchingItem.checkRemark = editedItem.checkRemark;

  //           // Re-check disable after editing
  //           // if (matchingItem.checkFlag == "1" ||
  //           //     matchingItem.checkFlag == "2") {
  //           //   matchingItem.disabled = true;
  //           // } else {
  //           //   matchingItem.disabled = false;
  //           // }
  //         }
  //       }
  //     }
  //   }
  // }

  bool isChecklistCompleted(SlabCheckList slab) {
    return slab.list != null &&
        slab.list!.every(
          (item) => item.checkFlag == "1" || item.checkFlag == "2",
        );
  }

  void updateSlabCheckList(SlabCheckListResponse response) {
    if (response.checkListFlag != "1") return;

    final slabs = response.slabCheckList ?? [];

    int activeIndex = 0;

    // 🔍 Find last completed checklist
    for (int i = 0; i < slabs.length; i++) {
      if (isChecklistCompleted(slabs[i])) {
        activeIndex = i + 1;
      } else {
        break;
      }
    }

    // 🧠 Apply enable/disable rules
    for (int i = 0; i < slabs.length; i++) {
      final slab = slabs[i];

      for (final item in slab.list ?? []) {
        if (i < activeIndex) {
          // Completed slabs → fully locked
          print("name: ${slab.name}");
          item.disabled = true;
        } else if (i == activeIndex) {
          // Current slab → editable
          item.disabled = false;
        } else {
          // Future slabs → locked
          item.disabled = true;
        }
      }
    }

    // 🧩 Merge edited checklist values (your existing logic)
    for (SlabCheckList editedSlab in response.slabCheckListEdited ?? []) {
      final matchingSlab = slabs.firstWhere(
        (s) => s.id == editedSlab.id,
        orElse: () => SlabCheckList(),
      );

      for (ListElement editedItem in editedSlab.list ?? []) {
        final matchingItem = matchingSlab.list?.firstWhere(
          (i) => i.id == editedItem.id,
          orElse: () => ListElement(),
        );

        if (matchingItem?.id != null) {
          print(editedItem.name);
          matchingItem?.checkFlag = editedItem.checkFlag;
          matchingItem?.checkRemark = editedItem.checkRemark;
        }
      }
    }
  }

  Future<SlabCheckListResponse?> getSlabCheckList() async {
    Map<String, String> data = {
      "user_id": '0', // 0 TO Create new
      "project_id": widget.projectId!,
      "towar_id": widget.towarId ?? '',
      "slab_id": '0', //'widget.slabId!',
      "project_slab_check_id": widget.project_slab_check_id ?? ''
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.projectfinishingCheckListNew, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectSlabCheckListFromJson(response.body);

      if (dataModel.response?.errorCode == "0") {
        // ➡️ CALL your update function here before setting state
        updateSlabCheckList(dataModel.response!);

        setState(() {
          slabCheckListResponse = dataModel.response?.slabCheckList;
          addnoteController.text = dataModel.response?.remark ?? '';
          projectSlabCheckIdResponse =
              dataModel.response?.projectSlabCheckId ?? '';
        });
      } else {}
    }
    return null;
  }

  // List<Map<String, dynamic>> prepareChangedChecklist(
  //     List<SlabCheckList>? originalList) {
  //   if (originalList == null) return [];

  //   return originalList
  //       .map((category) {
  //         final filteredItems = category.list
  //             ?.where((item) =>
  //                 item.checkFlag != null && item.checkFlag != "0" ||
  //                 (item.checkRemark != null &&
  //                     item.checkRemark!.trim().isNotEmpty))
  //             .toList();

  //         if (filteredItems != null && filteredItems.isNotEmpty) {
  //           return {
  //             "id": category.id,
  //             "name": category.name,
  //             "tickflag": "",
  //             "list": filteredItems.map((item) => item.toJson()).toList(),
  //           };
  //         }

  //         return null;
  //       })
  //       .where((e) => e != null)
  //       .cast<Map<String, dynamic>>()
  //       .toList();
  // }
  List<Map<String, dynamic>> prepareChangedChecklist(
      List<SlabCheckList>? originalList) {
    if (originalList == null) return [];

    return originalList
        .map((category) {
          final filteredItems = category.list
              ?.where((item) =>
                      (item.checkFlag != null && item.checkFlag != "0" ||
                          (item.checkRemark != null &&
                              item.checkRemark!.trim().isNotEmpty)) &&
                      item.disabled == false // ✅ Only if not disabled
                  )
              .toList();

          if (filteredItems != null && filteredItems.isNotEmpty) {
            return {
              "id": category.id,
              "name": category.name,
              "tickflag": "",
              "list": filteredItems.map((item) => item.toJson()).toList(),
            };
          }

          return null;
        })
        .where((e) => e != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  List<Map<String, dynamic>> generateChangedChecklistPayload(
      List<SlabCheckList>? originalList) {
    if (originalList == null) return [];

    return originalList
        .map((category) {
          final changedItems =
              category.list?.where((item) => item.isChanged).toList();

          if (changedItems != null && changedItems.isNotEmpty) {
            return {
              "id": category.id,
              "name": category.name,
              "tickflag": "",
              "list": changedItems.map((item) => item.toJson()).toList(),
            };
          }

          return null;
        })
        .where((e) => e != null)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  setSlabCheckList({required String saveStatus}) async {
    final transformedData = prepareChangedChecklist(slabCheckListResponse);
    print('--------');
    print(transformedData);

    final transformedDataUpdated =
        generateChangedChecklistPayload(slabCheckListResponse);
    print('----transformedDataUpdated----');
    print(transformedDataUpdated);

    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.projectfinishingCheck));
    request.headers.addAll({"Authorization": "Bearer token"});
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    request.fields["save_status"] = saveStatus; // *
    request.fields["remark"] = addnoteController.text;
    request.fields["slab_id"] = '0'; // widget.slabId ?? '';
    request.fields["towar_id"] = widget.towarId!;
    request.fields["user_id"] = userId!;
    request.fields["slab_check_list"] = jsonEncode(slabCheckListResponse);
    request.fields["project_id"] = widget.projectId!;
    request.fields["project_slab_check_id"] = projectSlabCheckIdResponse;
    request.fields["slab_check_partial_list"] = jsonEncode(transformedData);

    for (int i = 0; i < arrayFiles.length; i++) {
      PlatformFile file = arrayFiles[i];
      request.files.add(
        await http.MultipartFile.fromPath(
          "slab_check_document[]",
          file.path.toString(),
          contentType: MediaType('application/pdf', file.extension ?? ""),
        ),
      );
    }

    print(request.fields);

    var response = await request.send();

    if (response.statusCode == 200) {
      CustomLoading.progressDialog(isLoading: false, context: context);

      // Navigator.of(context).pop();
      // ignore: use_build_context_synchronously
      showDialog<void>(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Set radius to zero
              ),
              titlePadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              actionsPadding:
                  const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                'Checklist ${saveStatus == "0" ? 'Saved' : 'Submitted'} Successfully.',
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

                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(7)),
                    child: const Text(
                      "Okay",
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
    } else {}
  }

  @override
  void initState() {
    getSlabCheckList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 40,
        color: Colors.black,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  CustomLoading.progressDialog(
                      isLoading: true, context: context);

                  setSlabCheckList(saveStatus: '0');
                },
                child: const Text(
                  textAlign: TextAlign.center,
                  "SAVE",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const VerticalDivider(
              color: Colors.white,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  // setSlabCheckList(saveStatus: '1');
                  showDialog<void>(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set radius to zero
                          ),
                          titlePadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          actionsPadding: const EdgeInsets.only(
                              bottom: 10, left: 10, right: 10),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          actionsAlignment: MainAxisAlignment.center,
                          title: const Text(
                            // "Once submitted it cannot be ammended! \nAre you seure, you want to submit?",
                            "Are You Sure? You want to Submit? \nOnce Submitted, it cannot be amended!",
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
                                width: 140,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
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
                                CustomLoading.progressDialog(
                                    isLoading: true, context: context);

                                setSlabCheckList(saveStatus: '1');
                                Navigator.of(context).pop();
                                // deleteProjectPms(
                                //     projectPmsId: projectPmsDetailsResponse?[k]
                                //             .mstProjectPmsId ??
                                //         '');
                                // getProjectPms(
                                //     projectId:
                                //         widget.projectId,
                                //     towarId: widget.towarId);
                              },
                              child: Container(
                                width: 140,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(7)),
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
                },
                child: const Text(
                  textAlign: TextAlign.center,
                  "SUBMIT",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            widget.towarName!.isNotEmpty
                ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
                : widget.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            "Checklist",
            // '${widget.title} Checklist',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: slabCheckListResponse?.length ?? 0,
                    itemBuilder: (context, index) {
                      // slabCheckListResponse?[index].checkRemark ?? '';
                      // });
                      return GestureDetector(
                        onTap: () {
                          if (slabCheckListResponse?[index].isCollapse == "0") {
                            setState(() {
                              slabCheckListResponse?[index].isCollapse = "1";
                            });
                          } else {
                            setState(() {
                              slabCheckListResponse?[index].isCollapse = "0";
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 241, 241, 241),
                                    borderRadius: BorderRadius.circular(8)
                                    // border: Border(
                                    //   bottom: BorderSide(color: Colors.black),
                                    // ),
                                    ),
                                child: Row(
                                  children: [
                                    Text(
                                      slabCheckListResponse?[index].name ?? '',
                                      style: TextStyle(
                                          color: slabCheckListResponse?[index]
                                                          .list?[0]
                                                          .checkFlag ==
                                                      '0' &&
                                                  index != 0
                                              ? Colors.grey
                                              : Colors.black,

                                          // color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    Icon(slabCheckListResponse?[index]
                                                .isCollapse ==
                                            "1"
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded)
                                  ],
                                ),
                              ),
                              if (slabCheckListResponse?[index].isCollapse ==
                                  "1")
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: slabCheckListResponse?[index]
                                          .list!
                                          .length ??
                                      0,
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int subIndex) {
                                    TextEditingController controllerEdit =
                                        TextEditingController();
                                    // setState(() {
                                    controllerEdit.text =
                                        slabCheckListResponse?[index]
                                                .list?[subIndex]
                                                .checkRemark ??
                                            '';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          Opacity(
                                            opacity:
                                                slabCheckListResponse?[index]
                                                            .list?[subIndex]
                                                            .disabled ==
                                                        true
                                                    ? 0.5
                                                    : 1.0,
                                            child: Row(
                                              children: [
                                                Text(
                                                  slabCheckListResponse?[index]
                                                          .list?[subIndex]
                                                          .name ??
                                                      '',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Spacer(),
                                                InkWell(
                                                  onTap: () {
                                                    if (slabCheckListResponse?[
                                                                index]
                                                            .list?[subIndex]
                                                            .disabled ==
                                                        false) {
                                                      setState(() {
                                                        if (slabCheckListResponse?[
                                                                    index]
                                                                .list?[subIndex]
                                                                .checkFlag ==
                                                            '1') {
                                                          setState(() {
                                                            slabCheckListResponse?[
                                                                    index]
                                                                .list?[subIndex]
                                                                .checkFlag = "0";
                                                          });
                                                        } else {
                                                          slabCheckListResponse?[
                                                                  index]
                                                              .list?[subIndex]
                                                              .checkFlag = "1";
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 18,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: slabCheckListResponse?[
                                                                      index]
                                                                  .list?[
                                                                      subIndex]
                                                                  .checkFlag ==
                                                              "1"
                                                          ? Colors.black
                                                          : Colors.transparent,
                                                      border: Border.all(
                                                          color: Colors.black),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      "Yes",
                                                      style: TextStyle(
                                                        color: slabCheckListResponse?[
                                                                        index]
                                                                    .list?[
                                                                        subIndex]
                                                                    .checkFlag ==
                                                                "1"
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                InkWell(
                                                  onTap: () {
                                                    if (slabCheckListResponse?[
                                                                index]
                                                            .list?[subIndex]
                                                            .disabled ==
                                                        false) {
                                                      setState(() {
                                                        if (slabCheckListResponse?[
                                                                    index]
                                                                .list?[subIndex]
                                                                .checkFlag ==
                                                            '2') {
                                                          setState(() {
                                                            slabCheckListResponse?[
                                                                    index]
                                                                .list?[subIndex]
                                                                .checkFlag = "0";
                                                          });
                                                        } else {
                                                          slabCheckListResponse?[
                                                                  index]
                                                              .list?[subIndex]
                                                              .checkFlag = "2";
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 18,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: slabCheckListResponse?[
                                                                      index]
                                                                  .list?[
                                                                      subIndex]
                                                                  .checkFlag ==
                                                              "2"
                                                          ? Colors.black
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      border: Border.all(
                                                          color: Colors.black),
                                                    ),
                                                    child: Text(
                                                      "No",
                                                      style: TextStyle(
                                                        color: slabCheckListResponse?[
                                                                        index]
                                                                    .list?[
                                                                        subIndex]
                                                                    .checkFlag ==
                                                                "2"
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Opacity(
                                            opacity:
                                                slabCheckListResponse?[index]
                                                            .list?[subIndex]
                                                            .disabled ==
                                                        true
                                                    ? 0.5
                                                    : 1.0,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Remarks :   ",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    // width: 600,
                                                    child: TextFormField(
                                                      maxLines: 3,
                                                      enabled: slabCheckListResponse?[
                                                                      index]
                                                                  .list?[
                                                                      subIndex]
                                                                  .disabled ==
                                                              true
                                                          ? false
                                                          : true,

                                                      // validator: (value) {
                                                      //   if (value!.isEmpty) {
                                                      //     return "(Start Date Cannot Be Empty)";
                                                      //   }
                                                      // },
                                                      // enabled: false,
                                                      // readOnly: true,
                                                      controller:
                                                          controllerEdit,
                                                      onChanged: (value) {
                                                        // setState(() {
                                                        slabCheckListResponse?[
                                                                    index]
                                                                .list?[subIndex]
                                                                .checkRemark =
                                                            value;
                                                        // });
                                                      },
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 13.0),
                                                      decoration:
                                                          const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets.all(
                                                                12.0),
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .black)),
                                                        hintText:
                                                            'Enter Remark',
                                                        hintStyle: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              116,
                                                              116,
                                                              116),
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          fontFamily:
                                                              'HelveticaNeue',
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
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    // separatorBuilder: (context, index) => Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 80),
                    //   child: const Divider(
                    //     color: Colors.grey,
                    //   ),
                    // ),
                  ),
                  // const Divider(),
                  // const SizedBox(height: 6),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black)),
                    child: Column(
                      children: [
                        Container(
                          // margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Row(
                            children: [
                              const Text(
                                "Add Note :   ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              Expanded(
                                // width: 600,
                                child: TextFormField(
                                    maxLines: 4,
                                    // validator: (value) {
                                    //   if (value!.isEmpty) {
                                    //     return "(Start Date Cannot Be Empty)";
                                    //   }
                                    // },
                                    // enabled: false,
                                    // readOnly: true,
                                    controller: addnoteController,
                                    // onChanged: (value) {
                                    //   print(value);
                                    //   // setState(() {
                                    //   slabCheckListResponse?[index].checkRemark = value;
                                    //   // });
                                    // },
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 13.0),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(12.0),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      hintText: 'Add Note',
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 116, 116, 116),
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w200,
                                        fontFamily: 'HelveticaNeue',
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        // const Divider(),
                        uploadDocImg(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget uploadDocImg() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Upload", style: TextStyle(fontSize: 16)), //
          Row(
            children: [
              InkWell(
                onTap: () async {
                  // if (arrayFiles.length != 4) {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      'jpg',
                      'jpeg',
                      'png',
                      // "mp4",
                      "pdf",
                    ],
                  );
                  if (result != null) {
                    PlatformFile file = result.files.first;
                    Uint8List? fileBytes = result.files.first.bytes;
                    setState(() {
                      arrayFilesBytes.add(fileBytes);
                      arrayFiles.add(file);
                    });

                    //inspect(arrayFiles[0]);
                  } else {
                    // User canceled the picker
                  }
                  // }
                },
                child: Image.asset(
                  'images/projectmanagement/img5.png',
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(width: 10),
              for (int j = 0; j < arrayFiles.length; j++)
                Row(
                  children: [
                    if (arrayFiles[j].extension == 'jpg' ||
                        arrayFiles[j].extension == 'jpeg' ||
                        arrayFiles[j].extension == 'png') //'jpg','jpeg','png',
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.file(
                              File(arrayFiles[j].path ?? ''),
                              height: 100,
                              width: 100,
                              fit: BoxFit.fill,
                            ),
                            Positioned(
                              right: -10,
                              top: -10,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    arrayFiles.remove(arrayFiles[j]);
                                    arrayFilesBytes.remove(arrayFilesBytes[j]);
                                  });
                                },
                                child: const Icon(Icons.close),
                              ),
                            )
                          ],
                        ),
                      ),
                    if (arrayFiles[j].extension == 'pdf')
                      Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return PdfViewer(
                                        isLocalFileUpload: true,
                                        localFiles: arrayFiles[j].path,
                                        fileName: arrayFiles[j].name,
                                        fileUrl: arrayFiles[j].path,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                // width: 100,
                                child: Image.asset(
                                  'images/projectmanagement/pdf.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -10,
                              top: -10,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    arrayFiles.remove(arrayFiles[j]);
                                    arrayFilesBytes.remove(arrayFilesBytes[j]);
                                  });
                                },
                                child: const Icon(Icons.close),
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
