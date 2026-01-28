// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "FountainKitFacebookConnector",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "facebook_connector", targets: ["facebook_connector"])
    ],
    targets: [
        .target(
            name: "facebook_connector"
        ),
        .testTarget(
            name: "facebook_connectorTests",
            dependencies: ["facebook_connector"]
        )
    ]
)
