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
    dependencies: [],
    targets: [
        .target(name: "App", dependencies: ["SignInFeature"]),
        .target(name: "SignInFeature", dependencies: ["Core"]),
        .target(name: "Core")
    ]
)
