#!/bin/bash
set -euo pipefail
test "$#" -eq 1 || { echo 'Használat: bash tests/run-metrics.sh docs/runs/<futás>'; exit 2; }
jq -s '
  ((.[-1].timestamp | fromdateiso8601) - (.[0].timestamp | fromdateiso8601)) as $seconds |
  ([.[].analysis.confirmedMaximumDisplayedHP | select(. != null)]) as $maxima |
  {
    megfigyelt_masodperc: $seconds,
    kepkockak: length,
    swipe_dontesek: ([.[] | select(.decision.type == "swipe")] | length),
    emberi_aktivitas_miatti_varakozas: ([.[] | select(.decision.reason | contains("felhasználó aktív"))] | length),
    kezdo_hiteles_maximum: ($maxima[0] // null),
    zaro_hiteles_maximum: ($maxima[-1] // null),
    hp_novekedes: (if ($maxima|length)>0 then $maxima[-1]-$maxima[0] else null end),
    hp_perc: (if ($maxima|length)>0 and $seconds>0 then (($maxima[-1]-$maxima[0])*60/$seconds) else null end),
    nagy_kaktusz_gyozelmi_dontesek: ([.[] | select(.decision.reason | contains("Nagy szívkaktusz legyőzve"))] | length)
  }
' "$1/events.jsonl"
