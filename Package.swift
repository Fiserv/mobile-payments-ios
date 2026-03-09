// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "mobile-payments-ios",
    platforms: [
        .iOS(.v16_4)
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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.8/FiservMobilePayments.xcframework.zip",
            checksum: "e916dd73676c53a6c09b5de9ad9cca8243006dc37bf125c0c34e584cfbd63da4"
        )
    ]
)
