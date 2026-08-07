// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSandboxKit",
    platforms: [
        .iOS("27.0"),
        .macOS("27.0"),
        .visionOS("27.0"),
        .tvOS("27.0"),
        .watchOS("27.0")
    ],
    products: [
        .library(
            name: "SwiftSandboxKit",
            targets: ["SwiftSandboxKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftSandboxKit",
            dependencies: [],
            path: "Sources/SwiftSandboxKit",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "SwiftSandboxKitTests",
            dependencies: ["SwiftSandboxKit"],
            path: "Tests/SwiftSandboxKitTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        ),
    ]
)
