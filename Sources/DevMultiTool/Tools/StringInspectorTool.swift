import SwiftUI

struct StringInspectorTool: DeveloperTool {
    var id: String = "string-inspector"
    var name: String = "String Inspector"
    var iconName: String = "text.magnifyingglass"
    var category: ToolCategory = .inspector
    
    var view: AnyView {
        AnyView(StringInspectorView())
    }
}

struct StringInspectorView: View {
    @State private var inputText: String = ""
    
    var characterCount: Int { inputText.count }
    
    var wordCount: Int {
        let components = inputText.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.count
    }
    
    var lineCount: Int {
        if inputText.isEmpty { return 0 }
        return inputText.components(separatedBy: .newlines).count
    }
    
    var byteCount: Int {
        inputText.data(using: .utf8)?.count ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .frame(height: 120)
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
            
            HStack(spacing: 16) {
                StatBox(title: "Characters", value: "\(characterCount)")
                StatBox(title: "Words", value: "\(wordCount)")
            }
            
            HStack(spacing: 16) {
                StatBox(title: "Lines", value: "\(lineCount)")
                StatBox(title: "Bytes", value: "\(byteCount)")
            }
            
            Button(action: {
                inputText = ""
            }) {
                Text("Clear")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(8)
    }
}
