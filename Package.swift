// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.
// https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode

import PackageDescription

let package = Package(
    name: "Framework",
    platforms: [
      .iOS(.v15), .macOS(.v10_13), .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Framework",
            targets: ["Extensions","Libs"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Extensions",
            dependencies: []),
           .target(
            name: "Libs",
            dependencies: ["Extensions"]),
        .testTarget(
            name: "ExtensionsTests",
            dependencies: ["Extensions"]),
    ]
)
