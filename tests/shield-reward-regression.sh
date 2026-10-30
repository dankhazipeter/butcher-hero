#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-174156-16cab21e-play --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -se '[.[]|.analysis.visibleTargets[]|select((.ocrStrings|index("64"))!=null)] | length>0 and all(.displayedHP != 5 and .displayedHP != 50)' "$log/events.jsonl" >/dev/null
echo 'PASS: fractional shield reward does not poison visible64HP guard identity'
log=$(.build/release/ButcherHeroBot replay docs/runs/20260919-174801-84e95575-play --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -se '[.[]|select(.frame<=3)|.analysis.visibleTargets[]|select(.x>400 and .y>200 and .y<350)] | length>0 and all(.displayedHP==null or .displayedHP>=60)' "$log/events.jsonl" >/dev/null
echo 'PASS: HP-row geometry rejects 1.5 reward misread in the next live sequence'
