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
        .package(url: "https://github.com/pkluz/PKHUD", exact: "5.4.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation", exact: "0.9.14"),
        .package(url: "https://github.com/realm/realm-swift", exact: "10.28.1"),
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
                "SettingsFeature",
                "GitHub",
                "Core",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                "AuthAPI",
                "Core",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]
        ),
        .target(
            name: "GitHub",
            dependencies: [
                "GitHubAPI",
            ]
        ),
        .target(name: "AuthAPI"),
        .target(
            name: "GitHubAPI",
            dependencies: [
                "Core",
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
            ]
        ),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "PKHUD", package: "PKHUD"),
                .product(name: "RealmSwift", package: "realm-swift"),
            ],
            resources: [
                .process("Resources/Localizable.strings"),
            ]
        ),
        .testTarget(
            name: "ActsPackageTests",
            dependencies: [
                "SignInFeature",
                "ActionsFeature",
                "SettingsFeature",
            ]
        ),
    ]
)
