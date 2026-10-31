// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ButcherHeroBot",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ButcherHeroBot", targets: ["ButcherHeroBot"]),
        .executable(name: "ButcherHeroAutomation", targets: ["ButcherHeroAutomation"])
    ],
    targets: [
        .executableTarget(name: "ButcherHeroBot"),
        .target(name: "RewardAutomationCore", resources: [.copy("Resources/RewardIcons"), .copy("Resources/RewardDigits"), .copy("Resources/FreeBadges")]),
        .executableTarget(name: "ButcherHeroAutomation", dependencies: ["RewardAutomationCore"]),
        .testTarget(name: "RewardAutomationCoreTests", dependencies: ["RewardAutomationCore"])
    ]
)
