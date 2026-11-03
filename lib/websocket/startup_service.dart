import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service to manage app auto-start on system boot
class StartupService {
  /// Enable app to start on system boot
  static Future<void> enableAutoStart() async {
    try {
      if (Platform.isWindows) {
        await _enableWindowsAutoStart();
      } else if (Platform.isMacOS) {
        await _enableMacOSAutoStart();
      } else if (Platform.isLinux) {
        await _enableLinuxAutoStart();
      }
      debugPrint('✅ Auto-start enabled');
    } catch (e) {
      debugPrint('❌ Auto-start error: $e');
    }
  }

  /// Disable app from starting on system boot
  static Future<void> disableAutoStart() async {
    try {
      if (Platform.isWindows) {
        await _disableWindowsAutoStart();
      } else if (Platform.isMacOS) {
        await _disableMacOSAutoStart();
      } else if (Platform.isLinux) {
        await _disableLinuxAutoStart();
      }
      debugPrint('✅ Auto-start disabled');
    } catch (e) {
      debugPrint('❌ Auto-start disable error: $e');
    }
  }

  // ====== Windows Implementation ======
  static Future<void> _enableWindowsAutoStart() async {
    try {
      final executablePath = Platform.resolvedExecutable;
      final regPath =
          'HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run';
      final appName = 'Stallion_Buildtech';

      // Using reg.exe to add registry entry
      final result = await Process.run('reg', [
        'add',
        regPath,
        '/v',
        appName,
        '/t',
        'REG_SZ',
        '/d',
        '"$executablePath"',
        '/f',
      ]);

      if (result.exitCode == 0) {
        debugPrint('📝 Windows: Added auto-start to registry');
      } else {
        debugPrint('⚠️ Windows: Registry add failed: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('❌ Windows auto-start error: $e');
    }
  }

  static Future<void> _disableWindowsAutoStart() async {
    try {
      final regPath =
          'HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run';
      final appName = 'Stallion_Buildtech';

      final result = await Process.run('reg', [
        'delete',
        regPath,
        '/v',
        appName,
        '/f',
      ]);

      if (result.exitCode == 0) {
        debugPrint('📝 Windows: Removed auto-start from registry');
      } else {
        debugPrint('⚠️ Windows: Registry delete failed: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('❌ Windows auto-start disable error: $e');
    }
  }

  // ====== macOS Implementation ======
  static Future<void> _enableMacOSAutoStart() async {
    try {
      final homeDir = Platform.environment['HOME'];
      final launchAgentsDir = '$homeDir/Library/LaunchAgents';

      // Create LaunchAgents directory if it doesn't exist
      await Directory(launchAgentsDir).create(recursive: true);

      final bundleIdentifier = 'com.stallion.buildtech';
      final plistPath = '$launchAgentsDir/$bundleIdentifier.plist';
      final executablePath = Platform.resolvedExecutable;

      // Create plist content
      final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$bundleIdentifier</string>
    <key>ProgramArguments</key>
    <array>
        <string>$executablePath</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/$bundleIdentifier.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/$bundleIdentifier.error.log</string>
</dict>
</plist>''';

      await File(plistPath).writeAsString(plistContent);

      // Set permissions
      await Process.run('chmod', ['644', plistPath]);

      debugPrint('📝 macOS: Created LaunchAgent plist');
    } catch (e) {
      debugPrint('❌ macOS auto-start error: $e');
    }
  }

  static Future<void> _disableMacOSAutoStart() async {
    try {
      final homeDir = Platform.environment['HOME'];
      final bundleIdentifier = 'com.stallion.buildtech';
      final plistPath = '$homeDir/Library/LaunchAgents/$bundleIdentifier.plist';

      final file = File(plistPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('📝 macOS: Removed LaunchAgent plist');
      }
    } catch (e) {
      debugPrint('❌ macOS auto-start disable error: $e');
    }
  }

  // ====== Linux Implementation ======
  static Future<void> _enableLinuxAutoStart() async {
    try {
      final homeDir = Platform.environment['HOME'];
      final autoStartDir = '$homeDir/.config/autostart';

      // Create autostart directory if it doesn't exist
      await Directory(autoStartDir).create(recursive: true);

      final desktopFilePath = '$autoStartDir/ws_tray_demo.desktop';
      final executablePath = Platform.resolvedExecutable;

      // Create .desktop file
      final desktopContent = '''[Desktop Entry]
Type=Application
Name=WS Tray Demo
Comment=WebSocket notification listener
Exec=$executablePath
Icon=application-x-executable
Terminal=false
Categories=Utility;
X-GNOME-Autostart-enabled=true
''';

      await File(desktopFilePath).writeAsString(desktopContent);

      // Make executable
      await Process.run('chmod', ['+x', desktopFilePath]);

      debugPrint('📝 Linux: Created .desktop autostart file');
    } catch (e) {
      debugPrint('❌ Linux auto-start error: $e');
    }
  }

  static Future<void> _disableLinuxAutoStart() async {
    try {
      final homeDir = Platform.environment['HOME'];
      final desktopFilePath = '$homeDir/.config/autostart/ws_tray_demo.desktop';

      final file = File(desktopFilePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('📝 Linux: Removed .desktop autostart file');
      }
    } catch (e) {
      debugPrint('❌ Linux auto-start disable error: $e');
    }
  }

  /// Check if auto-start is currently enabled
  static Future<bool> isAutoStartEnabled() async {
    try {
      if (Platform.isWindows) {
        return await _isWindowsAutoStartEnabled();
      } else if (Platform.isMacOS) {
        return await _isMacOSAutoStartEnabled();
      } else if (Platform.isLinux) {
        return await _isLinuxAutoStartEnabled();
      }
    } catch (e) {
      debugPrint('❌ Check auto-start error: $e');
    }
    return false;
  }

  static Future<bool> _isWindowsAutoStartEnabled() async {
    try {
      final regPath =
          'HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run';
      final appName = 'Stallion_Buildtech';

      final result = await Process.run('reg', [
        'query',
        regPath,
        '/v',
        appName,
      ]);

      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _isMacOSAutoStartEnabled() async {
    try {
      final homeDir = Platform.environment['HOME'];
      final bundleIdentifier = 'com.stallion.buildtech';
      final plistPath = '$homeDir/Library/LaunchAgents/$bundleIdentifier.plist';

      return await File(plistPath).exists();
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _isLinuxAutoStartEnabled() async {
    try {
      final homeDir = Platform.environment['HOME'];
      final desktopFilePath = '$homeDir/.config/autostart/ws_tray_demo.desktop';

      return await File(desktopFilePath).exists();
    } catch (e) {
      return false;
    }
  }
}
