// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GODareDI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GODareDI",
            targets: ["GODareDI"]
        ),
    ],
    targets: [
        .target(
            name: "GODareDI",
            path: "Sources/GODareDI"
        ),
        .testTarget(
            name: "GODareDITests",
            dependencies: [.target(name: "GODareDI")],
            path: "Tests/GODareDITests"
        )
    ]
)
