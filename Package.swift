// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNES",
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),

        .package(url: "https://github.com/thara/SDL.git", .branch("csdl")),
        .package(url: "https://github.com/twostraws/SwiftGD.git", from: "2.0.0"),
        .package(url: "https://github.com/thara/SoundIO.git", from: "0.3.1"),
        .package(url: "https://github.com/thara/NesSndEmuSwift.git", from: "0.2.0"),

        .package(url: "https://github.com/Quick/Quick.git", from: "2.2.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),

        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.0"),
    ],
    targets: [
        .target(name: "SwiftNES", dependencies: ["NesSndEmuSwift", "SoundQueue"]),
        .target(
            name: "SwiftNESMain",
            dependencies: ["SwiftNES", "SDL", "Logging", "Commander"]),
        .testTarget(
            name: "SwiftNESTests",
            dependencies: ["SwiftNES", "Quick", "Nimble"]),
        .target(
            name: "DumpSpriteImage",
            dependencies: ["SwiftNES", "SwiftGD", "Logging", "Commander"]),

        .target(
            name: "SoundQueueCpp",
            dependencies: ["CSDL2"]),
        .target(
            name: "SoundQueueCppWrapper",
            dependencies: ["SoundQueueCpp"]),
        .target(
            name: "SoundQueue",
            dependencies: ["SoundQueueCppWrapper"]),

    ],
    cxxLanguageStandard: .cxx98
)
