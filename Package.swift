// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNES",
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),

        .package(url: "https://github.com/thara/SDL.git", .branch("swiftnes-5")),
        .package(url: "https://github.com/twostraws/SwiftGD.git", from: "2.0.0"),

        .package(url: "https://github.com/Quick/Quick.git", from: "2.2.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),

        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.0"),

        .package(url: "https://github.com/apple/swift-format.git", .branch("swift-5.3-branch")),
    ],
    targets: [
        .target(name: "SwiftNES"),
        .target(
            name: "SwiftNESMain",
            dependencies: ["SwiftNES", "SDL", "Logging", "Commander"]),
        .target(
            name: "DumpSpriteImage",
            dependencies: ["SwiftNES", "SwiftGD", "Logging", "Commander"]),
        .testTarget(
            name: "SwiftNESTests",
            dependencies: ["SwiftNES", "Quick", "Nimble"]),

        .target(name: "NES"),
        .target(
            name: "NESMain",
            dependencies: ["NES", "SDL", "Commander"]),
    ]
)
