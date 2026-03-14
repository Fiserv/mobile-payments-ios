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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.14/FiservMobilePayments.xcframework.zip",
            checksum: "87d01d0ef3ea76af275c1b96af77da1fc4fe1c328334596c935086b5977a58ad"
        )
    ]
)
