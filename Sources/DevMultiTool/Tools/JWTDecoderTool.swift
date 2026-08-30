import SwiftUI
import AppKit

struct JWTDecoderTool: DeveloperTool {
    var id: String = "jwt-decoder"
    var name: String = "JWT Decoder"
    var iconName: String = "key.fill"
    var category: ToolCategory = .converter
    
    var view: AnyView {
        AnyView(JWTDecoderView())
    }
}

struct JWTDecoderView: View {
    @State private var jwtToken: String = ""
    @State private var headerJSON: String = ""
    @State private var payloadJSON: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("JWT Token:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $jwtToken)
                .font(.system(.body, design: .monospaced))
                .frame(height: 80)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                .onChange(of: jwtToken) { _ in
                    decodeJWT()
                }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !headerJSON.isEmpty {
                        Text("Header:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: .constant(headerJSON))
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 80)
                            .padding(4)
                            .background(Color(NSColor.windowBackgroundColor))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                    }
                    
                    if !payloadJSON.isEmpty {
                        Text("Payload:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: .constant(payloadJSON))
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 120)
                            .padding(4)
                            .background(Color(NSColor.windowBackgroundColor))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                    }
                }
            }
        }
    }
    
    private func decodeJWT() {
        errorMessage = nil
        let token = jwtToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if token.isEmpty {
            headerJSON = ""
            payloadJSON = ""
            return
        }
        
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            errorMessage = "Invalid JWT format. Expected 3 parts separated by dots."
            headerJSON = ""
            payloadJSON = ""
            return
        }
        
        headerJSON = decodeBase64URL(parts[0]) ?? "Invalid Header Base64"
        payloadJSON = decodeBase64URL(parts[1]) ?? "Invalid Payload Base64"
    }
    
    private func decodeBase64URL(_ value: String) -> String? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: .utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else { return nil }
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        
        return String(data: data, encoding: .utf8)
    }
}
