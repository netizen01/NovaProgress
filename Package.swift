// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NovaProgress",
    products: [
        .library(name: "NovaProgress", targets: ["NovaProgress"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "NovaProgress", dependencies: [])
    ]
)
