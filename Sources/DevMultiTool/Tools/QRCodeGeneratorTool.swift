import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGeneratorTool: DeveloperTool {
    var id: String = "qrcode-generator"
    var name: String = "QR Code Generator"
    var iconName: String = "qrcode"
    var category: ToolCategory = .generator
    
    var view: AnyView {
        AnyView(QRCodeGeneratorView())
    }
}

struct QRCodeGeneratorView: View {
    @State private var inputText: String = ""
    @State private var qrImage: NSImage? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter URL or text to generate QR code...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: inputText) { newValue in
                    generateQRCode(from: newValue)
                }
            
            if let image = qrImage {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(20)
                    .background(Color.white) // QR codes usually need white background to be scannable
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.writeObjects([image])
                }) {
                    Label("Copy QR Code", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text("Type something to generate")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .onAppear {
            if !inputText.isEmpty {
                generateQRCode(from: inputText)
            }
        }
    }
    
    private func generateQRCode(from string: String) {
        if string.isEmpty {
            qrImage = nil
            return
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                qrImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            }
        }
    }
}
