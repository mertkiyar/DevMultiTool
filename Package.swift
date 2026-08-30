// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DevMultiTool",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DevMultiTool", targets: ["DevMultiTool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.16.1")
    ],
    targets: [
        .executableTarget(
            name: "DevMultiTool",
            dependencies: [
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")
            ],
            path: "Sources/DevMultiTool"
        ),
    ]
)
