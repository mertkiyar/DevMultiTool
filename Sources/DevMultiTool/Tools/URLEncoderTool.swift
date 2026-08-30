import SwiftUI
import AppKit

struct URLEncoderTool: DeveloperTool {
    var id: String = "url-encoder"
    var name: String = "URL Encoder / Decoder"
    var iconName: String = "link"
    var category: ToolCategory = .converter
    
    var view: AnyView {
        AnyView(URLEncoderView())
    }
}

struct URLEncoderView: View {
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
            .onChange(of: isEncoding) { _ in processText() }
            
            Text("Input URL / Text:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .frame(height: 120)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                .onChange(of: inputText) { _ in processText() }
            
            HStack {
                Text("Output:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.setString(outputText, forType: .string)
                    HistoryManager.shared.add(
                        toolID: "url-encoder",
                        toolName: "URL \(isEncoding ? "Encode" : "Decode")",
                        input: inputText,
                        output: outputText
                    )
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                .disabled(outputText.isEmpty)
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
            let allowedCharacterSet = CharacterSet.urlQueryAllowed
            outputText = inputText.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
        } else {
            outputText = inputText.removingPercentEncoding ?? ""
        }
    }
}
