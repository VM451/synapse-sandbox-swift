// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SynapseSandbox",
    platforms: [
        .iOS("27.0"),
        .macOS("27.0"),
        .visionOS("27.0")
    ],
    products: [
        .library(
            name: "SynapseSandbox",
            targets: ["SynapseSandbox"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SynapseSandbox",
            dependencies: [],
            path: "Sources/SynapseSandbox",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "SynapseSandboxTests",
            dependencies: ["SynapseSandbox"],
            path: "Tests/SynapseSandboxTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .swiftLanguageMode(.v6)
            ]
        ),
    ]
)
