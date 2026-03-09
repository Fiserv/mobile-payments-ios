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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.10/FiservMobilePayments.xcframework.zip",
            checksum: "e9335cad5769aad6dc46fccd1c56483e7d8d10417a29493496b3b072488de82a"
        )
    ]
)
