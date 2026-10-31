# A gyűjtő és a dashboard együttes kiesése

2026-10-31. A felhasználó újabb elmulasztott Health jutalmat és elérhetetlen
127.0.0.1:8765 oldalt jelzett. Ezután saját maga bezárta a játékot, és annak
újraindításáig diagnózist kért. A játékot nem indítjuk el helyette.

## Bizonyított állapot

A 20:36Z körüli folyamatellenőrzésben nincs ButcherHeroAutomation,
supervise-free-rewards.py vagy dashboard/server.py, és nincs listener a8765
porton. A korábbi39912 és86104 eszközmunkamenetre is „Unknown process id”
érkezik. Az állapotfájlok még running=true értéket tartalmaznak; ez nem
bizonyít élő folyamatot. A régi supervisor57653, worker57658 már nem él.

A Free-napló utolsó átvétele BFC40697: Health18600 (18.6K),
20:19:57.751Z click_sent, 20:20:00.003Z claim_confirmed_ui. A worker
utolsó lastCheckedAt értéke20:20:00.998Z. Ezek UTC időpontok, Budapest
szerint21:19:57 és21:20:00. Nem tudjuk pontosan, mikor szűntek meg a
folyamatok az utolsó bejegyzést követően.

Nincs hozzájuk új supervisor_stopped vagy worker_restart bejegyzés.
A helyi DiagnosticReports fájlnevei között nem találtunk friss Butcher/
Python összeomlási jelentést. Ez nem bizonyítja, hogy nem volt összeomlás,
SIGKILL vagy futtatókörnyezeti megszüntetés. Az egyidejűnek látszó kiesés
és az eltűnt execsession közös futtatókörnyezeti problémát valószínűsít,
de a pontos ok és az egyidejűség sem bizonyított. Új Health-felismerési
hibát ebből nem állítunk. A felhasználó kézi átvétele nem boteredmény.

## Helyreállítás és korlát

A read-only statisztikai szervert újraindítottuk a meglévő indítóval,
execsession17574. A /health HTTP-kérés sikeres, a port újra elérhető.
A gyűjtő újraindítása --resume-run kapcsolóval történt, execsession12456,
első worker65067. A játék metaadatpróbája running=false, ezért a worker
„Játékablak nem található; várakozás” állapotban van. Nincs új játékindítás,
statreset, modellváltoztatás, reconcile vagy kitalált átvételi adat.

Ez helyreállítás, NEM tartóssági javítás. A korábbi foregroundexecsession
módszer ismételten megszűnt; önmagában nem nevezhető igazoltan tartósnak.
Kérdést küldtünk két külön macOS Terminal-ablak használatáról: ezekben a
szokásos indítók futnának, új login/startup automatizáció nélkül. Válasz
nélkül nem állítunk be launchd szolgáltatást, automatikus gépindítást vagy
új engedélyeket. Más futtató esetén a képrögzítési/input jogosultságot és
az első valódi átvételt külön ellenőrizni kell, nem elég a PID vagy a HTTP.

Kód és felismerési elvárás nem változott. Következő lépés a futtatási mód
egyeztetése és új játékablak mellett friss kép/valódi átvétel ellenőrzése.

