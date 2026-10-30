#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-164311-fc543447-play --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -se '[.[]|select(.decision.reason|startswith("HP-t takaró időzítő:"))]|length==1' "$log/events.jsonl" >/dev/null
echo 'PASS: overlapping timer receives exactly one observation sidestep, no repeated blind movement'
