// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TronWebSwift",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "TronWebSwift", targets: ["TronWebSwift"]),
        .library(name: "WalletCoreSwiftProtobuf", targets: ["WalletCoreSwiftProtobuf"])
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
                "WalletCoreSwiftProtobuf",
                .product(name: "secp256k1", package: "secp256k1.swift"),
            ]
        ),
        .binaryTarget(
            name: "WalletCoreSwiftProtobuf",
            url: "https://github.com/trustwallet/wallet-core/releases/download/4.2.9/SwiftProtobuf.xcframework.zip",
            checksum: "946efd4b0132b92208335902e0b65e0aba2d11b9dd6f6d79cc8318e2530c9ae0"
        ),
        .testTarget(
            name: "TronWebSwiftTests",
            dependencies: ["TronWebSwift", "CryptoSwift"]
        ),
    ]
)
