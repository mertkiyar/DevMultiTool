import SwiftUI
import AppKit

struct SampleTextTool: DeveloperTool {
    var id: String = "sample-text"
    var name: String = "Sample Text Generator"
    var iconName: String = "text.alignleft"
    var category: ToolCategory = .generator
    
    var view: AnyView {
        AnyView(SampleTextView())
    }
}

struct SampleTextView: View {
    @State private var type: Int = 0
    @State private var count: Int = 5
    @State private var generatedText: String = ""
    
    let loremWords = ["lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "enim", "ad", "minim", "veniam", "quis", "nostrud", "exercitation"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Format", selection: $type) {
                Text("Words").tag(0)
                Text("Sentences").tag(1)
                Text("Paragraphs").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            HStack {
                Stepper("Count: \(count)", value: $count, in: 1...100)
                Spacer()
                Button("Generate") {
                    generate()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }
            
            TextEditor(text: .constant(generatedText))
                .font(.system(.body))
                .frame(height: 150)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
            
            Button(action: {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(generatedText, forType: .string)
                
                HistoryManager.shared.add(
                    toolID: "sample-text",
                    toolName: "Sample Text",
                    input: "Type: \(type), Count: \(count)",
                    output: generatedText
                )
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "doc.on.doc")
                    Text("Copy to Clipboard")
                    Spacer()
                }
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(generatedText.isEmpty)
        }
        .onAppear {
            if generatedText.isEmpty {
                generate()
            }
        }
    }
    
    private func generate() {
        switch type {
        case 0:
            generatedText = (0..<count).map { _ in loremWords.randomElement()! }.joined(separator: " ")
        case 1:
            generatedText = (0..<count).map { _ in generateSentence() }.joined(separator: " ")
        case 2:
            generatedText = (0..<count).map { _ in generateParagraph() }.joined(separator: "\n\n")
        default:
            break
        }
    }
    
    private func generateSentence() -> String {
        let length = Int.random(in: 5...12)
        var words = (0..<length).map { _ in loremWords.randomElement()! }
        words[0] = words[0].capitalized
        return words.joined(separator: " ") + "."
    }
    
    private func generateParagraph() -> String {
        let length = Int.random(in: 3...7)
        return (0..<length).map { _ in generateSentence() }.joined(separator: " ")
    }
}
