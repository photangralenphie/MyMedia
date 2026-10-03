// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "MyMediaAPI",
	platforms: [
		.macOS(.v15)
	],
	products: [
		.library(name: "MyMediaAPI", targets: ["MyMediaAPI"])
	],
	dependencies: [
		.package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.26.0"),
		.package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.5.0")
	],
	targets: [
		.target(
			name: "MyMediaAPI",
			dependencies: [
				.product(name: "Hummingbird", package: "hummingbird")
			],
			resources: [
				.process("Resources/openapi.yaml"),
				.process("Resources/scalarDocs.html")
			]
		)
	]
)
