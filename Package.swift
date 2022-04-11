// swift-tools-version:5.5

import PackageDescription

let package = Package(
  name: "RemoteImage",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "RemoteImage",
      targets: ["RemoteImage"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "RemoteImage",
      dependencies: []),
    .testTarget(
      name: "RemoteImageTests",
      dependencies: ["RemoteImage"]),
  ])
