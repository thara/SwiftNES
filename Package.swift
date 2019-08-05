// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNES",
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),

        .package(url: "https://github.com/thara/SDL.git", .branch("fix_no_texture_on_release")),

        .package(url: "https://github.com/Quick/Quick.git", from: "2.1.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),

        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "SwiftNES",
            dependencies: ["Logging"]),
        .target(
            name: "SwiftNESMain",
            dependencies: ["SwiftNES", "SDL", "Logging", "Commander"]),
        .testTarget(
            name: "SwiftNESTests",
            dependencies: ["SwiftNES", "Quick", "Nimble"]),
    ]
)
