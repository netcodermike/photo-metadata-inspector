// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "PhotoMetadata", platforms: [.macOS(.v13)], products: [.executable(name: "PhotoMetadata", targets: ["PhotoMetadata"])], targets: [.executableTarget(name: "PhotoMetadata")])
