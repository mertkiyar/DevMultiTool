import SwiftUI

struct URLParserTool: DeveloperTool {
    var id: String = "url-parser"
    var name: String = "URL Parser"
    var iconName: String = "link"
    var category: ToolCategory = .inspector
    
    var view: AnyView {
        AnyView(URLParserView())
    }
}

struct URLParserView: View {
    @State private var inputURL: String = ""
    
    var parsedURL: URLComponents? {
        // Automatically trim whitespace and decode slightly if needed
        let trimmed = inputURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return URLComponents(string: trimmed)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Enter URL (e.g., https://api.site.com:8080/v1/users?id=5)", text: $inputURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if inputURL.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "link.badge.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.bottom, 8)
                    Text("Paste a URL to parse")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else if let components = parsedURL {
                ScrollView {
                    VStack(spacing: 12) {
                        URLPartRow(title: "Scheme", value: components.scheme)
                        URLPartRow(title: "Host", value: components.host)
                        URLPartRow(title: "Port", value: components.port?.description)
                        URLPartRow(title: "Path", value: components.path.isEmpty ? nil : components.path)
                        URLPartRow(title: "Fragment", value: components.fragment)
                        
                        if let queryItems = components.queryItems, !queryItems.isEmpty {
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Query Parameters")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(queryItems, id: \.self) { item in
                                    HStack {
                                        Text(item.name)
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.blue)
                                        Text("=")
                                            .foregroundColor(.secondary)
                                        Text(item.value ?? "")
                                            .font(.system(.body, design: .monospaced))
                                            .textSelection(.enabled)
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(Color.primary.opacity(0.05))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.red.opacity(0.5))
                        .padding(.bottom, 8)
                    Text("Invalid URL format")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
    }
}

struct URLPartRow: View {
    let title: String
    let value: String?
    
    var body: some View {
        if let val = value, !val.isEmpty {
            HStack {
                Text(title)
                    .frame(width: 80, alignment: .leading)
                    .foregroundColor(.secondary)
                
                Text(val)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                
                Spacer()
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
    }
}
