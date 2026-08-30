# Contributing to DevMultiTool

Thank you for your interest in contributing to DevMultiTool! As an extensible developer tool, we welcome new utilities, bug fixes, and performance improvements.

## Project Architecture

The application relies on a strictly protocol-oriented architecture to maintain UI consistency and separation of concerns. All tools live in the `Sources/DevMultiTool/Tools` directory.

### Adding a New Tool

To add a new utility to the application, you do not need to modify any core UI logic. Follow these steps:

1. **Create the Tool File:**
   Create a new `.swift` file in `Sources/DevMultiTool/Tools/` (e.g., `MyCustomTool.swift`).

2. **Conform to `DeveloperTool`:**
   Define a `struct` that conforms to the `DeveloperTool` protocol.
   ```swift
   import SwiftUI

   struct MyCustomTool: DeveloperTool {
       var id: String = "my-custom-tool"
       var name: String = "Custom Tool"
       var iconName: String = "wrench.and.screwdriver"
       var category: ToolCategory = .generator // See ToolCategory enum
       
       var view: AnyView {
           AnyView(MyCustomToolView())
       }
   }
   ```

3. **Build the View:**
   Create the SwiftUI view that handles the logic and UI for your tool.
   ```swift
   struct MyCustomToolView: View {
       var body: some View {
           VStack {
               Text("Tool Interface Goes Here")
           }
           .padding()
       }
   }
   ```

4. **Register the Tool:**
   Open `Sources/DevMultiTool/Core/ToolRegistry.swift` and append your tool to the array in the `loadTools()` method.
   ```swift
   tools.append(MyCustomTool())
   ```

## Design Guidelines

- **Native Look and Feel:** Utilize standard SwiftUI components (`TextField`, `Button`, `Form`) without excessive custom styling to ensure compatibility with macOS light and dark modes.
- **Offline First:** Tools should function entirely offline whenever possible. If network requests are strictly necessary (e.g., fetching a Public IP), handle failure gracefully and asynchronously.
- **State Management:** Keep tool state localized. Avoid writing to `UserDefaults` or `AppStorage` unless saving critical user preferences.
- **Copy to Clipboard:** If your tool generates output, provide a clear, one-click button to copy the result to the `NSPasteboard`.

## Pull Request Process

1. Fork the repository and create your feature branch (`git checkout -b feature/amazing-tool`).
2. Ensure your code compiles without warnings (`swift build`).
3. Commit your changes with descriptive messages (`git commit -m 'feat: add Amazing Tool'`).
4. Push to the branch (`git push origin feature/amazing-tool`).
5. Open a Pull Request on GitHub describing your tool and its use case.
