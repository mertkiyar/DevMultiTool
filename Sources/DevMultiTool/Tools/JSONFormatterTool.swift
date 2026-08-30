import SwiftUI
import AppKit

struct JSONFormatterTool: DeveloperTool {
    var id: String = "json-formatter"
    var name: String = "JSON Formatter"
    var iconName: String = "curlybraces.square.fill"
    var category: ToolCategory = .formatter
    
    var view: AnyView {
        AnyView(JSONFormatterView())
    }
}

struct JSONFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Input JSON (Minified or Unformatted):")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .frame(height: 120)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
            
            HStack {
                Button("Format JSON") {
                    formatJSON()
                }
                .buttonStyle(PlainButtonStyle())
                .padding(6)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
                
                Button("Copy Result") {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.setString(outputText, forType: .string)
                    HistoryManager.shared.add(
                        toolID: "json-formatter",
                        toolName: "JSON Formatter",
                        input: "Raw JSON",
                        output: outputText
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                .disabled(outputText.isEmpty)
            }
            
            Text("Output:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: .constant(outputText))
                .font(.system(.body, design: .monospaced))
                .frame(height: 150)
                .padding(4)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
        }
    }
    
    private func formatJSON() {
        errorMessage = nil
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            outputText = ""
            return
        }
        
        guard let data = trimmed.data(using: .utf8) else {
            errorMessage = "Invalid encoding."
            return
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                // Disable automatic escaping of slashes in URLs if possible, otherwise just string replace
                outputText = prettyString.replacingOccurrences(of: "\\/", with: "/")
            }
        } catch {
            errorMessage = "Invalid JSON structure."
        }
    }
}
