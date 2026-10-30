# K/M számformátum a jutalomlistában — 2026-10-30

## Kérés és döntés

A „Mikor, mit, mennyit?” lista is rövidítse a nagy értékeket a játékhoz
hasonlóan, ne csak a grafikonok. A korábbi294-es döntés teljes táblázati
számkijelzését ez felülírja; a közös számskála és a pontos adat megmarad.

Az app.js listakirajzolása most ugyanazt a formatCompact függvényt hívja,
mint a statkártyák. Példák:18300→+18,3K;2360000→+2,3M;
99800000→+99,8M;100000000→+100M. A540 marad+540.
Hiányzó összeg nem nulla, hanem kérdőjel. Az összeget nem csonkítjuk a
naplóban/APIban; a teljes érték rámutatáskor title-ben és az akadálymentes
aria-labelben is elérhető.

## Ellenőrzés és működés

Új Node-regresszió a tényleges dashboard/app.js-t futtatja vm-ben,
minimális teszt-DOMmal és rögzített APIválasszal. A fenti öt összeg és
a hiányzó összeg valódi táblázatcelláját ellenőrzi, valamint a pontos
tooltipet, aria-labelt és a forrásadat változatlanságát. Nem élő naplót
vagy játékot használ; ugyanabban a commit/push/PR-kapuban fut.

A Sites készség helyi-only munkamenete: a meglévő helyi szerver szolgálja
ki a fájlt, nincs felhős publikálás vagy új szerver/gyűjtő indítása.
A változáshoz a meglévő oldalt újra kell tölteni. A böngészős kapcsolat
korábbi elérhetetlensége miatt vizuális PASS-t nem állítunk; a kirajzolást
automatizált teszttel és a kiszolgált JS ellenőrzésével vizsgáljuk.

Eredmény: teljes23Swift+15statisztika+3Gitkapu+9felügyelet+14Node teszt
és3JS-szintaxisellenőrzésPASS. A HTTP-n kiszolgált app.js az új compact
cellát és a pontos title/aria-labelt tartalmazza.20:54:55Zkor a66095worker
friss sikeres képidővel, megszakítás nélkül futott.
