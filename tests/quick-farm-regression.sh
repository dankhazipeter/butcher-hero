#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bot=.build/release/ButcherHeroBot
replay() {
  "$bot" replay "$1" --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p'
}
log=$(replay docs/runs/20260919-161659-2865aa6c-observe/frame-00000.png)
jq -e '.analysis.target.displayedHP==67 and (.decision.reason|startswith("Island 2")|not)' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-162240-32041d4b-play/frame-00042.png)
jq -e '.analysis.target.displayedHP==174 and (.decision.reason|startswith("Island 2")|not)' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-162240-32041d4b-play/frame-00038.png)
jq -e '.analysis.minimapPose.anchor!="dusty-gulch-venom-guard"' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-161504-957412ab-play/frame-00010.png)
jq -e '.analysis.playerDisplayedHP==2320 and .analysis.playerHealthFraction<0.5 and .analysis.playerHealthSource=="ocr-current"' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-161504-957412ab-play/frame-00000.png)
jq -e '.analysis.nearbyThreatCount>=1' "$log/events.jsonl" >/dev/null
log=$(replay docs/runs/20260919-162738-7547e4ca-play/frame-00052.png)
jq -e '[.analysis.visibleTargets[].displayedHP] | any(. == 1160) and all(. == null or . < 10000)' "$log/events.jsonl" >/dev/null
echo 'PASS: nearby67/174farm, no Island1Venom anchor, numeric2320HP, close red stub and partial edge1160HP'
log=$(replay docs/runs/20260919-163957-f0a49628-play/frame-00092.png)
jq -e '.analysis.minimapPose.anchor=="dusty-gulch-orange-skull" and .analysis.minimapPose.x>0' "$log/events.jsonl" >/dev/null
echo 'PASS: orange skull beats ambiguous green weapon anchor at the island gate'
