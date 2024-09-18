// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShapeUp",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
        .tvOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ShapeUp",
            targets: ["ShapeUp"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ShapeUp",
            resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(
            name: "ShapeUpTests",
            dependencies: ["ShapeUp"]),
    ],
    swiftLanguageVersions: [.v5, .version("6")]
)
