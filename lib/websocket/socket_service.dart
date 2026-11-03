import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:stallion/main.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'notification_service.dart';
import 'debug_service.dart';
import 'portal_access_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _initialized = false;
  static String? currentActiveTowerId;

  // Cache of tower active states: towerId -> isActive
  static final Map<String, bool> _towerActiveStates = {};

  // Broadcast stream to notify widgets of tower status changes
  static final StreamController<Map<String, dynamic>> _statusController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get towerStatusStream => _statusController.stream;

  // Broadcast stream to notify widgets of permission note status changes
  static final StreamController<Map<String, dynamic>> _permissionController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get permissionStatusStream => _permissionController.stream;

  static bool isTowerActive(String towerId, {bool defaultValue = true}) {
    if (towerId.isEmpty) return defaultValue;
    return _towerActiveStates[towerId] ?? defaultValue;
  }

  static void setTowerActive(String towerId, bool isActive) {
    if (towerId.isEmpty) return;
    _towerActiveStates[towerId] = isActive;
  }

  static void start(String token) {
    _connect(token);
  }

  static void _connect(String token) {
    try {
      // Clean up any existing connection
      _socket?.disconnect();
      _socket?.dispose();

      // Ensure base URL doesn't have trailing slash for socket.io client connection compatibility
      final String baseUrl = AppUrl.baseURL.endsWith('/')
          ? AppUrl.baseURL.substring(0, AppUrl.baseURL.length - 1)
          : AppUrl.baseURL;

      DebugService.log('Attempting Socket.IO connection to $baseUrl...');

      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .enableReconnection()
            .build(),
      );

      _socket!.onConnect((_) {
        print('✅ SOCKET_STATUS: Connected successfully');
        DebugService.log('✅ Socket.IO connected and authenticated successfully');
      });

      _socket!.onDisconnect((data) {
        print('🔌 SOCKET_STATUS: Disconnected, data=$data');
        DebugService.log('🔌 Socket.IO disconnected');
      });

      _socket!.onConnectError((err) {
        print('❌ SOCKET_STATUS: Connection error: $err');
        DebugService.log('❌ Socket.IO connection error: $err');
      });

      _socket!.onError((err) {
        print('❌ SOCKET_STATUS: Socket error: $err');
        DebugService.log('❌ Socket.IO error: $err');
      });

      // Wildcard listener to capture and print EVERY incoming event
      _socket!.onAny((event, data) {
        print('🔔 SOCKET_ANY_EVENT: event="$event", data=$data');
        DebugService.log('🔔 SOCKET_ANY_EVENT: event="$event", data=$data');

        // On macOS (and Windows), use onAny as a fallback to catch
        // notification-bearing events since FCM push isn't available
        // on desktop without APNS certificates.
        if (Platform.isMacOS || Platform.isWindows) {
          _tryShowNotificationFromAnyEvent(event, data);
        }
      });

      // Register the new tower:status-changed listener and its variations
      _socket!.on('tower:status-changed', (data) {
        _handleTowerStatusChanged(data);
      });
      _socket!.on('tower-status-changed', (data) {
        _handleTowerStatusChanged(data);
      });
      _socket!.on('tower_status_changed', (data) {
        _handleTowerStatusChanged(data);
      });

      // Register the new permission:note-status-changed listener
      _socket!.on('permission:note-status-changed', (data) {
        _handlePermissionNoteStatusChanged(data);
      });

      // Register auth:logout-all-devices listener
      _socket!.on('auth:logout-all-devices', (data) {
        _handleLogoutAllDevices(data);
      });
      _socket!.on('auth_logout_all_devices', (data) {
        _handleLogoutAllDevices(data);
      });

      // Retain backwards compatibility for notification events if they are ever triggered via socket
      _socket!.on('notification', (data) {
        _onNotificationReceived(data);
      });
      _socket!.on('notifications', (data) {
        _onNotificationReceived(data);
      });
      _socket!.on('new_notification', (data) {
        _onNotificationReceived(data);
      });
      _socket!.on('new-notification', (data) {
        _onNotificationReceived(data);
      });
      _socket!.on('notification:new', (data) {
        _onNotificationReceived(data);
      });
      _socket!.on('push_notification', (data) {
        _onNotificationReceived(data);
      });
      _socket!.on('user_notification', (data) {
        _onNotificationReceived(data);
      });

      _socket!.connect();
      _initialized = true;
    } catch (e) {
      DebugService.log('❌ WS connect error (exception): $e');
    }
  }

  static void _handleTowerStatusChanged(dynamic data) {
    DebugService.log('🔔 Received tower:status-changed event: $data');
    print('🔔 SOCKET_EVENT: Received tower:status-changed event raw data: $data');
    try {
      if (data == null) return;
      
      // If data is a List (common in Dart Socket.IO callbacks), get the first element
      dynamic rawPayload = data;
      if (data is List && data.isNotEmpty) {
        rawPayload = data.first;
      }
      
      // Decode if it is a JSON string
      final decoded = rawPayload is String ? jsonDecode(rawPayload) : rawPayload;
      if (decoded == null) return;
      
      // Unpack nested "data" key if present
      final payload = (decoded is Map && decoded.containsKey('data') && decoded['data'] is Map) 
          ? decoded['data'] 
          : decoded;

      final String? towerId = (payload['towerId'] ?? payload['tower_id'])?.toString();
      final String? towerName = (payload['towerName'] ?? payload['tower_name'])?.toString();
      final String? projectId = (payload['projectId'] ?? payload['project_id'])?.toString();
      final dynamic activeVal = payload['isActive'] ?? payload['is_active'];
      final bool isActive = activeVal == true || activeVal?.toString() == 'true';

      print('🔔 SOCKET_EVENT PARSED: towerId=$towerId, towerName=$towerName, isActive=$isActive, projectId=$projectId');

      if (towerId != null) {
        setTowerActive(towerId, isActive);
        _statusController.add({
          'towerId': towerId,
          'towerName': towerName,
          'projectId': projectId,
          'isActive': isActive,
        });

        // If the tower is deactivated and it matches the current active tower screen
        if (!isActive && towerId == currentActiveTowerId) {
          _showTowerDeactivatedDialog(towerName ?? towerId);
        }
      }
    } catch (e) {
      DebugService.log('❌ Error handling tower status change: $e');
      print('❌ SOCKET_EVENT ERROR: $e');
    }
  }

  static void _handleLogoutAllDevices(dynamic data) {
    DebugService.log('🔒 Received auth:logout-all-devices event: $data');
    print('🔒 SOCKET_EVENT: Received auth:logout-all-devices event raw data: $data');
    PortalAccessService.forceLogout(isAccountDisabled: false, isLogoutAllDevices: true);
  }

  static void _handlePermissionNoteStatusChanged(dynamic data) {
    DebugService.log('🔔 Received permission:note-status-changed event: $data');
    print('🔔 SOCKET_EVENT: Received permission:note-status-changed event raw data: $data');
    try {
      if (data == null) return;

      dynamic rawPayload = data;
      if (data is List && data.isNotEmpty) {
        rawPayload = data.first;
      }

      final decoded = rawPayload is String ? jsonDecode(rawPayload) : rawPayload;
      if (decoded == null) return;

      final payload = (decoded is Map && decoded.containsKey('data') && decoded['data'] is Map) 
          ? decoded['data'] 
          : decoded;

      final String? permissionId = (payload['permissionId'] ?? payload['permission_id'])?.toString();
      final String? permissionName = (payload['permissionName'] ?? payload['permission_name'])?.toString();
      final String? projectId = (payload['projectId'] ?? payload['project_id'])?.toString();
      final String? field = payload['field']?.toString(); // "permission_note", "demand_note", "receipt_note"
      final dynamic val = payload['value'];
      final bool value = val == true || val?.toString() == 'true';

      print('🔔 SOCKET_EVENT PARSED: permissionId=$permissionId, permissionName=$permissionName, field=$field, value=$value, projectId=$projectId');

      if (permissionId != null && field != null) {
        _permissionController.add({
          'permissionId': permissionId,
          'permissionName': permissionName,
          'projectId': projectId,
          'field': field,
          'value': value,
        });
      }
    } catch (e) {
      DebugService.log('❌ Error handling permission note status change: $e');
      print('❌ SOCKET_EVENT ERROR: $e');
    }
  }

  static void _showTowerDeactivatedDialog(String towerName) {
    final navState = navigatorKey.currentState;
    if (navState != null) {
      navState.push(
        RawDialogRoute(
          barrierDismissible: false,
          barrierColor: Colors.black54,
          pageBuilder: (BuildContext dialogContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Alert'),
                  ],
                ),
                content: const Text(
                  'This tower is deactivated by the admin.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // pop dialog
                      navState.popUntil((route) {
                        return route.settings.name == '/dashboard' ||
                            route.isFirst;
                      });
                    },
                    child: const Text('OK', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  static void _onNotificationReceived(dynamic data) async {
    if (kDebugMode) {
      print("================= SOCKET.IO NOTIFICATION RAW PAYLOAD =================");
      print(data is String ? data : jsonEncode(data));
      print("======================================================================");
    }
    DebugService.log('📩 Received notification: $data');
    DebugService.trackMessage('received');

    // Prevent duplicate notifications on platforms that have native FCM (Android, iOS)
    if (Platform.isAndroid || Platform.isIOS) {
      DebugService.log('ℹ️ Ignored Socket.IO notification on mobile to prevent duplicate with FCM');
      return;
    }

    try {
      final decoded = data is String ? jsonDecode(data) : data;

      if (!_initialized) {
        DebugService.log('⚠️ Notification ignored: System not initialized');
        return;
      }

      final Map<String, dynamic> map = (decoded is Map) ? Map<String, dynamic>.from(decoded) : {};
      final dynamic notificationData = map['data'] ?? map['payload'] ?? map;

      final notificationType = (notificationData is Map) ? notificationData['notification_type'] : map['notification_type'];

      // ✅ Decide route dynamically
      final route = routeFromNotificationType(notificationType?.toString());

      // ✅ Encode route + full data
      final payload = jsonEncode({'route': route, 'args': notificationData});

      final String title = (map['title'] ?? map['notification_title'] ?? (notificationData is Map ? (notificationData['title'] ?? notificationData['notification_title']) : null))?.toString() ?? 'Stallion';
      final String body = (map['message'] ?? map['body'] ?? map['notification_body'] ?? (notificationData is Map ? (notificationData['message'] ?? notificationData['body'] ?? notificationData['notification_body']) : null))?.toString() ?? '';

      DebugService.log('🔔 Showing notification: title=$title, body=$body');
      DebugService.log('➡️ Route: $route');

      NotificationService.show(title, body, payload: payload);
    } catch (e) {
      DebugService.log('❌ Error processing notification message: $e');
    }
  }

  /// Fallback: inspect any socket event for notification-like content on desktop
  /// platforms where FCM push isn't available.
  static void _tryShowNotificationFromAnyEvent(String event, dynamic data) {
    // Skip known structural/status events that are NOT notifications
    const ignoredEvents = {
      'connected',
      'connect',
      'disconnect',
      'tower:status-changed',
      'tower-status-changed',
      'tower_status_changed',
      'permission:note-status-changed',
      'pong',
      'ping',
    };
    if (ignoredEvents.contains(event)) return;

    try {
      dynamic rawPayload = data;
      if (data is List && data.isNotEmpty) {
        rawPayload = data.first;
      }
      final decoded = rawPayload is String ? jsonDecode(rawPayload) : rawPayload;
      if (decoded == null || decoded is! Map) return;

      final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
      final dynamic nested = map['data'] ?? map['payload'];
      final Map<String, dynamic>? nestedMap = (nested is Map) ? Map<String, dynamic>.from(nested) : null;

      // Extract message/body from either top-level or nested data
      final String? body = map['message']?.toString() ??
          map['body']?.toString() ??
          map['notification_body']?.toString() ??
          nestedMap?['message']?.toString() ??
          nestedMap?['body']?.toString();

      if (body == null || body.trim().isEmpty) return;

      final String title = map['title']?.toString() ??
          map['notification_title']?.toString() ??
          nestedMap?['title']?.toString() ??
          'Stallion';

      final notificationType = nestedMap?['notification_type']?.toString() ??
          map['notification_type']?.toString();
      final route = routeFromNotificationType(notificationType);
      final payload = jsonEncode({'route': route, 'args': nestedMap ?? map});

      print('🔔 DESKTOP_FALLBACK: Showing notification from event="$event", title=$title, body=$body');
      NotificationService.show(title, body, payload: payload);
    } catch (e) {
      // Silently ignore parse errors for non-notification events
    }
  }

  static String routeFromNotificationType(String? type) {
    if (type == null) return '/';
    final t = type.toLowerCase();

    if (t.contains('legal') ||
        t == 'legal_file_uploaded' ||
        t == 'ws-upload-legal-diagram' ||
        t == 'ws-upload-sublegal-diagram' ||
        t == 'ws-update-legal-status' ||
        t == 'ws-set-legal-remark') {
      return '/legal';
    }

    if (t.contains('permission') || t.contains('permisson')) {
      return '/permissions';
    }

    switch (t) {
      case 'task_assigned':
      case 'meeting_task_assigned':
      case 'meeting-task-assigned':
      case 'meeting_task_assign':
      case 'meeting_task':
        return '/taskManagerScreen';
      case 'legal':
        return '/legal';
      case 'budget-set':
        return '/budgetScreen';
      case 'sop_submitted':
      case 'sop-submitted':
      case 'sop_submit':
      case 'sop_docs':
      case 'ws-sop-submitted':
        return '/sopDocsScreen';
      case 'ws-sop-list':
      case 'ws-sop-assign':
        return '/sopScreen';
      case 'tenant':
        return '/tenantManagementScreen';
      case 'partiallyordersupply':
        return '/statusOfSupplyViewScreen';
      case 'rccorderdeliver':
        return '/orderHistoryViewScreen';
      case 'wo-ceritify-work':
      case 'wo-certify-work':
      case 'wo_certify_work':
        return '/myContractsDetailViewScreen';
      case 'generatedpr':
        return '/dailyProgressReportScreen';
      case 'slab_check':
        return '/checklistScreen';
      case 'slaberrordetails':
        return '/issueRccReportScreen';
      case 'architech-certificate':
        return '/architechCertificate';
      case 'masnory_check':
        return '/checkListMasonryScreen';
      case 'masonryerrordetails':
        return '/issueMasonryReportScreen';
      case 'masonryokreport':
        return '/masonryStatusScreen';
      case 'rccverifyorder':
      case 'poRequestedViewScreen':
        return '/poRequestedViewScreen';
      case 'wo_authenticate':
      case 'wo-authenticate':
      case 'wo_assigned':
      case 'wo-assigned':
      case 'wo_issued':
      case 'wo-issued':
        return '/woRequestedViewScreen';
      default:
        return '/';
    }
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  static void setInitialized() {
    _initialized = true;
  }

  static Future<Map<String, String>?> resolveProjectByBody(
    String body, {
    String? referenceId,
    String? permissionName,
  }) async {
    try {
      final handler = NetworkHandler();
      final response = await handler.get(AppUrl.getMobileProjectList);
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        final List projectList = decoded['data']?['projects'] ?? decoded['data'] ?? [];

        if (projectList.isNotEmpty) {
          // 1. Search by project name matching body or permissionName
          final String textToSearch = "$body ${permissionName ?? ''}".toLowerCase();
          for (var item in projectList) {
            final String name = item['name'] ?? "";
            if (name.isNotEmpty && textToSearch.contains(name.toLowerCase())) {
              return {
                'id': item['id']?.toString() ?? "",
                'name': name,
              };
            }
          }

          // 2. Fallback lookup by referenceId in project legal permissions
          if (referenceId != null && referenceId.isNotEmpty) {
            for (var item in projectList) {
              final String projId = item['id']?.toString() ?? "";
              final String projName = item['name'] ?? "";
              if (projId.isEmpty) continue;

              try {
                await handler.ensureProjectContext(projId);
                final legalResp = await handler.get("${AppUrl.baseURL}legal-permissions/projects/$projId");
                if (legalResp != null && (legalResp.statusCode == 200 || legalResp.statusCode == 201)) {
                  final decodedLegal = json.decode(legalResp.body);
                  var rawData = decodedLegal['data'];
                  List perms = [];
                  if (rawData is List) {
                    perms = rawData;
                  } else if (rawData is Map && rawData['permissions'] is List) {
                    perms = rawData['permissions'];
                  }
                  for (var p in perms) {
                    if (p is Map) {
                      final String pId = p['id']?.toString() ?? "";
                      final String legId = p['legal_id']?.toString() ?? "";
                      final String projLegId = p['project_legal_id']?.toString() ?? "";
                      final String permId = p['permission_id']?.toString() ?? "";
                      if (pId == referenceId || legId == referenceId || projLegId == referenceId || permId == referenceId) {
                        return {
                          'id': projId,
                          'name': projName,
                        };
                      }
                    }
                  }
                }
              } catch (_) {}
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
