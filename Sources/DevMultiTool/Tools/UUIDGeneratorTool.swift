import SwiftUI
import AppKit

struct UUIDGeneratorTool: DeveloperTool {
    var id: String = "uuid-generator"
    var name: String = "UUID Generator"
    var iconName: String = "number"
    var category: ToolCategory = .generator
    
    var view: AnyView {
        AnyView(UUIDGeneratorView())
    }
}

struct UUIDGeneratorView: View {
    @State private var generatedUUIDs: [String] = []
    @State private var count: Int = 1
    @State private var isUppercase: Bool = true
    @State private var includeHyphens: Bool = true
    
    @State private var copiedUUID: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Stepper("Count: \(count)", value: $count, in: 1...100)
                Spacer()
                Toggle("UPPERCASE", isOn: $isUppercase)
                Toggle("Hyphens (-)", isOn: $includeHyphens)
            }
            .padding(.bottom, 8)
            
            Button(action: generate) {
                Text("Generate UUIDs")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            if !generatedUUIDs.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(generatedUUIDs, id: \.self) { uuid in
                            HStack {
                                Text(uuid)
                                    .font(.system(.body, design: .monospaced))
                                    .textSelection(.enabled)
                                
                                Spacer()
                                
                                Button(action: {
                                    copyToClipboard(uuid)
                                }) {
                                    Image(systemName: copiedUUID == uuid ? "checkmark" : "doc.on.doc")
                                        .foregroundColor(copiedUUID == uuid ? .green : .secondary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(10)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(6)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            if generatedUUIDs.isEmpty {
                generate()
            }
        }
    }
    
    private func generate() {
        var newUUIDs: [String] = []
        for _ in 0..<count {
            var uuid = UUID().uuidString
            if !isUppercase {
                uuid = uuid.lowercased()
            }
            if !includeHyphens {
                uuid = uuid.replacingOccurrences(of: "-", with: "")
            }
            newUUIDs.append(uuid)
        }
        
        withAnimation {
            generatedUUIDs = newUUIDs
        }
        
        let output = newUUIDs.joined(separator: "\n")
        HistoryManager.shared.add(
            toolID: "uuid-generator",
            toolName: "UUID Generator",
            input: "Count: \(count)",
            output: output
        )
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        withAnimation {
            copiedUUID = text
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.copiedUUID == text {
                withAnimation {
                    self.copiedUUID = nil
                }
            }
        }
    }
}
