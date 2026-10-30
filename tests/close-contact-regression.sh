#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-172137-23bbadc8-play --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -se '[.[]|select(.frame<=4 and (.decision.reason|startswith("Finom közelítés:")))]|length>=1' "$log/events.jsonl" >/dev/null
echo 'PASS: recorded67HP tree receives early contact correction by frame4, not frame8'
