import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/models/sop_category_model.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/ui/views/sopModule/sop_details.dart';
import 'package:stallion/ui/views/sopModule/sop_docs.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

class SopScreen extends StatefulWidget {
  const SopScreen({super.key});

  @override
  State<SopScreen> createState() => _SopScreenState();
}

class _SopScreenState extends State<SopScreen> {
  late NotificationArgs args;
  final NetworkHandler apiNetworkHandler = NetworkHandler();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as NotificationArgs;
  }

  static const bool testWithMockData = false;
  bool _isLoading = true;
  List<DevSopCategory>? sopCategories = [];

  Future<void> fetchSopList() async {
    setState(() {
      _isLoading = true;
    });

    if (testWithMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        sopCategories = [
          DevSopCategory(
            id: "16",
            name: "Demolition",
            totalCount: 10,
            pendingCount: 10,
            completedCount: 0,
          ),
          DevSopCategory(
            id: "17",
            name: "Excavation",
            totalCount: 15,
            pendingCount: 15,
            completedCount: 0,
          ),
          DevSopCategory(
            id: "18",
            name: "Foundation",
            totalCount: 8,
            pendingCount: 8,
            completedCount: 0,
          ),
        ];
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Fetch categories with tower_id
      String towerId = args.response?.towarId ?? '';
      String catUrl = AppUrl.devSopCategories;
      if (towerId.isNotEmpty) {
        catUrl = "$catUrl?tower_id=$towerId";
      }

      var catResponse = await apiNetworkHandler.get(catUrl);
      if (catResponse != null && (catResponse.statusCode == 200 || catResponse.statusCode == 201)) {
        final catDataModel = devSopCategoryResponseFromJson(catResponse.body);
        List<DevSopCategory> loadedCategories = catDataModel.data ?? [];
        loadedCategories = loadedCategories.where((c) => c.isEnabled != false).toList();

        setState(() {
          sopCategories = loadedCategories;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching SOP categories: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSopList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
            args.towarName!.isNotEmpty == true
                ? '${args.projectName!.toUpperCase()} - ${args.towarName!.toUpperCase()}'
                : args.projectName!.toUpperCase(),
            style:
                const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: _isLoading
          ? CustomLoading.buildSopListSkeletonInline(context)
          : Column(
              children: [
          const SizedBox(
            height: 30,
            child: Center(
              child: Text('S.O.P',
                  style: TextStyle(
                    fontFamily: 'HelveticaNeue',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center),
            ),
          ),
          const Divider(
            height: 1.0,
            color: Colors.black,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffe9ecef),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xffdee2e6), width: 1.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Category',
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                ),
                Expanded(
                  child: Text('Pending / Total',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                ),
                Expanded(
                  child: Text('Action',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sopCategories?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final category = sopCategories![index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 60, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xffe9ecef), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return SopDetails(
                              projectId: args.projectId,
                              towarId: args.response?.towarId ?? '',
                              projectName: args.projectName,
                              towarName: args.towarName ?? '',
                              sopId: category.id,
                              title: category.name,
                              assingToId: "",
                            );
                          },
                        ),
                      ).then((value) => fetchSopList());
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(category.name ?? '',
                                style: TextStyle(
                                  fontFamily: 'HelveticaNeue',
                                  fontSize: isMobile ? 13 : 15,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                          Expanded(
                            child: Text(
                                '${category.pendingCount} / ${category.totalCount}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'HelveticaNeue',
                                  fontSize: isMobile ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                          Expanded(
                            child: category.logsPresent
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return SopDocsScreen(
                                                projectId: args.projectId,
                                                towarId: args.response?.towarId ?? '',
                                                projectName: args.projectName,
                                                towarName: args.towarName ?? '',
                                                title: category.name,
                                                sopId: category.id,
                                              );
                                            },
                                          ),
                                        ).then((value) => fetchSopList());
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 4),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black),
                                            borderRadius: BorderRadius.circular(8)),
                                        child: Text(
                                          "View Pdf",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'HelveticaNeue',
                                            fontSize: isMobile ? 11 : 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
