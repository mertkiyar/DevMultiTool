import SwiftUI
import AppKit

struct HistoryView: View {
    @Binding var showHistory: Bool
    @StateObject private var historyManager = HistoryManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        showHistory = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                
                Text("History")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    historyManager.clear()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Clear History")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            if historyManager.history.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.bottom, 8)
                    Text("No history yet.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(historyManager.history) { item in
                            HistoryRowView(item: item)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct HistoryRowView: View {
    let item: HistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.toolName)
                    .font(.headline)
                Spacer()
                Text(item.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !item.input.isEmpty {
                Text("Input: \(item.input.prefix(50))\(item.input.count > 50 ? "..." : "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            HStack {
                Text(item.output)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.setString(item.output, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }
        }
        .padding(10)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
    }
}
