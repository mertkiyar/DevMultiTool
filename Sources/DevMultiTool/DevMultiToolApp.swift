import SwiftUI
import AppKit

@main
struct DevMultiToolApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("DevMultiTool", systemImage: "hammer.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
