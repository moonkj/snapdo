// swift-tools-version: 5.9
// SnapDoCore — shared library consumed by both the iOS app and the macOS training CLI.
// Per classification spec §0: SnapDo / SnapDoCore / SnapDoTrainer three-target structure.
import PackageDescription

let package = Package(
    name: "SnapDoCore",
    defaultLocalization: "ko",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SnapDoCore", targets: ["SnapDoCore"])
    ],
    targets: [
        .target(
            name: "SnapDoCore",
            path: "Sources/SnapDoCore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SnapDoCoreTests",
            dependencies: ["SnapDoCore"],
            path: "Tests/SnapDoCoreTests"
        )
    ]
)
