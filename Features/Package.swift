// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Features",
            targets: ["Features"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Data"),
        .package(path: "../Utils"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Features",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "Data", package: "Data"),
                .product(name: "Utils", package: "Utils")
            ]
        ),

    ]
)
