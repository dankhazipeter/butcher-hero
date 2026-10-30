#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-181615-c713dcbb-observe/frame-00000.png --replay-player-state tests/fixtures/player-5990.json | sed -n 's/^Napló: //p')
jq -e '.analysis.visibleTargets[0].displayedHP==4310 and (.decision.reason|contains("bosspróba indul 4310"))' "$log/events.jsonl" >/dev/null
echo 'PASS: identified4310/500heart guardian starts the bounded trial without global boss mode'
