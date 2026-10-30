#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-180354-06eefdb9-play/frame-00021.png --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -e '.analysis.target.displayedHP==923 and .analysis.target.bossEvidence==false and .analysis.nearbyThreatCount==0 and .decision.type=="swipe"' "$log/events.jsonl" >/dev/null
echo 'PASS: visible923tree is actionable farm, not a nearby hostile boss'
