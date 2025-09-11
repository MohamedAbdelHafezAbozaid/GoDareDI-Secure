// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GoDareDI",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "GoDareDI",
            targets: ["GoDareDI"]
        ),
    ],
    dependencies: [
        // No external dependencies
    ],
    targets: [
        .target(
            name: "GoDareDI",
            dependencies: [],
            path: "Sources/GoDareDI"
        ),
    ]
)