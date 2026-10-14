import BrazeKit
import Flutter
import UIKit
import braze_plugin

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Dart の initialize(apiKey, endpoint) が呼ばれる前に iOS ネイティブ設定を保存する。
    // push.automation = true でAPNs登録・Push受信・フォアグラウンド表示を自動処理する。
    BrazePlugin.configure { configuration in
      configuration.push.automation = true
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
