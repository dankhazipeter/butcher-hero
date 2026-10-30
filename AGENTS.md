# Butcher Hero — aktív projektutasítások

## Kötelező commit minden lezárt változtatási kör után — 2026-10-30

A felhasználó kérése: minden érdemi kód-, teszt-, konfiguráció- vagy
dokumentációváltoztatási kör végén készüljön egy áttekinthető Git-commit.
Előtte releváns ellenőrzés, dokumentációfrissítés, diff- és staged-ellenőrzés.
Csak a körhöz tartozó módosításokat stage-eljük; más felhasználói munkát nem
foglalunk bele és nem írunk felül. Az induló commit kivételként a meglévő
projekt egyértelműen jelölt alapállapotát is rögzíti; nem találunk ki múltbeli
commitokat. Pusztán olvasási/megfigyelési körhöz nem kell üres commit.

Nyers felvételek, futó naplók, build és titkok nem kerülhetnek commitba;
a szükséges kis tesztreferenciák igen. Ha a commit akadályba ütközik, ezt
jelezzük, nem állítjuk sikeresnek. Git-szerzői identitást nem találunk ki.
Távoli repó bekötése/push külön felhasználói kérésre; most nincs remote/push.
A játék STOP-ját ez az adminisztratív kérés nem oldja fel. Részletek289.

## ELSŐBBSÉG — FELHASZNÁLÓI STOP, 2026-10-30 12:50:59 Bucharest

A felhasználó: „álljunk le! most kikapcsolom a gépet”. A jutalomfigyelő
83220PID-je szabályosan leállt;10:50:59.818Zwatcher_stopped, running=false,
folyamatellenőrzés szerint nincs futófigyelő vagy játékbot. HeartbeatPAUSED
ellenőrizve. Nincs automatikus képernyőfigyelés/input, újraindítás csak új,
kifejezett felhasználói folytatásra. Napló, képek és kód megmaradtak. Részletek288.
Az alábbi futási állapotok történetiek; a287-es élő teszt eredménye megmarad.

## ELSŐBBSÉG — CSAK FREE-JUTALOM AUTOMATIZÁCIÓ, 2026-10-30

Legújabb287:az újraindított játék ablakát a83220figyelő automatikusan
visszatalálta. Élőképi+napló+felhasználói igazolás: kézi húzásnál várakozás,
elengedés után540PierceDamageés593CutDefenseátvétel, mindkettő egyszer
könyvelve.10:31:05.883Z/40.569Zinput_deferred→08.334Z/46.026Zclick_sent
→10.603Z/48.291Zclaim_confirmed_ui; utóképeken explicit+540/+593.
A286-os ablakhiány történeti. Figyelő fut,1s, nincs régi bot/heartbeat.
Hatástalan elküldött input utáni1sújrapróba még csak teszttel igazolt.

Legújabb286:FELHASZNÁLÓI JAVÍTÁSKÉRÉSRE kézi húzásvédelem és1sFree-újrapróba
elkészült. Lenyomott egérgomb vagy friss húzás alatt nincs automatikus
kattintás; elengedés után friss ellenőrzés. Megmaradt, olvashatóFreekártya
1s után újrapróbálható, nincs állandó foglalás. Siker csak két játékHUD-képen
eltűnt kártyából. Újrapróbák ugyanazonclaimID, egyszeri összeg; időszakot
az utolsó click_sent dönti el, click_attempts külön számláló.
Ez felülírja284elküldött inputot végleg tiltó szabályát. Releasebuild/11tesztPASS.
Új figyelőPID83220/session97973; aktuális állapot mindig state.json.
286végpont:10:24:33.239Zablaknemtalálható; figyelő él és vár, nincs még
új éles átvételi igazolás. Külön kérés nélkül nem indítunk játékot.

Legújabb285:578CutDefense felismerése jó;09:19:55.936Zclick_sent után
09:20:04.676Zclaim_unconfirmed, a kártya megmaradt. Előképen aktív kézi
joystick; inputütközés valószínű, nem bizonyított. Nem számolt sikeres átvétel.
Elküldött kattintás duplavédelme tiltotta az azonnali újrapróbát. Csak
diagnózis történt, nincs javítás/újraindítás. Kézi húzásvédelme még nincs.

Legújabb284:felhasználói képenFREE18Kkimaradt, majd kézzel vette fel.
Időzítővel összeragadt OCRés kattintás előtti elutasítás utáni beragadt
foglalás javítva. Szűk számmező és token-geometria; csak el nem küldött
kattintás foglalása oldható fel. A kézi átvételt nem írjuk bot-eredménynek.
Új6tesztes regresszió és a felhasználói kép18000HP-felismerésePASS.
Új figyelőfolyamat a build után indult; frissPID a data/free-rewards/state.jsonban.
Korábbi60266PID/52505sessionmár történeti, ne használjuk újra azonosításra.

284élőPASS:66033PID/79555session,09:00:51.489Zúj18000HP-kattintás,
09:00:53.168Z-visszaigazolás, utána550cutdamage is átvéve. A javítás működik,
figyelő fut; friss állapot:data/free-rewards/state.json.

A felhasználó újra folytatást kért, megadta a nyolc jutalom ikonos
statképeit, és engedélyezte a bal oldali event alattiFreejutalom észlelését,
átvételét és naplózását. Ez felülírja a tegnapi teljesSTOP-ot ezen a szűk körön.
Mozgás, harc, bolt és egyéb automatizáció nincs. A régi heartbeatPAUSED marad.

