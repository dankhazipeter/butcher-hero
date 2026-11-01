# Kiválasztott időszak: mettől meddig, milyen hosszan?

2026-11-01. A felhasználó szeretné jól láthatóan tudni, melyik időszakot
tartalmazza a statisztika, különösen Mostani futás és Minden esetén.

## Megjelenítés

Az eddigi apró dátumsor helyett a szűrők alatt önálló összefoglaló panel:
kiválasztott időszak neve; Kezdet és Vége teljes év/hó/nap/óra/perc/másodperc
felbontással; az intervallum hossza nap/óra/perc/mp bontásban. Az időzóna és
a diagrambontás is itt marad. Keskeny képernyőn a három mező egymás alá áll.
Nem folyamatos aria-live bejelentés: a másodpercenként változó dátum ne
olvassa fel újra és újra a teljes szöveget.

Az API tényleges `range.mode/from/to` értékeit mutatjuk. Nem az inaktív
egyéni dátummezőkből vagy a worker aktuális processzkezdéséből származtatjuk
a munkamenetet. A backend és annak stat-session-kezdőpontja változatlan.
Az `<time datetime>` a teljes eredeti ISO-határt őrzi; a felirat a böngésző
IANA-időzónájában jelenik meg, nyelvválasztástól függetlenül. Új poll a
szerver új végidejét mutatja, nem egy külön helyi óra által továbbmozgatott
intervallumot. Ez kapcsolatvesztésnél is a ténylegesen megjelenített utolsó
adatok határa marad.

Run: a szünetek és folytatásos újraindítások is a statisztikai időablak
részei, ez nem aktív játékidő. All: a megőrzött napló teljes időszaka minden
munkamenettel. Egyéni és gördülő nézetek is saját pontos határukat mutatják.
A hossz az UTC-pillanatok különbsége, nem a helyi faliórák kivonása;
DST-visszaállásnál is helyes. Üres új munkamenet0mp, hibás negatív intervallum
nem lesz kitalált0. HU/EN külön nyelvi fájlban, új futtatási függőség nélkül.

## Ellenőrzés

3új Node integrációs teszt a tényleges app.js-szel:

- Run/All/custom alkalmazott határok, évváltás, napos hossz és eltérő
  dátummező-piszkozat nem írja át a látható statisztikai időszakot;
- új poll frissíti a végét/hosszát, HU→EN váltás nem fetch/reset;
- Budapest DST-visszaállás két02:30helyi időpontja közt1óra, új
  munkamenet0mp, negatív intervallum nem nulla.

Teljes kapu216teszt+7JS-szintaxis sikeres. Nincs backend- vagy gyűjtőváltozás,
nincs releasebuild, fejlesztéshez kért stop, új munkamenet vagy történeti
jutalomnapló-átírás.

Élő, rejtett IAB-lapon13:27–13:28Budapest: Mostani futás kezdete
2026-11-01 10:45:57, Minden kezdete2026-10-29 21:56:28. Az új név, teljes
határok, mozgó végidő, hossz és magyarázat látszik. A saját Minden-kattintás
csak ezt a tesztlapot szűrte, nem reset és nem gyűjtőinput. Helyi PNG-proof:
`.build/ui-proof/337-run.png`, `337-all.png`, nem publikus Gitadat. Tesztlap
bezárva. A user már nyitott dashboardján egyszeri reload kell az új JS/HTML-hez.

Külön runtime-pillanatkép12:29Z: a natív game-status szerint a játék nem fut.
12:28:36Z-től a watcher játékablakot nem talál; a meglévő supervisor friss
kép hiányában12:29:11Z új worker24266-ot indított, watcher_resumed-del,
nem statresettel. Ez nem UI-betöltés miatti saját stop/restart. A supervisor
fut és vár; a játékot ebből az UI-kérésből nem indítjuk el automatikusan.
