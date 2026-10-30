#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-175529-376f1363-play/frame-00040.png --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -e '.analysis.nearbyThreatCount==0 and all(.analysis.visibleTargets[]; .bar.minX!=297 or .bar.minY!=479)' "$log/events.jsonl" >/dev/null
echo 'PASS: red boot is not a nearby enemy'
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-161504-957412ab-play/frame-00000.png --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -e '.analysis.nearbyThreatCount>=1 and any(.analysis.visibleTargets[]; .bar.minX==244 and .bar.minY==470)' "$log/events.jsonl" >/dev/null
echo 'PASS: depleted DOC bar remains a nearby threat'
