import 'dart:async';
import 'dart:convert';
import 'dart:developer' as DebugService;
import 'dart:io' show HttpOverrides, Platform, exit, InternetAddress, Socket;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/models/notification_args.dart';
import 'package:stallion/sidemenuscreen.dart';
import 'package:stallion/ui/views/NoInternetConnectionPage/NoInternetConnectionPage.dart';
import 'package:stallion/ui/views/accountmanagement/payment_request.dart';
import 'package:stallion/ui/views/accountmanagement/porequested.dart';
import 'package:stallion/ui/views/accountmanagement/worequested.dart';
import 'package:stallion/ui/views/budget/ui/budget_screen.dart';
import 'package:stallion/ui/views/forcefullyupdate/forcefullyupdate.dart';
import 'package:stallion/ui/views/legal/legal_screen.dart';
import 'package:stallion/ui/views/loading/loading_screen.dart';
import 'package:stallion/ui/views/masonry/checklist_masonry_screen.dart';
import 'package:stallion/ui/views/masonry/issuemasonryreport_screen.dart';
import 'package:stallion/ui/views/masonry/masonry_status_screen.dart';
import 'package:stallion/ui/views/mycontracts/mycontractdetailview.dart';
import 'package:stallion/ui/views/orderhistory/orderhistoryview.dart';
import 'package:stallion/ui/views/permission/permissions.dart';
import 'package:stallion/ui/views/rccstructure/supplies/architech_certificate.dart';
import 'package:stallion/ui/views/rccstructure/checklist/checklist_screen.dart';
import 'package:stallion/ui/views/rccstructure/dpr/daily_progress_report.dart';
import 'package:stallion/ui/views/rccstructure/slab/issuerccreport_screen.dart';
import 'package:stallion/ui/views/sopModule/sop_screen.dart';
import 'package:stallion/ui/views/sopModule/sop_docs.dart';
import 'package:stallion/ui/views/statusofsupply/statussupplyview.dart';
import 'package:stallion/ui/views/tenantManagement/tenantManagementList.dart';
import 'package:stallion/ui/views/task_manager/task_manager_screen.dart';
import 'package:stallion/ui/views/tutorial/tutorial_screen.dart';
import 'package:stallion/ui/views/undermaintainence/undermaintainence.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/websocket/UpdateWrapper.dart';
import 'package:stallion/websocket/notification_service.dart';
import 'package:stallion/websocket/session_service.dart';
import 'package:stallion/websocket/single_instance_ipc.dart';
import 'package:stallion/websocket/socket_service.dart';
import 'package:stallion/websocket/startup_service.dart';
import 'package:stallion/websocket/tray_service.dart';
// import 'package:velopack_flutter/velopack_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'models/get_force_update_popup.dart';
import 'package:velopack_flutter/velopack_flutter.dart';
// import 'package:flutter_single_instance/flutter_single_instance.dart';

// Global navigator key for reliable notification routing
final navigatorKey = GlobalKey<NavigatorState>();

// void main(List<String> args) async {
// Future<void> main(List<String> args) async {
//   // STEP 1: Init Rust library FIRST
//   await RustLib.init();

//   // 2. Handle background installation hooks
//   // If Velopack is installing/updating, it runs your app with these flags.
//   // We must exit early so Tray/Socket services don't start in the background.
//   // final veloCommands = [
//   //   '--veloapp-install',
//   //   '--veloapp-updated',
//   //   '--veloapp-obsolete',
//   //   '--veloapp-uninstall',
//   // ];

//   // if (veloCommands.any((cmd) => args.contains(cmd))) {
//   //   exit(0);
//   // }

//   // STEP 2: Handle hooks and EXIT IMMEDIATELY
//   final veloCommands = [
//     '--veloapp-install',
//     '--veloapp-updated',
//     '--veloapp-obsolete',
//     '--veloapp-uninstall'
//   ];
//   if (veloCommands.any((cmd) => args.contains(cmd))) {
//     exit(0); // This prevents the crash during installation
//   }
//   // WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Window Manager
//   // await windowManager.ensureInitialized();
//   // STEP 3: ONLY then start Flutter
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize your custom services
//   await NotificationService.init();

//   SocketService.setInitialized();

//   // These services (Tray/Startup) especially need the early exit above
//   // to avoid running during the installation process.
//   await TrayService.init();
//   await StartupService.enableAutoStart();
// Future<void> main(List<String> args) async {
//   // 1. MUST BE FIRST
//   await RustLib.init();

//   // 2. Handle Velopack hooks and EXIT IMMEDIATELY
//   // Do NOT initialize any services before this check
//   final veloCommands = [
//     '--veloapp-install',
//     '--veloapp-updated',
//     '--veloapp-obsolete',
//     '--veloapp-uninstall'
//   ];
//   if (veloCommands.any((cmd) => args.contains(cmd))) {
//     exit(0);
//   }

//   // 3. ONLY proceed if it's NOT an installation hook
//   WidgetsFlutterBinding.ensureInitialized();

//   // Now it is safe to initialize your services
//   await NotificationService.init();
//   SocketService.setInitialized();
//   await TrayService.init();
//   await StartupService.enableAutoStart();

//   final savedPhone = await SessionService.getPhone();

//   if (savedPhone != null) {
//     SocketService.start(savedPhone);
//   }

