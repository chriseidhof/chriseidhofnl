// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chris",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Website", targets: ["Website"]),
        .library(
            name: "Chris",
            targets: ["Chris"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams", from: "2.0.0"),
        .package(url: "https://github.com/robb/Swim.git", branch: "main"),
        .package(url: "file:///Users/chris/objc.io/StaticSite/", branch: "main"),
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "Website",
            dependencies: ["Chris"]),
        .target(
            name: "Helpers",
            dependencies: [
                "StaticSite",
                .product(name: "HTML", package: "Swim"),
                "Yams",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax")
            ]),
        .target(
            name: "SwiftUIViews",
            dependencies: [
                "StaticSite",
                "Yams",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                "Helpers",
                .product(name: "HTML", package: "Swim"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax")
            ]),
        .target(
            name: "Chris",
            dependencies: [
                "StaticSite",
                "Yams",
                "Helpers",
                .product(name: "HTML", package: "Swim"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "ChrisTests",
            dependencies: ["Chris"]),
    ]
)

