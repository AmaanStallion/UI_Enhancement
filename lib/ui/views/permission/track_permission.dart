import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/project_permission.dart';
import 'package:stallion/models/track_permission.dart';
import 'package:stallion/ui/custom_loading/custom_loading.dart';
// Imported for global apiNetworkHandler instance and types
import 'package:stallion/ui/views/constructionmanagementschedule/fancynode/pms_view/tree_tile.dart';
import 'package:stallion/ui/views/permission/track_permission_list.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';

/// Screen to view the permission tracking dashboard.
/// It displays a list of employees and their pending/assigned permission status count.
class TrackPermission extends StatefulWidget {
  const TrackPermission({
    super.key,
    required this.projectId,
    required this.towarId,
    required this.projectName,
    required this.towarName,
  });

  final String? projectId;
  final String? towarId;
  final String? projectName;
  final String? towarName;

  @override
  State<TrackPermission> createState() => _TrackPermissionState();
}

class _TrackPermissionState extends State<TrackPermission> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<PermissionTrackingList>? permissionTrackingListData = [];
  int _selectedCardIndex = -1;

  /// Fetches track permission data from the API endpoint
  Future<PermissionTrackingList?> getTrackPermission() async {
    CustomLoading.progressDialog(isLoading: true, context: context, skeletonType: CustomLoading.skeletonTrackPermission);
    final SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString('mobileNo');

    if (AppUrl.useNewBackend) {
      String userRole = prefs.getString('userProfile') ?? "";
      String parentDevId = prefs.getString('parentDeveloperId') ?? "";

      // 1. Ensure active projectToken matches target projectId FIRST
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await apiNetworkHandler.ensureProjectContext(widget.projectId);
      }

      // 2. Fetch auth/me if userRole or parentDevId is missing
      if (userRole.isEmpty || parentDevId.isEmpty) {
        try {
          var meResponse = await apiNetworkHandler.get("${AppUrl.baseURL}auth/me");
          if (meResponse != null && (meResponse.statusCode == 200 || meResponse.statusCode == 201)) {
            final decodedMe = json.decode(meResponse.body);
            if (decodedMe['success'] == true && decodedMe['data'] != null) {
              userRole = decodedMe['data']['role'] ?? "";
              parentDevId = decodedMe['data']['parent_developer_id']?.toString() ?? "";
              prefs.setString('userProfile', userRole);
              prefs.setString('parentDeveloperId', parentDevId);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error fetching me details: $e");
          }
        }
      }

      // 3. Fetch users assigned to THIS project (GET /users/project/:projectId)
      Set<String> validProjectUserIds = {};
      Map<String, String> userIdToName = {};
      bool hasFetchedProjectUsers = false;

      try {
        String projUsersUrl = "${AppUrl.baseURL}users/project/${widget.projectId}";
        var projUsersResponse = await apiNetworkHandler.get(projUsersUrl);
        if (projUsersResponse != null && (projUsersResponse.statusCode == 200 || projUsersResponse.statusCode == 201)) {
          hasFetchedProjectUsers = true;
          final decodedUsers = json.decode(projUsersResponse.body);
          List uList = [];
          if (decodedUsers is List) {
            uList = decodedUsers;
          } else if (decodedUsers is Map) {
            if (decodedUsers['data'] is List) {
              uList = decodedUsers['data'];
            } else if (decodedUsers['data'] is Map && decodedUsers['data']['users'] is List) {
              uList = decodedUsers['data']['users'];
            } else if (decodedUsers['users'] is List) {
              uList = decodedUsers['users'];
            }
          }
          for (var u in uList) {
            if (u is Map) {
              String uId = u['id']?.toString() ?? u['user_id']?.toString() ?? u['user']?['id']?.toString() ?? "";
              String uName = u['name'] ?? u['user_name'] ?? u['full_name'] ?? u['username'] ?? u['user']?['name'] ?? "";
              if (uId.isNotEmpty) {
                validProjectUserIds.add(uId);
                if (uName.isNotEmpty) {
                  userIdToName[uId] = uName;
                }
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching project users: $e");
        }
      }

      if (kDebugMode) {
        print("DEBUG: validProjectUserIds for project ${widget.projectId} = $validProjectUserIds");
      }

      // 4. Unique Grouping by User ID: Fetch permissions from permissions/projects/:projectId
      String url = "${AppUrl.baseURL}permissions/projects/${widget.projectId}";
      var response = await apiNetworkHandler.get(url);
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          var data = decoded['data'];
          List list = [];
          if (data is List) {
            list = data;
          } else if (data is Map && data['permissions'] is List) {
            list = data['permissions'];
          }

          Map<String, List<Map<String, dynamic>>> groupedByUserId = {};
          Map<String, String> embeddedUserNames = {};

          // Seed groupedByUserId with all valid project user IDs so all project users appear
          for (var uId in validProjectUserIds) {
            groupedByUserId[uId] = [];
          }

          for (var item in list) {
            if (item is Map) {
              String assignId = "";
              String assignName = "";

              if (item['assigned_to'] is Map) {
                assignId = item['assigned_to']['id']?.toString() ?? item['assigned_to']['user_id']?.toString() ?? "";
                assignName = item['assigned_to']['name']?.toString() ?? item['assigned_to']['user_name']?.toString() ?? item['assigned_to']['full_name']?.toString() ?? "";
              } else if (item['assigned_user'] is Map) {
                assignId = item['assigned_user']['id']?.toString() ?? item['assigned_user']['user_id']?.toString() ?? "";
                assignName = item['assigned_user']['name']?.toString() ?? item['assigned_user']['user_name']?.toString() ?? item['assigned_user']['full_name']?.toString() ?? "";
              } else if (item['assigned_user_details'] is Map) {
                assignId = item['assigned_user_details']['id']?.toString() ?? item['assigned_user_details']['user_id']?.toString() ?? "";
                assignName = item['assigned_user_details']['name']?.toString() ?? item['assigned_user_details']['user_name']?.toString() ?? item['assigned_user_details']['full_name']?.toString() ?? "";
              }

              if (assignId.isEmpty) {
                if (item['assigned_user_id'] != null && item['assigned_user_id'].toString().isNotEmpty && item['assigned_user_id'].toString() != "null" && item['assigned_user_id'].toString() != "0") {
                  assignId = item['assigned_user_id'].toString();
                } else if (item['assigned_to'] != null && item['assigned_to'] is! Map && item['assigned_to'].toString().isNotEmpty && item['assigned_to'].toString() != "null" && item['assigned_to'].toString() != "0") {
                  assignId = item['assigned_to'].toString();
                }
              }

              if (assignName.isEmpty) {
                assignName = item['assigned_user_name']?.toString() ??
                    item['assigned_to_name']?.toString() ??
                    "";
              }

              if (assignId.isNotEmpty && assignId != "null" && assignId != "0") {
                if (validProjectUserIds.contains(assignId)) {
                  groupedByUserId.putIfAbsent(assignId, () => []).add(Map<String, dynamic>.from(item));
                  if (assignName.isNotEmpty && !embeddedUserNames.containsKey(assignId)) {
                    embeddedUserNames[assignId] = assignName;
                  }
                } else if (!hasFetchedProjectUsers) {
                  groupedByUserId.putIfAbsent(assignId, () => []).add(Map<String, dynamic>.from(item));
                  if (assignName.isNotEmpty && !embeddedUserNames.containsKey(assignId)) {
                    embeddedUserNames[assignId] = assignName;
                  }
                } else {
                  if (kDebugMode) {
                    print("DEBUG: Excluding user_id $assignId because they are not assigned to project ${widget.projectId}");
                  }
                }
              }
            }
          }

          // 4. Metric Calculation & Name Resolution per User ID
          List<PermissionTrackingList> trackingList = [];
          Map<String, int> nameCounts = {};

          groupedByUserId.forEach((uid, userPerms) {
            String resolvedName = userIdToName[uid] ?? embeddedUserNames[uid] ?? uid;
            nameCounts[resolvedName] = (nameCounts[resolvedName] ?? 0) + 1;
          });

          groupedByUserId.forEach((uid, userPerms) {
            int total = userPerms.length;
            int pending = 0;
            for (var p in userPerms) {
              String status = p['permission_status']?.toString() ?? "";
              if (status != "Issued" && status != "Paid") {
                pending++;
              }
            }

            String baseName = userIdToName[uid] ?? embeddedUserNames[uid] ?? uid;
            String displayName = (nameCounts[baseName] != null && nameCounts[baseName]! > 1)
                ? "$baseName (ID: $uid)"
                : baseName;

            trackingList.add(PermissionTrackingList(
              transEmpId: uid,
              transEmpName: displayName,
              pendingCount: pending.toString(),
              totalCount: total.toString(),
            ));
          });

          setState(() {
            permissionTrackingListData = trackingList;
          });
        }
      }

      if (mounted) {
        CustomLoading.progressDialog(isLoading: false, context: context);
      }
      return null;
    }

    Map<String, String> data = {
      "user_id": userId!,
      "project_id": widget.projectId!,
    };
    
    // API Call to get tracked permission status
    var response = await apiNetworkHandler.post(
        AppUrl.webProjectPermissionTrackList, data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dataModel = tracklPermissionFromJson(response.body);
      if (dataModel.response?.errorCode == "0") {
        setState(() {
          permissionTrackingListData =
              dataModel.response?.permissionTrackingList;
        });
      }
    }
    if (mounted) {
      CustomLoading.progressDialog(isLoading: false, context: context);
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getTrackPermission();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.isMobile;
    final double horizontalPadding = isMobile ? 16.0 : 40.0;

    Widget scaffoldContent = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.towarName != null && widget.towarName!.isNotEmpty
              ? '${widget.projectName!.toUpperCase()} - ${widget.towarName!.toUpperCase()}'
              : widget.projectName!.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
            letterSpacing: 0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.0),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Column(
          children: [
            // Section Title
            Container(
              padding: const EdgeInsets.only(top: 3, bottom: 3),
              width: double.maxFinite,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xfff0f0f0), width: 1.0),
                ),
              ),
              child: const Text(
                "TRACK PERMISSIONS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'HelveticaNeue',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            
            // Modernized Table Header Card
            Container(
              margin: EdgeInsets.fromLTRB(horizontalPadding, 4.0, horizontalPadding, 4.0),
              decoration: BoxDecoration(
                color: const Color(0xfff8f9fa),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xffe9ecef), width: 1.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Employee Name",
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Pending / Assigned",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Action",
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable list of employee tracking statistics
            Expanded(
              child: permissionTrackingListData == null || permissionTrackingListData!.isEmpty
                  ? const Center(
                      child: Text(
                        "No tracking data found",
                        style: TextStyle(
                          fontFamily: 'HelveticaNeue',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 2.0),
                      itemCount: permissionTrackingListData!.length,
                      itemBuilder: (context, i) {
                        final bool isSelected = _selectedCardIndex == i;
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCardIndex = i;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 5.0),
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: isSelected ? const Color(0xffd6d6d6) : const Color(0xfff0f0f0),
                                  width: 1.0,
                                ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.015),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    permissionTrackingListData?[i].transEmpName ?? '',
                                    style: const TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '${permissionTrackingListData?[i].pendingCount} / ${permissionTrackingListData?[i].totalCount}',
                                    style: const TextStyle(
                                      fontFamily: 'HelveticaNeue',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ModernViewButton(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) {
                                                return TrackPermissionList(
                                                  projectId: widget.projectId,
                                                  towarId: widget.towarId,
                                                  projectName: widget.projectName,
                                                  towarName: widget.towarName,
                                                  assignToId: permissionTrackingListData?[i].transEmpId,
                                                  transEmpName: permissionTrackingListData?[i].transEmpName,
                                                );
                                              },
                                            ),
                                          ).then((_) {
                                            getTrackPermission();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    ),
            ),
          ],
        ),
      ),
    );

    return scaffoldContent;
  }
}

/// Custom Modern styled "View" button with hover and press transitions
class ModernViewButton extends StatefulWidget {
  final VoidCallback onTap;
  const ModernViewButton({Key? key, required this.onTap}) : super(key: key);

  @override
  _ModernViewButtonState createState() => _ModernViewButtonState();
}

class _ModernViewButtonState extends State<ModernViewButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.black : Colors.white,
              border: Border.all(
                color: _isHovered ? Colors.black : const Color(0xffcccccc),
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Text(
              "View",
              style: TextStyle(
                fontFamily: 'HelveticaNeue',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isHovered ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
