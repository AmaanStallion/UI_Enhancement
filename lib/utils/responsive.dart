import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/widgets.dart';

extension ResponsiveContext on BuildContext {
  /// Returns true if the device behaves like a mobile phone.
  /// 
  /// Under this rule:
  /// - iOS/Android devices (including iPad and iPhone) ALWAYS behave like a phone
  ///   in both portrait and landscape.
  /// - Desktop platforms (macOS/Windows/Linux) and Desktop Web ALWAYS behave like desktop
  ///   (shows sidebar) because the user manages layout width on desktop.
  bool get isMobile {
    if (kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS ||
             defaultTargetPlatform == TargetPlatform.android;
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return false;
    }
    return Platform.isIOS || Platform.isAndroid;
  }
}

class Responsive {
  static bool isMobile(BuildContext context) => context.isMobile;
  static bool isDesktop(BuildContext context) => !context.isMobile;
}

