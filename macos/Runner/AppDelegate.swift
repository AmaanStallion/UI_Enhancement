import Cocoa
import FlutterMacOS
import UserNotifications

@main
class AppDelegate: FlutterAppDelegate {

  private var notificationChannel: FlutterMethodChannel?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Disable App Nap so macOS doesn't throttle APNS delivery
    ProcessInfo.processInfo.disableAutomaticTermination("Receiving push notifications")
    ProcessInfo.processInfo.disableSuddenTermination()
    ProcessInfo.processInfo.beginActivity(
      options: [.userInitiated, .idleSystemSleepDisabled],
      reason: "Receiving real-time push notifications"
    )

    // Register for remote notifications with APNS
    NSApplication.shared.registerForRemoteNotifications()

    // Set notification delegate BEFORE super
    UNUserNotificationCenter.current().delegate = self

    super.applicationDidFinishLaunching(notification)

    // Set up method channel AFTER super (Flutter engine is now ready)
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      for window in NSApplication.shared.windows {
        if let flutterVC = window.contentViewController as? FlutterViewController {
          self.notificationChannel = FlutterMethodChannel(
            name: "com.stallion.apns_notifications",
            binaryMessenger: flutterVC.engine.binaryMessenger
          )
          NSLog("✅ APNS method channel initialized")
          return
        }
      }
      NSLog("⚠️ Could not find FlutterViewController for method channel")
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func application(_ application: NSApplication,
                             didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    NSLog("✅ APNS registered with token: \(tokenString)")
  }

  override func application(_ application: NSApplication,
                             didFailToRegisterForRemoteNotificationsWithError error: Error) {
    NSLog("❌ APNS registration failed: \(error.localizedDescription)")
  }

  // Handle incoming remote notification data (background delivery)
  override func application(_ application: NSApplication,
                             didReceiveRemoteNotification userInfo: [String: Any]) {
    NSLog("📬 didReceiveRemoteNotification: \(userInfo)")
    forwardToFlutter(userInfo: userInfo)
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let content = notification.request.content
    NSLog("📬 willPresent: title='\(content.title)' body='\(content.body)'")

    // ALWAYS forward to Flutter for local notification display
    forwardToFlutter(title: content.title, body: content.body)

    // Show native banner (works when app is minimized/not focused)
    if #available(macOS 11.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    NSLog("📬 Notification clicked")
    completionHandler()
  }

  // MARK: - Safe Flutter forwarding (only simple strings, never crashes)
  private func forwardToFlutter(title: String = "", body: String = "") {
    guard !body.isEmpty else { return }
    // Only pass simple String values - never pass userInfo/dictionaries
    let safeArgs: [String: String] = ["title": title, "body": body]
    notificationChannel?.invokeMethod("onAPNSNotification", arguments: safeArgs)
  }

  private func forwardToFlutter(userInfo: [String: Any]) {
    let title = userInfo["title"] as? String
        ?? (userInfo["aps"] as? [String: Any])?["alert"] as? String
        ?? (((userInfo["aps"] as? [String: Any])?["alert"]) as? [String: Any])?["title"] as? String
        ?? ""
    let body = (((userInfo["aps"] as? [String: Any])?["alert"]) as? [String: Any])?["body"] as? String
        ?? userInfo["body"] as? String
        ?? userInfo["message"] as? String
        ?? ""
    forwardToFlutter(title: title, body: body)
  }
}
