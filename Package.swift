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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.21/FiservMobilePayments.xcframework.zip",
            checksum: "8853573369241157d550eb7700610648086bf78ab028a7d492de55289a1a23f8"
        )
    ]
)
