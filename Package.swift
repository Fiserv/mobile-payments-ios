// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "FiservMobilePayments",
    platforms: [
        .iOS(.v16.4)
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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.0/FiservMobilePayments.xcframework.zip",
            checksum: "35618461be72852dcabc83c41ceabf8d67c350e7b84af45254b48d9192b3cf25"
        )
    ]
)
