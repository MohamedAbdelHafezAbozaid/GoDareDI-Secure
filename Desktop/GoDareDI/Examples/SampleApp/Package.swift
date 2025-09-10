// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SampleApp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "SampleApp",
            dependencies: ["GoDareDI"],
            path: "Sources"
        )
    ]
)
