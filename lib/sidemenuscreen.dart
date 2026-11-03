import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/ui/shared/ui_helpers.dart';
import 'package:stallion/ui/views/accountmanagement/accountmanagement.dart';
import 'package:stallion/ui/views/cms/cms_details.dart';
import 'package:stallion/ui/views/dashboard/dashboard_screen.dart';
import 'package:stallion/ui/views/helpandsupport/helpsupport.dart';
import 'package:stallion/ui/views/mycontracts/mycontract_list_view.dart';
import 'package:stallion/ui/views/mycontracts/mycontracts.dart';
import 'package:stallion/ui/views/myprofile/myprofileview.dart';
import 'package:stallion/ui/views/notifications/notifications_screen.dart';
import 'package:stallion/ui/views/orderhistory/orderhistoryview.dart';
import 'package:stallion/ui/views/statusofsupply/statussupplyview.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/utils/responsive.dart';
import 'package:stallion/websocket/portal_access_service.dart';
import 'package:stallion/websocket/socket_service.dart';

enum SideMenuTabType {
  myProjects,
  myContracts,
  accountManagement,
  statusOfSupplies,
  notifications,
  orderHistory,
  aboutUs,
  helpAndSupport,
  myProfile,
}

class MenuTabItem {
  final SideMenuTabType type;
  final String title;
  final IconData icon;
  final Widget view;

  MenuTabItem({
    required this.type,
    required this.title,
    required this.icon,
    required this.view,
  });
}

class SideMenuScreen extends StatefulWidget {
  const SideMenuScreen({Key? key}) : super(key: key);

  @override
  State<SideMenuScreen> createState() => _SideMenuScreenState();
}

