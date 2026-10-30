#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
before=$(shasum docs/bot-state.json docs/navigation-state.json docs/navigation-v2-map.json docs/map-objectives.json)
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-212136-028e4724-play --replay-player-state tests/fixtures/player-7060.json | sed -n 's/^Napló: //p')
jq -s -e 'length >= 21 and all(.[]; .analysis.confirmedMaximumDisplayedHP == 7060) and (.[17].analysis.playerDisplayedHP != 7400)' "$log/events.jsonl" >/dev/null
test "$before" = "$(shasum docs/bot-state.json docs/navigation-state.json docs/navigation-v2-map.json docs/map-objectives.json)"
echo 'PASS: repeated 740GKC noise does not learn 7400 maximum; replay is read-only'
