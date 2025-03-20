// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PalauaandsonsCapacitorSharing",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "PalauaandsonsCapacitorSharing",
            targets: ["SharingPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "SharingPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/SharingPlugin"),
        .testTarget(
            name: "SharingTests",
            dependencies: ["SharingPlugin"],
            path: "ios/Tests/PluginTests")
    ]
)
