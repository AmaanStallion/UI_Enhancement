import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stallion/main.dart';
import 'package:stallion/utils/api_network_call.dart';
import 'package:stallion/utils/app_url.dart';
import 'package:stallion/websocket/socket_service.dart';

/// Service that periodically checks if the user's portal_access has been
/// revoked by the admin. If revoked, the user is force-logged out with a
/// message dialog.
class PortalAccessService {
  static Timer? _pollingTimer;
  static bool _isLoggingOut = false;

  /// Polling interval — how often we call /auth/me to check portal_access.
  static const Duration _pollInterval = Duration(seconds: 30);

  /// Start periodic portal access checking.
  /// Call this after the user is logged in and on the main screen.
  static void startMonitoring() {
    // Cancel any existing timer first
    stopMonitoring();
    _isLoggingOut = false;

    if (kDebugMode) {
      print('🔒 PortalAccessService: Monitoring started (every ${_pollInterval.inMinutes} min)');
    }

    // Run the first check after a short delay (don't block init)
    _pollingTimer = Timer.periodic(_pollInterval, (_) {
      _checkPortalAccess();
    });
  }

  /// Stop periodic checking. Call on logout or dispose.
  static void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    if (kDebugMode) {
      print('🔒 PortalAccessService: Monitoring stopped');
    }
  }

  /// Check /auth/me for portal_access status.
  static Future<void> _checkPortalAccess() async {
    // Guard: don't check if already logging out
    if (_isLoggingOut) return;

    try {
      final handler = NetworkHandler();
      final response = await handler.get(
        AppUrl.authMe,
        skipPortalAccessCheck: true, // Avoid infinite loop
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final bool portalAccess = decoded['data']['portal_access'] ?? true;

          if (!portalAccess) {
            if (kDebugMode) {
              print('🔒 PortalAccessService: portal_access is FALSE — forcing logout');
            }
            await forceLogout();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔒 PortalAccessService: Error checking portal access: $e');
      }
    }
  }

  /// Force-logout the user: clear session, disconnect socket, navigate to
  /// login, and show an informational dialog.
  static Future<void> forceLogout({
    bool isAccountDisabled = true,
    bool isLogoutAllDevices = false,
  }) async {
    // Guard: prevent multiple concurrent logouts
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      // 1. Stop monitoring
      stopMonitoring();

      // 2. Disconnect WebSocket
      SocketService.disconnect();

      // 3. Clear all stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 4. Navigate to the login/tutorial screen
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushNamedAndRemoveUntil('/tutorial', (route) => false);

        // 5. Show the appropriate dialog after navigation completes
        Future.delayed(const Duration(milliseconds: 500), () {
          if (isLogoutAllDevices) {
            _showLogoutAllDevicesDialog();
          } else if (isAccountDisabled) {
            _showDisabledAccountDialog();
          } else {
            _showSessionExpiredDialog();
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔒 PortalAccessService: Error during force logout: $e');
      }
      _isLoggingOut = false;
    }
  }

  /// Perform logout of all devices API call and local logout cleanup
  static Future<void> performLogoutAllDevices() async {
    try {
      await NetworkHandler().logoutAllDevices();
    } catch (e) {
      if (kDebugMode) {
        print('🔒 PortalAccessService: Error calling logout-all-devices API: $e');
      }
    }

    stopMonitoring();
    SocketService.disconnect();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', "");
    prefs.setString('userName', "");
    prefs.setString('mobileNo', "");
    prefs.setString('companyName', "");
    prefs.setString('companyId', "");
    prefs.setString('profileImg', "");
    prefs.setString('desingnation', "");
    prefs.setString('userType', "");
    prefs.setString('userProfile', "");
    await prefs.clear();

    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamedAndRemoveUntil('/tutorial', (route) => false);
    }
  }

  /// Show a dialog informing the user they were logged out from all devices.
  static void _showLogoutAllDevicesDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
              const SizedBox(height: 16),
              const Icon(Icons.devices, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Logged Out of All Devices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'You have been logged out because a logout from all devices was initiated.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _isLoggingOut = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show a dialog informing the user their session has expired.
  static void _showSessionExpiredDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
              const SizedBox(height: 16),
              const Icon(Icons.info_outline, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Session Expired',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your session has expired. Please log in again to continue.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _isLoggingOut = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show a dialog informing the user their account was disabled.
  static void _showDisabledAccountDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/Icon-512.png', height: 80, fit: BoxFit.fitWidth),
              const SizedBox(height: 16),
              const Icon(Icons.block, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Account Disabled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account was disabled by the admin. Please contact admin.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _isLoggingOut = false;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
