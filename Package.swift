// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TronWebSwift",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "TronWebSwift", targets: ["TronWebSwift"]),
    ],
    dependencies: [
         .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMinor(from: "5.4.0")),
         .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.2"),
         .package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "TronWebSwift",
            dependencies: [
                "BigInt",
                "CryptoSwift",
                .product(name: "secp256k1", package: "secp256k1.swift"),
            ]
        ),
        .testTarget(
            name: "TronWebSwiftTests",
            dependencies: ["TronWebSwift", "CryptoSwift"]
        ),
    ]
)
