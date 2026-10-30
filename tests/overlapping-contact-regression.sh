#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
replay() {
  .build/release/ButcherHeroBot replay "$1" --replay-player-state tests/fixtures/player-7060.json | sed -n 's/^Napló: //p'
}
log=$(replay docs/runs/20260919-192612-5b181452-play/frame-00000.png)
jq -e '.analysis.nearbyThreatCount>=1 and any(.analysis.visibleTargets[]; .displayedHP==2740 and .distance<30 and .bar.minX==325 and .bar.minY==402)' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-193600-d4e90045-observe/frame-00000.png)
jq -e '.analysis.nearbyThreatCount==0 and .analysis.playerDisplayedHP==7060' "$log/events.jsonl" >/dev/null
bash tests/red-stub-frame-regression.sh
echo 'PASS: overlapped2740HP contact recognized within30px; ordinary full-health scene and red boots excluded'
