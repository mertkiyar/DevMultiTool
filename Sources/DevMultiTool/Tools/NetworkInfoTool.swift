import SwiftUI
import AppKit

struct NetworkInfoTool: DeveloperTool {
    var id: String = "network-info"
    var name: String = "Network Info"
    var iconName: String = "network"
    var category: ToolCategory = .network
    
    var view: AnyView {
        AnyView(NetworkInfoView())
    }
}

struct NetworkInfoView: View {
    @State private var localIP: String = "Loading..."
    @State private var publicIP: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 20) {
            IPCard(title: "Local IP (en0)", ipAddress: localIP, systemImage: "macbook.and.iphone")
            IPCard(title: "Public IP", ipAddress: publicIP, systemImage: "globe")
            
            Button(action: {
                refreshIPs()
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            refreshIPs()
        }
    }
    
    private func refreshIPs() {
        localIP = getLocalIPAddress() ?? "Not found"
        
        publicIP = "Fetching..."
        guard let url = URL(string: "https://api.ipify.org") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let ip = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.publicIP = ip
                }
            } else {
                DispatchQueue.main.async {
                    self.publicIP = "Error"
                }
            }
        }.resume()
    }
    
    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: (interface?.ifa_name)!)
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}

struct IPCard: View {
    let title: String
    let ipAddress: String
    let systemImage: String
    
    @State private var copied: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(ipAddress)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(ipAddress, forType: .string)
                    withAnimation { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { copied = false }
                    }
                }) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .foregroundColor(copied ? .green : .blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(8)
    }
}
