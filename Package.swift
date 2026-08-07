// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSandboxKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2),
        .tvOS(.v18),
        .watchOS(.v11)
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
