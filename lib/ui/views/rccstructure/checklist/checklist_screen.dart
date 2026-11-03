import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/rcc_checklist_api_models.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/mycontracts/imagepreviewview.dart';
import 'package:stallion/ui/views/rccstructure/checklist/create_new_checklisr_screen.dart';
import 'package:stallion/ui/views/rccstructure/pdfviewer.dart';
import 'package:stallion/ui/views/rccstructure/rcc_skeleton_loader.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'create_check_listscreen.dart';

class CheckListScreen extends StatefulWidget {
  const CheckListScreen({super.key});

  @override
  State<CheckListScreen> createState() => _CheckListScreenState();
}

class _CheckListScreenState extends State<CheckListScreen> {
  NotificationArgs? args;
  NetworkHandler apiNetworkHandler = NetworkHandler();
  bool isLoading = true;
  bool _isInit = true;
  List<SlabSubmissionEntry>? submissionsList;
  DeveloperInfo? developerInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is NotificationArgs) {
        args = routeArgs;
      }
      getCheckStatus();
      _isInit = false;
    }
  }

  Future<void> getCheckStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String? projectId = args?.projectId;
      if (projectId != null && projectId.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(projectId);
      }

      final String slabId = args?.response?.slabId ?? '';
      if (slabId.isNotEmpty) {
        final String url = AppUrl.getSlabSubmissions(slabId);
        var response = await apiNetworkHandler.get(url);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final resData = slabSubmissionsResponseFromJson(response.body);
          if (resData.success && resData.data != null) {
            submissionsList = resData.data!.data;
            developerInfo = resData.data!.developer;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Get Slab Submissions Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String getSubHeaderTitle() {
    final slabTitle = args?.response?.slabNo?.trim().toUpperCase() ?? '';
    if (slabTitle.isNotEmpty) {
      return '$slabTitle - RCC CHECKLIST';
    }
    return 'RCC CHECKLIST';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final String projectName = args?.projectName ?? '';
    final String towerName = args?.towarName ?? '';
    final String appBarTitle = towerName.isNotEmpty
        ? '${projectName.toUpperCase()} - ${towerName.toUpperCase()}'
        : projectName.toUpperCase();

    final double btnHeaderWidth = isMobile ? 125.0 : 145.0;

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
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 10.0 : 16.0),
          child: InkWell(
            onTap: () {
              var projectId = args?.projectId ?? '';
              var pName = args?.projectName ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return CreateNewCheckList(
                      projectId: projectId,
                      towarId: args?.towarIdFk ?? args?.response?.towarId ?? '',
                      projectName: pName,
                      towarName: args?.towarName ?? '',
                      title: args?.response?.slabNo ?? '',
                      slabId: args?.response?.slabId ?? '',
                      restrictChecklistCategory: args?.response?.restrictChecklistCategory,
                    );
                  },
                ),
              ).then((value) => getCheckStatus());
            },
            child: Container(
              height: isMobile ? 44 : 48,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "CREATE CHECKLIST",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SubHeader Section (Centered slab name - RCC CHECKLIST with balance spacing)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 6 : 8,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(width: btnHeaderWidth),
                  Expanded(
                    child: Text(
                      getSubHeaderTitle(),
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      final String slabId = args?.response?.slabId ?? '';
                      if (slabId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewer(
                              fileName: "Detailed_Checklist.pdf",
                              fileUrl: AppUrl.getRccChecklistsPdf(slabId),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: btnHeaderWidth,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 5 : 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Detailed Checklist",
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
            ),
            const Divider(height: 1.0, color: Colors.black12),

            // Content Body / Skeleton Loader
            Expanded(
              child: isLoading
                  ? ChecklistSkeletonScreen(isMobile: isMobile)
                  : (submissionsList != null && submissionsList!.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12.0 : 20.0,
                            vertical: isMobile ? 12.0 : 16.0,
                          ),
                          itemCount: submissionsList!.length,
                          itemBuilder: (context, index) {
                            final item = submissionsList![index];
                            return _buildChecklistCard(
                              context: context,
                              item: item,
                              index: index,
                              isMobile: isMobile,
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            "No Submissions Found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required bool isMobile,
    bool isFilledBlack = false,
  }) {
    final double btnWidth = isMobile ? 85.0 : 105.0;
    final double btnHeight = isMobile ? 24.0 : 34.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: btnWidth,
        height: btnHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFilledBlack ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isFilledBlack ? Colors.white : Colors.black,
            fontSize: isMobile ? 11 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistCard({
    required BuildContext context,
    required SlabSubmissionEntry item,
    required int index,
    required bool isMobile,
  }) {
    final double labelWidth = isMobile ? 95.0 : 115.0;

    final String userName =
        item.createdByUser?.name ?? developerInfo?.name ?? 'User';
    final String companyName = developerInfo?.companyName ?? '';
    final DateTime displayDate =
        item.submittedAt ?? item.createdAt ?? DateTime.now();
    final String dateStr = DateFormat('dd/MM/yyyy').format(displayDate);

    final String categoriesStr = item.data?.categories
            .map((c) => c.name)
            .where((n) => n.isNotEmpty)
            .join(", ") ??
        '';

    String notesStr = '-';
    if (item.remarks != null && item.remarks!.trim().isNotEmpty) {
      notesStr = item.remarks!.trim();
    }

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: isMobile ? 10.0 : 14.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xffe9ecef)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Submitted By / Edited By + RCC Checklist Label
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(
                    !item.isSubmitted ? "Edited By" : "Submitted By",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(" - ",
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "(RCC Checklist)",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: isMobile ? 11 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 2. Company + Action Button ("View Pdf" / "Edit")
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(
                    "Company",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(" - ",
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    companyName.isNotEmpty ? companyName : '-',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  label: item.isSubmitted ? "View Pdf" : "Edit",
                  isMobile: isMobile,
                  isFilledBlack: !item.isSubmitted,
                  onTap: () {
                    if (item.isSubmitted) {
                      if (item.fileUrl != null && item.fileUrl!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewer(
                              fileName: item.fileName ?? "Submission.pdf",
                              fileUrl: item.fileUrl!,
                            ),
                          ),
                        );
                      }
                    } else {
                      var projectId = args?.projectId ?? '';
                      var projectName = args?.projectName ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateCheckList(
                            projectId: projectId,
                            towarId: args?.towarIdFk ?? args?.response?.towarId ?? '',
                            projectName: projectName,
                            towarName: args?.towarName ?? '',
                            title: args?.response?.slabNo ?? '',
                            slabId: args?.response?.slabId ?? '',
                            submissionEntry: item,
                            restrictChecklistCategory: args?.response?.restrictChecklistCategory,
                          ),
                        ),
                      ).then((value) => getCheckStatus());
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 3. Date + Action Button ("View Docs")
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(
                    "Date",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(" - ",
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.files.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(
                    label: "View Docs",
                    isMobile: isMobile,
                    onTap: () {
                      viewDocs(files: item.files);
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // 4. Categories (up to 3 lines)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(" - ",
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    categoriesStr.isNotEmpty ? categoriesStr : '-',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 5. Notes (Remarks text, up to 3 lines)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Text(
                    "Notes",
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(" - ",
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    notesStr,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  viewDocs({required List<SubmissionFile> files}) {
    final isMobile = context.isMobile;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              actionsPadding:
                  const EdgeInsets.only(bottom: 14, left: 16, right: 16),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              actionsAlignment: MainAxisAlignment.center,
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: const Text(
                  "View Documents",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "OKAY",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              content: SizedBox(
                height: 320,
                width: isMobile ? double.maxFinite : 440,
                child: SingleChildScrollView(
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (int i = 0; i < files.length; i++)
                        (files[i].extension?.toLowerCase() == 'pdf' ||
                                (files[i].fileName?.endsWith('.pdf') ?? false))
                            ? InkWell(
                                onTap: () {
                                  if (files[i].fileUrl != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewer(
                                          fileName: files[i].fileName ?? "Doc.pdf",
                                          fileUrl: files[i].fileUrl!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xffe9ecef),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xfff8f9fa),
                                  ),
                                  width: isMobile ? 120 : 140,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'images/projectmanagement/pdf.png',
                                        width: 80,
                                        height: 80,
                                      ),
                                      const SizedBox(height: 6),
                                      AppText(
                                        title: files[i].fileName ?? '',
                                        fontSize: 12,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  if (files[i].fileUrl != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ImagePreviewViewer(
                                          fileName: files[i].fileName ?? '',
                                          fileUrl: files[i].fileUrl!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xffe9ecef),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xfff8f9fa),
                                  ),
                                  width: isMobile ? 120 : 140,
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    children: [
                                      Image.network(
                                        files[i].fileUrl ?? '',
                                        width: 80,
                                        height: 80,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.insert_drive_file,
                                          size: 60,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      AppText(
                                        title: files[i].fileName ?? '',
                                        fontSize: 12,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
