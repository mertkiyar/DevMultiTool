# DevMultiTool 🛠️

DevMultiTool is a high-performance, native macOS Menu Bar application designed for developers. It provides essential day-to-day utilities right at your fingertips without the overhead of heavy web-based wrappers. Built purely with Swift and SwiftUI, it uses zero battery and starts up instantly.

## 🚀 Features

- **Menu Bar Native:** Lives in your macOS menu bar. Just click the hammer icon!
- **Zero Dock Clutter:** Runs entirely as an accessory app without polluting your dock.
- **Tools Included:**
  - `UUID Generator`: Generate single or multiple UUIDs with various formats.
  - `Base64 Converter`: Instantly encode and decode strings to Base64.
  - `JSON ↔ CSV Converter`: Convert JSON arrays to CSV or vice-versa easily.
  - `Sample Text Generator`: Generate dummy Lorem Ipsum words, sentences, or paragraphs.
- **History System:** Keeps track of your recently generated outputs so you never lose them. Just click the clock icon!
- **Instant Copy:** One-click copy buttons for every tool.

## 🏗 Architecture

The app is built using **Protocol-Oriented Programming (POP)**. Every tool conforms to the `DeveloperTool` protocol, making the app 100% scalable and extensible. 
You can easily add new tools without touching the core UI components.

## 🛠 How to Build & Run

1. Make sure you have Xcode and the Xcode command line tools installed.
2. Open your terminal and run `swift run` inside the project folder.
3. The app will build and a hammer icon will appear in your macOS menu bar!

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
To add a new tool:
1. Create a new struct conforming to `DeveloperTool`.
2. Add your tool to the `ToolRegistry`.

Enjoy building faster! ⚡️
