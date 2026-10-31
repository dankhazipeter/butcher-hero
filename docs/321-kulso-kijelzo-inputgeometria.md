# Külső kijelző: ellenőrzött kattintás és koordinátanapló

2026-10-31. A felhasználó szerint külső monitorra tett játéknál látszik
automatikus input, de nem a helyes helyre megy. Ez felhasználói megfigyelés;
nem volt még róla rögzített tényleges kurzorpont, ezért nem állítunk
bizonyított konkrét skálázási vagyY-flip gyökérokot.

## Biztos mérések

Read-only metadata a gépen: laptop1512×982 logikai pont,2xRetina;
külső kijelzők2560×1440,1x, Quartzeredet−5120/−553 és−2560/−553.
AppKit ugyanezekre−5120/95 és−2560/95 értékeket adott: a két koordinátateret
nem keverjük. A friss játékablak a laptopon volt874/33/637/882 ponttal,
SCWindow és CGWindowList ugyanazt adta. Nem indokolt feltétel nélküliY-flip.

Mindhárom kijelzőt alvónak jelezte a system_profiler; CGGetActiveDisplayList
0, CGGetOnlineDisplayList3. ScreenRecording ésAccessibility preflighttrue.
Ez magyarázó körülmény a jelenlegi képrögzítési hibához, nem bizonyíték arra,
hogy minden korábbi streamhiba ugyanez volt. A gépet nem ébresztettük.

User referencia: `references/2026-10-31/external-pierce567-user.png`,
788×1083. LáthatóFREE és nyíl567. A jelenlegi olvasó típust és célpontot
helyesen ad: a cél a kézzel ellenőrzött8/627/87/108-as kártyán belül van.
Az összegnil: ez külön nyitott számolvasási hiba, nem találunk ki567-es
naplóeredményt. A beküldött PNG nem az aktuális képernyő.

## Változás

A régi kód a normalizált célpontot közvetlenül SCWindow.frame-re vetítette,
majd ellenőrizetlen kurzorwarpot végzett. Nem naplózta, hova érkezett.
Az új útvonal közös mindenFree/kristály/eventkattintásnál:

1. Aktiválás utáni friss kép és a meglévő tartalmiellenőrzések.
2. UgyanazonCGWindowID+PID aktuális, képernyőn lévőQuartzbounds.
3. Friss képpel egyezőkeret (1pont), képarány(1%), aktívkijelzőn lévőpont,
   valóban előtérben lévő játék. Hiba esetén nincs input.
4. Logikai pontban számolunk: origin+normalizáltpont×ablakméret.
   A1x/2xkép ugyanazt a globálispontot adja, a negatívértékek megmaradnak.
5. Warp siker ellenőrzése, mouseMoved esemény,25ms után ténylegesCGkurzor
   legfeljebb2pont eltéréssel; újra ablak/kijelző/STOP/egérvédelem.
6. input_geometry napló cél/kurzor/keret/képméret/aktívkijelző tartalommal;
   csak ezután mouse-down. Mouse-up továbbra is mindig kimegy.

A mouseMoved indoka, hogy a warp önmagában nem küld eseményt; ennek
konkrétCatalyst/külsőkijelzős javítóhatása még csak hipotézis, nem igazolt
éleseredmény. Appleforrás: [kurzormozgatás](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/QuartzDisplayServicesConceptual/Articles/MouseCursor.html),
[CGEvent location](https://developer.apple.com/documentation/coregraphics/cgevent/location).

Az input_geometry az adottFree/kristály/event napló diagnosztikai sora.
Nem jutalom és nem elküldött kattintás. A tényleges átvételt változatlanul
csak a meglévő utóképes állapotgép könyveli. Elutasítás után új frissképes
próba jöhet, hibás/régi koordinátából nincs fallback. Nincs mozgás vagy új
játékengedély. Aktívkijelző hiányában a képrögzítés eleve vár, nem indít streamet.

## Teszt és fennmaradó igazolás

6új RewardInputGeometryTests: laptop1x/2x, mindkét tényleges negatív
monitoreredet, fölötte/alatta/jobbra monitor, átlógó ablak, mozgás/resize,
rossz képarány, alvó/hiányzó kijelző, érvénytelen pont és warpeltérés,
valamint a felhasználói kép célpontja. Tisztageometria, nem valós egérinput.
A kötelező check-rewards.sh szűrője kifejezetten tartalmazza ezt az osztályt.
Teljes138teszt (59Swift+19stat+7game+3git+10supervisor+40Node),7JSsyntaxPASS.

Új stagingrelease betöltve --resume-run-nal; nem lett új statmunkamenet.
A supervisor újra aktív, alvókijelzőn nincs sikeres képolvasás és jutalom.
**Még szükséges:** ébren tartott gépen a játékot visszatenni a hibás külső
kijelzőre, friss input_geometry és utóképes valódi átvétel alapján ellenőrizni.
Amíg ez nincs, a történeti hiba teljes megoldását nem állítjuk bizonyítottnak.
