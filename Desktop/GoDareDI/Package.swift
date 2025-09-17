// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GoDareDI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GoDareDI",
            targets: ["GoDareDI"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "GoDareDI",
            url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure/releases/download/v2.0.11/GoDareDI-2.0.11.xcframework.zip",
            checksum: "63d6b2e5336d116e6de994a6c71293bcbb882ea57890ac3be56ae338a45af501"
        ),
    ]
)
