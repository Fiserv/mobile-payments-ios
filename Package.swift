// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "mobile-payments-ios",
    platforms: [
        .iOS("16.4")
    ],
    products: [
        .library(
            name: "FiservMobilePayments",
            targets: ["FiservMobilePayments"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "FiservMobilePayments",
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.17/FiservMobilePayments.xcframework.zip",
            checksum: "5f5c0b2206b27e89e9832b15d5017b1c5025bba6fc192a26fad1bdcba5297859"
        )
    ]
)
