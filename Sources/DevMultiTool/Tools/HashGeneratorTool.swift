import SwiftUI
import AppKit
import CryptoKit

struct HashGeneratorTool: DeveloperTool {
    var id: String = "hash-generator"
    var name: String = "Hash Generator"
    var iconName: String = "number.square.fill"
    var category: ToolCategory = .converter
    
    var view: AnyView {
        AnyView(HashGeneratorView())
    }
}

struct HashGeneratorView: View {
    @State private var inputText: String = ""
    @State private var md5Hash: String = ""
    @State private var sha1Hash: String = ""
    @State private var sha256Hash: String = ""
    @State private var sha512Hash: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Input Text:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .frame(height: 100)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                .onChange(of: inputText) { _ in generateHashes() }
            
            ScrollView {
                VStack(spacing: 12) {
                    hashRow(title: "MD5", hash: md5Hash)
                    hashRow(title: "SHA-1", hash: sha1Hash)
                    hashRow(title: "SHA-256", hash: sha256Hash)
                    hashRow(title: "SHA-512", hash: sha512Hash)
                }
            }
        }
    }
    
    private func hashRow(title: String, hash: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.setString(hash, forType: .string)
                    HistoryManager.shared.add(
                        toolID: "hash-generator",
                        toolName: "Hash (\(title))",
                        input: inputText,
                        output: hash
                    )
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                .disabled(hash.isEmpty)
            }
            
            TextField("", text: .constant(hash))
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(.caption, design: .monospaced))
                .padding(6)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
        }
    }
    
    private func generateHashes() {
        guard let data = inputText.data(using: .utf8), !inputText.isEmpty else {
            md5Hash = ""
            sha1Hash = ""
            sha256Hash = ""
            sha512Hash = ""
            return
        }
        
        md5Hash = Insecure.MD5.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
        sha1Hash = Insecure.SHA1.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
        sha256Hash = SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
        sha512Hash = SHA512.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }
}
