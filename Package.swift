// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNES",
    products: [
        .library(name: "CGLFW3", targets: ["CGLFW3"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGL/OpenGL.git", from: "3.0.0"),
        .package(url: "https://github.com/SwiftGL/Math.git", from: "2.0.0"),
        .package(url: "https://github.com/SwiftGL/Image.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "2.1.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftNES",
            dependencies: []),
        .target(
            name: "SwiftNESMain",
            dependencies: ["SGLMath", "SGLImage", "SGLOpenGL", "CGLFW3"]),
        .testTarget(
            name: "SwiftNESTests",
            dependencies: ["SwiftNES", "Quick", "Nimble"]),

        .systemLibrary(name: "CGLFW3", pkgConfig: "glfw", providers: [.brew(["glfw"]), .apt(["glfw"])]),
    ]
)
