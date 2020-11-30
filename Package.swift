// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kracerble",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
	.package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/PureSwift/GATT", .branch("master")), 
        .package(url: "https://github.com/PureSwift/BluetoothLinux", .branch("master")),
        .package(url: "https://github.com/yeokm1/SwiftSerial.git", from:"0.1.1"),
        .package(url: "https://github.com/crossroadlabs/Regex.git", from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "kracerble",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"), "GATT","BluetoothLinux","SwiftSerial","Regex"]),
        .testTarget(
            name: "kracerbleTests",
            dependencies: ["kracerble"]),
    ]
)
