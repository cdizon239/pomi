// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "pomi",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "pomi",
            path: "Sources/pomi",
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        )
    ]
)
