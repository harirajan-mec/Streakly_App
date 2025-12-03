import Flutter
import UIKit
import UserNotifications
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup widget communication channel
    let controller = window?.rootViewController as! FlutterViewController
    let widgetChannel = FlutterMethodChannel(
      name: "com.streakly.app/widget",
      binaryMessenger: controller.binaryMessenger
    )
    
    widgetChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "updateWidget":
        self.handleUpdateWidget(call: call, result: result)
      case "refreshWidget":
        self.handleRefreshWidget(result: result)
      case "clearWidgetData":
        self.handleClearWidgetData(result: result)
      case "getWidgetData":
        self.handleGetWidgetData(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleUpdateWidget(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "Arguments not found", details: nil))
      return
    }
    
    let streakCount = args["streakCount"] as? Int ?? 0
    let todayCompleted = args["todayCompleted"] as? Bool ?? false
    let habitName = args["habitName"] as? String ?? "Streakly"
    let nextReminder = args["nextReminder"] as? String ?? "No reminders"
    
    if let defaults = UserDefaults(suiteName: "group.com.streakly.app") {
      defaults.set(streakCount, forKey: "streakCount")
      defaults.set(todayCompleted, forKey: "todayCompleted")
      defaults.set(habitName, forKey: "habitName")
      defaults.set(nextReminder, forKey: "nextReminder")
      defaults.synchronize()
      
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      
      result(true)
    } else {
      result(FlutterError(code: "APP_GROUPS_ERROR", message: "Could not access app groups", details: nil))
    }
  }
  
  private func handleRefreshWidget(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
    result(true)
  }
  
  private func handleClearWidgetData(result: @escaping FlutterResult) {
    if let defaults = UserDefaults(suiteName: "group.com.streakly.app") {
      defaults.removePersistentDomain(forName: "group.com.streakly.app")
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      result(true)
    } else {
      result(FlutterError(code: "APP_GROUPS_ERROR", message: "Could not access app groups", details: nil))
    }
  }
  
  private func handleGetWidgetData(result: @escaping FlutterResult) {
    if let defaults = UserDefaults(suiteName: "group.com.streakly.app") {
      let data: [String: Any] = [
        "streakCount": defaults.integer(forKey: "streakCount"),
        "todayCompleted": defaults.bool(forKey: "todayCompleted"),
        "habitName": defaults.string(forKey: "habitName") ?? "Streakly",
        "nextReminder": defaults.string(forKey: "nextReminder") ?? "No reminders"
      ]
      result(data)
    } else {
      result(FlutterError(code: "APP_GROUPS_ERROR", message: "Could not access app groups", details: nil))
    }
  }
}
