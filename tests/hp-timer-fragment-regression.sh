#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-185320-f2487515-play/frame-00032.png --replay-player-state tests/fixtures/player-6510.json | sed -n 's/^Napló: //p')
jq -e '.analysis.playerHealthSource != "ocr-current" and (.decision.reason|startswith("HP-t takaró időzítő:"))' "$log/events.jsonl" >/dev/null
echo 'PASS: clipped52s+KHP triggers bounded observation, not invented fresh health'
