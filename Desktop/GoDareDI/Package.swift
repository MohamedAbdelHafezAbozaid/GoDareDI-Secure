// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GoDareDI",
    platforms: [
        .iOS(.v18),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "GoDareDI",
            targets: ["GoDareDI"]
        ),
    ],
    targets: [
        .target(
            name: "GoDareDI",
            path: "Sources/GoDareDI",
            swiftSettings: [
                .define("SWIFT_PACKAGE"),
                .unsafeFlags(["-enable-library-evolution"])
            ]
        ),
    ]
)
