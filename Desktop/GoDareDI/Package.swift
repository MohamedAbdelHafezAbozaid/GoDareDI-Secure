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
            checksum: "a9b8b65019240dd112512b7725e6c1e07dcfcc4bdf161636070854f63e88b236"
        ),
    ]
)
