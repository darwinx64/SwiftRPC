// swift-tools-version: 5.9
import PackageDescription

let package = Package(
	name: "SwiftRPC",
	platforms: [
		.macOS(.v10_13)
	],
	products: [
		.library(
			name: "SwiftRPC",
			targets: ["SwiftRPC"]),
	],
	dependencies: [
		.package(url: "https://github.com/Kitura/BlueSocket.git", exact: "2.0.4")
	],
	targets: [
		.target(
			name: "SwiftRPC",
			dependencies: [
				.product(name: "Socket", package: "bluesocket")
			]
		)
	]
)
