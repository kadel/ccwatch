// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudeMonitorBar",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ClaudeMonitorBar",
            path: "Sources/ClaudeMonitorBar"
        )
    ]
)
