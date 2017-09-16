// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SGLOpenGL",
    products: [
        .library(name: "SGLOpenGL", targets: ["SGLOpenGL"]),
        .executable(name: "glgen", targets: ["Tools"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "SGLOpenGL", dependencies: []),
        .target(name: "Tools", dependencies: []),
    ]
)
