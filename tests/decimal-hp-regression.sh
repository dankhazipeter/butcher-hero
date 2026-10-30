#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-173528-34b0a014-play/frame-00027.png --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -e '.analysis.playerDisplayedHP != 1590 and .analysis.playerHealthSource != "ocr-current"' "$log/events.jsonl" >/dev/null
echo 'PASS: 15.9K is not silently reinterpreted as 1.59K; no invented critical HP'
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-173902-728bc518-play/frame-00004.png --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -e '.decision.reason|startswith("HP-t takaró időzítő:")' "$log/events.jsonl" >/dev/null
echo 'PASS: fresh kill timer permits one bounded observation step, not a navigation deadlock'
