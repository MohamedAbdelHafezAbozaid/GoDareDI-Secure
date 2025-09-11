// swift-tools-version: 6.0
import PackageDescription

// 🔒 BINARY FRAMEWORK PACKAGE - NO SOURCE CODE ACCESS
let package = Package(
    name: "GoDareDI",
    platforms: [
        .iOS(.v17)
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