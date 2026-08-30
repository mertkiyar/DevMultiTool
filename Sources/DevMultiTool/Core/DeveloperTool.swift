import SwiftUI

enum ToolCategory: String, CaseIterable, Identifiable {
    case generator = "Generators"
    case converter = "Converters"
    case formatter = "Formatters"
    case inspector = "Inspectors"
    
    var id: String { self.rawValue }
}

protocol DeveloperTool: Identifiable {
    var id: String { get }
    var name: String { get }
    var iconName: String { get }
    var category: ToolCategory { get }
    var view: AnyView { get }
}
