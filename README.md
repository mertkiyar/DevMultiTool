# DevMultiTool

DevMultiTool is a native macOS menu bar application designed to provide developers with instant access to frequently used utilities. Built entirely with SwiftUI and Swift Package Manager, it operates quietly in the background and can be summoned instantly via a global hotkey.

The core philosophy of DevMultiTool is speed, native performance, and extensibility. It aims to replace scattered web-based tools with a single, secure, offline-capable desktop application.

## Features

The application currently includes a comprehensive suite of developer utilities:

### Data & Encoders
- **JSON Formatter:** Validate, format, and minify JSON payloads.
- **Base64 Converter:** Encode and decode strings to/from Base64.
- **URL Encoder:** Percent-encode and decode URLs and query parameters.
- **JWT Decoder:** Decode and inspect JSON Web Tokens without relying on external servers.

### Generators
- **UUID Generator:** Generate v4 UUIDs in bulk with formatting options.
- **Hash Generator:** Compute MD5, SHA-1, SHA-256, and SHA-512 hashes instantly.
- **QR Code Generator:** Create scannable QR codes from text or URLs using native CoreImage.
- **Sample Text:** Generate lorem ipsum placeholder text.
- **JSON Filler:** Generate mock JSON structures for testing.

### Converters & Inspectors
- **Number Base Converter:** Real-time simultaneous conversion between Decimal, Hexadecimal, Binary, and Octal formats.
- **Unix Timestamp:** Convert between epoch timestamps and human-readable dates.
- **Color Converter:** Convert color codes between HEX, RGB, and HSL formats.
- **String Inspector:** Analyze string metrics including character, word, line, and byte counts.
- **URL Parser:** Dissect complex URLs into scheme, host, path, and extract query parameters into structured tables.
- **Network Info:** Retrieve local (en0) and public IP addresses with single-click copying.

### System Integration
- **Global Hotkey:** Summon the application from any context.
- **Pin Window:** Pin the popover to keep it visible while working in other windows.
- **Launch at Login:** Native integration with `SMAppService` to start silently on boot.
- **Dark/Light Mode:** Seamless integration with macOS system appearances.

## Requirements

- macOS 13.0 or later
- Swift 5.9+
- Xcode 15.0+ (for building from source)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/mertkiyar/DevMultiTool.git
   ```
2. Navigate to the project directory:
   ```bash
   cd DevMultiTool
   ```
3. Build and run using Swift Package Manager:
   ```bash
   swift run
   ```
   Alternatively, open `Package.swift` in Xcode and run the `DevMultiTool` target.

## Usage

Once launched, DevMultiTool resides in the macOS menu bar. Click the icon to reveal the tool interface. 

You can bind a global hotkey in the "Settings" tab to toggle the popover instantly without using the mouse. The application keeps track of your most frequently used tools and allows you to pin favorites to the top of the list for faster access.

## Architecture

The application uses a plugin-based architecture for its tools. Every tool conforms to the `DeveloperTool` protocol and is registered in the `ToolRegistry`. This makes adding new tools exceptionally straightforward without modifying the core UI logic.

See `CONTRIBUTING.md` for detailed instructions on how to create and register a new tool.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
