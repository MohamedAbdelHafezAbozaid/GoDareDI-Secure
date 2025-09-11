// swift-tools-version: 5.9
import PackageDescription

// 🔒 BINARY FRAMEWORK PACKAGE - NO SOURCE CODE ACCESS
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
    targets: [
        // 🔒 BINARY TARGET - SOURCE CODE IS PROTECTED
        .binaryTarget(
            name: "GoDareDI",
            path: "GoDareDI.xcframework"
        ),
    ]
)