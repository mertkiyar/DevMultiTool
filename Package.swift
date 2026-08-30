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
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DevMultiTool",
            dependencies: [],
            path: "Sources/DevMultiTool"
        ),
    ]
)
