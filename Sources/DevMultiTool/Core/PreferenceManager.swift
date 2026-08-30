import Foundation

class PreferenceManager: ObservableObject {
    static let shared = PreferenceManager()
    
    @Published var favoriteToolIDs: [String] {
        didSet {
            UserDefaults.standard.set(favoriteToolIDs, forKey: "favoriteToolIDs")
        }
    }
    
    @Published var toolUsageCounts: [String: Int] {
        didSet {
            UserDefaults.standard.set(toolUsageCounts, forKey: "toolUsageCounts")
        }
    }
    
    init() {
        self.favoriteToolIDs = UserDefaults.standard.stringArray(forKey: "favoriteToolIDs") ?? []
        self.toolUsageCounts = UserDefaults.standard.dictionary(forKey: "toolUsageCounts") as? [String: Int] ?? [:]
    }
    
    func incrementUsage(for toolID: String) {
        toolUsageCounts[toolID, default: 0] += 1
    }
    
    func toggleFavorite(for toolID: String) {
        if let index = favoriteToolIDs.firstIndex(of: toolID) {
            favoriteToolIDs.remove(at: index)
        } else {
            favoriteToolIDs.append(toolID)
            if favoriteToolIDs.count > 3 {
                favoriteToolIDs.removeFirst()
            }
        }
    }
    
    func isFavorite(_ toolID: String) -> Bool {
        return favoriteToolIDs.contains(toolID)
    }
}
