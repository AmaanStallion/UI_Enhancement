import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/dashboard/project_towar_list.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
import 'package:stallion/utils/api_network_call.dart';
import '../../../models/get_project_list.dart';
import '../../../utils/app_url.dart';
import '../../../utils/responsive.dart';
import '../workprogess/workprogess_list.dart';
import 'package:stallion/websocket/socket_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class ProjectListScreenView extends StatefulWidget {
  const ProjectListScreenView(
      {Key? key, this.callback, this.projectId, this.towarId, this.projectName})
      : super(key: key);

  final Function? callback;
  //final Function(String screen, String projId, String projName) updateScreen;
  final String? projectId;
  final String? towarId;
  final String? projectName;

  @override
  State<ProjectListScreenView> createState() => _ProjectListScreenViewState();
}

class _ProjectListScreenViewState extends State<ProjectListScreenView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NetworkHandler apiNetworkHandler = NetworkHandler();
  bool flagcalled = false;
  bool norecord = false;
  bool flagDeveloperConsultant = false; //Developer
  List<ProjectDetails>? projectDetails = [];
  List<ProjectDetails>? _allProjectDetails = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrollable = false;
  int? groupValue = 0;

  String? accountManagement;
  String? mycontract;
  String? statusofsupply;
  String? orderhistory;
  String? loginType = '';
  String? consultant;
  String? developer;
  String? contractor;
  String? masterDashboardFlag;

  String? groupFlag = '0';

  String? username = '';
  String? acquisitionTab = '';

  String? designation = '';
  String? userprofile = '';
  String token = '';

  final Map<String, List<dynamic>> _projectModulesCache = {};
  bool _isSwitchingProject = false;
  List<ProjectDetails> _masterProjects = [];

  void _filterProjectsByRole() {
    if (!AppUrl.useNewBackend) return;

    String targetRole = 'user';
    if (loginType == 'consultant') {
      targetRole = 'consultant_emp';
    } else if (loginType == 'contractor') {
      targetRole = 'contractor_emp';
    } else {
      targetRole = 'user';
    }

    _allProjectDetails = _masterProjects.where((p) {
      if (targetRole == 'user') {
        return p.role == 'user' || p.role == null || p.role!.isEmpty;
      }
      return p.role == targetRole;
    }).toList();

    projectDetails = _allProjectDetails;
    norecord = projectDetails!.isEmpty;
  }

  void _updateGroupValueFromLoginType() {
    if (developer == '1' && consultant == '1' && contractor == '1') {
      if (loginType == 'consultant') {
        groupValue = 1;
      } else if (loginType == 'contractor') {
        groupValue = 2;
      } else {
        groupValue = 0;
      }
    } else if (developer == '1' && consultant == '1') {
      if (loginType == 'consultant') {
        groupValue = 1;
      } else {
        groupValue = 0;
      }
    } else if (developer == '1' && contractor == '1') {
      if (loginType == 'contractor') {
        groupValue = 1;
      } else {
        groupValue = 0;
      }
    } else if (consultant == '1' && contractor == '1') {
      if (loginType == 'contractor') {
        groupValue = 1;
      } else {
        groupValue = 0;
      }
    } else {
      groupValue = 0;
    }
  }

  Future<getprojectlistResponse?> fetchProjectDetails() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');
    String? loginTypePref = prefs.getString('loginType');
    // Image display uses master token (project list is always master-token context)
    token = prefs.getString('masterToken') ?? prefs.getString('token') ?? "";

    if (AppUrl.useNewBackend) {
      // Use GET /projects/mobile — returns all projects across all developers
      // with modules[] pre-loaded per project. Always called with master token.
      final prefs = await _prefs;
      await prefs.remove('projectToken');

      var response = await apiNetworkHandler.getWithMasterToken(AppUrl.getMobileProjectList);
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          // Response shape: { data: { total_projects, projects: [...] } }
          final data = decoded['data'];
          final list = (data is Map ? data['projects'] : data) as List? ?? [];
          List<ProjectDetails> tempDetails = [];

          // Clear module cache before repopulating
          _projectModulesCache.clear();

          for (var item in list) {
            final projectId = item['id']?.toString() ?? "";
            final String roleStr = item['role']?.toString() ?? item['role in this project']?.toString() ?? "user";
            final List<dynamic> itemModules = item['modules'] is List ? List<dynamic>.from(item['modules']) : [];

            // Cache modules[] using composite key `${projectId}_$roleStr` to avoid role collisions
            _projectModulesCache["${projectId}_$roleStr"] = itemModules;
            _projectModulesCache[projectId] = itemModules;

            final bool isExactlyOneTower = item['exactlyOneTower'] == true || item['exactlyOneTower']?.toString() == 'true';

            final projectItem = ProjectDetails(
              projectId: projectId,
              projectName: item['name'] ?? "",
              placeName: item['location'] ?? "",
              // project_image_url is a relative path — prefix with baseURL
              projectImgName: item['project_image_url'] != null && (item['project_image_url'] as String).isNotEmpty
                  ? (item['project_image_url'] as String).startsWith('http')
                      ? item['project_image_url']
                      : "${AppUrl.newBaseURL.replaceAll(RegExp(r'/$'), '')}${item['project_image_url']}"
                  : "",
              towerFlag: isExactlyOneTower ? "0" : "1",
              exactlyOneTower: isExactlyOneTower,
              role: roleStr,
              modules: itemModules,
              endDt: "2030-12-31 00:00:00",
              towarId: "",
              towarName: "",
              isAdmin: "0",
              projectIssue: "",
              applyDwg: item['apply_dwg'] == true || item['apply_dwg']?.toString() == 'true',
            );
            tempDetails.add(projectItem);
          }

          _masterProjects = tempDetails.reversed.toList();

          bool hasDeveloper = _masterProjects.any((p) => p.role == 'user' || p.role == 'developer' || p.role == null || p.role!.isEmpty);
          bool hasConsultant = _masterProjects.any((p) => p.role == 'consultant_emp' || p.role == 'consultant');
          bool hasContractor = _masterProjects.any((p) => p.role == 'contractor_emp' || p.role == 'contractor');

          developer = hasDeveloper ? "1" : "0";
          consultant = hasConsultant ? "1" : "0";
          contractor = hasContractor ? "1" : "0";

          int totalRoles = (hasDeveloper ? 1 : 0) + (hasConsultant ? 1 : 0) + (hasContractor ? 1 : 0);
          flagDeveloperConsultant = totalRoles > 1;

          String savedRole = loginTypePref ?? 'developer';
          if (savedRole == 'developer' && hasDeveloper) {
            loginType = 'developer';
          } else if (savedRole == 'consultant' && hasConsultant) {
            loginType = 'consultant';
          } else if (savedRole == 'contractor' && hasContractor) {
            loginType = 'contractor';
          } else {
            if (hasDeveloper) loginType = 'developer';
            else if (hasConsultant) loginType = 'consultant';
            else if (hasContractor) loginType = 'contractor';
            else loginType = 'developer';
          }

          _updateGroupValueFromLoginType();
          _filterProjectsByRole();

          _searchController.clear();
          mycontract = "0";
          groupFlag = "0";
          statusofsupply = "0";
          accountManagement = "0";
          orderhistory = "0";
          masterDashboardFlag = "0";

          prefs.setString('loginType', loginType!);

          setState(() {
            norecord = projectDetails!.isEmpty;
            flagcalled = true;
          });
          _checkScrollability();
          return null;
        }
      }
      setState(() {
        flagcalled = true;
        norecord = true;
      });
      return null;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "device_name": 'IOS',
      "device_id": '',
      "login_type": loginTypePref ?? '',
    };

    if (kDebugMode) {
      print(data);
    }

    var response =
        await apiNetworkHandler.post(AppUrl.getProjectListRequest, data);
    if (kDebugMode) {
      print(response.statusCode);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = getprojectlistFromJson(response.body);
      if (kDebugMode) {
        print(dataModel.response?.errorCode);
      }
      if (dataModel.response?.errorCode == "0") {
        _searchController.clear();
        _allProjectDetails = dataModel.response?.projectDetails;
        projectDetails = _allProjectDetails;
        mycontract = dataModel.response?.contractorActive;
        groupFlag = dataModel.response?.groupFlag;
        statusofsupply = dataModel.response?.supplierActive;
        accountManagement = dataModel.response?.accountMagActive;
        orderhistory = dataModel.response?.orderHistoryTabActive;
        consultant = dataModel.response?.is_consultant;
        developer = dataModel.response?.is_developer;
        contractor = dataModel.response?.is_contractor;
        masterDashboardFlag = dataModel.response?.masterDashboardFlag;
        if (dataModel.response!.userDetails!.isNotEmpty) {
          username = dataModel.response?.userDetails?[0].userName;
          acquisitionTab = dataModel.response?.acquisitionTab;
          userprofile = dataModel.response?.userDetails?[0].userProfile;
          designation = dataModel.response?.userDetails?[0].desingnation;
        }
        if (developer == '1' && consultant == '1' && contractor == '1') {
          flagDeveloperConsultant = true;
          if (loginType == '') {
            prefs.setString('loginType', 'developer');
          }
        } else if (developer == '1' && consultant == '1') {
          flagDeveloperConsultant = true;
          if (loginType == '') {
            prefs.setString('loginType', 'developer');
          }
        } else if (developer == '1' && contractor == '1') {
          flagDeveloperConsultant = true;
          if (loginType == '') {
            prefs.setString('loginType', 'developer');
          }
        } else if (consultant == '1' && contractor == '1') {
          flagDeveloperConsultant = true;
          if (loginType == '') {
            prefs.setString('loginType', 'consultant');
          }
        } else {
          if (developer == '1') {
            prefs.setString('loginType', 'developer');
          } else if (consultant == '1') {
            prefs.setString('loginType', 'consultant');
          } else if (contractor == '1') {
            prefs.setString('loginType', 'contractor');
          }
          flagDeveloperConsultant = false;
        }
        updateForDeveloperConsultant();
        setState(() {
          norecord = false;
          flagcalled = true;
        });
        _checkScrollability();
      } else if (dataModel.response?.errorCode == "1") {
        setState(() {
          flagcalled = true;
          norecord = true;
        });
      }
    }
    return null;
  }

  Widget _error(BuildContext context, String url, dynamic error) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        image: DecorationImage(
          image: AssetImage('images/default_building.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  String? version = '';
  String? storeVersion = '';
  String? storeUrl = '';
  String? packageName = '';
  StreamSubscription? _towerStatusSubscription;

  @override
  void initState() {
    super.initState();
    fetchProjectDetails();
    _towerStatusSubscription = SocketService.towerStatusStream.listen((event) {
      if (mounted) {
        setState(() {}); // Trigger refresh when a tower status changes
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

  // Future checkVersion() async {
  //   final versionCheck = VersionCheck(
  //     packageName: Platform.isMacOS
  //         ? 'com.stallionbuildllp.stallion'
  //         : 'com.stallionbuildllp.stallion',
  //     packageVersion: '2.3.7',
  //     showUpdateDialog: customShowUpdateDialog,
  //     country: 'in',
  //   );

  //   await versionCheck.checkVersion(context);
  //   setState(() {
  //     version = versionCheck.packageVersion;
  //     packageName = versionCheck.packageName;
  //     storeVersion = versionCheck.storeVersion;
  //     storeUrl = versionCheck.storeUrl;
  //   });
  // }
  Future<void> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    String latestVersion = "2.5.3";

    if (isUpdateAvailable(currentVersion, latestVersion)) {
      customShowUpdateDialog(context, latestVersion);
    }
  }

  bool isUpdateAvailable(String currentVersion, String latestVersion) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> latestParts = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > (i < currentParts.length ? currentParts[i] : 0)) {
        return true; // A higher version is available
      }
    }
    return false;
  }

  void customShowUpdateDialog(BuildContext context, String versionCheck) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('New Update Available'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Do you really want to update to ${versionCheck}?'),
              Text('(current version ${versionCheck})'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('UPDATE'),
            onPressed: () async {
              // await versionCheck.launchStore();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('CLOSE'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future updateForDeveloperConsultant() async {
    final SharedPreferences prefs = await _prefs;

    if (username != '') {
      prefs.setString('userName', username!);
    }
    print('1---------------------${acquisitionTab}');
    if (acquisitionTab != '') {
      prefs.setString('acquisitionTab', acquisitionTab!);
    }

    if (designation != '') {
      prefs.setString('desingnation', designation!);
    }

    if (userprofile != '') {
      prefs.setString('userProfile', userprofile!);
    }

    if (mycontract == '1') {
      prefs.setString('mycontract', '1');
    } else {
      prefs.setString('mycontract', '0');
    }
    if (groupFlag == '1') {
      prefs.setString('groupFlag', '1');
    } else {
      prefs.setString('groupFlag', '0');
    }

    if (accountManagement == '1') {
      prefs.setString('accountmanagment', '1');
    } else {
      prefs.setString('accountmanagment', '0');
    }

    if (statusofsupply == '1') {
      prefs.setString('statusofsupply', '1');
    } else {
      prefs.setString('statusofsupply', '0');
    }

    if (masterDashboardFlag == '1') {
      prefs.setString('masterDashboardFlag', '1');
    } else {
      prefs.setString('masterDashboardFlag', '0');
    }

    if (orderhistory == '1') {
      prefs.setString('orderhistory', '1');
    } else {
      prefs.setString('orderhistory', '0');
    }

    widget.callback!();
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

  double _getPortraitCardWidth() {
    final mediaQuery = MediaQuery.of(context);
    final double shortestSide = mediaQuery.size.shortestSide;
    if (shortestSide < 600) {
      return 175.0; // Mobile card width 175
    } else {
      return 180.0; // Tablet card width 180
    }
  }

  double _getAspectRatio() {
    final double cardWidth = _getPortraitCardWidth();
    final double cardHeight = cardWidth * 1.25 + 75; // 75px for text
    return cardWidth / cardHeight;
  }

  double _getCrossAxisSpacing() {
    final mediaQuery = MediaQuery.of(context);
    final double shortestSide = mediaQuery.size.shortestSide;
    if (shortestSide < 600) {
      return 10.0; // Mobile inner gap 10
    } else {
      return 100.0; // Tablet inner gap 100
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return LoaderOverlay(
        useDefaultLoading: false,
        overlayWidgetBuilder: (_) => const Center(
              child: SpinKitRing(
                lineWidth: 5.0,
                color: Colors.black,
                size: 50.0,
              ),
            ),
        child: Material(
          color: Colors.white,
          child: Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  top: !isMobile ? false : true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (flagDeveloperConsultant == true)
                        _buildSleekCapsuleRoleToggle(isMobile),
                      if (isMobile)
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                            top: flagDeveloperConsultant == true ? 0.0 : 8.0,
                            bottom: 8.0,
                          ),
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.center,
                              heightFactor: 0.75,
                              child: Image.asset(
                                'images/Icon-512.png',
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: isMobile
                              ? EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 96.0 + MediaQuery.of(context).viewInsets.bottom,
                                )
                              : EdgeInsets.only(
                                  left: 24.0,
                                  right: 24.0,
                                  top: 12.0,
                                  bottom: 96.0 + MediaQuery.of(context).viewInsets.bottom,
                                ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              flagcalled == true
                                  ? norecord == true
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(40.0),
                                            child: Text('No Project Found',
                                                style: isMobile ? normalText : boldText),
                                          ),
                                        )
                                      : projectDetails!.isEmpty
                                          ? Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                                                    const SizedBox(height: 16),
                                                    const Text(
                                                      "No projects match your search",
                                                      style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 24),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _searchController.clear();
                                                        _filterProjects('');
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.black,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'Clear Search',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : isMobile
                                              ? GridView.builder(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: _getColumns(),
                                                    crossAxisSpacing: _getCrossAxisSpacing(),
                                                    mainAxisSpacing: MediaQuery.of(context).size.shortestSide < 600 ? 10.0 : 20.0,
                                                    childAspectRatio: _getAspectRatio(),
                                                  ),
                                                  itemCount: projectDetails!.length,
                                                  itemBuilder: (context, index) {
                                                    return _buildMobileProjectCard(index);
                                                  },
                                                )
                                              : Wrap(
                                                  direction: Axis.horizontal, // default
                                                  alignment: WrapAlignment.start, // default
                                                  children: List.generate(
                                                      projectDetails!.length, (index) {
                                                    final proj = projectDetails![index];
                                                    final bool isSingleTowerDeactivated = proj.towerFlag == "0" &&
                                                        proj.towarId != null &&
                                                        proj.towarId!.isNotEmpty &&
                                                        !SocketService.isTowerActive(proj.towarId!);
                                                    final Color imageBgColor = isSingleTowerDeactivated ? const Color(0xFFE0E0E0) : Colors.white;
                                                    return Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 12.0,
                                                          top: 12.0,
                                                          bottom: 20.0),
                                                      child: GestureDetector(
                                                        onTap: () => _handleProjectTap(index),
                                                        child: Container(
                                                          margin: const EdgeInsets.only(
                                                            left: 20.0,
                                                            top: 20.0,
                                                            bottom: 20.0,
                                                            right: 30.0,
                                                          ),
                                                          width: 145,
                                                          // height: 200,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.center,
                                                            children: <Widget>[
                                                              (projectDetails![index].projectImgName == null ||
                                                                      projectDetails![index].projectImgName!.isEmpty)
                                                                  ? Container(
                                                                      height: 185,
                                                                      decoration: BoxDecoration(
                                                                        color: imageBgColor,
                                                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                                        image: DecorationImage(
                                                                          image: const AssetImage('images/default_building.png'),
                                                                          fit: BoxFit.fill,
                                                                          colorFilter: isSingleTowerDeactivated
                                                                              ? const ColorFilter.mode(Color(0xFFD0D0D0), BlendMode.multiply)
                                                                              : null,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : CachedNetworkImage(
                                                                      height: 185,
                                                                      imageUrl: AppUrl.useNewBackend
                                                                          ? "${AppUrl.baseURL}projects/${projectDetails![index].projectId}/image"
                                                                          : (AppUrl.getProjectImageUrl +
                                                                              projectDetails![index]
                                                                                  .projectImgName!),
                                                                      httpHeaders: AppUrl.useNewBackend &&
                                                                              token != ""
                                                                          ? {
                                                                              "Authorization":
                                                                                  "Bearer $token"
                                                                            }
                                                                          : null,
                                                                      placeholder: (context, url) =>
                                                                          Shimmer.fromColors(
                                                                        baseColor:
                                                                            const Color(0xFFF0F0F0),
                                                                        highlightColor:
                                                                            const Color(0xFFF9F9F9),
                                                                        child: Container(
                                                                          height: 185,
                                                                          decoration: BoxDecoration(
                                                                            color: imageBgColor,
                                                                            borderRadius: BorderRadius.circular(8),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      imageBuilder: (context,
                                                                              imageProvider) =>
                                                                          Container(
                                                                        decoration: BoxDecoration(
                                                                          color: imageBgColor,
                                                                          borderRadius:
                                                                              const BorderRadius
                                                                                  .all(
                                                                                  Radius.circular(
                                                                                      8)),
                                                                          image: DecorationImage(
                                                                            image: imageProvider,
                                                                            fit: BoxFit.fill,
                                                                            colorFilter: isSingleTowerDeactivated
                                                                                ? const ColorFilter.mode(Color(0xFFD0D0D0), BlendMode.multiply)
                                                                                : null,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      errorWidget: _error,
                                                                    ),
                                                              verticalSpaceSmall,
                                                              Text(
                                                                  projectDetails![index]
                                                                      .projectName!,
                                                                  textAlign: TextAlign.center,
                                                                  style: boldText),
                                                              verticalSpaceTiny,
                                                              projectDetails![index]
                                                                          .towarName! !=
                                                                      ""
                                                                  ? Text(
                                                                      projectDetails![index]
                                                                          .towarName!,
                                                                      textAlign:
                                                                          TextAlign.center,
                                                                      style: normalText)
                                                                  : const SizedBox(),
                                                              projectDetails![index]
                                                                          .towarName! !=
                                                                      ""
                                                                  ? verticalSpaceTiny
                                                                  : const SizedBox(),
                                                              Text(
                                                                  projectDetails![index]
                                                                      .placeName!,
                                                                  textAlign: TextAlign.center,
                                                                  style:
                                                                      normalText14GreyColor),
                                                              verticalSpaceSmall,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                )
                                  : _buildProjectListSkeleton(isMobile),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                  Positioned(
                    left: isMobile ? 16 : 24,
                    right: isMobile ? 16 : 24,
                    bottom: MediaQuery.of(context).padding.bottom +
                        MediaQuery.of(context).viewInsets.bottom +
                        16,
                    child: Center(child: _buildGlassSearchBar()),
                  ),
              if (flagcalled == false)
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
          ),
        ),
    );
  }

  Widget _buildMobileProjectCard(int index) {
    final double cardWidth = _getPortraitCardWidth();
    final double imageHeight = cardWidth * 1.25;
    final project = projectDetails![index];
    final bool isSingleTowerDeactivated = project.towerFlag == "0" &&
        project.towarId != null &&
        project.towarId!.isNotEmpty &&
        !SocketService.isTowerActive(project.towarId!);
    final Color imageBgColor = isSingleTowerDeactivated ? const Color(0xFFE0E0E0) : Colors.white;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: InkWell(
          onTap: () => _handleProjectTap(index),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (projectDetails![index].projectImgName == null ||
                        projectDetails![index].projectImgName!.isEmpty)
                    ? Container(
                        width: double.infinity,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: imageBgColor,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          image: DecorationImage(
                            image: const AssetImage('images/default_building.png'),
                            fit: BoxFit.fill,
                            colorFilter: isSingleTowerDeactivated
                                ? const ColorFilter.mode(Color(0xFFD0D0D0), BlendMode.multiply)
                                : null,
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        width: double.infinity,
                        height: imageHeight,
                        imageUrl: AppUrl.useNewBackend
                            ? "${AppUrl.baseURL}projects/${projectDetails![index].projectId}/image"
                            : (AppUrl.getProjectImageUrl +
                                projectDetails![index].projectImgName!),
                        httpHeaders: AppUrl.useNewBackend && token != ""
                            ? {"Authorization": "Bearer $token"}
                            : null,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: const Color(0xFFF0F0F0),
                          highlightColor: const Color(0xFFF9F9F9),
                          child: Container(
                            width: double.infinity,
                            height: imageHeight,
                            decoration: BoxDecoration(
                              color: imageBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        fit: BoxFit.fill,
                        imageBuilder: (context, imageProvider) => Container(
                          height: imageHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: imageBgColor,
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                              colorFilter: isSingleTowerDeactivated
                                  ? const ColorFilter.mode(Color(0xFFD0D0D0), BlendMode.multiply)
                                  : null,
                            ),
                          ),
                        ),
                        errorWidget: _error,
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    children: [
                      Text(
                        projectDetails![index].projectName!,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (projectDetails![index].towarName! != "") ...[
                        const SizedBox(height: 3),
                        Text(
                          projectDetails![index].towarName!,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black87),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        projectDetails![index].placeName!,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Calls POST /auth/mobile/switch-by-project using the master token,
  /// stores the returned project token, then navigates into the project.
  /// The master token is never touched by this method.
  Future<void> _switchToProject(int index) async {
    if (_isSwitchingProject) return;
    _isSwitchingProject = true;

    final project = projectDetails![index];
    final String projectId = project.projectId!;

    CustomLoading.progressDialog(isLoading: true, context: context);
    try {
      final response = await apiNetworkHandler.postWithMasterToken(
        AppUrl.switchByProject,
        {"project_id": projectId},
      );

      if (!mounted) return;
      CustomLoading.progressDialog(isLoading: false, context: context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final newToken = decoded['data']?['token']?.toString();

        if (newToken != null && newToken.isNotEmpty) {
          // Store project token — master token is untouched
          final prefs = await _prefs;
          await prefs.setString('projectToken', newToken);
          await prefs.setString('activeProjectId', projectId);
          NetworkHandler.activeProjectIdCache = projectId;
          // Navigate into the project with pre-loaded modules for this specific project role
          _navigateIntoProject(
            index,
            project.modules ?? _projectModulesCache["${projectId}_${project.role}"] ?? _projectModulesCache[projectId] ?? [],
          );
        } else {
          _showSwitchError("Unable to switch project: no token received.");
        }
      } else {
        _showSwitchError("Unable to switch to this project. Please try again.");
      }
    } catch (e) {
      if (mounted) {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }
      _showSwitchError("Network error while switching project.");
    } finally {
      _isSwitchingProject = false;
    }
  }

  void _showSwitchError(String message) {
    Alert(
      closeIcon: const SizedBox(),
      padding: const EdgeInsets.only(top: 0.0),
      image: Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
      style: const AlertStyle(
        titleTextAlign: TextAlign.center,
        descTextAlign: TextAlign.center,
        descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        isCloseButton: true,
      ),
      context: context,
      desc: message,
      alertAnimation: fadeAlertAnimation,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
          child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ],
    ).show();
  }

  void _navigateIntoProject(int index, List<dynamic> preloadedModules) {
    final project = projectDetails![index];
    if (project.towerFlag == "0") {
      var dateend = project.endDt;
      var arrDateEnd = dateend?.split(" ");
      var strActDays = arrDateEnd![0];
      DateTime tempDate = DateFormat("yyyy-MM-dd").parse(strActDays);
      tempDate.add(const Duration(days: 10));
      DateTime now = DateTime.now();

      if (tempDate.isAfter(now)) {
        var projectId = project.projectId!;
        var towarId = project.towarId!;
        var projectName = project.towarName! != ""
            ? project.projectName!
            : '${project.projectName!}, ${project.placeName!}';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkProgressList(
              projectId: projectId,
              towarId: towarId,
              projectName: projectName,
              towarName: project.towarName! != "" ? project.towarName! : "",
              consultantMagicLink: project.consultantMagicLink,
              contractorMagicLink: project.contractorMagicLink,
              vendMagicLink: project.vendMagicLink,
              preloadedModules: preloadedModules,
            ),
          ),
        ).then((value) async {
          // Clear project token — back to project list uses master token
          final prefs = await _prefs;
          await prefs.remove('projectToken');
          setState(() {
            flagcalled = false;
            projectDetails = [];
          });
          fetchProjectDetails();
        });
      } else {
        Alert(
          closeIcon: const SizedBox(),
          padding: const EdgeInsets.only(top: 0.0),
          image: Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
          style: const AlertStyle(
            titleTextAlign: TextAlign.center,
            descTextAlign: TextAlign.center,
            descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            isCloseButton: true,
          ),
          context: context,
          desc: "You have not subscribed the membership. Please contact support team.",
          alertAnimation: fadeAlertAnimation,
          buttons: [
            DialogButton(
              onPressed: () => Navigator.of(context).pop(),
              color: Colors.black,
              child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ],
        ).show();
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectTowarList(
            projectId: project.projectId,
            title: project.projectName,
            projectImageUrl: project.projectImgName,
            preloadedModules: preloadedModules,
          ),
        ),
      ).then((value) async {
        // Clear project token — back to project list uses master token
        final prefs = await _prefs;
        await prefs.remove('projectToken');
      });
    }
  }

  Future<void> _handleProjectTap(int index) async {
    final project = projectDetails![index];

    if (project.towerFlag == "0") {
      CustomLoading.progressDialog(isLoading: true, context: context);
      try {
        final towersResponse = await apiNetworkHandler.get("${AppUrl.baseURL}towers?project_id=${project.projectId}");
        if (towersResponse != null && (towersResponse.statusCode == 200 || towersResponse.statusCode == 201)) {
          final towersDecoded = json.decode(towersResponse.body);
          if (towersDecoded['success'] == true && towersDecoded['data'] is List && (towersDecoded['data'] as List).isNotEmpty) {
            final towersList = towersDecoded['data'] as List;
            Map? matched;
            if (project.towarId != null && project.towarId!.isNotEmpty && project.towarId != '0') {
              matched = towersList.firstWhere(
                (t) => t is Map && t['id']?.toString() == project.towarId,
                orElse: () => null,
              );
            }
            if (matched == null && project.towarName != null && project.towarName!.trim().isNotEmpty) {
              final tName = project.towarName!.trim().toLowerCase();
              matched = towersList.firstWhere(
                (t) => t is Map && (t['name'] ?? '').toString().trim().toLowerCase() == tName,
                orElse: () => null,
              );
            }
            final singleTower = matched ?? towersList[0];
            project.towarId = singleTower['id']?.toString() ?? "";
            project.towarName = singleTower['name'] ?? project.towarName ?? "";
            final bool isTActive = singleTower['is_active'] == true || singleTower['is_active']?.toString() == 'true' || singleTower['isActive'] == true || singleTower['isActive']?.toString() == 'true';
            if (project.towarId!.isNotEmpty) {
              SocketService.setTowerActive(project.towarId!, isTActive);
            }
          }
        }
      } catch (_) {}
      if (mounted) {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }
    }

    if (project.towerFlag == "0" && project.towarId != null && project.towarId!.isNotEmpty) {
      final bool isTowerActive = SocketService.isTowerActive(project.towarId!);
      if (!isTowerActive) {
        _showDeactivatedAlert();
        return;
      }
    }
    // Always switch workspace context before entering any project
    _switchToProject(index);
  }

  void _showDeactivatedAlert() {
    Alert(
      closeIcon: const SizedBox(),
      padding: const EdgeInsets.only(top: 0.0),
      image: Image.asset('images/Icon-512.png',
          height: 80, fit: BoxFit.fitWidth),
      style: const AlertStyle(
        titleTextAlign: TextAlign.center,
        descTextAlign: TextAlign.center,
        descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        isCloseButton: true,
      ),
      context: context,
      desc: "This tower is deactivated by the admin.",
      alertAnimation: fadeAlertAnimation,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
          child: const Text("CLOSE",
              style: TextStyle(color: Colors.white, fontSize: 15)),
        ),
      ],
    ).show();
  }

  Widget _buildSleekCapsuleRoleToggle(bool isMobile) {
    List<Map<String, String>> segments = [];
    if (developer == '1' && consultant == '1' && contractor == '1') {
      segments = [
        {"title": "DEVELOPER", "type": "developer"},
        {"title": "CONSULTANT", "type": "consultant"},
        {"title": "CONTRACTOR", "type": "contractor"},
      ];
    } else if (developer == '1' && consultant == '1') {
      segments = [
        {"title": "DEVELOPER", "type": "developer"},
        {"title": "CONSULTANT", "type": "consultant"},
      ];
    } else if (developer == '1' && contractor == '1') {
      segments = [
        {"title": "DEVELOPER", "type": "developer"},
        {"title": "CONTRACTOR", "type": "contractor"},
      ];
    } else if (consultant == '1' && contractor == '1') {
      segments = [
        {"title": "CONSULTANT", "type": "consultant"},
        {"title": "CONTRACTOR", "type": "contractor"},
      ];
    } else {
      return const SizedBox.shrink();
    }

    final int activeIdx = (groupValue != null && groupValue! < segments.length) ? groupValue! : 0;
    final double alignX = segments.length > 1
        ? -1.0 + activeIdx * (2.0 / (segments.length - 1))
        : 0.0;

    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(
          top: isMobile ? 6.0 : 12.0,
          left: isMobile ? 16.0 : 24.0,
          right: isMobile ? 16.0 : 24.0,
          bottom: isMobile ? 4.0 : 8.0,
        ),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          height: isMobile ? 36.0 : 40.0,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEF3),
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.all(3.0),
        child: Stack(
          children: [
            // Sliding capsule pill background
            AnimatedAlign(
              alignment: Alignment(alignX, 0.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              child: FractionallySizedBox(
                widthFactor: 1.0 / segments.length,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab labels
            Row(
              children: List.generate(segments.length, (idx) {
                final seg = segments[idx];
                final bool isSelected = activeIdx == idx;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      setState(() {
                        groupValue = idx;
                        loginType = seg["type"];
                        _searchController.clear();
                        if (AppUrl.useNewBackend) {
                          _filterProjectsByRole();
                        }
                      });
                      final SharedPreferences prefs = await _prefs;
                      prefs.setString('loginType', loginType!);
                      if (!AppUrl.useNewBackend) {
                        setState(() {
                          flagcalled = false;
                        });
                        fetchProjectDetails();
                      }
                    },
                    child: Center(
                      child: Text(
                        seg["title"]!,
                        style: TextStyle(
                          fontSize: isMobile ? 11.5 : 13.0,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 0.3,
                          color: isSelected ? Colors.black : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildProjectListSkeleton(bool isMobile) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF0F0F0),
      highlightColor: const Color(0xFFF9F9F9),
      period: const Duration(milliseconds: 1500),
      child: isMobile
          ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getColumns(),
                crossAxisSpacing: _getCrossAxisSpacing(),
                mainAxisSpacing: MediaQuery.of(context).size.shortestSide < 600 ? 10.0 : 20.0,
                childAspectRatio: _getAspectRatio(),
              ),
              itemCount: 6,
              itemBuilder: (context, index) => _buildSkeletonCard(),
            )
          : Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              children: List.generate(6, (index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, top: 12.0, bottom: 20.0),
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 20.0,
                      top: 20.0,
                      bottom: 20.0,
                      right: 30.0,
                    ),
                    width: 145,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 185,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 70,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildSkeletonCard() {
    final double cardWidth = _getPortraitCardWidth();
    final double imageHeight = cardWidth * 1.25;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image skeleton
              Container(
                width: double.infinity,
                height: imageHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  children: [
                    // Project name skeleton
                    Container(
                      width: 100,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Place name skeleton
                    Container(
                      width: 70,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _filterProjects(String query) {
    if (query.isEmpty) {
      projectDetails = _allProjectDetails;
    } else {
      projectDetails = _allProjectDetails?.where((project) {
        final name = project.projectName?.toLowerCase() ?? '';
        final place = project.placeName?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || place.contains(searchLower);
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
              onChanged: _filterProjects,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search projects...',
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
                          _filterProjects('');
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
}
