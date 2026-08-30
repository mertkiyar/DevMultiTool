import SwiftUI

struct ContentView: View {
    @StateObject private var registry = ToolRegistry()
    @State private var searchText = ""
    @State private var selectedToolID: String? = nil
    
    @State private var showHistory = false
    
    @AppStorage("appTheme") private var appTheme: Int = 0 // 0: System, 1: Light, 2: Dark
    
    @StateObject private var prefManager = PreferenceManager.shared
    
    var sortedAllTools: [any DeveloperTool] {
        let tools = registry.tools.filter { searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText) }
        return tools.sorted {
            let count1 = prefManager.toolUsageCounts[$0.id] ?? 0
            let count2 = prefManager.toolUsageCounts[$1.id] ?? 0
            if count1 == count2 { return $0.name < $1.name }
            return count1 > count2
        }
    }
    
    var favoriteTools: [any DeveloperTool] {
        prefManager.favoriteToolIDs.compactMap { id in
            registry.tools.first(where: { $0.id == id })
        }.filter { searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showHistory {
                HistoryView(showHistory: $showHistory)
                    .transition(.move(edge: .bottom))
                    .id("history-view")
            } else if selectedToolID == nil {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search tools...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        Spacer()
                        
                        Button(action: {
                            appTheme = (appTheme + 1) % 3
                        }) {
                            Image(systemName: themeIcon)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Change Theme")
                        
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
                    
                    List {
                        if !favoriteTools.isEmpty {
                            Section(header: Text("Favorites").font(.caption).foregroundColor(.secondary)) {
                                ForEach(favoriteTools, id: \.id) { tool in
                                    ToolRowView(tool: tool)
                                        .onTapGesture {
                                            prefManager.incrementUsage(for: tool.id)
                                            withAnimation(.spring()) {
                                                selectedToolID = tool.id
                                            }
                                        }
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                }
                                .onMove(perform: prefManager.moveFavorites)
                            }
                        }
                        
                        let remainingTools = sortedAllTools.filter { !prefManager.isFavorite($0.id) }
                        if !remainingTools.isEmpty {
                            Section(header: Text(favoriteTools.isEmpty ? "All Tools" : "Other Tools").font(.caption).foregroundColor(.secondary)) {
                                ForEach(remainingTools, id: \.id) { tool in
                                    ToolRowView(tool: tool)
                                        .onTapGesture {
                                            prefManager.incrementUsage(for: tool.id)
                                            withAnimation(.spring()) {
                                                selectedToolID = tool.id
                                            }
                                        }
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .padding(.horizontal, 8)
                }
                .transition(.move(edge: .leading))
                .id("main-list")
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
                    .id("detail-view-\(tool.id)")
                }
            }
        }
        .frame(width: 420, height: 500)
        .preferredColorScheme(appTheme == 1 ? .light : (appTheme == 2 ? .dark : nil))
    }
    
    private var themeIcon: String {
        switch appTheme {
        case 1: return "sun.max"
        case 2: return "moon.fill"
        default: return "circle.lefthalf.filled"
        }
    }
}

struct ToolRowView: View {
    let tool: any DeveloperTool
    @ObservedObject var prefManager = PreferenceManager.shared
    
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
            
            Button(action: {
                withAnimation {
                    prefManager.toggleFavorite(for: tool.id)
                }
            }) {
                Image(systemName: prefManager.isFavorite(tool.id) ? "star.fill" : "star")
                    .foregroundColor(prefManager.isFavorite(tool.id) ? .yellow : .secondary)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.trailing, 4)
            
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