//   HttpOverrides.global = MyHttpOverrides();
//   if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
//     var window = await window_size.getWindowInfo();
//     if (window.screen != null) {
//       final screenFrame = window.screen?.visibleFrame;
//       const width = 1000.0;
//       const height = 650.0;
//       final left = ((screenFrame!.width - width) / 2).roundToDouble();
//       final top = ((screenFrame.height - height) / 3).roundToDouble();
//       final frame = Rect.fromLTWH(left, top, width, height);
//       window_size.setWindowFrame(frame);
//       window_size.setWindowMinSize(const Size(1100, 650));
//       window_size.setWindowTitle('STALLION');
//     }
//     runApp(const ProviderScope(child: MyApp()));
//   } else {
//     if (Platform.isAndroid || Platform.isIOS) {
//       await Intercom.instance.initialize(
//         't4qk3o7a',
//         androidApiKey: 'android_sdk-8c728b2d1cc875bd141e7a47217e90861e129fd8',
//         iosApiKey: 'ios_sdk-c1c91680436e87185d79ffa013c987b642a4f3  08',
//       );
//     }
//     // runApp(const MyApp());
//     runApp(const AppShell());
//   }
// }

// Future<void> main(List<String> args) async {
//   // 1. Rust MUST be first
//   await RustLib.init();

//   // 2. Velopack install/update hooks → EXIT IMMEDIATELY
//   final veloCommands = [
//     '--veloapp-install',
//     '--veloapp-updated',
//     '--veloapp-obsolete',
//     '--veloapp-uninstall',
//   ];
//   if (veloCommands.any((cmd) => args.contains(cmd))) {
//     exit(0);
//   }

//   // 3. Enforce SINGLE INSTANCE (VERY IMPORTANT)
//   final isPrimaryInstance = await FlutterSingleInstance.ensureSingleInstance(
//     onSecondInstance: (args) {
//       // Notification clicked while app already running
//       NotificationService.handleExternalArgs(args);
//     },
//   );

//   if (!isPrimaryInstance) {
//     // Another instance is already running → exit silently
//     exit(0);
//   }

//   // 4. Safe to start Flutter
//   WidgetsFlutterBinding.ensureInitialized();

//   // 5. Init services ONCE
//   await NotificationService.init();
//   SocketService.setInitialized();
//   await TrayService.init();
//   await StartupService.enableAutoStart();

//   final savedPhone = await SessionService.getPhone();
//   if (savedPhone != null) {
//     SocketService.start(savedPhone);
//   }

//   HttpOverrides.global = MyHttpOverrides();

//   // 6. Desktop
//   if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
//     final window = await window_size.getWindowInfo();
//     if (window.screen != null) {
//       final screenFrame = window.screen!.visibleFrame;
//       const width = 1000.0;
//       const height = 650.0;

//       final left = ((screenFrame.width - width) / 2).roundToDouble();
//       final top = ((screenFrame.height - height) / 3).roundToDouble();

//       window_size.setWindowFrame(
//         Rect.fromLTWH(left, top, width, height),
//       );
//       window_size.setWindowMinSize(const Size(1100, 650));
//       window_size.setWindowTitle('STALLION');
//     }

//     runApp(const ProviderScope(child: MyApp()));
//     return;
//   }

//   // 7. Mobile
//   if (Platform.isAndroid || Platform.isIOS) {
//     await Intercom.instance.initialize(
//       't4qk3o7a',
//       androidApiKey: 'android_sdk-8c728b2d1cc875bd141e7a47217e90861e129fd8',
//       iosApiKey: 'ios_sdk-c1c91680436e87185d79ffa013c987b642a4f308',
//     );
//   }

//   runApp(const AppShell());
// }

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint("Firebase initialization failed: $e");
    }
  }
  
  final isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  if (isDesktop) {
    // 1. Check Velopack hooks FIRST before any initialization
    final veloCommands = [
      '--veloapp-install',
      '--veloapp-updated',
      '--veloapp-obsolete',
      '--veloapp-uninstall',
    ];

    if (veloCommands.any((cmd) => args.contains(cmd))) {
      exit(0);
    }

    // 2. Only initialize Rust if NOT in install mode
    await RustLib.init();

    // 3. Enforce SINGLE INSTANCE
    final instance = FlutterSingleInstance();
    
    // Set custom process name to bypass running the 'ps -p' command
    FlutterSingleInstance.processName = "stallion";

    bool isPrimary = true;
    try {
      isPrimary = await instance.isFirstInstance();
    } catch (e) {
      isPrimary = true;
    }

    if (!isPrimary) {
      bool ipcConnectSuccess = false;
      try {
        final socket = await Socket.connect(
          InternetAddress.loopbackIPv4,
          40404,
          timeout: const Duration(milliseconds: 300),
        );
        socket.destroy();
        ipcConnectSuccess = true;
      } catch (_) {}

      if (ipcConnectSuccess) {
        // 🔁 Forward args to running instance
        await SingleInstanceIpc.sendArgs(args);

        // 🔝 Bring existing window to front
        await windowManager.ensureInitialized();
        await TrayService.restoreWindow();
        exit(0);
      } else {
        isPrimary = true;
      }
    }

    if (isPrimary) {
      // 🟢 First instance → start IPC server
      await SingleInstanceIpc.startServer((incomingArgs) async {
        await TrayService.restoreWindow();
        NotificationService.handleExternalArgs(incomingArgs);
      });
    }
  }

  // 4. Init services ONCE
  await NotificationService.init();
  SocketService.setInitialized();
  
  if (isDesktop) {
    await TrayService.init();
    await StartupService.enableAutoStart();
  }

  final prefs = await SharedPreferences.getInstance();
  // Prefer masterToken for socket startup — this is the permanent login credential
  final savedToken = prefs.getString('masterToken') ?? prefs.getString('token');
  if (savedToken != null && savedToken.isNotEmpty) {
    SocketService.start(savedToken);
  }

  HttpOverrides.global = MyHttpOverrides();

  // 5. Desktop
  if (isDesktop) {
    final window = await window_size.getWindowInfo();
    if (window.screen != null) {
      final screenFrame = window.screen!.visibleFrame;
      const width = 1000.0;
      const height = 650.0;

      final left = ((screenFrame.width - width) / 2).roundToDouble();
      final top = ((screenFrame.height - height) / 3).roundToDouble();

      window_size.setWindowFrame(
        Rect.fromLTWH(left, top, width, height),
      );
      window_size.setWindowMinSize(const Size(1100, 650));
      window_size.setWindowTitle('Stallion');
    }

    runApp(const ProviderScope(child: MyApp()));
    return;
  }

  // 6. Mobile
  if (Platform.isAndroid || Platform.isIOS) {
    await Intercom.instance.initialize(
      't4qk3o7a',
      androidApiKey: 'android_sdk-8c728b2d1cc875bd141e7a47217e90861e129fd8',
      iosApiKey: 'ios_sdk-c1c91680436e87185d79ffa013c987b642a4f308',
    );
  }

  runApp(const ProviderScope(child: AppShell()));
}

