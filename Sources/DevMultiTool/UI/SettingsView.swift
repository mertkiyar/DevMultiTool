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
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
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
                        if newValue {
                            try? SMAppService.mainApp.register()
                        } else {
                            try? SMAppService.mainApp.unregister()
                        }
                    }
            }
        }
        .padding(20)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
                .padding(.bottom, 8)
            
            Text(AppConstants.appName)
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version \(AppConstants.version) (\(AppConstants.buildNumber))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, 8)
            
            Text("Developed by \(AppConstants.developerName)")
                .font(.body)
            
            Link("Visit GitHub Repository", destination: URL(string: AppConstants.githubURL)!)
                .padding(.top, 4)
        }
        .padding(20)
    }
}
