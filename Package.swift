// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chris",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "Website", targets: ["Website"]),
        .library(
            name: "Chris",
            targets: ["Chris"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams", from: "2.0.0"),
        .package(name: "HTML", url: "https://github.com/robb/Swim.git", .branch("main")),
        .package(url: "https://github.com/chriseidhof/StaticSite.git", .branch("main")),
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50600.1")),
        .package(name: "Minilog", url: "https://github.com/chriseidhof/minilog.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "Website",
            dependencies: ["Chris"]),
        .target(
            name: "Helpers",
            dependencies: [
                "StaticSite",
                "HTML",
                "Yams",
                "SwiftSyntax",
                .product(name: "SwiftSyntaxParser", package: "SwiftSyntax")
            ]),
        .target(
            name: "Log",
            dependencies: [
                "StaticSite",
                "HTML",
                "Yams",
                "SwiftSyntax",
                "Helpers",
                .product(name: "SwiftSyntaxParser", package: "SwiftSyntax"),
                .product(name: "Minilog", package: "Minilog"),
            ]),
        .target(
            name: "Chris",
            dependencies: [
                "StaticSite",
                "HTML",
                "Yams",
                "SwiftSyntax",
                "Helpers",
                "Log",
                .product(name: "SwiftSyntaxParser", package: "SwiftSyntax")
            ]),
        .testTarget(
            name: "ChrisTests",
            dependencies: ["Chris"]),
    ]
)
