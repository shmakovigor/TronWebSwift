// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TronWebSwift",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(
            name: "TronWebSwift",
            type: .static,
            targets: ["TronWebSwift"]
        ),
    ],
    dependencies: [
         .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMinor(from: "5.4.0")),
         .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.2"),
         .package(url: "https://github.com/gigabitcoin/secp256k1.swift.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "TronWebSwift",
            dependencies: [
                "BigInt",
                "CryptoSwift",
                .product(name: "secp256k1", package: "secp256k1.swift")
            ]
        ),
        .testTarget(
            name: "TronWebSwiftTests",
            dependencies: ["TronWebSwift", "CryptoSwift"]),
    ]
)