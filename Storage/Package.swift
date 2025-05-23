// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Storage",
            targets: ["Storage"]
        ),
    ],
    targets: [
        .target(
            name: "Storage",
            resources: [
                .process("Resources/WatchListDataFile.xcdatamodeld")
            ]
        )
    ]
)
