import SwiftUI
import AppKit

struct JSONFillerTool: DeveloperTool {
    var id: String = "json-filler"
    var name: String = "JSON Filler (Mock)"
    var iconName: String = "curlybraces"
    var category: ToolCategory = .generator
    
    var view: AnyView {
        AnyView(JSONFillerView())
    }
}

struct JSONField: Identifiable {
    let id = UUID()
    var key: String = ""
    var value: String = ""
}

struct JSONFillerView: View {
    @State private var fields: [JSONField] = [JSONField(key: "id", value: "")]
    @State private var generatedJSON: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Define Key-Value pairs. Click the dice 🎲 to generate random values.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach($fields) { $field in
                        HStack {
                            TextField("Key", text: $field.key)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            
                            TextField("Value", text: $field.value)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            
                            RandomValueButton(field: $field)
                            
                            Button(action: {
                                fields.removeAll(where: { $0.id == field.id })
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(2)
            }
            .frame(maxHeight: 200)
            
            HStack {
                Button(action: {
                    fields.append(JSONField())
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text("Add Field")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Generate JSON") {
                    generateJSON()
                }
                .buttonStyle(PlainButtonStyle())
                .padding(6)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
            }
            
            if !generatedJSON.isEmpty {
                Divider()
                
                TextEditor(text: .constant(generatedJSON))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 120)
                    .padding(4)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                
                HStack {
                    Spacer()
                    Button("Copy JSON") {
                        let pb = NSPasteboard.general
                        pb.clearContents()
                        pb.setString(generatedJSON, forType: .string)
                        HistoryManager.shared.add(
                            toolID: "json-filler",
                            toolName: "JSON Filler",
                            input: "\(fields.count) keys",
                            output: generatedJSON
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func generateJSON() {
        var dict: [String: Any] = [:]
        for field in fields {
            let key = field.key.trimmingCharacters(in: .whitespaces)
            guard !key.isEmpty else { continue }
            
            let val = field.value
            
            if let num = Int(val) {
                dict[key] = num
            } else if let num = Double(val) {
                dict[key] = num
            } else if val.lowercased() == "true" {
                dict[key] = true
            } else if val.lowercased() == "false" {
                dict[key] = false
            } else {
                dict[key] = val
            }
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            if let jsonString = String(data: data, encoding: .utf8) {
                generatedJSON = jsonString
            }
        } catch {
            generatedJSON = "{ \"error\": \"Failed to generate JSON\" }"
        }
    }
}

struct RandomValueButton: View {
    @Binding var field: JSONField
    @State private var showPopover = false
    
    @State private var isNumber = false
    @State private var length = 8
    
    @State private var useLowercase = true
    @State private var useUppercase = true
    @State private var useNumbers = false
    @State private var useSpecial = false
    
    var body: some View {
        Button(action: {
            showPopover.toggle()
        }) {
            Image(systemName: "dice.fill")
                .foregroundColor(.blue)
                .font(.system(size: 16))
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showPopover, arrowEdge: .trailing) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Generate Random")
                    .font(.headline)
                
                Picker("Type", selection: $isNumber) {
                    Text("String").tag(false)
                    Text("Number").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Stepper("Length: \(length)", value: $length, in: 1...64)
                
                if !isNumber {
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("Lowercase (a-z)", isOn: $useLowercase)
                        Toggle("Uppercase (A-Z)", isOn: $useUppercase)
                        Toggle("Numbers (0-9)", isOn: $useNumbers)
                        Toggle("Special (!@#...)", isOn: $useSpecial)
                    }
                }
                
                Button("Generate") {
                    if isNumber {
                        field.value = generateNumber(length: length)
                    } else {
                        field.value = generateString(length: length)
                    }
                    showPopover = false
                }
                .buttonStyle(PlainButtonStyle())
                .padding(6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(width: 220)
        }
    }
    
    private func generateNumber(length: Int) -> String {
        let digits = "0123456789"
        return String((0..<length).map { _ in digits.randomElement()! })
    }
    
    private func generateString(length: Int) -> String {
        var chars = ""
        if useLowercase { chars += "abcdefghijklmnopqrstuvwxyz" }
        if useUppercase { chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
        if useNumbers   { chars += "0123456789" }
        if useSpecial   { chars += "!@#$%^&*()-_=+[]{}|;:,.<>?" }
        
        if chars.isEmpty { chars = "abcdefghijklmnopqrstuvwxyz" }
        
        return String((0..<length).map { _ in chars.randomElement()! })
    }
}
