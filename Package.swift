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
        .package(name: "HTML", url: "https://github.com/robb/Swim.git", .branch("main")),
        .package(url: "file:///Users/chris/objc.io/StaticSite/", .branch("main")),
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .branch("main")),
    ],
    targets: [
        .executableTarget(
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
            name: "SwiftUIViews",
            dependencies: [
                "StaticSite",
                "HTML",
                "Yams",
                "SwiftSyntax",
                "Helpers",
                .product(name: "SwiftSyntaxParser", package: "SwiftSyntax")
            ]),
        .target(
            name: "Chris",
            dependencies: [
                "StaticSite",
                "HTML",
                "Yams",
                "SwiftSyntax",
                "Helpers",
                .product(name: "SwiftSyntaxParser", package: "SwiftSyntax"),
            ],
            resources: [
                .copy("Share Images/logo.pdf"),
            ]
        ),
        .testTarget(
            name: "ChrisTests",
            dependencies: ["Chris"]),
    ]
)

