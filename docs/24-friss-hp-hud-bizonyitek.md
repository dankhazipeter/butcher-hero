# Friss numerikus HP mint HUD-bizonyíték

Ez a technikai kutatási folyamat a `20260828-231447-play` biztonsági leállását elemzi.
A stop célja helyes — ismeretlen menüben ne küldjön inputot —, de az érintett kép biztosan
normál játéknézet volt.

## Incidens

A 71–77. eseményen a HUD-bizalom 35%-ra esett, majd a hatodik alacsony képnél a bot
leállt. A `frame-00075.png` azonban közvetlenül mutatja:

- a 340-es játékos-HP-t;
- a jobb felső minimapot;
- a lenti virtuális joystickot és fegyversort;
- a normál pályát, kaput és `UNLOCKS AT ISLAND 4` feliratot.

A játékos a kapu és egy sziklafal mellett állt. A háttér/átfedés miatt a zöld HP-csík
nem alkotott elfogadott komponenst. Piros cél nem volt, a minimap pedig ezen a helyen nem
adott használható játékos–piros pont vektort. Így csak a képméret 15% és az OCR-sor 20%
maradt, noha a közvetlen játékosrégióban időnként tiszta `340` szerepelt.

## Programdöntés

Az elfogadott `playerHealthSource == "ocr-current"` további 30 százalékpont
HUD-bizonyítékot ad. Ez helyspecifikus jel: nem egy tetszőleges képernyőszám, hanem a
játékos fölötti szűk OCR-régió temporálisan és a tanult 340-es maximumhoz igazolt értéke.

Az OCR-memória nem kap pluszpontot. Ha a szám ténylegesen eltűnik, és csík/minimap/cél
sincs, az ismeretlen képernyő számlálója továbbra is halad. Ez megőrzi a menü/reklám
elleni biztonsági korlátot.

## Regresszió

A `20260828-231659-replay` eredménye:

- 65: normál 100%-os HUD, spirál folytatódik;
- 70: friss OCR mellett 100%;
- 75: zöld csík és cél nélkül is 65%, mert a `340` friss `ocr-current`; nincs stop,
  a növekvő spirál folytatódik.

## Élő elfogadási feltételek

- ugyanebben a kapu/fal környezetben az időnként friss HP megszakítja a hamis HUD-stopot;
- valóban ismeretlen képernyő numerikus játékos-HP nélkül továbbra is leállít;
- a plusz bizalom nem használható OCR-memóriából vagy timer-szennyezett sorból.

## Első élő eredmény — `231840-play`

Az újraindítás 0. eseménye számszerű HP nélkül 35%-on helyesen várt. Már az 1. esemény
friss `340` OCR-je 65%-ra emelte a HUD-ot és engedte a spirálmozgást. A későbbi 38–39.
esemény a kapu/fal környezetében szintén 65%-os friss OCR-rel folytatódott; nem történt
hamis biztonsági stop. Ez élőben igazolja, hogy a pluszpont csak friss képi bizonyítéknál
aktiválódik és a normál játékmenetet helyreállítja.
