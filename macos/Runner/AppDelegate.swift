import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls {
      if url.scheme == "spotify-insights" {
        if let flutterViewController = mainFlutterWindow?.contentViewController as? FlutterViewController {
          let channel = FlutterMethodChannel(
            name: "spotify_insights/auth",
            binaryMessenger: flutterViewController.engine.binaryMessenger
          )
          channel.invokeMethod("handleAuthCallback", arguments: url.absoluteString)
        }
      }
    }
  }
}
