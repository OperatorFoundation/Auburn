// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Auburn",
    platforms: [
        .macOS(.v10_11) 
    ],
    products: [
        .library(
            name: "Auburn",
            targets: ["Auburn"])
    ],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Redshot.git", from: "0.8.0")
    ],
    targets: [
        .target(
            name: "Auburn",
            dependencies: ["RedShot"]),
        .testTarget(
            name: "AuburnTests",
            dependencies: ["Auburn", "RedShot"])
    ]
)