class _SideMenuScreenState extends State<SideMenuScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final NetworkHandler apiNetworkHandler = NetworkHandler();
  int count = 0;
  int selected_tab = 0;
  PageController pageController = PageController();
  String? Username = "";
  String? Designation = "";
  String? UserProfile = "";
  String? ProfileImg = "";
  String? token = "";
  bool flagcalled = false;
  bool accountmanagment = false;
  bool statusofsupply = false;
  bool mycontract = false;
  bool masterDashboardFlag = false;

  String groupFlag = '0';
  bool orderhistory = false;
  bool acquisitionTab = false;

  List<MenuTabItem> activeTabs = [];
  List<Widget> arrViews = [];

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    // Start monitoring portal_access status (Strategy 2)
    PortalAccessService.startMonitoring();
    // Listen to page changes and update the selection
    pageController.addListener(() {
      if (pageController.page != null) {
        int currentPage = pageController.page!.round();
        if (selected_tab != currentPage) {
          setState(() {
            selected_tab = currentPage;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    PortalAccessService.stopMonitoring();
    pageController.dispose();
    super.dispose();
  }

  void callback() {
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      Username = prefs.getString('userName') ?? "";
      Designation = prefs.getString('desingnation') ?? "";
      ProfileImg = prefs.getString('profileImg') ?? "";
      UserProfile = prefs.getString('userProfile') ?? "";
      token = prefs.getString('masterToken') ?? prefs.getString('token') ?? "";
    });

    if (AppUrl.useNewBackend) {
      try {
        var response = await apiNetworkHandler.get("${AppUrl.baseURL}auth/me");
        if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
          final decoded = json.decode(response.body);
          if (decoded['success'] == true && decoded['data'] != null) {
            var data = decoded['data'];

            // Check portal_access — force-logout if disabled by admin
            final bool portalAccess = data['portal_access'] ?? true;
            if (!portalAccess) {
              PortalAccessService.forceLogout();
              return;
            }

            setState(() {
              Username = data['name'] ?? "";
              Designation = data['designation'] ?? "";
              UserProfile = data['role'] ?? "";
              ProfileImg = data['profile_image_url'] ?? "";
            });
            prefs.setString('userName', Username ?? "");
            prefs.setString('desingnation', Designation ?? "");
            prefs.setString('userProfile', UserProfile ?? "");
            prefs.setString('profileImg', ProfileImg ?? "");
            prefs.setString('parentDeveloperId', data['parent_developer_id']?.toString() ?? "");
          }
        }
      } catch (e) {
        // Handle silently
      }
    }

    if (prefs.containsKey('accountmanagment')) {
      accountmanagment = prefs.getString('accountmanagment') == '1';
    } else {
      accountmanagment = false;
    }

    if (prefs.containsKey('acquisitionTab')) {
      acquisitionTab = prefs.getString('acquisitionTab') == '1';
    } else {
      acquisitionTab = false;
    }

    if (prefs.containsKey('statusofsupply')) {
      statusofsupply = prefs.getString('statusofsupply') == '1';
    } else {
      statusofsupply = false;
    }

    if (prefs.containsKey('mycontract')) {
      mycontract = prefs.getString('mycontract') == '1';
    } else {
      mycontract = false;
    }

    if (prefs.containsKey('masterDashboardFlag')) {
      masterDashboardFlag = prefs.getString('masterDashboardFlag') == '1';
    } else {
      masterDashboardFlag = false;
    }

    if (prefs.containsKey('groupFlag')) {
      groupFlag = prefs.getString('groupFlag') ?? '0';
    } else {
      groupFlag = '0';
    }

    if (prefs.containsKey('orderhistory')) {
      orderhistory = prefs.getString('orderhistory') == '1';
    } else {
      orderhistory = false;
    }

    List<MenuTabItem> tempTabs = [];

    // 0. Landing page: My Projects (always at index 0, not in sidebar)
    tempTabs.add(MenuTabItem(
      type: SideMenuTabType.myProjects,
      title: 'My Projects',
      icon: Icons.home,
      view: ProjectListScreen(callback: callback),
    ));

    // 1. My Contracts (if assigned)
    if (mycontract) {
      tempTabs.add(MenuTabItem(
        type: SideMenuTabType.myContracts,
        title: 'My Contracts',
        icon: Icons.save_as_outlined,
        view: groupFlag == '1'
            ? MycontractListView(
                projectId: "",
                towarId: "",
                projectName: "ALL PROJECT",
                navigationFlag: "SideMenu",
              )
            : MyContractsView(
                projectId: "",
                towarId: "",
                projectName: "ALL PROJECT",
                navigationFlag: "SideMenu",
                categoryId: '',
                developerId: '',
              ),
      ));
    }

    // 2. Account Management (if assigned)
    if (accountmanagment) {
      tempTabs.add(MenuTabItem(
        type: SideMenuTabType.accountManagement,
        title: 'Account Management',
        icon: Icons.ballot_outlined,
        view: AccountManagementView(
          projectId: "",
          towarId: "",
          projectName: "ALL PROJECT",
          navigationFlag: "SideMenu",
        ),
      ));
    }

    // 3. Status of Supplies (if assigned)
    if (statusofsupply) {
      tempTabs.add(MenuTabItem(
        type: SideMenuTabType.statusOfSupplies,
        title: 'Status of Supplies',
        icon: Icons.local_shipping_outlined,
        view: const StatusOfSupplyView(),
      ));
    }

    // 4. Order History (if assigned)
    if (orderhistory) {
      tempTabs.add(MenuTabItem(
        type: SideMenuTabType.orderHistory,
        title: 'Order History',
        icon: Icons.list_alt_outlined,
        view: const OrderHistoryView(),
      ));
    }

    // 5. Notifications (default/always present)
    tempTabs.add(MenuTabItem(
      type: SideMenuTabType.notifications,
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      view: NotificationsScreen(
        projectId: "",
        towarId: "",
        projectName: "ALL PROJECT",
        onBack: () {
          pageController.jumpToPage(0);
        },
      ),
    ));

    // 6. About Us (default/always present)
    tempTabs.add(MenuTabItem(
      type: SideMenuTabType.aboutUs,
      title: 'About Us',
      icon: Icons.info_outline,
      view: CmsPageHtml(
        cmsId: '1',
        navigationFlag: "SideMenu",
        onBack: () {
          pageController.jumpToPage(0);
        },
      ),
    ));

    // 7. Help and Support (default/always present)
    tempTabs.add(MenuTabItem(
      type: SideMenuTabType.helpAndSupport,
      title: 'Help and Support',
      icon: Icons.help_outline,
      view: HelpSupport(
        onBack: () {
          pageController.jumpToPage(0);
        },
      ),
    ));

    // 8. My Profile (always present, not in sidebar, accessed via topView click)
    tempTabs.add(MenuTabItem(
      type: SideMenuTabType.myProfile,
      title: 'My Profile',
      icon: Icons.person,
      view: MyProfileView(
        onBack: () {
          pageController.jumpToPage(0);
        },
      ),
    ));

    setState(() {
      activeTabs = tempTabs;
      arrViews = tempTabs.map((t) => t.view).toList();
      flagcalled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final currentTabType = activeTabs.isNotEmpty && selected_tab < activeTabs.length
        ? activeTabs[selected_tab].type
        : null;
    final isProfileTab = currentTabType == SideMenuTabType.myProfile;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1.0),
      resizeToAvoidBottomInset: false,
      appBar: isMobile
          ? AppBar(
              backgroundColor: isProfileTab ? Colors.black : Colors.white,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: isProfileTab ? Colors.white : Colors.black, size: 28.0),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: isProfileTab ? Colors.white : Colors.black, size: 28.0),
                  onPressed: () {
                    int index = activeTabs.indexWhere(
                        (t) => t.type == SideMenuTabType.notifications);
                    if (index != -1) {
                      pageController.jumpToPage(index);
                    }
                  },
                ),
              ],
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      _buildMobileHeader(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildMobileMenuItems(),
                        ),
                      ),
                      const Divider(height: 1),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: flagcalled == true
          ? isMobile
              ? PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: arrViews)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 4.5,
                      decoration: BoxDecoration(
                        color: isProfileTab ? Colors.black : const Color.fromRGBO(245, 245, 245, 1.0),
                        border: Border(
                          right: BorderSide(
                            color: isProfileTab ? const Color(0xff333333) : const Color.fromRGBO(230, 230, 230, 1.0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            _buildDesktopHeader(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildDesktopMenuItems(),
                              ),
                            ),
                            const Divider(height: 1),
                            _buildLogoutButton(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: arrViews),
                    ),
                  ],
                )
          : const SizedBox(
              width: 100.0,
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  Widget _buildProfileAvatar({double radius = 40.0}) {
    final double size = radius * 2;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ProfileImg == null || ProfileImg!.isEmpty
            ? ClipOval(
                child: Image.asset(
                  'images/profile-icon.png',
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              )
            : ClipOval(
                child: AppUrl.useNewBackend
                    ? CachedNetworkImage(
                        width: size,
                        height: size,
                        imageUrl: ProfileImg!.startsWith('http')
                            ? ProfileImg!
                            : "${AppUrl.baseURL}${ProfileImg!.startsWith('/') ? ProfileImg!.substring(1) : ProfileImg!}",
                        httpHeaders: token != null && token!.isNotEmpty
                            ? {"Authorization": "Bearer $token"}
                            : null,
                        placeholder: (context, url) => const CircularProgressIndicator(color: Colors.black),
                        errorWidget: (context, url, error) => Image.asset(
                          'images/profile-icon.png',
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        AppUrl.globalProfileImgURLThumbs + ProfileImg!,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'images/profile-icon.png',
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return InkWell(
      onTap: () {
        int index = activeTabs.indexWhere((t) => t.type == SideMenuTabType.myProfile);
        if (index != -1) {
          _navigateAndClose(index);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileAvatar(radius: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Username ?? 'User',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'HelveticaNeue',
                        ),
                      ),
                      if (Designation != null && Designation!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          Designation!,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontFamily: 'HelveticaNeue',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    final currentTabType = activeTabs.isNotEmpty && selected_tab < activeTabs.length
        ? activeTabs[selected_tab].type
        : null;
    final isProfileTab = currentTabType == SideMenuTabType.myProfile;

    return InkWell(
      onTap: () {
        int index = activeTabs.indexWhere((t) => t.type == SideMenuTabType.myProfile);
        if (index != -1) {
          pageController.jumpToPage(index);
          setState(() {
            selected_tab = index;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        color: isProfileTab ? Colors.black : const Color.fromRGBO(245, 245, 245, 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileAvatar(radius: 60),
            const SizedBox(height: 16),
            Text(
              Username ?? 'User',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isProfileTab ? Colors.white70 : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'HelveticaNeue',
              ),
            ),
            if (Designation != null && Designation!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                Designation!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isProfileTab ? Colors.white54 : Colors.black54,
                  fontSize: 13,
                  fontFamily: 'HelveticaNeue',
                ),
              ),
            ],
            if (UserProfile != null && UserProfile!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                UserProfile!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isProfileTab ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                  fontFamily: 'HelveticaNeue',
                ),
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: isProfileTab ? const Color(0xff333333) : Colors.grey.shade300, thickness: 1, height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWidget(IconData icon, String title, bool isSelected, VoidCallback onTap,
      {bool isLogout = false}) {
    final currentTabType = activeTabs.isNotEmpty && selected_tab < activeTabs.length
        ? activeTabs[selected_tab].type
        : null;
    final isProfileTab = !context.isMobile && currentTabType == SideMenuTabType.myProfile;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? (isProfileTab ? Colors.white : Colors.black) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            hoverColor: isLogout
                ? Colors.red.withOpacity(0.08)
                : (isProfileTab ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            leading: Icon(
              icon,
              color: isLogout
                  ? Colors.red
                  : (isSelected 
                      ? (isProfileTab ? Colors.black : Colors.white) 
                      : (isProfileTab ? Colors.white70 : Colors.black87)),
              size: 22,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isLogout
                    ? Colors.red
                    : (isSelected 
                        ? (isProfileTab ? Colors.black : Colors.white) 
                        : (isProfileTab ? Colors.white70 : Colors.black87)),
                fontSize: 15,
                fontFamily: 'HelveticaNeue',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMobileMenuItems() {
    List<Widget> items = [];
    final sidebarTabs = activeTabs
        .where((t) =>
            t.type != SideMenuTabType.myProjects &&
            t.type != SideMenuTabType.myProfile &&
            t.type != SideMenuTabType.notifications)
        .toList();

    for (var tab in sidebarTabs) {
      int pageIndex = activeTabs.indexOf(tab);
      bool isSelected = (selected_tab == pageIndex);
      items.add(_buildMenuItemWidget(
        tab.icon,
        tab.title,
        isSelected,
        () {
          if (pageIndex != -1) {
            _navigateAndClose(pageIndex);
          }
        },
      ));
    }

    return items;
  }

  List<Widget> _buildDesktopMenuItems() {
    List<Widget> items = [];
    final sidebarTabs = activeTabs
        .where((t) =>
            t.type != SideMenuTabType.myProjects &&
            t.type != SideMenuTabType.myProfile)
        .toList();

    for (var tab in sidebarTabs) {
      int pageIndex = activeTabs.indexOf(tab);
      bool isSelected = (selected_tab == pageIndex);
      items.add(_buildMenuItemWidget(
        tab.icon,
        tab.title,
        isSelected,
        () {
          if (pageIndex != -1) {
            pageController.jumpToPage(pageIndex);
            setState(() {
              selected_tab = pageIndex;
            });
          }
        },
      ));
    }

    return items;
  }

  Widget _buildLogoutButton() {
    return _buildMenuItemWidget(
      Icons.logout,
      'Logout',
      false,
      _showLogoutDialog,
      isLogout: true,
    );
  }

  void _navigateAndClose(int pageIndex) {
    Navigator.pop(context);
    pageController.jumpToPage(pageIndex);
  }

  void _showLogoutDialog() {
    if (context.isMobile) {
      Navigator.pop(context);
    }
    Alert(
      closeIcon: const SizedBox(),
      padding: const EdgeInsets.only(top: 0.0),
      image:
          Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
      style: const AlertStyle(
        titleTextAlign: TextAlign.center,
        descTextAlign: TextAlign.center,
        descStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        isCloseButton: true,
      ),
      context: context,
      desc: 'Are you sure you want to logout?',
      alertAnimation: fadeAlertAnimation,
      content: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DialogButton(
                  onPressed: () => Navigator.pop(context),
                  color: Colors.black,
                  child: const Text("NO",
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DialogButton(
                  onPressed: () {
                    Navigator.pop(context);
                    logout();
                  },
                  color: Colors.black,
                  child: const Text("YES",
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DialogButton(
            onPressed: () {
              Navigator.pop(context);
              PortalAccessService.performLogoutAllDevices();
            },
            color: Colors.red,
            child: const Text("LOGOUT OF ALL DEVICES",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      buttons: [],
    ).show();
  }

  void logout() async {
    PortalAccessService.stopMonitoring();
    SocketService.disconnect();
    final SharedPreferences prefs = await _prefs;
    prefs.setString('userId', "");
    prefs.setString('userName', "");
    prefs.setString('mobileNo', "");
    prefs.setString('companyName', "");
    prefs.setString('companyId', "");
    prefs.setString('profileImg', "");
    prefs.setString('desingnation', "");
    prefs.setString('userType', "");
    await prefs.clear();
    await Future.delayed(const Duration(seconds: 1));
    _pop();
  }

  _pop() {
    Navigator.of(context).pushReplacementNamed('/tutorial');
  }
}
