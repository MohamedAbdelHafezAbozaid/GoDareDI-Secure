// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ComprehensiveSample",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .executable(
            name: "ComprehensiveSample",
            targets: ["ComprehensiveSample"]),
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "ComprehensiveSample",
            dependencies: ["GoDareDI"],
            path: "Sources/ComprehensiveSample"
        ),
    ]
)
