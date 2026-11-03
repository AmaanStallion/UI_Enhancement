import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:stallion/models/get_project_list.dart';
import 'package:stallion/models/project_towar_list_modal.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/workprogess/workprogess_list.dart';
import 'package:stallion/ui/widgets/app_text.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/websocket/socket_service.dart';

class ProjectTowarList extends StatefulWidget {
  final String? projectId;
  final String? title;
  final String? projectImageUrl;
  // Modules pre-loaded from GET /projects/mobile — avoids extra /modules/assignable call
  final List<dynamic>? preloadedModules;

  const ProjectTowarList({
    super.key,
    this.projectId,
    this.title,
    this.projectImageUrl,
    this.preloadedModules,
  });

  @override
  State<ProjectTowarList> createState() => _ProjectTowarListState();
}

class _ProjectTowarListState extends State<ProjectTowarList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<ProjectDetails>? projectDetails = [];
  List<ProjectDetails>? _allTowerDetails = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrollable = false;
  bool _isLoading = true;
  String token = '';
  StreamSubscription? _towerStatusSubscription;

  NetworkHandler apiNetworkHandler = NetworkHandler();
  
  void _navigateToWorkProgressDirectly(int index) {
    var dateend = projectDetails![index].endDt;
    var arrDateEnd = dateend?.split(" ");
    var strActDays = arrDateEnd![0];
    DateTime tempDate = DateFormat("yyyy-MM-dd").parse(strActDays);
    tempDate.add(const Duration(days: 10));
    DateTime now = DateTime.now();
    
    if (tempDate.isAfter(now)) {
      var projectId = projectDetails![index].projectId!;
      var towarId = projectDetails![index].towarId!;
      var projectName = "";
      projectDetails![index].towarName! != ""
          ? projectName = projectDetails![index].projectName!
          : projectName = '${projectDetails![index].projectName!}, ${projectDetails![index].placeName!}';
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) {
            return WorkProgressList(
              projectId: projectId,
              towarId: towarId,
              projectName: projectName,
              towarName: projectDetails![index].towarName! != "" ? projectDetails![index].towarName! : "",
              consultantMagicLink: projectDetails![index].consultantMagicLink,
              contractorMagicLink: projectDetails![index].contractorMagicLink,
              vendMagicLink: projectDetails![index].vendMagicLink,
              preloadedModules: widget.preloadedModules,
            );
          },
        ),
      );
    } else {
      _showDeactivatedAlert(message: "You have not subscribed the membership. Please contact support team.");
    }
  }

  void _showDeactivatedAlert({String message = "This tower is deactivated by the admin."}) {
    Alert(
        closeIcon: const SizedBox(),
        padding: const EdgeInsets.only(top: 0.0),
        image: Image.asset('images/Icon-512.png',
            height: 80, fit: BoxFit.fitWidth),
        style: const AlertStyle(
            titleTextAlign: TextAlign.center,
            descTextAlign: TextAlign.center,
            descStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16),
            isCloseButton: true),
        context: context,
        desc: message,
        alertAnimation: fadeAlertAnimation,
        buttons: [
          DialogButton(
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.black,
            child: const Text(
              "CLOSE",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15),
            ),
          ),
        ]).show();
  }

  Future<getprojectlistResponse?> fetchProjectDetails() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      // Inside project context — use projectToken for image display
      token = prefs.getString('projectToken') ?? prefs.getString('masterToken') ?? prefs.getString('token') ?? "";
      _isLoading = true;
    });

    if (AppUrl.useNewBackend) {
      var response = await apiNetworkHandler.get("${AppUrl.baseURL}towers?project_id=${widget.projectId}");
      if (kDebugMode) {
        print("TOWERS STATUS: ${response?.statusCode}");
        print("TOWERS BODY: ${response?.body}");
      }
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          List<ProjectDetails> tempDetails = [];
          final list = decoded['data'] as List;
          for (var item in list) {
            final String tId = item['id']?.toString() ?? "";
            final bool isTActive = item['is_active'] == true || item['is_active']?.toString() == 'true' || item['isActive'] == true || item['isActive']?.toString() == 'true';
            if (tId.isNotEmpty) {
              SocketService.setTowerActive(tId, isTActive);
            }
            tempDetails.add(ProjectDetails(
              projectId: widget.projectId ?? "",
              towarId: tId,
              towarName: item['name'] ?? "",
              projectName: widget.title ?? "",
              placeName: item['location'] ?? item['place_name'] ?? "",
              projectImgName: item['tower_image_url'] ?? "",
              towerFlag: "0",
              endDt: "2030-12-31 00:00:00",
              isAdmin: "0",
              projectIssue: "",
            ));
          }
          _searchController.clear();
          _allTowerDetails = tempDetails.reversed.toList();
          setState(() {
            projectDetails = _allTowerDetails;
            _isLoading = false;
          });

          // Check if single tower is deactivated before auto-navigation
          if (projectDetails!.length == 1 && mounted) {
            final singleTower = projectDetails![0];
            final bool isTowerActive = SocketService.isTowerActive(singleTower.towarId ?? "");
            if (isTowerActive) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _navigateToWorkProgressDirectly(0);
                }
              });
            } else {
              // Show the dismissible warning since the only tower is deactivated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _showDeactivatedAlert();
                }
              });
            }
          }
          _checkScrollability();
          return null;
        }
      }
      setState(() {
        _isLoading = false;
      });
      return null;
    }

    Map<String, String> data = {
      "project_id": widget.projectId ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getTowerListByProjectiId, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = projectTowarListModalFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        _searchController.clear();
        _allTowerDetails = dataModel.response?.towerList;
        setState(() {
          projectDetails = _allTowerDetails;
          _isLoading = false;
        });
        if (projectDetails!.length == 1 && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _navigateToWorkProgressDirectly(0);
            }
          });
        }
        _checkScrollability();
      } else if (dataModel.response?.errorCode == "1") {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchProjectDetails();
    });
    _towerStatusSubscription = SocketService.towerStatusStream.listen((event) {
      if (mounted) {
        setState(() {}); // Trigger refresh on tower status changes
      }
    });
  }

  @override
  void dispose() {
    _towerStatusSubscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterTowers(String query) {
    if (query.isEmpty) {
      projectDetails = _allTowerDetails;
    } else {
      projectDetails = _allTowerDetails?.where((tower) {
        final name = tower.projectName?.toLowerCase() ?? '';
        final towerName = tower.towarName?.toLowerCase() ?? '';
        final place = tower.placeName?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) ||
            towerName.contains(searchLower) ||
            place.contains(searchLower);
      }).toList();
    }
    setState(() {});
    _checkScrollability();
  }

  void _checkScrollability() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        final isScrollable = _scrollController.position.maxScrollExtent > 0;
        if (_isScrollable != isScrollable) {
          setState(() {
            _isScrollable = isScrollable;
          });
        }
      }
    });
  }

  Widget _buildGlassSearchBar() {
    final isMobile = context.isMobile;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 450),
      margin: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.12),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTowers,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search towers...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _filterTowers('');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _getColumns() {
    final mediaQuery = MediaQuery.of(context);
    final double shortestSide = mediaQuery.size.shortestSide;
    if (shortestSide < 600) {
      return mediaQuery.orientation == Orientation.portrait ? 2 : 3;
    } else {
      return mediaQuery.orientation == Orientation.portrait ? 3 : 4;
    }
  }

  double _getCrossAxisSpacing(double itemWidth) {
    final mediaQuery = MediaQuery.of(context);
    final double shortestSide = mediaQuery.size.shortestSide;
    if (shortestSide < 600) {
      return 10.0; // Mobile inner gap 10
    } else {
      return 100.0; // Tablet inner gap 100
    }
  }

  double _getAspectRatio(double itemWidth) {
    final double cardHeight = itemWidth * 1.25 + 90;
    return itemWidth / cardHeight;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double itemWidth;
    final double containerWidth;
    if (isMobile) {
      final mediaQuery = MediaQuery.of(context);
      final double screenWidth = mediaQuery.size.width;
      final double shortestSide = mediaQuery.size.shortestSide;
      if (shortestSide < 600) {
        itemWidth = 175.0; // Mobile card width 175
        containerWidth = screenWidth - 32; // 16px side gaps
      } else {
        itemWidth = 180.0; // Tablet card width 180
        containerWidth = screenWidth - 32; // 16px side gaps
      }
    } else {
      itemWidth = 160.0;
      containerWidth = double.infinity;
    }

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(widget.title ?? '',
              style:
                  const TextStyle(fontStyle: FontStyle.normal, fontSize: 17.0)),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                top: !isMobile ? false : true,
                child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                padding: isMobile
                    ? EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 96.0 + MediaQuery.of(context).viewInsets.bottom,
                      )
                    : EdgeInsets.only(
                        left: 12.0,
                        right: 12.0,
                        top: 80.0,
                        bottom: 96.0 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                child: Column(
                  children: [
                    if (isMobile)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        width: double.maxFinite,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Colors.grey,
                        ))),
                        child: const AppText(
                          title: 'Tower List',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          titleTextAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? _buildTowerListSkeleton(isMobile, itemWidth)
                        : projectDetails!.isEmpty
                            ? _searchController.text.isNotEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "No towers match your search",
                                            style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton(
                                            onPressed: () {
                                              _searchController.clear();
                                              _filterTowers('');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text("Clear Search"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "No towers have been added to this project yet.",
                                            style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => WorkProgressList(
                                                    projectId: widget.projectId ?? "",
                                                    towarId: "",
                                                    projectName: widget.title ?? "",
                                                    towarName: "",
                                                    consultantMagicLink: "",
                                                    contractorMagicLink: "",
                                                    vendMagicLink: "",
                                                    preloadedModules: widget.preloadedModules,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.arrow_forward),
                                            label: const Text("Go to Work Progress / Permissions"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                            : isMobile
                                ? Center(
                                    child: SizedBox(
                                      width: containerWidth,
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: _getColumns(),
                                          crossAxisSpacing: _getCrossAxisSpacing(itemWidth),
                                          mainAxisSpacing: 20.0,
                                          childAspectRatio: _getAspectRatio(itemWidth),
                                        ),
                                        itemCount: projectDetails!.length,
                                        itemBuilder: (context, index) => Center(
                                          child: _buildTowerCard(index, itemWidth),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: SizedBox(
                                      width: containerWidth,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 12.0,
                                        runSpacing: 20.0,
                                        children: List.generate(projectDetails!.length, (index) {
                                          return _buildTowerCard(index, itemWidth);
                                        }),
                                      ),
                                    ),
                                  ),
                  ],
                ),
              ),
            ),
          ),
            if (!isMobile) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                    color: Colors.grey,
                  ))),
                  child: const AppText(
                    title: 'Tower List',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    titleTextAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            Positioned(
              left: isMobile ? 16 : 24,
              right: isMobile ? 16 : 24,
              bottom: MediaQuery.of(context).padding.bottom +
                  MediaQuery.of(context).viewInsets.bottom +
                  16,
              child: Center(child: _buildGlassSearchBar()),
            ),
            if (_isLoading)
              Center(
                child: SizedBox(
                  height: 64,
                  child: OverflowBox(
                    minHeight: 100,
                    maxHeight: 100,
                    child: Lottie.asset(
                      'assets/animation/running2.json',
                      repeat: true,
                    ),
                  ),
                ),
              ),
          ],
        ));
  }

  Widget _buildTowerCard(int index, double itemWidth) {
    String? imageUrlToShow = projectDetails![index].projectImgName;
    if (index == 0 && (imageUrlToShow == null || imageUrlToShow.isEmpty)) {
      if (AppUrl.useNewBackend) {
        imageUrlToShow = "${AppUrl.baseURL}projects/${widget.projectId}/image";
      } else {
        imageUrlToShow = widget.projectImageUrl;
      }
    }
    final String tId = projectDetails![index].towarId ?? "";
    final bool isDeactivated = !SocketService.isTowerActive(tId);
    final Color imageBgColor = isDeactivated ? const Color(0xFFE0E0E0) : Colors.white;
    return GestureDetector(
      onTap: () {
        final tower = projectDetails![index];
        final String tId = tower.towarId ?? "";
        final bool isTowerActive = SocketService.isTowerActive(tId);
        if (!isTowerActive) {
          _showDeactivatedAlert(message: "This tower is deactivated by the admin.");
          return;
        }

        var dateend = projectDetails![index].endDt;
        var arrDateEnd = dateend?.split(" ");
        var strActDays = arrDateEnd![0];
        DateTime tempDate =
            DateFormat("yyyy-MM-dd").parse(strActDays);
        if (kDebugMode) {
          print(tempDate);
        }
        var datenow = DateTime.now();
        var difference = tempDate.difference(datenow).inDays;
        if (kDebugMode) {
          print(difference);
        }
        if (difference > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkProgressList(
                projectId: widget.projectId ?? "",
                towarId: projectDetails![index].towarId ?? "",
                projectName: widget.title ?? "",
                towarName: projectDetails![index].towarName ?? "",
                consultantMagicLink: "",
                contractorMagicLink: "",
                vendMagicLink: "",
                preloadedModules: widget.preloadedModules,
              ),
            ),
          );
        } else {
          Alert(
              context: context,
              title: "Alert",
              desc: "Project has expired",
              buttons: [
                DialogButton(
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  color: Colors.black,
                  child: const Text(
                    "CLOSE",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15),
                  ),
                ),
              ]).show();
        }
      },
      child: SizedBox(
        width: itemWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (imageUrlToShow == null || imageUrlToShow.isEmpty)
                ? Container(
                    width: itemWidth,
                    height: itemWidth * 1.25,
                    decoration: BoxDecoration(
                      color: imageBgColor,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(8)),
                      image: DecorationImage(
                        image: const AssetImage('images/default_building.png'),
                        fit: BoxFit.fill,
                        colorFilter: isDeactivated
                            ? const ColorFilter.mode(Color(0xFFD0D0D0), BlendMode.multiply)
                            : null,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    height: itemWidth * 1.25,
                    imageUrl: AppUrl.useNewBackend
                        ? imageUrlToShow!
                        : (AppUrl.getProjectImageUrl +
                            imageUrlToShow!),
                    httpHeaders: AppUrl.useNewBackend &&
                            token != "" &&
                            imageUrlToShow!.contains(AppUrl.baseURL)
                        ? {
                            "Authorization": "Bearer $token"
                          }
                        : null,
                    placeholder: (context, url) =>
                        Shimmer.fromColors(
                      baseColor: const Color(0xFFF0F0F0),
                      highlightColor: const Color(0xFFF9F9F9),
                      child: Container(
                        height: itemWidth * 1.25,
                        decoration: BoxDecoration(
                          color: imageBgColor,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    imageBuilder:
                        (context, imageProvider) =>
                            Container(
                      width: itemWidth,
                      height: itemWidth * 1.25,
                      decoration: BoxDecoration(
                        color: imageBgColor,
                        borderRadius:
                            const BorderRadius.all(
                                Radius.circular(8)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                          colorFilter: isDeactivated
                              ? const ColorFilter.mode(Color(0xFFD0D0D0), BlendMode.multiply)
                              : null,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        Container(
                      width: itemWidth,
                      height: itemWidth * 1.25,
                      decoration: BoxDecoration(
                        color: imageBgColor,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(8)),
                        image: DecorationImage(
                          image: const AssetImage('images/default_building.png'),
                          fit: BoxFit.fill,
                          colorFilter: isDeactivated
                              ? const ColorFilter.mode(Color(0xFFD0D0D0), BlendMode.multiply)
                              : null,
                        ),
                      ),
                    ),
                  ),
            verticalSpaceSmall,
            Text(
                projectDetails![index].projectName!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
            verticalSpaceTiny,
            projectDetails![index].towarName! != ""
                ? Text(
                    projectDetails![index].towarName!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black87))
                : const SizedBox(),
            projectDetails![index].towarName! != ""
                ? verticalSpaceTiny
                : const SizedBox(),
            Text(
                projectDetails![index].placeName!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            verticalSpaceSmall,
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonTowerCard(double itemWidth) {
    return SizedBox(
      width: itemWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: itemWidth * 1.25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: itemWidth * 0.7,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: itemWidth * 0.5,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: itemWidth * 0.6,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTowerListSkeleton(bool isMobile, double itemWidth) {
    final double containerWidth;
    if (isMobile) {
      final mediaQuery = MediaQuery.of(context);
      final double screenWidth = mediaQuery.size.width;
      containerWidth = screenWidth - 32;
    } else {
      containerWidth = double.infinity;
    }

    return Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFF9F9F9),
      period: const Duration(milliseconds: 1500),
      child: isMobile
          ? Center(
              child: SizedBox(
                width: containerWidth,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getColumns(),
                    crossAxisSpacing: _getCrossAxisSpacing(itemWidth),
                    mainAxisSpacing: 20.0,
                    childAspectRatio: _getAspectRatio(itemWidth),
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => Center(
                    child: _buildSkeletonTowerCard(itemWidth),
                  ),
                ),
              ),
            )
          : Center(
              child: SizedBox(
                width: containerWidth,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12.0,
                  runSpacing: 20.0,
                  children: List.generate(4, (index) {
                    return _buildSkeletonTowerCard(itemWidth);
                  }),
                ),
              ),
            ),
    );
  }
}
