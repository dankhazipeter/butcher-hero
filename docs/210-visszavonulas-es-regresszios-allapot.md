# Visszavonulás és tesztelhető állapot — 2026-09-19

## Élő hiba

A `122032-play` az új koponyatilalom mellett nem adott közvetlen koponya-
követést, de a normál piros minimappont útja így is elérte a 18,8K boss
környezetét. A 28., 31–32., 38. döntés kifelé mozgott, a köztes lépések viszont
visszavették a régi északkeleti faljárást. A harci tilalom nem törölte ezt az
állapotot. Nem elég egyetlen kifelé swipe.

## Javítás

A tartós vereségsáv miatti visszavonulás most az általános bossőrrel azonosan
törli a statikus faljárást, minimap-kerülőt, hordozósarkot, célirányt és tartós
kerülőt, majd hat végrehajtott swipe-ig őrzi a kifelé irányt. Ez nem általános
világtájtilalom: a következő irányt friss képek alapján választja.

## Reprodukálható regresszió

A normál replay nem tölti a tartós navigációt, ezért a vereségsávra építő ágat
nem lehetett vele valóban tesztelni. Új opcionális kapcsoló:
`--replay-navigation-state tests/fixtures/failed-skulls.json`.
Ez csak replay módban engedélyezett, a megadott kis fixture-t olvassa, de sem
azt, sem a játék valódi tudástárát nem írja. Alapértelmezett replay változatlan.
A fixture két konkrét vereségsávot tartalmaz; más tesztek nem kapják meg automatikusan.
Build, fixture-es visszajátszás és élő ellenőrzés következik.

Build sikeres. `122344-replay` a teljes `122032-play` sorozattal és a fixture-rel:
28. képen vereségsáv-kifelé döntés, 29–33. képen öt további, azonos irányú
menekülési input. A korábbi faljárás nem folytatódik; 34-től friss irányhűtés /
minimap-döntés következik. A célzott regresszió ezzel sikeres.

Automatikus ellenőrző: `bash tests/regression.sh`. A 428-as OCR, a Venom-panel
biztonságos bezárása, a hatlépéses bosskijárat és a tudástárak/fixture változatlan
hash-e is átment. A gyors teszt két replaye azonos másodpercbe esett: a régi
naplónév ezért felülírta az első futás fájlját. Az első ellenőrzés még előtte
lefutott, de a bizonyítékmegőrzés hibás volt. Új naplónév minden futásnál egyedi
UUID-részletet tartalmaz; régi naplókat nem nevezünk át és nem törlünk.
