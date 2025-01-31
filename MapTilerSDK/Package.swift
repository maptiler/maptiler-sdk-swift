// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapTilerSDK",
    platforms: [
        // Minimum Supported Version
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MapTilerSDK",
            targets: ["MapTilerSDK"])
    ],
    targets: [
        .target(
            name: "MapTilerSDK"),
        .testTarget(
            name: "MapTilerSDKTests",
            dependencies: ["MapTilerSDK"]
        )
    ]
)
