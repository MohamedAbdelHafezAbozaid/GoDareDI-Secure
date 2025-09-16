// swift-tools-version: 6.0
import PackageDescription

// 🔒 ENCRYPTED BINARY FRAMEWORK PACKAGE - SOURCE CODE PROTECTED
let package = Package(
    name: "GODareDI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GODareDI",
            targets: ["GODareDIBinary"]
        ),
    ],
    targets: [
        // 🔐 ENCRYPTED BINARY TARGET - SOURCE CODE IS ENCRYPTED AND PROTECTED
        .binaryTarget(
            name: "GODareDIBinary",
            path: "GODareDI.xcframework"
        ),
    ]
)