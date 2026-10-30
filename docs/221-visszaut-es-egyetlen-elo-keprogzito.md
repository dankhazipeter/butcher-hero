# Visszaút és egyetlen élő képrögzítő — 2026-09-19

## Visszaút

`130112-4518a660-play`: teljes5610 HP-ról Titan–Deep Mines út, közben több
kis célból5650 maximum. A64. kép a zárt kapu déli, kerítéstől nyugati oldalán.
Az időkeret a13déli lépés hatodik lépése után lejárt. A következő
`130403-88941a0a-nudge` hét0,55s-os déli lépés befejezte ezt a szakaszt.
`130543-9e8e6517-observe`: tiszta útkereszteződés; a bot jól azonosította a WNW-élt.
`130551-3f46e703-play/12`: tényleges narancs–zöld kapu. A visszatérés sikeres,
de a12N/14W/10E/18N felvezetés még felesleges ingázásokat tartalmaz.

## Képrögzítési anomália

A 130403-as nudge még élt, amikor egy observe-folyamat is elindult.
A `130413-41bd3a5f-observe` több mint40másodpercig nem adott képet.
A játékablak külön ellenőrzése normál, élő képet mutatott; csak a beragadt
megfigyelőt állítottuk le. A következő egyedüli observe azonnal sikerült.
**Következtetés:** párhuzamos élő képrögzítés kerülendő; a pontos rendszerhiba
nem bizonyított. Nem játékbeli elakadás és nem jogosultsági tiltás.

## Programdöntés

A nem-replay módok közös, nem blokkoló operációsrendszer-zárat kérnek a
`docs/runs/.live-capture.lock` fájlon. Második élő bot/observe/nudge/tap világos
hibával kilép; a zár a folyamat megszűnésekor automatikusan felszabadul.
Replay párhuzamosan megengedett. Ez megelőzés, nem még igazolt API-timeout javítás.

Élő teszt: `132241-dd9dfd1c-observe`10képes futása közben a második
`132243-8d4a9cee-observe` azonnal1-es kilépéssel és világos zárolási üzenettel
állt le. Az első normálisan befejeződött, a következő nudge pedig ismét futott.

## Következő útvonalhiba

A 130551-es futás belépés után az északi ház/szekér sziklafalának ment.
A34. és69. képen18,8K boss a fal túlsó oldalán, sebzés nélkül.
A hurkot82. képnél megszakítottuk. `130744-929fb7e5-nudge`6S×0,50 után
`130809-105eeb6b-observe/1` a kőív északi oldalán áll; a további déli él
mérése folyamatban. Ezek még nem automatikusan beégetendő teljes útvonalak.
