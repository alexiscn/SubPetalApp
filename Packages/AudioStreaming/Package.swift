// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AudioStreaming",
    platforms: [
        .iOS(.v12),
        .macCatalyst(.v14),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "AudioStreaming",
            targets: ["AudioStreaming"]
        ),
    ],
    targets: [
        .target(
            name: "AudioStreaming",
            path: "AudioStreaming"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
