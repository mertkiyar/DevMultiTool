import Foundation

struct HistoryItem: Identifiable, Codable {
    var id = UUID()
    let toolID: String
    let toolName: String
    let input: String
    let output: String
    let timestamp: Date
}

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    @Published var history: [HistoryItem] = []
    
    private let key = "DevMultiToolHistory"
    
    private init() {
        load()
    }
    
    func add(toolID: String, toolName: String, input: String, output: String) {
        let item = HistoryItem(toolID: toolID, toolName: toolName, input: input, output: output, timestamp: Date())
        history.insert(item, at: 0)
        
        if history.count > 50 {
            history.removeLast()
        }
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let items = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            self.history = items
        }
    }
    
    func clear() {
        history.removeAll()
        save()
    }
}