/// AppShell is the root widget that checks for updates and decides
/// whether to show the UpdateManagerPage or the normal MyApp
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _updateAvailable = false;
  bool _checkingForUpdate = true;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    // Skip update checking in debug mode - only check in release builds
    if (kDebugMode || Platform.isIOS || Platform.isAndroid) {
      setState(() {
        _updateAvailable = false;
        _checkingForUpdate = false;
      });
      return;
    }

    try {
      // Check if an update is available using Velopack
      final available = await isUpdateAvailable(
        url: 'http://skrite.com/releases',
      );

      setState(() {
        _updateAvailable = available;
        _checkingForUpdate = false;
      });
    } catch (e) {
      debugPrint('Update check error: $e');
      // If check fails, assume no update and continue with app
      setState(() {
        _updateAvailable = false;
        _checkingForUpdate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking for updates
    if (_checkingForUpdate) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Checking for updates...'),
              ],
            ),
          ),
        ),
      );
    }

    // Show update manager if update is available
    if (_updateAvailable) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: UpdateManagerPage(
          onSkip: () {
            setState(() {
              _updateAvailable = false;
            });
          },
        ),
      );
    }

    // Otherwise show normal app
    return const ProviderScope(child: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

const int _blackPrimaryValue = 0xFF000000;
MaterialColor primaryBlack = const MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);

