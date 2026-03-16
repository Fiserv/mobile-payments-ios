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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.18/FiservMobilePayments.xcframework.zip",
            checksum: "8731e6c916d7bd89a465e3610368ead6359ead54f36d0c1d9452ffd02bdf374c"
        )
    ]
)
