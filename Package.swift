// swift-tools-version:5.10

import PackageDescription

let perPlatform: [(Target, Product)] = {
#if os(OSX)

    return [(
        .target(name: "glgen"),
        .executable(name: "glgen", targets: ["glgen"])
    )]

#else 
    return []

#endif

}()

let package = Package(
    name: "SGLOpenGL",
    products: [
        .library(name: "SGLOpenGL", targets: ["SGLOpenGL"]),
    ] + perPlatform.map { $0.1 },
    dependencies: [
    ],
    targets: [
        .target(name: "SGLOpenGL", dependencies: [])
    ] + perPlatform.map { $0.0 }
)
