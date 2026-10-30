# Végrehajtás-tudatos stratégiai állapot

Ez a dokumentum azt a szerződést rögzíti, hogy a bot belső stratégiai állapota csak
ténylegesen végrehajtható játéklépéssel haladhat. A képelemzés és a tudásfrissítés ettől
függetlenül folyamatos marad.

## Kötelező invariáns

- Ha a felhasználó az előző 1,5 másodpercben használta a gépet, a bot nem küld inputot.
- Ilyenkor az új képet továbbra is rögzíti, elemzi és naplózza.
- A stratégia `decide` állapotgépe viszont nem fut le: nem fogyhat célmemória,
  kerülőlépés, minimap-kerülő, harci kivárás vagy veszélyemlék egy végre nem hajtott
  döntés miatt.
- Amikor a gép újra szabad, a következő döntés az utolsó tényleges stratégiai állapotból
  folytatódik.

## A hibát bizonyító futás

A `docs/runs/20260828-203326-play` végén a szikla mögötti 10-es fa 282–284 px-re maradt.
A konzol sok háromlépéses kerülőt írt ki, de a „felhasználó aktív” őr ezek nagy részét
kihagyta. A stratégia mégis csökkentette a `detourFrames` számlálót, ezért papíron
végrehajtott kerülők után újra közvetlenül a sziklának indult.

## Javítás és ellenőrzés

A `play` ciklus most az elemzés után, de a stratégiai döntés előtt ellenőrzi az
inaktivitást. Aktív használatkor naplózott `VÁR` döntés készül, és az állapotgép nem
lép. A statikus `replay` az OCR- és célválasztási döntéseket ellenőrzi; ezt a konkrét
invariánst élőben, váltakozó felhasználói aktivitás mellett kell igazolni.

## Élő igazolás

A `docs/runs/20260828-204159-play` futásban két aktív felhasználói kép között egyetlen
tényleges swipe történt, és a cél rendre `167→139→118→92→66` px-re közeledett. A
közbenső képek minden alkalommal állapotmentes `VÁR` döntést naplóztak. Később a
10-szíves fa útvonala `238→211→192→185→165→130→102→81→68` px lett ugyanezzel a mintával,
majd automata támadás következett. A `frame-00095.png` közvetlen `+10` szívet és 268 HP-t
mutat, tehát ez max-HP-jutalom volt. Az input-végrehajtási invariáns élőben igazolt.
