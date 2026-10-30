#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bot=.build/release/ButcherHeroBot
replay() {
  "$bot" replay "$1" --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p'
}
log=$(replay docs/runs/20260919-192516-7c1c3ffa-observe/frame-00000.png)
jq -e '.analysis.island2SkullDirection.x > 0.9 and (.analysis.island2SkullDirection.y|fabs)<0.3 and .analysis.golemMapOffset.x>15' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-192415-29b0f273-observe/frame-00000.png)
jq -e '.analysis.expandedMapVisible==true and .analysis.island2SkullDirection==null and .analysis.golemMapOffset==null and .decision.type=="wait"' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-192612-5b181452-play/frame-00003.png)
jq -e '.analysis.island2SkullDirection==null and .analysis.golemMapOffset==null' "$log/events.jsonl" >/dev/null
echo 'PASS: east orange head recognized, expanded map excluded, defeated grey head excluded'
