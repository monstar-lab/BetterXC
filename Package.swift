// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BetterXC",
    dependencies: [
        .package(url: "https://github.com/xcodeswift/xcproj.git", from: "4.3.0"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "4.1.0"),
        .package(url: "https://github.com/kareman/Moderator.git", from: "0.4.3"),
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.1.4")
    ],
    targets: [
        .target(
            name: "BetterXC",
            dependencies: ["xcproj", "SwiftShell", "Moderator", "Rainbow"]
        ),
    ]
)
