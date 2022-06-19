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
        .package(url: "https://github.com/apple/swift-async-algorithms", branch: "swift-5.6"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", exact: "4.2.2"),
    ],
    targets: [
        .target(name: "App", dependencies: ["SignInFeature", "ActionsFeature"]),
        .target(
            name: "SignInFeature",
            dependencies: [
                "AuthAPI",
                "Core",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]
        ),
        .target(
            name: "ActionsFeature",
            dependencies: [
                "GitHubAPI",
                "Core",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]
        ),
        .target(name: "AuthAPI"),
        .target(
            name: "GitHubAPI",
            dependencies: [
                "Core",
            ]
        ),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ]
        )
    ]
)
