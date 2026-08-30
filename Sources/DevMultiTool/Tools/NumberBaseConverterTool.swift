import SwiftUI

struct NumberBaseConverterTool: DeveloperTool {
    var id: String = "number-base-converter"
    var name: String = "Base Converter"
    var iconName: String = "number.square"
    var category: ToolCategory = .converter
    
    var view: AnyView {
        AnyView(NumberBaseConverterView())
    }
}

struct NumberBaseConverterView: View {
    // We store the raw string inputs to allow the user to type freely (e.g. typing "10" temporarily before adding more)
    @State private var decText: String = ""
    @State private var hexText: String = ""
    @State private var binText: String = ""
    @State private var octText: String = ""
    
    // To prevent infinite update loops during text changing
    @State private var isUpdating: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            BaseInputRow(title: "Decimal (10)", prefix: "", text: $decText)
                .onChange(of: decText) { newValue in
                    updateFrom(value: newValue, radix: 10, source: "dec")
                }
            
            BaseInputRow(title: "Hexadecimal (16)", prefix: "0x", text: $hexText)
                .onChange(of: hexText) { newValue in
                    updateFrom(value: newValue, radix: 16, source: "hex")
                }
            
            BaseInputRow(title: "Binary (2)", prefix: "0b", text: $binText)
                .onChange(of: binText) { newValue in
                    updateFrom(value: newValue, radix: 2, source: "bin")
                }
            
            BaseInputRow(title: "Octal (8)", prefix: "0o", text: $octText)
                .onChange(of: octText) { newValue in
                    updateFrom(value: newValue, radix: 8, source: "oct")
                }
            
            Button(action: {
                isUpdating = true
                decText = ""
                hexText = ""
                binText = ""
                octText = ""
                isUpdating = false
            }) {
                Text("Clear All")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .padding()
    }
    
    private func updateFrom(value: String, radix: Int, source: String) {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        
        let cleanedValue = value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
        
        if cleanedValue.isEmpty {
            if source != "dec" { decText = "" }
            if source != "hex" { hexText = "" }
            if source != "bin" { binText = "" }
            if source != "oct" { octText = "" }
            return
        }
        
        if let number = Int64(cleanedValue, radix: radix) {
            if source != "dec" { decText = String(number, radix: 10) }
            if source != "hex" { hexText = String(number, radix: 16).uppercased() }
            if source != "bin" { binText = String(number, radix: 2) }
            if source != "oct" { octText = String(number, radix: 8) }
        } else {
            // Invalid input for the given radix, we just clear the others to show it's invalid
            if source != "dec" { decText = "Invalid" }
            if source != "hex" { hexText = "Invalid" }
            if source != "bin" { binText = "Invalid" }
            if source != "oct" { octText = "Invalid" }
        }
    }
}

struct BaseInputRow: View {
    let title: String
    let prefix: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                if !prefix.isEmpty {
                    Text(prefix)
                        .foregroundColor(.secondary)
                        .font(.system(.body, design: .monospaced))
                }
                
                TextField("...", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(.title3, design: .monospaced))
                    .disableAutocorrection(true)
                
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(text, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Copy")
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
        }
    }
}
