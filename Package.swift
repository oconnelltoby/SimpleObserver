// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SimpleObserver",
    products: [
        .library(name: "SimpleObserver", targets: ["SimpleObserver"]),
    ],
    targets: [
        .target(name: "SimpleObserver", dependencies: []),
        .testTarget(name: "SimpleObserverTests", dependencies: ["SimpleObserver"]),
    ]
)