class _MyAppState extends State<MyApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  NetworkHandler apiNetworkHandler = NetworkHandler();
  // Guard to ensure initial login/internet checks run only once

  bool _loginCheckGuard = false;
  bool _loginCheckCompleted = false;
  String? _pendingTerminatedNotificationPayload;

  void _triggerPendingNotification() {
    if (kDebugMode) {
      print("Pending notification check: $_pendingTerminatedNotificationPayload");
    }
    if (_pendingTerminatedNotificationPayload != null) {
      final payload = _pendingTerminatedNotificationPayload!;
      _pendingTerminatedNotificationPayload = null;
      if (kDebugMode) {
        print("Triggering pending notification payload: $payload");
      }
      NotificationService.triggerNotificationClick(payload);
    }
  }

  Future<ResponseWebforceupdatepopup?> Webforceupdate() async {
    try {
      Map<String, String> data = {"": ""};

      var response =
          await apiNetworkHandler.post(AppUrl.checkForceUpdate, data);
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataModel = webforceupdatepopupFromJson(response.body);
        if (kDebugMode) {
          print(dataModel.response?.errorCode);
        }
        if (dataModel.response?.errorCode == "0") {
          if (Platform.isMacOS) {
            var flag = false;
            if (dataModel.response?.macOsMaintains == "1") {
              flag = true;
              setState(() {
                page = const UnderMaintainence();
              });
            }

            if (flag == false) {
              if (dataModel.response?.webForceUpdate == "1") {
                PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                  String appName = packageInfo.appName;
                  String packageName = packageInfo.packageName;
                  String version = packageInfo.version;
                  String buildNumber = packageInfo.buildNumber;

                  print('appName = $appName');
                  print('packageName = $packageName');
                  print('version = $version');
                  print('buildNumber = $buildNumber');

                  int v1Number = getExtendedVersionNumber(version);
                  int v2Number = getExtendedVersionNumber(
                      dataModel.response!.macOsVersion!);
                  print('v1Number = $v1Number');
                  print('v2Number = $v2Number');
                  if (v2Number > v1Number) {
                    setState(() {
                      page = const ForcefullyUpdate();
                    });
                  } else {
                    checkLogin();
                  }
                });
              } else {
                checkLogin();
              }
            }
          } else {
            var flag = false;
            if (dataModel.response?.windowsMaintains == "1") {
              flag = true;
              setState(() {
                page = const UnderMaintainence();
              });
            }

            if (flag == false) {
              if (dataModel.response?.webForceUpdate == "1") {
                PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                  String appName = packageInfo.appName;
                  String packageName = packageInfo.packageName;
                  String version = packageInfo.version;
                  String buildNumber = packageInfo.buildNumber;

                  if (kDebugMode) {
                    print('appName = $appName');
                    print('packageName = $packageName');
                    print('version = $version');
                    print('buildNumber = $buildNumber');
                  }

                  int v1Number = getExtendedVersionNumber(version);
                  int v2Number = getExtendedVersionNumber(
                      dataModel.response!.windowsVersion!);

                  if (kDebugMode) {
                    print('v1Number = $v1Number');
                    print('v2Number = $v2Number');
                  }

                  if (v2Number > v1Number) {
                    setState(() {
                      page = const ForcefullyUpdate();
                    });
                  } else {
                    checkLogin();
                  }
                });
              } else {
                checkLogin();
              }
            }
          }
        }
      } else {
        // setState(() {
        // page = ApiFailWid(
        //   title: "Api Fail from Network",
        // );
        // });
        if (kDebugMode) {
          print(response.body);
        }
        return null;
      }
      return null;
    } catch (e) {
      setState(() {
        page = ApiFailWid(title: e.toString());
      });
    }
  }

  int getExtendedVersionNumber(String version) {
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  Widget page = const LoadingPage();
  static final Set<String> _processedFcmMessageIds = <String>{};
  static final Set<String> _processedFcmClickMsgIds = <String>{};

  static Future<bool> _isDuplicateFcmMessage(RemoteMessage message) async {
    final String msgId = message.messageId ??
        '${message.sentTime?.millisecondsSinceEpoch ?? 0}_${message.data['title'] ?? message.notification?.title ?? ''}_${message.data['body'] ?? message.notification?.body ?? ''}';

    if (msgId.isEmpty) return false;
    if (_processedFcmMessageIds.contains(msgId)) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedIds = prefs.getStringList('handled_fcm_msg_ids') ?? [];
      if (savedIds.contains(msgId)) {
        _processedFcmMessageIds.add(msgId);
        return true;
      }
      _processedFcmMessageIds.add(msgId);
      savedIds.add(msgId);
      if (savedIds.length > 50) {
        savedIds.removeAt(0);
      }
      await prefs.setStringList('handled_fcm_msg_ids', savedIds);
    } catch (_) {
      _processedFcmMessageIds.add(msgId);
    }
    return false;
  }

  static Future<bool> _isDuplicateFcmClick(RemoteMessage message) async {
    final String msgId = message.messageId ??
        '${message.sentTime?.millisecondsSinceEpoch ?? 0}_${message.data['title'] ?? message.notification?.title ?? ''}_${message.data['body'] ?? message.notification?.body ?? ''}';

    if (msgId.isEmpty) return false;
    if (_processedFcmClickMsgIds.contains(msgId)) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedIds = prefs.getStringList('handled_fcm_click_msg_ids') ?? [];
      if (savedIds.contains(msgId)) {
        _processedFcmClickMsgIds.add(msgId);
        return true;
      }
      _processedFcmClickMsgIds.add(msgId);
      savedIds.add(msgId);
      if (savedIds.length > 50) {
        savedIds.removeAt(0);
      }
      await prefs.setStringList('handled_fcm_click_msg_ids', savedIds);
    } catch (_) {
      _processedFcmClickMsgIds.add(msgId);
    }
    return false;
  }

  void _handleFcmMessageClick(RemoteMessage message) async {
    // Wait until checkLogin has completed to prevent navigator stack reset/logout issues
    int attempts = 0;
    while (!_loginCheckCompleted && attempts < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    try {
      Map<String, dynamic> rawRespMap = {};
      if (message.data['response'] != null) {
        if (message.data['response'] is Map) {
          rawRespMap = Map<String, dynamic>.from(message.data['response']);
        } else if (message.data['response'] is String) {
          try {
            rawRespMap = Map<String, dynamic>.from(json.decode(message.data['response']));
          } catch (_) {}
        }
      }

      final String? type = message.data['type'] ?? message.data['notification_type'] ?? message.data['notification_module_type'];
      final String? referenceId = message.data['reference_id']?.toString() ??
          message.data['legal_id']?.toString() ??
          message.data['leagl_id']?.toString() ??
          message.data['permission_id']?.toString() ??
          message.data['id']?.toString() ??
          rawRespMap['legal_id']?.toString() ??
          rawRespMap['leagl_id']?.toString() ??
          rawRespMap['permission_id']?.toString();
      final String? projectId = message.data['project_id']?.toString() ??
          message.data['projectId']?.toString() ??
          rawRespMap['project_id']?.toString() ??
          rawRespMap['projectId']?.toString();
      final String? projectName = message.data['project_name'] ?? message.data['projectName'];
      final String? permissionName = message.data['permission_name'] ?? message.data['legal_name'];
      final String? rawTower = message.data['towar_name'] ?? message.data['tower_name'] ?? message.data['towar_id']?.toString() ?? message.data['tower_id']?.toString() ?? rawRespMap['towar_id']?.toString() ?? rawRespMap['tower_id']?.toString();
      final String? categoryId = message.data['category_id']?.toString() ?? message.data['categoryId']?.toString() ?? message.data['sop_id']?.toString() ?? rawRespMap['category_id']?.toString() ?? rawRespMap['categoryId']?.toString() ?? rawRespMap['sop_id']?.toString();

      final String bodyText = message.notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';
      final String typeText = (type ?? '') + ' ' + (message.data['notification_module_type']?.toString() ?? '');

      final bool isLegalType = typeText.toLowerCase().contains('legal') ||
          bodyText.toLowerCase().contains('legal') ||
          type == 'ws-upload-legal-diagram' ||
          type == 'ws-upload-sublegal-diagram' ||
          type == 'ws-update-legal-status' ||
          type == 'ws-set-legal-remark' ||
          type == 'legal_file_uploaded';

      final String route = isLegalType ? '/legal' : SocketService.routeFromNotificationType(type);

      String resolvedProjId = (projectId != null && projectId.isNotEmpty && projectId != referenceId) ? projectId : '';
      String resolvedProjName = projectName ?? '';

      if (resolvedProjId.isEmpty || resolvedProjId == referenceId || resolvedProjName.isEmpty) {
        final resolved = await SocketService.resolveProjectByBody(
          "$resolvedProjName $bodyText",
          referenceId: referenceId,
          permissionName: permissionName,
        );
        if (resolved != null && resolved['id'] != null && resolved['id']!.isNotEmpty) {
          resolvedProjId = resolved['id']!;
          resolvedProjName = resolved['name'] ?? resolvedProjName;
        }
      }

      if (resolvedProjId.isEmpty && referenceId != null) {
        resolvedProjId = referenceId;
      }
      
      final payload = jsonEncode({
        'route': route,
        'args': {
          'msg': bodyText,
          'project_id': resolvedProjId,
          'notification_type': type ?? (isLegalType ? 'legal' : ''),
          'project_name': resolvedProjName,
          'towar_name': rawTower ?? '',
          'project_location': '',
          'response': {
            'project_id': resolvedProjId,
            'permission_id': referenceId,
            'legal_id': referenceId,
            'wo_order_id': referenceId,
            'wo_order_no': referenceId,
            'slab_id': referenceId,
            'towar_id': message.data['towar_id'] ?? message.data['tower_id'] ?? rawRespMap['towar_id'] ?? rawRespMap['tower_id'],
            'category_id': categoryId,
          }
        }
      });
      
      NotificationService.triggerNotificationClick(payload);
    } catch (e) {
      if (kDebugMode) {
        print("Error handling FCM message click: $e");
      }
    }
  }



  @override
  void initState() {
    super.initState();
    // Show UI immediately without waiting for network calls
    NotificationService.setOnNotificationClick((payload) async {
      if (payload == null || payload.isEmpty) return;

      try {
        final decoded = jsonDecode(payload);
        final String route = decoded['route'];
        
        // Safety guard: do not route to invalid/empty path (stops crashes & logouts)
        if (route == '/' || route.isEmpty) {
          DebugService.log('⚠️ Ignored invalid/empty route navigation.');
          return;
        }

        // Extract target project_id from args or response object
        final Map<String, dynamic>? args = decoded['args'] is Map ? decoded['args'] : null;
        String? targetProjectId = args?['project_id']?.toString();
        if (targetProjectId == null || targetProjectId.isEmpty) {
          targetProjectId = args?['response']?['project_id']?.toString();
        }

        // Perform workspace switch to acquire projectToken for target project before navigating
        if (targetProjectId != null && targetProjectId.isNotEmpty) {
          try {
            final response = await apiNetworkHandler.postWithMasterToken(
              AppUrl.switchByProject,
              {"project_id": targetProjectId},
            );
            if (response.statusCode == 200 || response.statusCode == 201) {
              final decodedSwitch = json.decode(response.body);
              final String? newToken = decodedSwitch['data']?['token']?.toString();
              if (newToken != null && newToken.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('projectToken', newToken);
                if (kDebugMode) {
                  print("🔄 Notification routing: Switched workspace to project $targetProjectId");
                }
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("⚠️ Error switching workspace for notification: $e");
            }
          }
        }

        void pushRoute() {
          if (navigatorKey.currentState == null) {
            if (kDebugMode) {
              print("⚠️ navigatorKey.currentState is null, retrying in 200ms...");
            }
            Future.delayed(const Duration(milliseconds: 200), pushRoute);
          } else {
            if (kDebugMode) {
              print("🚀 navigatorKey.currentState is ready, pushing: $route");
            }
            navigatorKey.currentState?.pushNamed(
              route,
              arguments: NotificationArgs.fromJson(decoded['args']),
            );
          }
        }
        pushRoute();
      } catch (e) {
        DebugService.log('❌ Invalid notification payload: $e');
      }
    });

    // macOS: Listen for APNS notifications forwarded from native AppDelegate
    // via method channel. This is needed because our custom
    // UNUserNotificationCenterDelegate intercepts notifications before
    // firebase_messaging can forward them to onMessage.
    if (Platform.isMacOS) {
      const apnsChannel = MethodChannel('com.stallion.apns_notifications');
      apnsChannel.setMethodCallHandler((MethodCall call) async {
        if (call.method == 'onAPNSNotification') {
          final args = call.arguments as Map?;
          if (args != null) {
            final String title = args['title']?.toString() ?? '';
            final String body = args['body']?.toString() ?? '';
            print("📬 APNS→Flutter: title=$title, body=$body");
            if (body.isNotEmpty) {
              NotificationService.show(title, body);
            }
          }
        }
      });
      print("📋 macOS APNS method channel listener registered");
    }

    if ((Platform.isAndroid || Platform.isIOS || Platform.isMacOS) && Firebase.apps.isNotEmpty) {
      print("📋 FCM onMessage listener registered for ${Platform.operatingSystem}");
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (await _isDuplicateFcmMessage(message)) {
          if (kDebugMode) {
            print("⚠️ Ignoring duplicate FCM onMessage event: ${message.messageId}");
          }
          return;
        }

        print("=================== FCM NOTIFICATION RAW PAYLOAD ===================");
        print("Message ID: ${message.messageId}");
        print("Title: ${message.notification?.title}");
        print("Body: ${message.notification?.body}");
        print("Data: ${jsonEncode(message.data)}");
        print("====================================================================");
        
        final notification = message.notification;
        final String? title = notification?.title ?? message.data['title'] ?? message.data['notification_title'];
        final String? body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? message.data['notification_body'];

        if (notification != null || title != null || body != null) {
          Map<String, dynamic> rawRespMap = {};
          if (message.data['response'] != null) {
            if (message.data['response'] is Map) {
              rawRespMap = Map<String, dynamic>.from(message.data['response']);
            } else if (message.data['response'] is String) {
              try {
                rawRespMap = Map<String, dynamic>.from(json.decode(message.data['response']));
              } catch (_) {}
            }
          }

          final String? type = message.data['type'] ?? message.data['notification_type'] ?? message.data['notification_module_type'];
          final String? referenceId = message.data['reference_id']?.toString() ??
              message.data['legal_id']?.toString() ??
              message.data['leagl_id']?.toString() ??
              message.data['permission_id']?.toString() ??
              message.data['id']?.toString() ??
              rawRespMap['legal_id']?.toString() ??
              rawRespMap['leagl_id']?.toString() ??
              rawRespMap['permission_id']?.toString();
          final String? projectId = message.data['project_id']?.toString() ??
              message.data['projectId']?.toString() ??
              rawRespMap['project_id']?.toString() ??
              rawRespMap['projectId']?.toString();
          final String? projectName = message.data['project_name'] ?? message.data['projectName'];
          final String? permissionName = message.data['permission_name'] ?? message.data['legal_name'];
          final String? rawTower = message.data['towar_name'] ?? message.data['tower_name'] ?? message.data['towar_id']?.toString() ?? message.data['tower_id']?.toString() ?? rawRespMap['towar_id']?.toString() ?? rawRespMap['tower_id']?.toString();
          final String? categoryId = message.data['category_id']?.toString() ?? message.data['categoryId']?.toString() ?? message.data['sop_id']?.toString() ?? rawRespMap['category_id']?.toString() ?? rawRespMap['categoryId']?.toString() ?? rawRespMap['sop_id']?.toString();

          final String bodyText = body ?? message.data['body'] ?? message.data['message'] ?? '';
          final String typeText = (type ?? '') + ' ' + (message.data['notification_module_type']?.toString() ?? '');

          final bool isLegalType = typeText.toLowerCase().contains('legal') ||
              bodyText.toLowerCase().contains('legal') ||
              type == 'ws-upload-legal-diagram' ||
              type == 'ws-upload-sublegal-diagram' ||
              type == 'ws-update-legal-status' ||
              type == 'ws-set-legal-remark' ||
              type == 'legal_file_uploaded';

          final String route = isLegalType ? '/legal' : SocketService.routeFromNotificationType(type);

          // Defer layout generation to async project name lookup
          () async {
            String resolvedProjId = (projectId != null && projectId.isNotEmpty && projectId != referenceId) ? projectId : '';
            String resolvedProjName = projectName ?? '';

            if (resolvedProjId.isEmpty || resolvedProjId == referenceId || resolvedProjName.isEmpty) {
              final resolved = await SocketService.resolveProjectByBody(
                "$resolvedProjName $bodyText",
                referenceId: referenceId,
                permissionName: permissionName,
              );
              if (resolved != null && resolved['id'] != null && resolved['id']!.isNotEmpty) {
                resolvedProjId = resolved['id']!;
                resolvedProjName = resolved['name'] ?? resolvedProjName;
              }
            }

            if (resolvedProjId.isEmpty && referenceId != null) {
              resolvedProjId = referenceId;
            }

            final payload = jsonEncode({
              'route': route,
              'args': {
                'msg': bodyText,
                'project_id': resolvedProjId,
                'notification_type': type ?? (isLegalType ? 'legal' : ''),
                'project_name': resolvedProjName,
                'towar_name': rawTower ?? '',
                'project_location': '',
                'response': {
                  'project_id': resolvedProjId,
                  'permission_id': referenceId,
                  'legal_id': referenceId,
                  'wo_order_id': referenceId,
                  'wo_order_no': referenceId,
                  'slab_id': referenceId,
                  'towar_id': message.data['towar_id'] ?? message.data['tower_id'] ?? rawRespMap['towar_id'] ?? rawRespMap['tower_id'],
                  'category_id': categoryId,
                }
              }
            });

            // On iOS, native APNS handles foreground alert via setForegroundNotificationPresentationOptions(alert:true)
            // On macOS/Android/Windows, we show via local notification plugin since native push isn't reliable
            if (!Platform.isIOS || notification == null) {
              NotificationService.show(
                title ?? '',
                body ?? '',
                payload: payload,
              );
            }
          }();
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        if (await _isDuplicateFcmClick(message)) {
          if (kDebugMode) {
            print("⚠️ Ignoring duplicate FCM onMessageOpenedApp event: ${message.messageId}");
          }
          return;
        }

        if (kDebugMode) {
          print("FCM Background click event: ${message.messageId}");
        }
        _handleFcmMessageClick(message);
      });

      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
        if (message != null) {
          if (await _isDuplicateFcmClick(message)) {
            if (kDebugMode) {
              print("⚠️ Ignoring duplicate FCM getInitialMessage event: ${message.messageId}");
            }
            return;
          }
          if (kDebugMode) {
            print("FCM Terminated click event: ${message.messageId}");
          }
          try {
            Map<String, dynamic> rawRespMap = {};
            if (message.data['response'] != null) {
              if (message.data['response'] is Map) {
                rawRespMap = Map<String, dynamic>.from(message.data['response']);
              } else if (message.data['response'] is String) {
                try {
                  rawRespMap = Map<String, dynamic>.from(json.decode(message.data['response']));
                } catch (_) {}
              }
            }

            final String? type = message.data['type'] ?? message.data['notification_type'] ?? message.data['notification_module_type'];
            final String? referenceId = message.data['reference_id']?.toString() ??
                message.data['legal_id']?.toString() ??
                message.data['leagl_id']?.toString() ??
                message.data['permission_id']?.toString() ??
                message.data['id']?.toString() ??
                rawRespMap['legal_id']?.toString() ??
                rawRespMap['leagl_id']?.toString() ??
                rawRespMap['permission_id']?.toString();
            final String? projectId = message.data['project_id']?.toString() ??
                message.data['projectId']?.toString() ??
                rawRespMap['project_id']?.toString() ??
                rawRespMap['projectId']?.toString();
            final String? projectName = message.data['project_name'] ?? message.data['projectName'];
            final String? permissionName = message.data['permission_name'] ?? message.data['legal_name'];
            final String? rawTower = message.data['towar_name'] ?? message.data['tower_name'] ?? message.data['towar_id']?.toString() ?? message.data['tower_id']?.toString() ?? rawRespMap['towar_id']?.toString() ?? rawRespMap['tower_id']?.toString();
            final String? categoryId = message.data['category_id']?.toString() ?? message.data['categoryId']?.toString() ?? message.data['sop_id']?.toString() ?? rawRespMap['category_id']?.toString() ?? rawRespMap['categoryId']?.toString() ?? rawRespMap['sop_id']?.toString();

            final String bodyText = message.notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';
            final String typeText = (type ?? '') + ' ' + (message.data['notification_module_type']?.toString() ?? '');

            final bool isLegalType = typeText.toLowerCase().contains('legal') ||
                bodyText.toLowerCase().contains('legal') ||
                type == 'ws-upload-legal-diagram' ||
                type == 'ws-upload-sublegal-diagram' ||
                type == 'ws-update-legal-status' ||
                type == 'ws-set-legal-remark' ||
                type == 'legal_file_uploaded';

            final String route = isLegalType ? '/legal' : SocketService.routeFromNotificationType(type);

            String resolvedProjId = (projectId != null && projectId.isNotEmpty && projectId != referenceId) ? projectId : '';
            String resolvedProjName = projectName ?? '';

            if (resolvedProjId.isEmpty || resolvedProjId == referenceId || resolvedProjName.isEmpty) {
              final resolved = await SocketService.resolveProjectByBody(
                "$resolvedProjName $bodyText",
                referenceId: referenceId,
                permissionName: permissionName,
              );
              if (resolved != null && resolved['id'] != null && resolved['id']!.isNotEmpty) {
                resolvedProjId = resolved['id']!;
                resolvedProjName = resolved['name'] ?? resolvedProjName;
              }
            }

            if (resolvedProjId.isEmpty && referenceId != null) {
              resolvedProjId = referenceId;
            }
            
            final payload = jsonEncode({
              'route': route,
              'args': {
                'msg': bodyText,
                'project_id': resolvedProjId,
                'notification_type': type ?? (isLegalType ? 'legal' : ''),
                'project_name': resolvedProjName,
                'towar_name': rawTower ?? '',
                'project_location': '',
                'response': {
                  'project_id': resolvedProjId,
                  'permission_id': referenceId,
                  'legal_id': referenceId,
                  'wo_order_id': referenceId,
                  'wo_order_no': referenceId,
                  'slab_id': referenceId,
                  'towar_id': message.data['towar_id'] ?? message.data['tower_id'] ?? rawRespMap['towar_id'] ?? rawRespMap['tower_id'],
                  'category_id': categoryId,
                }
              }
            });

            _pendingTerminatedNotificationPayload = payload;
            if (_loginCheckCompleted) {
              _triggerPendingNotification();
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error handling initial message: $e");
            }
          }
        }
      });
    }

    checkLogin();

    _checkSilently();
  }

  Future<void> _checkSilently() async {
    // 1. Safety Gate: Skip if we are in Debug mode or just developing
    // kReleaseMode is from 'package:flutter/foundation.dart';
    if (!kReleaseMode || Platform.isIOS || Platform.isAndroid) {
      print("Skipping Velopack check in Debug mode.");
      return;
    }

    try {
      // 2. This will only run in the real installed .exe
      bool available = await isUpdateAvailable(
        url: "http://skrite.com/releases",
      );

      if (available && mounted) {
        // Show Update Page...
      }
    } catch (e) {
      // 3. Catch the 'Not properly installed' exception gracefully
      debugPrint(
        "Velopack not initialized: App probably not installed via Setup.exe",
      );
    }
  }

  Future<void> checkInternet() async {
    final bool isConnected =
        await InternetConnectionChecker.instance.hasConnection;

    if (isConnected) {
      Webforceupdate();
    } else {
      setState(() {
        page = NoInternetConnectionPage(callback: callback);
      });
    }
  }

  void callback() {
    checkInternet();
  }

  void checkLogin() async {
    // Prevent re-entrance if we've already run the initial login flow
    if (_loginCheckGuard) return;
    _loginCheckGuard = true;
    final SharedPreferences prefs = await _prefs;

    // Check if this is a fresh install
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      await prefs.clear();
      await prefs.setBool('isFirstRun', false);
      setState(() {
        page = TutorialScreen();
        _loginCheckCompleted = true;
      });
      return;
    }

    if (prefs.containsKey('userId')) {
      String? userId = prefs.getString('userId');
      if (userId != null) {
        NotificationService.registerFCMToken();
        setState(() {
          page = const SideMenuScreen();
          _loginCheckCompleted = true;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          _triggerPendingNotification();
        });
      } else {
        setState(() {
          page = TutorialScreen();
          _loginCheckCompleted = true;
        });
      }
    } else {
      setState(() {
        page = TutorialScreen();
        _loginCheckCompleted = true;
      });
    }

    // Run network checks in background after UI is shown
    Future.delayed(const Duration(milliseconds: 100), () {
      checkInternet();
    });
  }

  // VersionCheck versionCheck = VersionCheck();
  // Future checkVersion() async {
  //   versionCheck = await VersionCheck(
  //     packageName: Platform.isMacOS
  //         ? 'com.stallionbuildllp.stallion'
  //         : 'com.stallionbuildllp.stallion',
  //     packageVersion: '2.3.7',
  //     showUpdateDialog: customShowUpdateDialog,
  //     country: 'in',
  //   ).checkVersion(context);
  // }

  Future<void> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    String latestVersion = "2.5.3";
    if (isUpdateAvailable1(latestVersion, currentVersion)) {
      customShowUpdateDialog(context, latestVersion);
    }
  }

  bool isUpdateAvailable1(String currentVersion, String latestVersion) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> latestParts = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > (i < currentParts.length ? currentParts[i] : 0)) {
        return true; // A higher version is available
      }
    }
    return false;
  }

  void customShowUpdateDialog(BuildContext context, String latestVersion) {
    // if (versionCheck.packageVersion != null &&
    //     versionCheck.storeVersion != null) {
    setState(() {
      page = const ForcefullyUpdate();
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        scrollBehavior: Platform.isMacOS
            ? const MaterialScrollBehavior()
            : MyCustomScrollBehavior(),
        title: 'Stallion',
        locale: const Locale('en', 'IN'),
        supportedLocales: const [
          Locale('en', 'IN'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // navigatorObservers: [FlutterSmartDialog.observer],
        // builder: FlutterSmartDialog.init(),
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.white,
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
          useMaterial3: true,
          primarySwatch: primaryBlack,
          fontFamily: 'HelveticaNeue',
        ),
        /*theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: primaryBlack,
          fontFamily: 'HelveticaNeue'),*/
        home: LoaderOverlay(
            useDefaultLoading: false,
            overlayWidgetBuilder: (_) => const Center(
                child: SpinKitRing(
                    lineWidth: 5.0, color: Colors.black, size: 50.0)),
            child: page),
        routes: <String, WidgetBuilder>{
          // Set routes for using the Navigator.
          '/tutorial': (BuildContext context) => TutorialScreen(),
          '/dashboard': (BuildContext context) => const SideMenuScreen(),
          '/permissions': (BuildContext context) => Permissions(),
          '/legal': (BuildContext context) => LegalScreen(),
          '/budgetScreen': (BuildContext context) => BudgetScreen(),
          '/sopScreen': (BuildContext context) => SopScreen(),
          '/sopDocsScreen': (BuildContext context) => const SopDocsScreen(),
          '/tenantManagementScreen': (BuildContext context) =>
              TenantManagementList(),
          '/statusOfSupplyViewScreen': (BuildContext context) =>
              StatusOfSupplyView(),
          '/orderHistoryViewScreen': (BuildContext context) =>
              OrderHistoryView(),
          '/myContractsDetailViewScreen': (BuildContext context) =>
              MyContractsDetailView(),
          '/dailyProgressReportScreen': (BuildContext context) =>
              DailyProgressReport(),
          '/checklistScreen': (BuildContext context) => CheckListScreen(),
          '/issueRccReportScreen': (BuildContext context) => IssueRccReport(),
          '/architechCertificate': (BuildContext context) =>
              ArchitechCertificate(),
          '/checkListMasonryScreen': (BuildContext context) =>
              CheckListMasonryScreen(),
          '/issueMasonryReportScreen': (BuildContext context) =>
              IssueMasonryReport(),
          '/masonryStatusScreen': (BuildContext context) =>
              MasonryStatusScreen(),
          '/poRequestedViewScreen': (BuildContext context) => PoRequestedView(),
          '/woRequestedViewScreen': (BuildContext context) => WoRequestedView(),
          '/paymentRequestedViewScreen': (BuildContext context) =>
              PaymentRequestedView(),
          '/taskManagerScreen': (BuildContext context) => const TaskManagerView(),
        },
        debugShowCheckedModeBanner: false);
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class ApiFailWid extends StatefulWidget {
  String? title;
  ApiFailWid({super.key, this.title});

  @override
  State<ApiFailWid> createState() => _ApiFailWidState();
}

class _ApiFailWidState extends State<ApiFailWid> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Stallion",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              widget.title ?? '',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
