import SwiftUI
import ServiceManagement

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 250)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("appTheme") private var appTheme: Int = 0
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    
    var body: some View {
        Form {
            Section(header: Text("Appearance").font(.headline)) {
                Picker("Theme:", selection: $appTheme) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.bottom, 12)
            
            Section(header: Text("System").font(.headline)) {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        do {
                            if newValue {
                                if SMAppService.mainApp.status != .enabled {
                                    try SMAppService.mainApp.register()
                                }
                            } else {
                                if SMAppService.mainApp.status == .enabled {
                                    try SMAppService.mainApp.unregister()
                                }
                            }
                        } catch {
                            print("SMAppService Error: \(error)")
                            // Revert if failed
                            launchAtLogin = SMAppService.mainApp.status == .enabled
                        }
                    }
            }
        }
        .padding(20)
        .onAppear {
            let isEnabled = SMAppService.mainApp.status == .enabled
            if launchAtLogin != isEnabled {
                launchAtLogin = isEnabled
            }
        }
    }
}

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                .padding(.bottom, 12)
            
            Text(AppConstants.appName)
                .font(.system(size: 24, weight: .bold))
            
            Text("Version \(AppConstants.version) (\(AppConstants.buildNumber))")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
            
            Text("Designed and engineered by \(AppConstants.developerName)")
                .font(.system(size: 12))
                .foregroundColor(.primary)
            
            Text("© 2026 \(AppConstants.developerName). All rights reserved.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
            
            Link("Visit GitHub", destination: URL(string: AppConstants.githubURL)!)
                .buttonStyle(LinkButtonStyle())
                .font(.system(size: 12, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}
