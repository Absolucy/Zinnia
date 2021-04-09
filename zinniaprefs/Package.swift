// swift-tools-version:5.2

import Foundation
import PackageDescription

guard let theosPath = ProcessInfo.processInfo.environment["THEOS"],
      let projectDir = ProcessInfo.processInfo.environment["PWD"]
else {
	fatalError("""
	THEOS env var not set. If you're using Xcode, open this package with `make dev`
	""")
}

let libFlags: [String] = [
	"-F\(theosPath)/vendor/lib", "-F\(theosPath)/lib",
	"-I\(theosPath)/vendor/include", "-I\(theosPath)/include",
]

let cFlags: [String] = libFlags + [
	"-Wno-unused-command-line-argument", "-Qunused-arguments",
]

let cxxFlags: [String] = [
]

let swiftFlags: [String] = libFlags + [
]

let package = Package(
	name: "ZinniaPrefs",
	platforms: [.iOS("12.2")],
	products: [
		.library(
			name: "ZinniaPrefs",
			targets: ["ZinniaPrefs"]
		),
	],
	targets: [
		.target(
			name: "ZinniaPrefsC",
			cSettings: [.unsafeFlags(cFlags)],
			cxxSettings: [.unsafeFlags(cxxFlags)]
		),
		.target(
			name: "ZinniaPrefs",
			dependencies: ["ZinniaPrefsC"],
			swiftSettings: [.unsafeFlags(swiftFlags)]
		),
	]
)
