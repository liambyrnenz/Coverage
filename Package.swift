// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Coverage",
    platforms: [.macOS(.v10_13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "Coverage",
            targets: ["Coverage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/liambyrnenz/CommandLineUtilities.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Coverage",
            dependencies: ["CoverageLibrary"]),
        .target(
            name: "CoverageCommon",
            dependencies: ["CommandLineUtilities"]),
        .target(
            name: "CoverageDataAccess",
            dependencies: ["CommandLineUtilities", "CoverageCommon"]),
        .target(
            name: "CoverageLibrary",
            dependencies: ["CommandLineUtilities", "CoverageDataAccess"]),
        
        .testTarget(
            name: "CoverageDataAccessTests",
            dependencies: ["CoverageDataAccess"]),
        .testTarget(
            name: "CoverageLibraryTests",
            dependencies: ["CoverageLibrary"])
    ]
)
