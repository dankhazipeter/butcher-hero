# Kiemelt +10 szívfa élő sikere: 676 HP

## Élő bizonyítás — `20260829-033954-play`

A kiemelt szívfa-prioritás első élő próbája pontosan a tervezett sorrendet adta:

1. az 1.22K boss miatt aktív hatswipe-os menekülési memória a 25. döntésig
   elsőbbséges maradt;
2. a 10-szíves, 174 HP-s fa ezután 203→140→93 pixelre közeledett;
3. a cél eltűnt, a következő friss képen közvetlen zöld `+10` piros szív jelent meg;
4. a teljes HP `666→676` lett.

A türkiz quest-út és a bossirány-hűtés nem térítette el újra a botot, miután a veszély
memóriája szabályosan lejárt. A játékos a teljes szakaszban 100% közelében maradt.

## Akadályállapot regressziója ugyanebben a futásban

A következő, 16-os statikonú 291 HP-s cél 270 pixel körül statikus maradt. A bot a
53. eseménynél nyolclépéses tartós kerülőt indított, azt a következő döntéseken nem
nullázta le, majd a második sikertelen megközelítés után hosszú területelhagyásra
váltott. Ez élőben igazolja a `65`-ös finomítást: a kiemelt cél nem törli a saját
stagnálásból indított akadálykerülőt.

## Eredmény

- a 300 pixeles kiemelt szívfa-prioritás megtartandó;
- boss mindig előtte fut;
- cél-specifikus tartós kerülő és hosszú kiszakadás megmarad;
- a hiteles aktuális maximum 676.
