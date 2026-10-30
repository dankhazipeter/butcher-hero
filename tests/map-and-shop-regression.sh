#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# No -O here: legacy assert() checks must remain enabled.
swiftc Sources/ButcherHeroBot/ShopInspector.swift tests/shop-inspector-tests.swift -o .build/shop-inspector-tests
.build/shop-inspector-tests
swiftc Sources/ButcherHeroBot/ShopInspector.swift Sources/ButcherHeroBot/ShopAuditor.swift tests/shop-auditor-tests.swift -o .build/shop-auditor-tests
.build/shop-auditor-tests
# These tests deliberately use precondition(), active under -O as well.
swiftc -O Sources/ButcherHeroBot/MinimapAnchorDetector.swift Sources/ButcherHeroBot/VisualOdometry.swift Sources/ButcherHeroBot/LocalWorldMap.swift tests/local-map-tests.swift -o .build/local-map-tests
.build/local-map-tests
swiftc -O Sources/ButcherHeroBot/MinimapAnchorDetector.swift tests/minimap-anchor-tests.swift -o .build/minimap-anchor-tests
.build/minimap-anchor-tests
swiftc Sources/ButcherHeroBot/ProgressWatchdog.swift tests/progress-watchdog-tests.swift -o .build/progress-watchdog-tests
.build/progress-watchdog-tests
swiftc Sources/ButcherHeroBot/RunCancellation.swift tests/cancellation-tests.swift -o .build/cancellation-tests
.build/cancellation-tests
swiftc Sources/ButcherHeroBot/MinimapAnchorDetector.swift Sources/ButcherHeroBot/LandmarkCorridorPlanner.swift tests/corridor-tests.swift -o .build/corridor-tests
.build/corridor-tests
swiftc Sources/ButcherHeroBot/MinimapAnchorDetector.swift Sources/ButcherHeroBot/MinimapTargetQuarantine.swift tests/target-quarantine-tests.swift -o .build/target-quarantine-tests
.build/target-quarantine-tests
swiftc Sources/ButcherHeroBot/WeaponRewardEvidence.swift tests/weapon-reward-tests.swift -o .build/weapon-reward-tests
.build/weapon-reward-tests
