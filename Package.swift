// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapTilerSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MapTilerSDK",
            targets: ["MapTilerSDK"])
    ],
    targets: [
        .target(
            name: "MapTilerSDK",
            path: "Sources/MapTilerSDK",
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "MapTilerSDKTests",
            dependencies: ["MapTilerSDK"],
            path: "Tests"
        )
    ]
)
