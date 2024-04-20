// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "observing",
    platforms: [.macOS(.v10_15), .iOS(.v13), .macCatalyst(.v13)],
    products: [
        .library(
            name: "observing",
            targets: ["observing"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/objective-audio/cpp_utils.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "observing",
            dependencies: [
                .product(name: "cpp-utils", package: "cpp_utils")
            ]
        ),
        .testTarget(
            name: "observing-tests",
            dependencies: [
                "observing",
            ],
            cxxSettings: [
                .unsafeFlags(["-fcxx-modules"])
            ]
        ),
    ],
    cLanguageStandard: .gnu18,
    cxxLanguageStandard: .gnucxx2b
)
