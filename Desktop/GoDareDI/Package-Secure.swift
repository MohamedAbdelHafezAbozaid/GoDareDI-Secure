// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoDareDI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Binary framework product - source code is hidden
        .library(
            name: "GoDareDI",
            targets: ["GoDareDI"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        // Binary target - pre-compiled framework
        .binaryTarget(
            name: "GoDareDI",
            path: "BinaryFrameworks/GoDareDI.xcframework"
        ),
    ]
)