Program:ButcherHeroAutomation watch-free --interval1. Helyi napló:
data/free-rewards/events.jsonl, bizonyítékképek:evidence/, állapot:state.json.
Indítás/leállítás:scripts/start-free-rewards.sh / scripts/stop-free-rewards.sh.
Jutalomtípusok:hp,regeneration,piercing_damage,cutting_damage,smash_damage,
piercing_defense,cutting_defense,smash_defense. Nyolc névvel jelölt, friss
statikon alapján alak+színillesztés; a pajzs elkülöníti a védelmet. A régi
színheurisztika törölve. Bizonytalan ikonunknown,kép megőrzendő.
Napló:reward_detected→click_intent→click_sent→claim_confirmed_ui vagy
claim_unconfirmed. A kattintási idő UTC ISO8601; a kliens időzónájaBucharest.
Statisztikában a látott jutalomértékeket összegezzük, nem állítunk ezekből
szorzókkal módosított teljesHP-növekedést. Részletek282.

Utolsó ellenőrzés2026-10-30T08:39:42Z:60266PIDfut,1sfigyelés,
24igazolt átvétel,0hibás/besorolatlan/függő tétel. A frissebb futási státusz
mindig data/free-rewards/state.json. Aktívexecsession52505; nem indítunk
párhuzamos figyelőt. Jelenlegi bináris mind a8típust kezeli, nem a281félkész kód.

## ELSŐBBSÉG — FELHASZNÁLÓI STOP, 2026-10-29

A felhasználó a gép terhelése miatt teljes leállítást és a játék bezárását
kérte. A játék Command-Q-val bezárva; nincs játék-, bot- vagy jutalomfigyelő
folyamat. Heartbeat PAUSED. Új kifejezett kérésig nincs fejlesztési futás,
megfigyelés, játékindítás vagy automatizáció. Részletek:281.

Az első Free-jutalom-automatizáció kódja félkész. Csak dry-run futott,
jutalomra nem kattintott. A színalapú ikonbesorolás hibás: az591-es fejszés
jutalom védelem volt. Újrakezdéskor a nyolc típust (3sebzés,3védelem,HP,
regen) a kézzel feltárt statpanel szerint kell felismerni, majd élőben tesztelni.
A részletes statlista alsó sorainak kézi feltárása még nem sikerült teljesen.
Ne indítsuk a jelenlegiwatch-freekódot éles kattintással ellenőrzés nélkül.

## Új kezdet — 2026-10-29

A játék frissült. A felhasználó kérésére a taktikát nulláról építjük újra,
az általa megadott lépések szerint. Ez felülírja a korábbi folyamatos játék
és automatikus felügyelet utasításait.

**Aktuális mód: a felhasználó első lépésére várunk.**

- Nincs automatikus mozgás, kattintás, farmolás vagy játékindítás.
- Nincs folyamatos megfigyelés vagy automatikus képernyőmentés.
- Képet a felhasználó jelzésére nézünk; a „Látod?” egyetlen ellenőrzést enged.
- A korábbi heartbeat PAUSED; külön kérés nélkül nem kapcsoljuk vissza.
- A „folytasd” az előkészítés folytatása, önmagában nem mozgási engedély.

## Tiszta kiindulás

A régi állapotok, térképek, útvonalak, célok és időzítők visszaállítható
archívuma: `docs/archive/2026-10-29-before-restart/`. Mind a21korábbi felső
szintű JSON eredeti tartalommal megmaradt; SHA256-egyezés ellenőrizve.
Forráskód, tesztek, nyers képek és történeti jegyzetek megmaradtak.

A régi kód az előző verzió kísérleti eszköztára. Beégetett céljai, koordinátái,
harci küszöbei és UI-felismerése friss ellenőrzést igényelnek. Régi állapotot
ne állítsunk vissza automatikusan. A kód alapértékei nem valódi játékadatok.

Jelenlegi munkamenet: `docs/session-state.json`.
Újrakezdési jegyzet: `docs/280-frissitett-jatek-tiszta-kezdet.md`.

## Küldetés és munkamód

Helyben futó, képi visszacsatolásra épülő játékost fejlesztünk. A felhasználó
most az első lépéseket adja meg. Új mechanikát és taktikát az új verzió
bizonyítékaiból tanulunk; a régi napló ötletforrás, nem aktív előírás.

Egyetlen friss kép készült a „Látod?” kérésre:
`docs/runs/20261029-223657-10037739-observe/frame-00000.png`.
Vizuális feliratok: BOSS TOWER, 0/9, saját élet mellett473M.
A régi elemző7660-at és Island2-mozgást javasolt: ez elavult kimenet,
nem új stat és nem végrehajtott input. Új ellenőrzött harci stat vagy útvonal nincs.

## Működési korlátok

- Vásárlásra, gem-/pénzköltésre és reklámindításra nincs engedély.
- Kifejezett stop azonnal leállít minden inputot és automatikus felügyeletet.
- Régi PNG nem aktuális képernyő; kihagyott inputból nem tanulunk akadályt.
- Emberi közlés, vizuális tény, következtetés és hipotézis külön jelölendő.

## Kötelező dokumentáció

A `docs/` magyar, élő tudásbázis. Minden érdemi megfigyelés, döntés, cáfolat,
mechanika és javítás ugyanabban a ciklusban MD-be kerül, bizonyítékkal.
Új témához új sorszámozott fájl és indexbejegyzés kell. Kódváltozáskor az
architektúra és taktika is frissítendő. Történeti tudást archiválunk.

Indulási olvasmányok: ez a fájl, `docs/README.md`, `docs/session-state.json`,
`docs/280-frissitett-jatek-tiszta-kezdet.md`, majd az érintett aktuális témadoksi.
Lezáráskor az index, az aktuális állapot és a nyitott kérdések egyezését ellenőrizzük.
