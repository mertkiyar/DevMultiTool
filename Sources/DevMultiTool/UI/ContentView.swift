import SwiftUI

struct ContentView: View {
    @StateObject private var registry = ToolRegistry()
    @State private var searchText = ""
    @State private var selectedToolID: String? = nil
    
    @State private var showHistory = false
    
    var filteredTools: [any DeveloperTool] {
        if searchText.isEmpty {
            return registry.tools
        } else {
            return registry.tools.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search tools...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showHistory.toggle()
                        selectedToolID = nil
                    }
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .help("History")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if showHistory {
                HistoryView(showHistory: $showHistory)
                    .transition(.move(edge: .bottom))
            } else if selectedToolID == nil {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(filteredTools, id: \.id) { tool in
                            ToolRowView(tool: tool)
                                .onHover { isHovered in
                                    // İsteğe bağlı: Hover efekti
                                }
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedToolID = tool.id
                                    }
                                }
                        }
                    }
                    .padding()
                }
            } else {
                if let tool = registry.tools.first(where: { $0.id == selectedToolID }) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 16) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedToolID = nil
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(.blue)
                            
                            Text(tool.name)
                                .font(.headline)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        
                        Divider()
                        
                        tool.view
                            .padding()
                    }
                    .transition(.move(edge: .trailing))
                }
            }
        }
        .frame(width: 420, height: 500)
    }
}

struct ToolRowView: View {
    let tool: any DeveloperTool
    
    var body: some View {
        HStack {
            Image(systemName: tool.iconName)
                .frame(width: 30)
                .foregroundColor(.blue)
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(tool.name)
                    .font(.body)
                Text(tool.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 12))
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}
