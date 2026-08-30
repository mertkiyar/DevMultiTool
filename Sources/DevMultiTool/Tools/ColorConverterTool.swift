import SwiftUI
import AppKit

struct ColorConverterTool: DeveloperTool {
    var id: String = "color-converter"
    var name: String = "Color Converter"
    var iconName: String = "paintpalette.fill"
    var category: ToolCategory = .converter
    
    var view: AnyView {
        AnyView(ColorConverterView())
    }
}

struct ColorConverterView: View {
    @State private var hexInput: String = ""
    @State private var rString: String = ""
    @State private var gString: String = ""
    @State private var bString: String = ""
    
    @State private var previewColor: Color = .clear
    @State private var isEditingHex = false
    @State private var isEditingRGB = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Color Preview:")
                    .font(.headline)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(previewColor)
                    .frame(width: 60, height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
            }
            .padding()
            .cornerRadius(8)
            
            Divider()
            
            Text("HEX Input:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("#")
                    .foregroundColor(.secondary)
                TextField("e.g. FF5733", text: $hexInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: hexInput) { _ in
                        if !isEditingRGB {
                            isEditingHex = true
                            updateFromHex()
                            isEditingHex = false
                        }
                    }
            }
            .padding(8)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
            
            Text("RGB Input:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            HStack(spacing: 12) {
                rgbField(title: "R", text: $rString)
                rgbField(title: "G", text: $gString)
                rgbField(title: "B", text: $bString)
            }
            
            Spacer()
        }
    }
    
    private func rgbField(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            TextField("0-255", text: text)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: text.wrappedValue) { _ in
                    if !isEditingHex {
                        isEditingRGB = true
                        updateFromRGB()
                        isEditingRGB = false
                    }
                }
        }
        .padding(8)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
    }
    
    private func updateFromHex() {
        var cleanHex = hexInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        
        guard cleanHex.count == 6, let rgbValue = UInt64(cleanHex, radix: 16) else {
            previewColor = .clear
            return
        }
        
        let r = Double((rgbValue & 0xFF0000) >> 16)
        let g = Double((rgbValue & 0x00FF00) >> 8)
        let b = Double(rgbValue & 0x0000FF)
        
        rString = "\(Int(r))"
        gString = "\(Int(g))"
        bString = "\(Int(b))"
        
        previewColor = Color(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }
    
    private func updateFromRGB() {
        guard let r = Int(rString), let g = Int(gString), let b = Int(bString),
              r >= 0 && r <= 255, g >= 0 && g <= 255, b >= 0 && b <= 255 else {
            previewColor = .clear
            return
        }
        
        hexInput = String(format: "%02X%02X%02X", r, g, b)
        previewColor = Color(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0)
    }
}
