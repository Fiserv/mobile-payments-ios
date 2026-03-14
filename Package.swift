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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.16/FiservMobilePayments.xcframework.zip",
            checksum: "e3e586db96a779abcbfd0ea7ffc4310b4894af726c7b8105e8d38c6173f01728"
        )
    ]
)
