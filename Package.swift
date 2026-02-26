// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "FiservMobilePayments",
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
            url: "https://github.com/Fiserv/mobile-payments-ios/releases/download/1.0.6/FiservMobilePayments.xcframework.zip",
            checksum: "00ddf653a14bab59d170767d5d7237b706b20368de175cb363d40447681787be"
        )
    ]
)
