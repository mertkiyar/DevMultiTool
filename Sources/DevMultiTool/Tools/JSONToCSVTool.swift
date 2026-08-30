import SwiftUI
import AppKit

struct JSONToCSVTool: DeveloperTool {
    var id: String = "json-csv"
    var name: String = "JSON ↔ CSV Converter"
    var iconName: String = "arrow.left.arrow.right"
    var category: ToolCategory = .formatter
    
    var view: AnyView {
        AnyView(JSONToCSVView())
    }
}

struct JSONToCSVView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isJSONToCSV: Bool = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Conversion", selection: $isJSONToCSV) {
                Text("JSON to CSV").tag(true)
                Text("CSV to JSON").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Text("Input Data:")
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
                Button("Convert") {
                    convert()
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
                        toolID: "json-csv",
                        toolName: "JSON/CSV Converter",
                        input: inputText,
                        output: outputText
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                .disabled(outputText.isEmpty)
            }
            
            Text("Output Data:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: .constant(outputText))
                .font(.system(.body, design: .monospaced))
                .frame(height: 120)
                .padding(4)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
        }
    }
    
    private func convert() {
        errorMessage = nil
        if inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            outputText = ""
            return
        }
        
        if isJSONToCSV {
            convertJSONToCSV()
        } else {
            convertCSVToJSON()
        }
    }
    
    private func convertJSONToCSV() {
        guard let data = inputText.data(using: .utf8) else { return }
        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]], !jsonArray.isEmpty else {
                errorMessage = "Input must be a JSON array of objects. e.g. [{\"id\": 1}]"
                return
            }
            
            let keys = jsonArray[0].keys.sorted()
            var csvString = keys.joined(separator: ",") + "\n"
            
            for dict in jsonArray {
                let values = keys.map { key -> String in
                    if let val = dict[key] {
                        let strVal = String(describing: val)
                        if strVal.contains(",") || strVal.contains("\"") {
                            return "\"\(strVal.replacingOccurrences(of: "\"", with: "\"\""))\""
                        }
                        return strVal
                    }
                    return ""
                }
                csvString += values.joined(separator: ",") + "\n"
            }
            outputText = csvString
        } catch {
            errorMessage = "Invalid JSON format."
        }
    }
    
    private func convertCSVToJSON() {
        let rows = inputText.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard rows.count > 1 else {
            errorMessage = "CSV must have a header row and at least one data row."
            return
        }
        
        let headers = rows[0].components(separatedBy: ",")
        var jsonArray: [[String: String]] = []
        
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")
            var dict: [String: String] = [:]
            for (index, header) in headers.enumerated() {
                if index < columns.count {
                    let key = header.trimmingCharacters(in: .whitespaces)
                    var val = columns[index].trimmingCharacters(in: .whitespaces)
                    if val.hasPrefix("\"") && val.hasSuffix("\"") {
                        val = String(val.dropFirst().dropLast())
                    }
                    dict[key] = val
                }
            }
            jsonArray.append(dict)
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            if let jsonString = String(data: data, encoding: .utf8) {
                outputText = jsonString
            }
        } catch {
            errorMessage = "Error generating JSON."
        }
    }
}
