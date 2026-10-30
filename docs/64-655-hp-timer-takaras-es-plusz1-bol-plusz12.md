# 655 HP, timer-takarás és +1-ből hamis +12

## Élő fejlődés — `20260829-033114-play`

A nyers 923-as bossőrrel futó build 642-ről három gyors lépcsővel 655 maximális HP-ra
fejlődött:

- `642→647`: 124 HP-s cél befejezése után stabil +5;
- `647→652`: következő rövid farmcél után stabil +5;
- `652→655`: következő cél után stabil +3.

A végérték több friss OCR-képen és a `bot-state.json` állapotban is stabil. A pontos
egyedi célhozzárendelések jutalomeffektus nélküli képkockák miatt erős következtetések;
a +5/+5/+3 lépcsők és a 655-ös maximum biztosak.

## Timer-takarás nem sérülés

A `frame-00054` képen egy `22h 27m` újratermelődési kör ráfedett a játékos zöld
HP-csíkjára. A pixelmérés egyetlen képen 27%-ot adott, előtte és utána 95%, később
friss OCR-rel teljes 655. A `nearbyRespawnTimer` őr helyesen nem indított kritikus
visszavonulást; ez újabb élő igazolása a közös timer-takarási hibának.

## Kék fejsze ikonból hamis számjegy

A `frame-00058` vizuálisan zöld `+1` és kék fejsze ikon. A következő OCR-képen a Vision
`+12`-t adott: a fejsze alakjának egy része 2-es számjegyként ragadt az 1-hez. A max HP
655 maradt, tehát ez biztosan nem +12 szívjutalom.

## Programdöntés

Az egész jutalomparser most csak a közvetlenül bizonyított értékeket fogadja el:
`1, 2, 3, 4, 5, 10, 20`. Tizedes alak és más, ismeretlen/összeragadt érték nem kerül
jutalommemóriába. Ez nem veszíti el a valódi HP-fejlődést, mert a maximumot a friss
játékos-HP önállóan is hitelesíti; csak az effektushoz kötött harclezárás lesz
konzervatívabb.

## Futás folytatása

A 140–155. esemény egy 4-es statikonú, rövid HP-jú cél befejezése után stabil
`655→659` lépcsőt adott. Közvetlen effektus a páros képkockákból kimaradt, ezért a
+4 célhozzárendelés erős következtetés; a 659-es új maximum biztos és tartós.
