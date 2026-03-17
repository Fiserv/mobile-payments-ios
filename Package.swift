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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.20/FiservMobilePayments.xcframework.zip",
            checksum: "2e0f2fdba1da760e9d59156350ea5c533c457c8f42954ee333dd93bd046505e3"
        )
    ]
)
