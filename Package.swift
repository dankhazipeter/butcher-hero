// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ButcherHeroBot",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ButcherHeroBot", targets: ["ButcherHeroBot"]),
        .executable(name: "ButcherHeroAutomation", targets: ["ButcherHeroAutomation"]),
        .executable(name: "ButcherHeroApp", targets: ["ButcherHeroApp"])
    ],
    targets: [
        .executableTarget(name: "ButcherHeroBot"),
        .target(name: "RewardAutomationCore", resources: [.copy("Resources/RewardIcons"), .copy("Resources/RewardDigits"), .copy("Resources/FreeBadges")]),
        .executableTarget(name: "ButcherHeroAutomation", dependencies: ["RewardAutomationCore"]),
        // Native Dock app: collector + statistics + controls (replaces the CLI collector and web dashboard).
        .executableTarget(name: "ButcherHeroApp", dependencies: ["RewardAutomationCore"], resources: [.copy("Resources/Icons")]),
        .testTarget(name: "RewardAutomationCoreTests", dependencies: ["RewardAutomationCore"])
    ]
)
