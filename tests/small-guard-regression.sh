#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
replay() {
 .build/release/ButcherHeroBot replay "$1" --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p'
}
log=$(replay docs/runs/20260919-171158-6e547290-play/frame-00000.png)
jq -e '.decision.reason|startswith("Kontrollált bosspróba indul 1220")' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-161416-fc529d1c-observe/frame-00000.png)
jq -e '.decision.reason|startswith("Kontrollált bosspróba indul")|not' "$log/events.jsonl" >/dev/null
echo 'PASS: close 1220 guard trial, no automatic DOC trial'
