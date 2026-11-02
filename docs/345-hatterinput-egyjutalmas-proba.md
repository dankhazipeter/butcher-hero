# Háttérkattintás — elkülönített egyjutalmas próba, 2026-11-02

## Kutatás és felhatalmazás

A user először lehetőségfeltárást, majd kifejezetten az elkülönített próbát
engedélyezte: „Próbálkozz, persze!”. Cél: Free átvétele másik alkalmazásban
végzett munka közben, fókuszváltás és valódi kurzormozgatás nélkül. Nem
ébren tartás, nem kristály-/bolt-/harcinput vagy a játék módosítása.

A jelenlegi normál Capture.click/crystalClick/eventEndClick aktivál, warpol,
globális HID-tapra postol, majd megpróbál visszaállítani. WindowInputGeometry
szándékosan foregroundot és valódi kurzorcélt követel. Ezeket nem lazítjuk
és nem cseréljük automatikusan a kísérlet kedvéért.

Apple-források és helyi SDK ugyanazt támasztják alá:

- [CGEvent.postToPid](https://developer.apple.com/documentation/coregraphics/cgevent/posttopid(_:))
  folyamatcélzott eseményküldésre szolgál (CGEvent.h komment, macOS10.11+).
- [Private event state](https://developer.apple.com/documentation/coregraphics/cgeventsourcestateid)
  elkülönített forrásállapotot kínál; ez nyilvános API, nem privát framework.
- [Cocoa event architecture](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/EventArchitecture/EventArchitecture.html)
  szerint a háttérben fogadott input és az első kattintás kezelése függ az
  alkalmazás feldolgozásától. Az API létezése NEM bizonyítja a játék támogatását.
- [AXUIElementPerformAction](https://developer.apple.com/documentation/applicationservices/1462091-axuielementperformaction)
  másik lehetőség, de CUA read-only AX-olvasásban a futó játék csak ablakot,
  üres containert, ablakgombokat és menüsort exponált; nincs külön Free/
  kristálygomb. Nem állítunk általános AX-lehetetlenséget más verzióra.

## Kísérleti megvalósítás

`ButcherHeroAutomation probe-background-free` külön kézzel indítható parancs.
Sem a watcher, sem a supervisor, sem az indító nem hívja meg automatikusan.
A normál inputkód változatlan. A próba nem aktivál alkalmazást, nem warpol,
nem küld globális tapra, és nem generál mouseMoved vagy billentyűeseményt.
Egy privateState forrásból legfeljebb egy leftDown/leftUp küldhető a bizonyított
játékPID-re, publikus windowhint mezőkkel. Az API void: a postolás nem ACK.

Védelmek:

- A normál watcherrel közös `docs/runs/.live-capture.lock` kizárólagos flock.
  Aktív collector mellett a valódi újCLI is elutasított, input nélkül.
- Meglévő Accessibility-jog kell, nincs új engedélykérés vagy TCC-állítás.
- Két friss, azonos fingerprintű, ismerttípusú/összegű Free-HUD; konkrét
  kristály/eventmodalok kizárása. Ugyanaz a PID/WindowID, friss Quartzkeret,
  aktívkijelző és változatlan képarány, a bizonyítékmentés után új ellenőrzés.
- A játék nem lehet az előtérben. A külső foregroundPID és a fizikai kurzor
  alapállapotát mintázzuk, majd20ms célközzel figyeljük. Egérgomb/kurzoreltérés,
  fókuszváltás vagy cancellation küldés előtt letilt. Nincs gépelt szöveg,
  billentyűleütés vagy idegenablaktartalom naplózása. A mintaköz a mainactor
  szinkron munkája alatt hosszabb lehet: nem folytonos matematikai bizonyíték.
- Küldés legkésőbb az8s keret5.másodpercéig engedett. A matchingup70ms után
  cancellation esetén is ugyanannak aPID-nek megy. Utána maximum6utókép;
  nincs retry vagy régi globális kattintásra visszaesés.
- Csak2egymást követő, azonos játék-HUDon hiányzó kártya és zavartalan mérés
  adhat claim_confirmed_ui-t. Egyébként nem igazolt; numerikus statnövekedést
  önmagában ez sem mér. A normál napló szabványos eseményei mellé a
  `data/background-input-probes/<claimID>.json` adja a fókusz/kurzormintákat.

Fejlesztési build: `swift build --scratch-path .build/background-probe -c release
--product ButcherHeroAutomation` (egyetlen parancs). Aktív `.build/release`
NEM cserélt. A próba csak explicit operátori felhatalmazással, a gyűjtő rövid
leállítása és biztos visszaindítása mellett futtatható; nem általános unattended
opció. Rendes újraindítás `butcher-hero start`, alapértelmezett resume-run.

## Eddigi élő eredmény: nincs még tényleges háttérinput

Két átadás a következő Free várható megjelenése körül,09:57 és10:03Z.
Mindkettő küldés ELŐTT állt meg. Második pontos diagnózis:
baselinePID72012==gamePID72012, mouseReady=true, buttonDown=false.
Tehát maga a játék volt előtérben; ilyenkor nem lehet bizonyítani a háttérmódot.
NINCS elküldött kísérleti postToPid, nincs könyvelt próba-claim, és nincs
bizonyíték sem e módszer működésére, sem a technológia alkalmatlanságára.

A helyi, nem commitolt `.build/345-run-once.py` átadás után finally/exec-pel
rögtön visszaindította a normál közös launchert. Első normál utóclaim
09:57:47Pierce565, második10:03:10CutDefense625. Legutóbbi indulóworker
94243, session83792; friss runtimeJSON a mérvadó. Nincs statreset.

A usernek aszinkron jeleztük: másik alkalmazást kell előtérbe tenni, az egeret
kb10másodpercig nyugton hagyni; gépelés tartalmát nem figyeljük. Érdemi
háttérpróba csak ilyen körülmények között folytatható. Meglévő külsőmonitoros
geodehiba nem tárgya a kísérletnek, nincs rá javítás vagy hibamentességi állítás.

## Offline kapu

4újSwiftunit: foreground/idegenPID kizárás; kézi egér/cancellation; stale/
future/NaN frame; explicitCLI+lock+privateState+PID és tiltott aktiválás/warp/
globális tap/fallback forrásregresszió. Teljes233teszt+7JS-kapu; stagingrelease
lefordult. A kapu önmagában soha nem futtat élő probe-ot vagy játékinputot.
