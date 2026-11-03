// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'tray_service.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   static bool _initialized = false;
//   static void Function(String? payload)? _onNotificationClick;

//   // static const String _appUserModelId = 'com.example.ws_tray_demo';
//   static const String _appUserModelId = 'com.stallion.buildtech';

//   static Future<void> init() async {
//     const windowsInit = WindowsInitializationSettings(
//       appUserModelId: _appUserModelId,
//       // guid: 'd3e0b5a1-8c9b-4d3c-a5b9-123456789abc',
//       guid: 'ba41e3da-7f33-439b-bb43-288806853bb6',

//       iconPath: 'windows/runner/resources/app_icon.ico',
//       appName: 'Stallion BuildTech',
//     );

//     const settings = InitializationSettings(windows: windowsInit);

//     await _notifications.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         await TrayService.showWindow();
//         _onNotificationClick?.call(response.payload);
//       },
//     );

//     _initialized = true;
//   }

//   static Future<void> show(String title, String body, {String? payload}) async {
//     if (!_initialized) return;

//     // ⚠️ NO parameters here for your version
//     const details = NotificationDetails(windows: WindowsNotificationDetails());

//     await _notifications.show(
//       DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
//       title,
//       body,
//       details,
//       payload: payload,
//     );
//   }

//   static void setOnNotificationClick(void Function(String? payload)? handler) {
//     _onNotificationClick = handler;
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'tray_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static void Function(String? payload)? _onNotificationClick;

  static const String _appUserModelId = 'com.stallion.buildtech';

  static Future<void> init() async {
    // Compute absolute icon path relative to executable
    final exePath = Platform.resolvedExecutable;
    final exeDir = path.dirname(exePath);
    final iconPath = path.join(exeDir, 'data', 'app_icon.ico');

    final windowsInit = WindowsInitializationSettings(
      appUserModelId: _appUserModelId,
      guid: 'ba41e3da-7f33-439b-bb43-288806853bb6',
      iconPath: iconPath,
      appName: 'Stallion BuildTech',
    );

    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );
    const androidInit = AndroidInitializationSettings('ic_notification');

    final settings = InitializationSettings(
      windows: windowsInit,
      macOS: darwinInit,
      iOS: darwinInit,
      android: androidInit,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Bring existing window to front
        // await TrayService.showWindow();
        await TrayService.restoreWindow();

        // Normal in-process notification click
        _onNotificationClick?.call(response.payload);
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'stallion_channel',
          'Stallion Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
        );
        await androidPlugin.createNotificationChannel(channel);
      }
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isMacOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    _initialized = true;
  }

  /// Called when a SECOND instance is launched (notification click)
  static void handleExternalArgs(List<String> args) {
    if (args.isEmpty) return;

    // Payload is usually passed as a single argument
    final payload = args.join(' ');

    // Bring window to front
    // TrayService.showWindow();
    TrayService.restoreWindow();

    // Forward payload to app router
    _onNotificationClick?.call(payload);
  }

  static bool shouldRemoveTitle(String? title, {String? payload}) {
    if (title != null && title.trim().isNotEmpty) {
      final lowerTitle = title.trim().toLowerCase();
      if (lowerTitle == 'sop submitted' ||
          lowerTitle == 'new task assigned' ||
          lowerTitle == 'task assigned' ||
          lowerTitle == 'new action item assigned' ||
          lowerTitle == 'action item assigned' ||
          lowerTitle == 'permission expiry alert' ||
          lowerTitle == 'permission expiry' ||
          lowerTitle == 'legal action alert' ||
          lowerTitle == 'legal action' ||
          lowerTitle.contains('sop submitted') ||
          lowerTitle.contains('new task assigned') ||
          lowerTitle.contains('action item assigned') ||
          lowerTitle.contains('permission expiry') ||
          lowerTitle.contains('legal action')) {
        return true;
      }
    }
    if (payload != null && payload.isNotEmpty) {
      try {
        final decoded = json.decode(payload);
        if (decoded is Map && decoded['args'] != null) {
          final args = decoded['args'];
          if (args is Map) {
            final type = args['notification_type']?.toString().toLowerCase();
            if (type == 'sop_submitted' ||
                type == 'sop-submitted' ||
                type == 'task_assigned' ||
                type == 'task-assigned' ||
                type == 'meeting_task_assigned' ||
                type == 'meeting-task-assigned' ||
                type == 'meeting_task_assign' ||
                type == 'meeting_task' ||
                type == 'permission_expiry' ||
                type == 'permission-expiry' ||
                type == 'legal_action' ||
                type == 'legal-action' ||
                type == 'legal_action_alert') {
              return true;
            }
          }
        }
      } catch (_) {}
    }
    return false;
  }

  static Future<void> show(
    String? title,
    String body, {
    String? payload,
  }) async {
    if (!_initialized) return;

    final bool removeTitle = shouldRemoveTitle(title, payload: payload);
    final String? sanitizedTitle = (removeTitle || title == null || title.trim().isEmpty)
        ? null
        : title.trim();

    final String? displayTitle = sanitizedTitle;
    final String displayBody = (body.trim().isNotEmpty) ? body : 'New notification received';

    final details = NotificationDetails(
      windows: const WindowsNotificationDetails(),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
      android: AndroidNotificationDetails(
        'stallion_channel',
        'Stallion Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          displayBody,
          contentTitle: displayTitle,
        ),
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      displayTitle,
      displayBody,
      details,
      payload: payload,
    );
  }

  static void setOnNotificationClick(
    void Function(String? payload)? handler,
  ) {
    _onNotificationClick = handler;
  }

  static void triggerNotificationClick(String? payload) {
    _onNotificationClick?.call(payload);
  }

  static Future<void> registerFCMToken() async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) return;
    if (Firebase.apps.isEmpty) return;

    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print("📋 FCM Permission authorizationStatus: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (Platform.isIOS || Platform.isMacOS) {
          await messaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
          String? apnsToken = await messaging.getAPNSToken();
          if (Platform.isIOS) {
            int retryCount = 0;
            while (apnsToken == null && retryCount < 10) {
              await Future.delayed(const Duration(seconds: 1));
              apnsToken = await messaging.getAPNSToken();
              retryCount++;
            }
          }
          print("📋 APNS Token retrieved: $apnsToken");
          if (apnsToken == null && Platform.isIOS) {
            if (kDebugMode) {
              print("Failed to get APNS token on iOS. FCM token cannot be generated.");
            }
            return;
          }
        }
        String? token;
        try {
          token = await messaging.getToken();
          print("📋 FCM token from getToken(): $token");
        } catch (e) {
          print("❌ Error getting FCM token: $e");
        }
        if (token == null && Platform.isMacOS) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          token = prefs.getString('macos_fallback_device_token');
          if (token == null || token.isEmpty) {
            token = "macos_desktop_${DateTime.now().millisecondsSinceEpoch}";
            await prefs.setString('macos_fallback_device_token', token);
          }
        }
        print("==================================================");
        print("🔥 DEVICE TOKEN FOR NOTIFICATIONS: $token");
        print("==================================================");
        if (token != null) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final userToken = prefs.getString('token');
          
          if (userToken != null && userToken.isNotEmpty) {
            final handler = NetworkHandler();
            final url = "${AppUrl.baseURL}notifications/register-token";
            
            final String platform;
            if (Platform.isAndroid) {
              platform = "android";
            } else {
              // macOS uses APNS just like iOS, so register as "ios"
              // to ensure the backend includes it in FCM push delivery
              platform = "ios";
            }
            final body = {
              "device_token": token,
              "platform": platform,
            };
            
            final response = await handler.post1(url, body);
            print("📋 Register Token Response status: ${response.statusCode}");
            print("📋 Register Token Response body: ${response.body}");
          } else {
            if (kDebugMode) {
              print("FCM Token registration skipped: user token is not available yet in SharedPreferences.");
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error registering FCM token: $e");
      }
    }
  }
}
