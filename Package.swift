// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Auburn",
    platforms: [
        .macOS(.v10_15) 
    ],
    products: [
        .library(
            name: "Auburn",
            targets: ["Auburn"])
    ],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Redshot.git", from: "0.8.4")
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
