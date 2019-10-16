// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Auburn",
    products: [
        .library(
            name: "Auburn",
            targets: ["Auburn"])
    ],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Redshot.git", from: "0.6.0")
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
