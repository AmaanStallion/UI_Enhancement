// import 'dart:io';
// import 'package:system_tray/system_tray.dart';
// import 'package:window_manager/window_manager.dart';
// import 'socket_service.dart';

// class TrayService {
//   static final SystemTray _tray = SystemTray();
//   static bool _allowExit = false;

//   static Future<void> init() async {
//     // Ensure window manager initialized
//     await windowManager.ensureInitialized();

//     // Prevent default close behavior
//     await windowManager.setPreventClose(true);

//     // Show window
//     await windowManager.show();

//     // Add listener to handle window close (hide to tray)
//     windowManager.addListener(_WindowCloseListener());

//     // Initialize tray icon
//     final iconPath = Platform.isWindows ? 'assets/icon.ico' : 'assets/icon.png';
//     await _tray.initSystemTray(title: 'Stallion_Buildtech', iconPath: iconPath);
//   }

//   /// Show window and bring to focus
//   static Future<void> showWindow() async {
//     if (!await windowManager.isVisible()) {
//       await windowManager.show();
//     }
//     await windowManager.focus();
//   }

//   /// Exit app completely (disconnect WebSocket and close)
//   static Future<void> exitApp() async {
//     print('🛑 Exiting app completely...');

//     try {
//       // Disconnect WebSocket
//       SocketService.disconnect();

//       // Set flag to allow close
//       _allowExit = true;

//       // Allow window to close
//       await windowManager.setPreventClose(false);

//       // Close window first
//       await windowManager.close();

//       // Small delay to ensure close event is processed
//       await Future.delayed(const Duration(milliseconds: 100));

//       // Then destroy
//       await windowManager.destroy();

//       // Exit the app
//       exit(0);
//     } catch (e) {
//       print('❌ Error during exit: $e');
//       exit(0);
//     }
//   }

//   /// Set allow exit flag
//   static void setAllowExit(bool value) {
//     _allowExit = value;
//   }

//   /// Get allow exit flag
//   static bool getAllowExit() {
//     return _allowExit;
//   }
// }

// /// Separate listener class to handle window close
// class _WindowCloseListener extends WindowListener {
//   @override
//   void onWindowClose() {
//     print('✖️ Close button clicked');

//     print('✖️ Close button clicked');

//     // If exitApp was called, allow close
//     if (TrayService.getAllowExit()) {
//       return;
//     }

//     // Otherwise, hide window to tray (keep WebSocket alive)
//     print('📦 Hiding window to system tray, WebSocket stays alive');
//     _hideWindowToTray();

//     // TODO: implement onWindowClose
//     super.onWindowClose();
//   }

//   @override
//   void onClose() {
//     print('✖️ Close button clicked');

//     // If exitApp was called, allow close
//     if (TrayService.getAllowExit()) {
//       return;
//     }

//     // Otherwise, hide window to tray (keep WebSocket alive)
//     print('📦 Hiding window to system tray, WebSocket stays alive');
//     _hideWindowToTray();
//   }

//   /// Helper method to hide window
//   Future<void> _hideWindowToTray() async {
//     try {
//       await windowManager.hide();
//       print('✅ Window hidden to tray');
//     } catch (e) {
//       print('❌ Error hiding window: $e');
//     }
//   }
// }

import 'dart:io';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'socket_service.dart';

class TrayService {
  static final SystemTray _tray = SystemTray();
  static bool _allowExit = false;
  static bool _isHiddenToTray = false;

  static Future<void> init() async {
    if (Platform.isIOS || Platform.isAndroid) return;
    await windowManager.ensureInitialized();

    // Prevent default close behavior
    await windowManager.setPreventClose(true);

    // Add close listener
    windowManager.addListener(_WindowCloseListener());

    // Init tray icon
    final iconPath = Platform.isWindows ? 'assets/icon.ico' : 'assets/icon.png';

    await _tray.initSystemTray(
      title: 'Stallion_Buildtech',
      iconPath: iconPath,
    );

    // // Optional: clicking tray icon restores window
    // _tray.registerSystemTrayEventHandler((eventName) async {
    //   if (eventName == kSystemTrayEventClick) {
    //     await restoreWindow();
    //   }
    // });
    // Clicking tray icon restores window
    _tray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == 'click') {
        await restoreWindow();
      }
    });
  }

  /// Restore window (used by relaunch, tray click, notifications)
  static Future<void> restoreWindow() async {
    if (Platform.isIOS || Platform.isAndroid) return;
    if (_isHiddenToTray || !await windowManager.isVisible()) {
      await windowManager.show();
    }

    await windowManager.focus();
    _isHiddenToTray = false;
  }

  /// Exit app completely
  static Future<void> exitApp() async {
    print('🛑 Exiting app completely...');

    try {
      SocketService.disconnect();

      if (Platform.isIOS || Platform.isAndroid) {
        exit(0);
      }

      _allowExit = true;

      await windowManager.setPreventClose(false);
      await windowManager.destroy();

      exit(0);
    } catch (e) {
      print('❌ Error during exit: $e');
      exit(0);
    }
  }

  static bool getAllowExit() => _allowExit;

  static void _markHidden() {
    _isHiddenToTray = true;
  }
}

/// Handles window close → hide to tray
class _WindowCloseListener extends WindowListener {
  @override
  void onWindowClose() async {
    if (TrayService.getAllowExit()) return;

    print('📦 Hiding window to system tray');
    await windowManager.hide();
    TrayService._markHidden();
  }
}
