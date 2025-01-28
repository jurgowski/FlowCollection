// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowCollection",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FlowCollection",
            targets: ["FlowCollection"]),
    ],
    targets: [
        .target(
            name: "FlowCollection"),
    ]
)
