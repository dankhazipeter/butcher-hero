#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
before=$(shasum docs/bot-state.json docs/navigation-state.json docs/local-world-map.json docs/navigation-v2-map.json docs/shop-state.json)
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-203949-12e735ce-play --kite-boss --replay-player-state tests/fixtures/player-7060.json | sed -n 's/^Napló: //p')
jq -se '
  any(.[]; .frame==4 and .decision.type=="swipe" and .decision.x < -0.8 and .decision.y > 0.45) and
  all(.[] | select(.frame>=3 and .frame<=8); .decision.type=="swipe" and .decision.x < -0.8) and
  all(.[] | select(.frame==9 or .frame==10); .decision.type=="wait" and (.decision.reason|contains("kezdő bossHP 18800"))) and
  all(.[] | select(.frame>=11); .decision.type=="wait")
' "$log/events.jsonl" >/dev/null
after=$(shasum docs/bot-state.json docs/navigation-state.json docs/local-world-map.json docs/navigation-v2-map.json docs/shop-state.json)
test "$before" = "$after"
echo 'PASS: missing contact never means clearance; fixed escape bearing; initial18800 death identity; no post-death retry; replay read-only'
