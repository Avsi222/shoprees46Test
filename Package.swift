// swift-tools-version:5.2
//
//  Package.swift
//  shoprees46Test
//
//  Created by Арсений Дорогин on 04.08.2020.
//

import PackageDescription

let package = Package(
    name: "shoprees46Test",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "shoprees46Test",
            targets: ["shoprees46Test"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "shoprees46Test",
            path: "shoprees46Test/Classes/"
        )
    ]
)
