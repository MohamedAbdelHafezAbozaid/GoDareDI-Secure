// swift-tools-version: 5.9
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
            dependencies: []
        ),
    ]
)