import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Required for PhonePe SDK to receive the callback after payment
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    var userInfo: [String: Any] = [:]
    userInfo["options"] = options
    userInfo["openUrl"] = url
    NotificationCenter.default.post(
      name: NSNotification.Name("ApplicationOpenURLNotification"),
      object: nil,
      userInfo: userInfo
    )
    return true
  }
}
