// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "MomentShared", platforms: [.iOS(.v17), .watchOS(.v10)], products: [.library(name: "MomentShared", targets: ["MomentShared"])], targets: [.target(name: "MomentShared")])
