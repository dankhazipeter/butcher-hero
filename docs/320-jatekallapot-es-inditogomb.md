# Játékállapot és explicit indítógomb — 2026-10-31

## Kérés és működés

A felhasználó a „no recent screen check” helyett egyértelmű jelzést kért,
ha a játék nem fut, és lehetőség szerint indítógombot. A játék és a gyűjtő
külön panelt kapott, magyarul és angolul is.

- Telepített, nem futó játék: piros „A játék nem fut” és Játék indítása.
- Nem található telepítés: külön hiba, nincs indítógomb/telepítés.
- Fut, de rejtett vagy nincs megfelelő képernyőn lévő ablaka: sárga jelzés.
- Futó játék: külön zöld státusz, ami NEM bizonyítja a gyűjtés működését.
- Hibás, hiányzó vagy elavult próba/kapcsolat: nem ellenőrizhető, nem
  állítjuk leálltnak és nem engedünk indítást a régi adatból.

A gomb csak explicit kattintásra indítja a konkrét játékot. Poll, frissítés,
nyelvváltás nem indít. Nem indul gyűjtő, nem lesz új watcher_started,
nem nullázódnak a számok. A STOP utasítás továbbra sem oldódik fel ettől.
Már futó játékra a szerver nem küld új open parancsot és nem fókuszálja.

## Megoldás és biztonsági határ

`ButcherHeroAutomation game-status`: NSWorkspace exact bundleazonosság,
telepítési út létezése, futó alkalmazás, isHidden és CGWindow ablakmetaadat.
Nem kér képernyőképet, nem küld inputot. A látható ablak itt képernyőn
lévő, legalább350×550-es normálrétegű játékablakot jelent; nem bizonyítja,
hogy más ablak nem takarja vagy hogy ScreenCaptureKit működik.

Python GameControl: fix helper,3s timeout,5s cache, érvénytelen válasz
UNKNOWN. A UI15s-nál régebbi gamepróbát és20s-nál régebbi APIválaszt
elavultnak tekint. Friss ismert játékhiány mellett a futó gyűjtő külön
„játékra vár” jelzést kap, a valóban leállt gyűjtő leállt marad.

A statisztika továbbra csak olvassa a naplót. Korábbi teljes read-only
dashboardkijelentéseket szűken felülírja az egyetlen indítóvégpont:

- POST `/api/game/launch`, kizárólag loopback, pontos Host/azonos Origin;
- szerverenként véletlen token kötelező egyedi fejlécben;
- más webhely/same-site kérés sem engedett; frame-ancestors none/DENY;
- csak legfeljebb128byte üresJSONobjektum, semmilyen app/path/args;
- fix `/usr/bin/open -b com.multicastgames.butcher`, shell nélkül;
- friss ellenőrzés indítás előtt,10s újraküldési korlát, soros indítás;
- a sikeres open csak elküldött kérés, nem igazolt futás. A UI legfeljebb
  15s-ig vár megerősítésre, hibánál nem mutat hamis zöld állapotot.

Frissítéskor a natívprogram új buildje és dashboardújraindítás szükséges;
régi segédprogrammal UNKNOWN az állapot. Az oldalt egyszer újra kell tölteni.

## Ellenőrzés és bizonyíték

7új Pythonunit/HTTPteszt fixparancsra,cache-re,hibákra,Origin/Host/token/
bodyvédelemre. 6új Node UI/státuszteszt: hiányzó/rejtett/ismeretlen játék,
explicit kattintás, dupla kattintás, sikertelen indítás és fordítások.
Teljes kapu132teszt (53Swift+19stat+7game+3git+10supervisor+40Node),
7JSsyntaxellenőrzéssel. Ugyanez kötelező commit/push/PR előtt.

ÉlesAPI18:54:51Z: game known/installed/running/windowVisible=true,
hidden=false, logikai futáskezdet változatlan2026-10-30T16:50:44.381Z.
Izolált, saját ideiglenes profilú Chrome:1280×1000 és375×812, nincs
vízszintes túlcsordulás. Képek `.build/game-status-{desktop,mobile}.png`.
Valódi játékot nem állítottunk le/indítottunk a teszt kedvéért, ezért az
éles indítást nem állítjuk igazoltnak; a szerződést mockkal teszteltük.

## Külön runtimehiba és következő lépés

A18:45utáni workerújraindítások oka streamindítási audió-/videórögzítési
hiba. A játék közben natívpróba szerint fut és ablaka látható. A320build
rövid betöltése után is ugyanez, nincs sikeres gyűjtőkép. Nem oldottuk meg
és nem könyvelünk jutalmat helyette. A felügyelő aktív, de ez nem sikeres
gyűjtés. Friss runtimePID-k a supervisor.json/state.json fájlokban; a
logikai munkamenetet --resume-run megőrizte. A képrögzítés külön diagnózist
igényel; a játékot nem nyitjuk újra automatikusan.
