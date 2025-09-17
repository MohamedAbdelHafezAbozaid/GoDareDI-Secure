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
            url: "https://github.com/MohamedAbdelHafezAbozaid/GoDareDI-Secure/releases/download/v2.0.12/GoDareDI-2.0.12.xcframework.zip",
            checksum: "aeb9d3723f8edbe706ff230c26dbc11c3641282c97846825c7b9e943bdfcadca"
        ),
    ]
)
