# Stabil jutalomlista-oszlopok — 2026-11-01

## Kérés és ok

A Mikor, mit, mennyit lista oszlopszélessége ne változzon, ha az állapot
Átvéve helyett éppen Nem igazolt. Korábban az automatikus táblázat-layout
a cellák tartalmából számolt, így a hosszabb státusz a többi oszlopra is hatott.

## Javítás

Explicit négyoszlopos colgroup és csak a ledgerre célzott table-layout:fixed.
Idő/jutalom/összeg/állapot:25/35/20/20 százalék, kizárólag a rendelkezésre
álló táblázatszélességtől függően. Így továbbra reszponzív, de az adatsorok
és feliratok nem rendezik újra az oszlopokat. A600pxminimum a négy oszlop
olvashatóságát védi; keskeny nézetben a meglévő görgethető wrapper működik.
Nem rejtjük el/csonkoljuk az állapotot, nincs új állapotszöveg vagy adatlogika.

## Ellenőrzés

- Új Node-regresszió rögzíti az oszlopsorrendet, fix layoutot, arányokat és
  a keskeny nézet görgethetőségét; teljes kapu229teszt+7JSellenőrzés.
- Izolált loopback böngészőpróba a tényleges index táblájával és valódi CSS-sel,
  szintetikus egyetlen sorral. Átvéve/Nem igazolt/Unconfirmed/Claimed között
  mind a négy oszlop X-koordinátája és szélessége azonos750px-en:
  187.5/262.5/150/150px.360pxwrapper mellett a600pxtábla oszlopai
  mind a négy állapotban150/210/120/120px. Nincs éles naplóírás vagy
  bizonytalanclaim mesterséges előállítása. Ideiglenes tesztszerver/lap zárva.
- A gyűjtő frissképes marad; csak statikus HTML/CSS és offline teszt változik.
  Nincs leállítás, backend/releasebetöltés, statreset vagy naplómódosítás.

A meglévő felhasználói dashboardlap egyszeri frissítés után veszi át a CSS-t.
