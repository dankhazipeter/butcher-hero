#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
bot=.build/release/ButcherHeroBot
if pgrep -f 'ButcherHeroBot play' >/dev/null; then
  echo 'STOP: állapot-hash regresszió nem futhat élő play mellett.' >&2
  exit 1
fi
before=$(shasum docs/bot-state.json docs/navigation-state.json docs/world-map.json docs/shop-state.json docs/local-world-map.json tests/fixtures/failed-skulls.json tests/fixtures/player-4870.json)

replay_log() {
  "$bot" replay "$@" --replay-player-state tests/fixtures/player-4870.json | sed -n 's/^Napló: //p'
}

log=$(replay_log docs/runs/20260919-120746-play/frame-00033.png --controlled-boss-trials)
jq -e '.analysis.target.displayedHP == 428' "$log/events.jsonl" >/dev/null
echo 'PASS: a látható 428 HP nem stat-1'

log=$(replay_log docs/runs/20260919-151542-94e15f8d-play/frame-00013.png)
jq -e '.analysis.popupClose == null' "$log/events.jsonl" >/dev/null
echo 'PASS: vörös háztető fehér X nélkül nem modal, nem töri meg a térképes célt'

log=$(replay_log docs/runs/20260919-142112-1f558f77-play/frame-00013.png --controlled-boss-trials)
jq -e '.analysis.innerMapEnemyVisible == false and (.decision.x // 0) <= 0' "$log/events.jsonl" >/dev/null
echo 'PASS: Island 2 kapujából a zöld Island 1 pont nem fordít vissza'

log=$(replay_log docs/runs/20260919-123241-5a5f5eb3-play/frame-00044.png)
jq -e '.analysis.playerHealthSource != "ocr-current" and .analysis.playerDisplayedHP != 5' "$log/events.jsonl" >/dev/null
echo 'PASS: csonkolt 5:23 nem friss 5 HP'

log=$(replay_log docs/runs/20260919-134014-e1eb1568-observe)
jq -se 'all(.[]; .analysis.expandedMapVisible == true and .decision.type == "wait" and .analysis.playerHealthSource != "ocr-current")' "$log/events.jsonl" >/dev/null
echo 'PASS: kinagyított térképen nincs input és nincs friss harci HP-tanulás'

log=$(replay_log docs/runs/20260919-133652-d62deb35-play --controlled-boss-trials)
jq -se '
  (map(select(.frame == 12))[0].decision) as $turn |
  ([.[] | select(.frame >= 13 and .frame <= 18) |
    .decision.type == "swipe" and .decision.x == $turn.x and .decision.y == $turn.y] | all)
' "$log/events.jsonl" >/dev/null
echo 'PASS: boss takarása nem szakítja félbe a hétlépéses oldalkerülőt'

log=$($bot replay docs/runs/20260919-125457-a8e9024a-play/frame-00044.png --replay-player-state tests/fixtures/player-5610.json | sed -n 's/^Napló: //p')
jq -e '.analysis.playerDisplayedHP == 3040 and .analysis.playerHealthSource == "ocr-current"' "$log/events.jsonl" >/dev/null
echo 'PASS: valódi 3,04K harci HP azonnali, nem régi magas memória'

log=$($bot replay docs/runs/20260919-125457-a8e9024a-play/frame-00106.png --replay-player-state tests/fixtures/player-5610.json | sed -n 's/^Napló: //p')
jq -e '.analysis.playerDisplayedHP == 1870 and .analysis.playerHealthSource == "ocr-current" and .decision.type == "wait"' "$log/events.jsonl" >/dev/null
echo 'PASS: távoli Titan-buborék mellett 1,87K felismerve, regeneráció'

log=$(replay_log docs/runs/20260919-130809-105eeb6b-observe/frame-00001.png --controlled-boss-trials)
jq -e '.analysis.playerPixelHealthFraction >= 0.95 and (.decision.reason | startswith("Vizuális útvonalgráf:"))' "$log/events.jsonl" >/dev/null
echo 'PASS: szöveggel kettévágott teljes csík nem hamis 23%'

log=$(replay_log docs/runs/20260919-125041-64028846-observe --controlled-boss-trials --replay-navigation-state tests/fixtures/stale-highland-flag.json)
jq -se 'all(.[]; .decision.type != "tap" and (.decision.reason | contains("Unstuck") | not))' "$log/events.jsonl" >/dev/null
echo 'PASS: nyílt arénából régi magaslati flag nem teleportálhat el'

log=$(replay_log docs/runs/20260919-115359-observe/frame-00001.png --controlled-boss-trials)
jq -e '.decision.type == "tap" and (.decision.reason | contains("bezár"))' "$log/events.jsonl" >/dev/null
echo 'PASS: Venom-részletező bezárás, nem automatikus EQUIP'

log=$(replay_log docs/runs/20260919-122904-159dcbb0-observe --controlled-boss-trials --replay-navigation-state tests/fixtures/failed-skulls.json)
jq -se '.[0].decision.reason | contains("indul 11400 HP-ról")' "$log/events.jsonl" >/dev/null
echo 'PASS: nagy 300-szíves kaktusz elsőbbséges a közeli 765-ösökkel szemben'

log=$(replay_log docs/runs/20260919-122032-play --controlled-boss-trials --replay-navigation-state tests/fixtures/failed-skulls.json)
jq -se '
  (map(select(.frame == 28))[0].decision) as $escape |
  ($escape.reason | contains("Tartós harci tudás")) and
  ([.[] | select(.frame >= 29 and .frame <= 33) |
    (.decision.reason | contains("menekülési irányt")) and
    (.decision.x == $escape.x) and (.decision.y == $escape.y)] | all) and
  ([.[] | select(.decision.reason | contains("koponyaküldetés"))] | length == 0)
' "$log/events.jsonl" >/dev/null
echo 'PASS: vereségsáv után öt további azonos kifelé input, nincs koponyaút'

log=$($bot replay docs/runs/20260919-145145-cae9073c-play --kite-boss --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -se '
  (map(select(.frame == 13))[0].decision.reason | contains("távolodás")) and
  ([.[] | select(.frame >= 14 and .frame <= 17) | .analysis.playerHealthSource != "ocr-memory-no-threat-guard"] | all) and
  ([.[] | select(.frame >= 19) | .decision.type == "wait" and (.decision.reason | contains("Kitérős") | not)] | all)
' "$log/events.jsonl" >/dev/null
echo 'PASS: takart boss-HP-nál korai visszavonulás, halál után nincs kísérleti mozgás'

log=$($bot replay docs/runs/20260919-160134-caa5c204-play --controlled-boss-trials --replay-player-state tests/fixtures/player-5840.json | sed -n 's/^Napló: //p')
jq -se '
  (map(select(.frame == 10))[0].decision.reason | contains("Friss LEVEL UP")) and
  ([.[] | select(.frame >= 10 and .frame <= 20) | .decision.reason | contains("röviden takarásba került") | not] | all)
' "$log/events.jsonl" >/dev/null
echo 'PASS: Venom18 jutalom lezárja a harcot, nincs halott őr-visszakeresés'
after=$(shasum docs/bot-state.json docs/navigation-state.json docs/world-map.json docs/shop-state.json docs/local-world-map.json tests/fixtures/failed-skulls.json tests/fixtures/player-4870.json)
test "$before" = "$after"
echo 'PASS: replay sem a játékállapotot, sem a fixture-t nem módosította'
