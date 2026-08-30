import SwiftUI
import AppKit

struct Base64ConverterTool: DeveloperTool {
    var id: String = "base64-converter"
    var name: String = "Base64 Converter"
    var iconName: String = "text.badge.plus"
    var category: ToolCategory = .converter
    
    var view: AnyView {
        AnyView(Base64ConverterView())
    }
}

struct Base64ConverterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isEncoding: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Mode", selection: $isEncoding) {
                Text("Encode").tag(true)
                Text("Decode").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: isEncoding) { _ in
                processText()
            }
            
            Text(isEncoding ? "Input Text:" : "Base64 Input:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .frame(height: 120)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                .onChange(of: inputText) { _ in
                    processText()
                }
            
            HStack {
                Text(isEncoding ? "Base64 Output:" : "Decoded Text:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: copyResult) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy Result")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                .disabled(outputText.isEmpty || outputText == "Invalid Base64 string")
            }
            
            TextEditor(text: .constant(outputText))
                .font(.system(.body, design: .monospaced))
                .frame(height: 120)
                .padding(4)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
        }
    }
    
    private func processText() {
        if inputText.isEmpty {
            outputText = ""
            return
        }
        
        if isEncoding {
            if let data = inputText.data(using: .utf8) {
                outputText = data.base64EncodedString()
            }
        } else {
            // Decoding
            let cleanBase64 = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
            if let data = Data(base64Encoded: cleanBase64),
               let decoded = String(data: data, encoding: .utf8) {
                outputText = decoded
            } else {
                outputText = "Invalid Base64 string"
            }
        }
    }
    
    private func copyResult() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputText, forType: .string)
        
        HistoryManager.shared.add(
            toolID: "base64-converter",
            toolName: "Base64 \(isEncoding ? "Encode" : "Decode")",
            input: inputText,
            output: outputText
        )
    }
}
