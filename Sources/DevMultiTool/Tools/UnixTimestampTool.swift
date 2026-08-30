import SwiftUI
import AppKit

struct UnixTimestampTool: DeveloperTool {
    var id: String = "unix-timestamp"
    var name: String = "Unix Timestamp"
    var iconName: String = "clock.fill"
    var category: ToolCategory = .converter
    
    var view: AnyView {
        AnyView(UnixTimestampView())
    }
}

struct UnixTimestampView: View {
    @State private var timestampString: String = ""
    @State private var dateString: String = ""
    @State private var useMilliseconds = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTimestamp: Int = Int(Date().timeIntervalSince1970)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Current Time:")
                    .font(.headline)
                
                Spacer()
                
                Text("\(currentTimestamp)")
                    .font(.system(.title3, design: .monospaced))
                    .foregroundColor(.blue)
                
                Button(action: {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.setString("\(currentTimestamp)", forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .onReceive(timer) { _ in
                currentTimestamp = Int(Date().timeIntervalSince1970)
            }
            
            Divider()
            
            HStack {
                Text("Timestamp:")
                    .frame(width: 80, alignment: .leading)
                
                TextField("e.g. 1693400000", text: $timestampString)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(6)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                    .onChange(of: timestampString) { _ in convertToDate() }
            }
            
            HStack {
                Spacer()
                Toggle("Milliseconds (ms)", isOn: $useMilliseconds)
                    .onChange(of: useMilliseconds) { _ in convertToDate() }
            }
            
            HStack {
                Text("Date:")
                    .frame(width: 80, alignment: .leading)
                
                TextField("Result", text: $dateString)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(6)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                
                Button(action: {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.setString(dateString, forType: .string)
                    HistoryManager.shared.add(
                        toolID: "unix-timestamp",
                        toolName: "Unix Timestamp",
                        input: timestampString,
                        output: dateString
                    )
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
                .disabled(dateString.isEmpty || dateString == "Invalid Timestamp")
            }
            
            Spacer()
        }
        .onAppear {
            if timestampString.isEmpty {
                timestampString = "\(currentTimestamp)"
                convertToDate()
            }
        }
    }
    
    private func convertToDate() {
        let trimmed = timestampString.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            dateString = ""
            return
        }
        
        guard let value = Double(trimmed) else {
            dateString = "Invalid Timestamp"
            return
        }
        
        let seconds = useMilliseconds ? value / 1000.0 : value
        let date = Date(timeIntervalSince1970: seconds)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        
        dateString = formatter.string(from: date)
    }
}
