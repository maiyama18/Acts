// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ActsPackage",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "App",
            targets: ["App"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", branch: "swift-5.6")
    ],
    targets: [
        .target(name: "App", dependencies: ["SignInFeature"]),
        .target(
            name: "SignInFeature",
            dependencies: [
                "Core",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]
        ),
        .target(name: "Core")
    ]
)
