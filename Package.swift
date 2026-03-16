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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.19/FiservMobilePayments.xcframework.zip",
            checksum: "60ca91794e324c0c7939974c7e5975a0e735ab732fa62c687c801ad925553f4f"
        )
    ]
)
