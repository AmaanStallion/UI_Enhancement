import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stallion/models/get_all_check_list.dart';
import 'package:stallion/models/projectSlabCheckList.dart';
import 'package:stallion/models/rcc_checklist_api_models.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:image_picker/image_picker.dart';

class CreateCheckList extends StatefulWidget {
  const CreateCheckList({
    super.key,
    this.projectId,
    this.towarId,
    this.projectName,
    this.towarName,
    this.slabId,
    this.title,
    this.project_slab_check_id,
    this.slabCheckDocument,
    this.submissionEntry,
    this.restrictChecklistCategory,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;
  final String? title;
  final String? slabId;
  final String? project_slab_check_id;
  final List<SlabCheckDocument>? slabCheckDocument;
  final SlabSubmissionEntry? submissionEntry;
  final bool? restrictChecklistCategory;

  @override
  State<CreateCheckList> createState() => _CreateCheckListState();
}

class _CreateCheckListState extends State<CreateCheckList> {
  NetworkHandler apiNetworkHandler = NetworkHandler();
  List<SubmissionCategory> categories = [];
  List<SubmissionFile> existingFiles = [];
  List<PlatformFile> arrayFiles = [];
  bool isLoading = true;
  bool restrictChecklistCategory = false;
  Map<String, SubmissionQuestionItem> latestSubmittedMap = {};

  TextEditingController addnoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchChecklistData();
  }

  bool isCategoryUnlocked(int categoryIndex) {
    if (!restrictChecklistCategory) return true;
    if (categoryIndex == 0) return true;
    if (categoryIndex - 1 >= categories.length) return false;

    final prevCategory = categories[categoryIndex - 1];
    if (prevCategory.items.isEmpty) return true;

    for (var item in prevCategory.items) {
      final String qId = item.id.toString();
      final bool isSubmittedInHistory = latestSubmittedMap.containsKey(qId) &&
          (latestSubmittedMap[qId]!.status == "Yes" ||
              latestSubmittedMap[qId]!.status == "No");
      if (!isSubmittedInHistory && !item.disabled) {
        return false;
      }
    }
    return true;
  }

  Future<void> fetchChecklistData() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      final String slabId = widget.slabId ?? '';
      final String towerId = widget.towarId ?? '';

      if (widget.restrictChecklistCategory != null) {
        restrictChecklistCategory = widget.restrictChecklistCategory!;
      } else if (towerId.isNotEmpty) {
        try {
          var towerRes = await apiNetworkHandler
              .get("${AppUrl.baseURL}rcc/$towerId/progress");
          if (towerRes != null &&
              (towerRes.statusCode == 200 || towerRes.statusCode == 201)) {
            final decodedTower = json.decode(towerRes.body);
            if (decodedTower['success'] == true &&
                decodedTower['data'] != null) {
              restrictChecklistCategory = decodedTower['data']
                          ['restrict_checklist_category'] ==
                      true ||
                  decodedTower['data']['restrict_checklist_category']
                          ?.toString() ==
                      'true';
            }
          }
        } catch (e) {
          if (kDebugMode) print("Error fetching tower progress flag: $e");
        }
      }

      // Step 1: Fetch Latest Submitted Checklist (API 3) for Question Locking
      latestSubmittedMap.clear();
      if (slabId.isNotEmpty) {
        final String latestUrl = AppUrl.getLatestSlabSubmission(slabId);
        var latestRes = await apiNetworkHandler.get(latestUrl);
        if (latestRes.statusCode == 200 || latestRes.statusCode == 201) {
          final latestData = latestSubmissionResponseFromJson(latestRes.body);
          if (latestData.success && latestData.data?.data != null) {
            final tree = latestData.data!.data!.data;
            if (tree != null) {
              for (var cat in tree.categories) {
                for (var item in cat.items) {
                  latestSubmittedMap[item.id.toString()] = item;
                }
              }
            }
          }
        }
      }

      // Step 2: Load categories (from draft submissionEntry or API 2 fallback)
      List<SubmissionCategory> loadedCategories = [];

      if (widget.submissionEntry != null &&
          widget.submissionEntry!.data?.categories != null &&
          widget.submissionEntry!.data!.categories.isNotEmpty) {
        // Load existing draft items
        existingFiles = List.from(widget.submissionEntry!.files);
        if (widget.submissionEntry!.remarks != null) {
          addnoteController.text = widget.submissionEntry!.remarks!;
        }

        for (var cat in widget.submissionEntry!.data!.categories) {
          List<SubmissionQuestionItem> items = [];
          for (var item in cat.items) {
            final String qId = item.id.toString();
            final bool isAlreadyAnsweredInSubmitted =
                latestSubmittedMap.containsKey(qId) &&
                    (latestSubmittedMap[qId]!.status == "Yes" ||
                        latestSubmittedMap[qId]!.status == "No");

            if (isAlreadyAnsweredInSubmitted) {
              final submittedItem = latestSubmittedMap[qId]!;
              items.add(
                SubmissionQuestionItem(
                  id: item.id,
                  question: item.question,
                  status: submittedItem.status,
                  remarks: submittedItem.remarks,
                  disabled: true, // LOCKED because already submitted!
                ),
              );
            } else {
              items.add(
                SubmissionQuestionItem(
                  id: item.id,
                  question: item.question,
                  status: item.status,
                  remarks: item.remarks,
                  disabled: false,
                ),
              );
            }
          }
          loadedCategories.add(
            SubmissionCategory(
              id: cat.id,
              name: cat.name,
              items: items,
              isCollapse: true,
            ),
          );
        }
      } else if (towerId.isNotEmpty) {
        // Fallback: Fetch blank categories via API 2
        final String groupedUrl = AppUrl.getSlabChecklistTypesGrouped(towerId);
        var groupedRes = await apiNetworkHandler.get(groupedUrl);
        if (groupedRes.statusCode == 200 || groupedRes.statusCode == 201) {
          final groupedData =
              checklistGroupedResponseFromJson(groupedRes.body);
          if (groupedData.success && groupedData.data != null) {
            for (var groupCat in groupedData.data!.data) {
              List<SubmissionQuestionItem> items = [];
              for (var question in groupCat.checklistTypes) {
                final String qId = question.id.toString();
                final bool isAlreadyAnswered =
                    latestSubmittedMap.containsKey(qId) &&
                        (latestSubmittedMap[qId]!.status == "Yes" ||
                            latestSubmittedMap[qId]!.status == "No");

                if (isAlreadyAnswered) {
                  final submittedItem = latestSubmittedMap[qId]!;
                  items.add(
                    SubmissionQuestionItem(
                      id: question.id,
                      question: question.name,
                      status: submittedItem.status,
                      remarks: submittedItem.remarks,
                      disabled: true, // LOCKED
                    ),
                  );
                } else {
                  items.add(
                    SubmissionQuestionItem(
                      id: question.id,
                      question: question.name,
                      status: "",
                      remarks: "",
                      disabled: false,
                    ),
                  );
                }
              }
              loadedCategories.add(
                SubmissionCategory(
                  id: groupCat.categoryId,
                  name: groupCat.categoryName,
                  items: items,
                  isCollapse: true,
                ),
              );
            }
          }
        }
      }

      categories = loadedCategories;
    } catch (e) {
      if (kDebugMode) print("Fetch Checklist Data Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteExistingFile(SubmissionFile doc) async {
    try {
      final String deleteUrl = AppUrl.deleteSubmissionFile(doc.id);
      var res = await apiNetworkHandler.delete(deleteUrl);
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() {
          existingFiles.removeWhere((f) => f.id == doc.id);
        });
      } else {
        setState(() {
          existingFiles.removeWhere((f) => f.id == doc.id);
        });
      }
    } catch (e) {
      setState(() {
        existingFiles.removeWhere((f) => f.id == doc.id);
      });
    }
  }

  Future<void> submitChecklist({required String saveStatus}) async {
    final String slabId = widget.slabId ?? '';
    final String submissionId = widget.submissionEntry?.id ??
        widget.project_slab_check_id ??
        '';

    if (slabId.isEmpty) return;

    try {
      String url;
      String httpMethod;
      if (submissionId.isNotEmpty) {
        url = AppUrl.putSlabSubmission(slabId, submissionId);
        httpMethod = 'PUT';
      } else {
        url = AppUrl.postSlabSubmission(slabId);
        httpMethod = 'POST';
      }

      var request = http.MultipartRequest(httpMethod, Uri.parse(url));

      String? token = await apiNetworkHandler.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['is_submitted'] = saveStatus == '1' ? 'true' : 'false';
      request.fields['remarks'] = addnoteController.text.trim();
      request.fields['data'] = jsonEncode({
        "categories": categories.map((c) => c.toJson()).toList(),
      });

      for (int i = 0; i < arrayFiles.length; i++) {
        PlatformFile file = arrayFiles[i];
        if (file.path != null) {
          final isPdf = file.extension?.toLowerCase() == 'pdf';
          request.files.add(
            await http.MultipartFile.fromPath(
              'files',
              file.path!,
              contentType: MediaType(
                isPdf ? 'application' : 'image',
                file.extension ?? '*',
              ),
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (mounted) {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          showDialog<void>(
            barrierDismissible: true,
            context: context,
            builder: (dialogContext) {
              final isMobile = dialogContext.isMobile;
              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 18 : 22,
                ),
                actionsPadding: EdgeInsets.only(
                  bottom: isMobile ? 14 : 18,
                  left: 16,
                  right: 16,
                ),
                actionsAlignment: MainAxisAlignment.center,
                title: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    saveStatus == "0" ? "DRAFT SAVED" : "SUCCESS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                content: Text(
                  'Checklist ${saveStatus == "0" ? 'Saved' : 'Submitted'} Successfully.',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: isMobile ? 140 : 180,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Okay",
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (kDebugMode) print("Submit Error: ${response.body}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomLoading.progressDialog(isLoading: false, context: context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting checklist: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final String projectName = widget.projectName ?? '';
    final String towerName = widget.towarName ?? '';
    final String appBarTitle = towerName.isNotEmpty
        ? '${projectName.toUpperCase()} - ${towerName.toUpperCase()}'
        : projectName.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          appBarTitle,
          style: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: isMobile ? 15.0 : 17.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 20,
            vertical: isMobile ? 8 : 12,
          ),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    CustomLoading.progressDialog(
                        isLoading: true, context: context);
                    submitChecklist(saveStatus: '0');
                  },
                  child: Container(
                    height: isMobile ? 42 : 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        "SAVE DRAFT",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    showDialog<void>(
                      barrierDismissible: true,
                      context: context,
                      builder: (dialogContext) {
                        final isMobile = dialogContext.isMobile;
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          titlePadding: EdgeInsets.zero,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 24,
                            vertical: isMobile ? 18 : 22,
                          ),
                          actionsPadding: EdgeInsets.only(
                            bottom: isMobile ? 14 : 18,
                            left: 16,
                            right: 16,
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          title: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              "SUBMIT CHECKLIST",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          content: Text(
                            "Are You Sure You Want to Submit?\nOnce submitted, it cannot be amended!",
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffe9ecef),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "No",
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      Navigator.of(dialogContext).pop();
                                      CustomLoading.progressDialog(
                                          isLoading: true, context: context);
                                      submitChecklist(saveStatus: '1');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: isMobile ? 42 : 46,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SubHeader Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 20,
                vertical: isMobile ? 8 : 10,
              ),
              color: Colors.white,
              child: Text(
                '${widget.title ?? ''} Checklist Inspection',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1.0, color: Colors.black12),

            // Form Body / Skeleton Loader
            Expanded(
              child: isLoading
                  ? ChecklistSkeletonScreen(isMobile: isMobile)
                  : GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      behavior: HitTestBehavior.translucent,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12.0 : 20.0,
                          vertical: isMobile ? 12.0 : 16.0,
                        ),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Accordions
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final bool unlocked = isCategoryUnlocked(index);
                              final isCollapsed = !unlocked ? true : category.isCollapse;
                              final Color headerBgColor = !unlocked
                                  ? const Color(0xffe9ecef)
                                  : const Color(0xfff8f9fa);

                              return Card(
                                color: Colors.white,
                                margin: EdgeInsets.only(
                                    bottom: isMobile ? 10.0 : 14.0),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: !unlocked
                                        ? const Color(0xffced4da)
                                        : const Color(0xffe9ecef),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Accordion Header
                                    InkWell(
                                      onTap: unlocked
                                          ? () {
                                              setState(() {
                                                category.isCollapse =
                                                    !category.isCollapse;
                                              });
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: isMobile ? 10 : 14,
                                          horizontal: isMobile ? 14 : 18,
                                        ),
                                        decoration: BoxDecoration(
                                          color: headerBgColor,
                                          borderRadius: isCollapsed
                                              ? BorderRadius.circular(12)
                                              : const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                category.name,
                                                style: TextStyle(
                                                  color: !unlocked
                                                      ? Colors.black54
                                                      : Colors.black,
                                                  fontSize: isMobile ? 14 : 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              !isCollapsed
                                                  ? Icons
                                                      .keyboard_arrow_up_rounded
                                                  : Icons
                                                      .keyboard_arrow_down_rounded,
                                              color: !unlocked
                                                  ? Colors.black38
                                                  : Colors.black87,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Accordion Items List
                                    if (!isCollapsed && unlocked)
                                      ListView.separated(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: category.items.length,
                                        separatorBuilder: (context, idx) =>
                                            const Divider(
                                          height: 1,
                                          color: Color(0xffe9ecef),
                                        ),
                                        itemBuilder: (context, subIndex) {
                                          final item = category.items[subIndex];
                                          final bool isDisabled = item.disabled;

                                          return Padding(
                                            padding: EdgeInsets.all(
                                                isMobile ? 12.0 : 16.0),
                                            child: Opacity(
                                              opacity: isDisabled ? 0.5 : 1.0,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item.question,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: isMobile
                                                                ? 13
                                                                : 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),

                                                      // Capsule "Yes" Button
                                                      InkWell(
                                                        onTap: () {
                                                          if (!isDisabled) {
                                                            setState(() {
                                                              item.status =
                                                                  item.status ==
                                                                          'Yes'
                                                                      ? ''
                                                                      : 'Yes';
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                            horizontal: isMobile
                                                                ? 14
                                                                : 18,
                                                            vertical: isMobile
                                                                ? 5
                                                                : 7,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: item.status ==
                                                                    "Yes"
                                                                ? Colors.black
                                                                : Colors
                                                                    .transparent,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          child: Text(
                                                            "Yes",
                                                            style: TextStyle(
                                                              color: item.status ==
                                                                      "Yes"
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontSize: isMobile
                                                                  ? 12
                                                                  : 14,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),

                                                      // Capsule "No" Button
                                                      InkWell(
                                                        onTap: () {
                                                          if (!isDisabled) {
                                                            setState(() {
                                                              item.status =
                                                                  item.status ==
                                                                          'No'
                                                                      ? ''
                                                                      : 'No';
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                            horizontal: isMobile
                                                                ? 14
                                                                : 18,
                                                            vertical: isMobile
                                                                ? 5
                                                                : 7,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: item.status ==
                                                                    "No"
                                                                ? Colors.black
                                                                : Colors
                                                                    .transparent,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                          ),
                                                          child: Text(
                                                            "No",
                                                            style: TextStyle(
                                                              color: item.status ==
                                                                      "No"
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontSize: isMobile
                                                                  ? 12
                                                                  : 14,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),

                                                  // Remark Input Box
                                                  TextFormField(
                                                    enabled: !isDisabled,
                                                    initialValue: item.remarks,
                                                    onChanged: (val) {
                                                      item.remarks = val;
                                                    },
                                                    style: TextStyle(
                                                        fontSize: isMobile
                                                            ? 13
                                                            : 14),
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Enter inspection remarks...",
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical:
                                                            isMobile ? 8 : 10,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Color(
                                                                    0xffe0e0e0)),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Additional Notes Card
                          Card(
                            color: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xffe9ecef)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 14.0 : 18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "General Notes / Remarks",
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: addnoteController,
                                    maxLines: 3,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context).unfocus(),
                                    style: TextStyle(
                                        fontSize: isMobile ? 13 : 14),
                                    decoration: InputDecoration(
                                      hintText:
                                          "Write general inspection notes or instructions...",
                                      contentPadding: const EdgeInsets.all(12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xffe0e0e0)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Attachment Documents Section
                          Card(
                            color: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xffe9ecef)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 14.0 : 18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Attachments",
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final bool isMobileDevice =
                                              !kIsWeb &&
                                                  (Platform.isAndroid ||
                                                      Platform.isIOS);
                                          if (isMobileDevice) {
                                            final source =
                                                await _showMediaSourcePickerSheet(
                                                    context);
                                            if (source == 'camera') {
                                              try {
                                                final ImagePicker picker =
                                                    ImagePicker();
                                                final XFile? photo =
                                                    await picker.pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 85,
                                                );
                                                if (photo != null) {
                                                  final bytes = await photo
                                                      .readAsBytes();
                                                  final length =
                                                      await photo.length();
                                                  final file = PlatformFile(
                                                    name: photo.name,
                                                    path: photo.path,
                                                    size: length,
                                                    bytes: bytes,
                                                  );
                                                  setState(() {
                                                    arrayFiles.add(file);
                                                  });
                                                }
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print(
                                                      "Checklist camera error: $e");
                                                }
                                              }
                                              return;
                                            } else if (source == 'gallery') {
                                              try {
                                                final ImagePicker picker =
                                                    ImagePicker();
                                                final List<XFile> photos =
                                                    await picker.pickMultiImage(
                                                        imageQuality: 85);
                                                if (photos.isNotEmpty) {
                                                  for (var photo in photos) {
                                                    final bytes = await photo
                                                        .readAsBytes();
                                                    final length =
                                                        await photo.length();
                                                    final file = PlatformFile(
                                                      name: photo.name,
                                                      path: photo.path,
                                                      size: length,
                                                      bytes: bytes,
                                                    );
                                                    setState(() {
                                                      arrayFiles.add(file);
                                                    });
                                                  }
                                                }
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print(
                                                      "Gallery picker error: $e");
                                                }
                                              }
                                              return;
                                            } else if (source == 'files') {
                                              FilePickerResult? result =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                allowMultiple: true,
                                                type: FileType.custom,
                                                allowedExtensions: [
                                                  'pdf',
                                                  'jpg',
                                                  'png',
                                                  'jpeg'
                                                ],
                                              );
                                              if (result != null) {
                                                setState(() {
                                                  arrayFiles
                                                      .addAll(result.files);
                                                });
                                              }
                                            }
                                          } else {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles(
                                              allowMultiple: true,
                                              type: FileType.custom,
                                              allowedExtensions: [
                                                'jpg',
                                                'pdf',
                                                'png',
                                                'jpeg'
                                              ],
                                            );
                                            if (result != null) {
                                              setState(() {
                                                arrayFiles
                                                    .addAll(result.files);
                                              });
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isMobile ? 12 : 16,
                                            vertical: isMobile ? 5 : 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            "+ Upload File",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isMobile ? 12 : 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Existing Submission Files Grid
                                  if (existingFiles.isNotEmpty) ...[
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        for (int i = 0;
                                            i < existingFiles.length;
                                            i++)
                                          _buildExistingFileTile(
                                            doc: existingFiles[i],
                                            isMobile: isMobile,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // Newly Added Files Grid
                                  if (arrayFiles.isNotEmpty) ...[
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        for (int i = 0;
                                            i < arrayFiles.length;
                                            i++)
                                          _buildNewFileTile(
                                            file: arrayFiles[i],
                                            index: i,
                                            isMobile: isMobile,
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
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
    );
  }

  Future<String?> _showMediaSourcePickerSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        final isMobile = context.isMobile;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "Attach Documents / Photos",
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Take Photo (Camera)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Capture a live photo using your camera",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('camera'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Choose Photos from Gallery",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Select photos from your device photo library",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('gallery'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.file_present_rounded, color: Colors.black87),
                  ),
                  title: const Text(
                    "Choose from Files (PDF / Documents)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Browse and select documents from device files",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('files'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExistingFileTile({
    required SubmissionFile doc,
    required bool isMobile,
  }) {
    final String docName = doc.fileName ?? 'File';
    final bool isPdf = (doc.extension?.toLowerCase() == 'pdf') ||
        docName.split('.').last.toLowerCase() == 'pdf';

    return Container(
      width: isMobile ? 130 : 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  if (doc.fileUrl != null && doc.fileUrl!.isNotEmpty) {
                    if (isPdf) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewer(
                            fileName: docName,
                            fileUrl: doc.fileUrl!,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImagePreviewViewer(
                            fileName: docName,
                            fileUrl: doc.fileUrl!,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: isPdf
                    ? Image.asset('images/projectmanagement/pdf.png',
                        height: 60, width: 60)
                    : (doc.fileUrl != null
                        ? Image.network(
                            doc.fileUrl!,
                            height: 60,
                            width: 60,
                            errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.insert_drive_file,
                                size: 50,
                                color: Colors.black45),
                          )
                        : const Icon(Icons.insert_drive_file,
                            size: 50, color: Colors.black45)),
              ),
              const SizedBox(height: 4),
              AppText(title: docName, fontSize: 11),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                deleteExistingFile(doc);
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewFileTile({
    required PlatformFile file,
    required int index,
    required bool isMobile,
  }) {
    final bool isPdf = file.extension?.toLowerCase() == 'pdf';

    return Container(
      width: isMobile ? 130 : 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe9ecef)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              isPdf
                  ? Image.asset('images/projectmanagement/pdf.png',
                      height: 60, width: 60)
                  : (file.path != null
                      ? Image.file(File(file.path!),
                          height: 60, width: 60, fit: BoxFit.cover)
                      : const Icon(Icons.insert_drive_file,
                          size: 50, color: Colors.black45)),
              const SizedBox(height: 4),
              AppText(title: file.name, fontSize: 11),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                setState(() {
                  arrayFiles.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
