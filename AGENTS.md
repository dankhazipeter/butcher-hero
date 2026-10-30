# Butcher Hero — aktív projektutasítások

302:a push előtti tesztkör különOCRellenőrzése is hibával állt meg; a live-
hibával való azonosság nem igazolt. A kapu BLOKKOLTA a feltöltést, nem került
megkerülésre. Most támogatott
VisioncomputeStageenkéntCPU-eszközt választunk a hivatalos macOS14+APIval.
Ez az accelerator-munkamenetek hibáját kerülő HIPOTÉZIS, nem bizonyított
véglegesgyökérok.20Swift/13statisztika/3kapu/9felügyelet/5NodehelybenPASS.
Előre fordítottCPUrelease betöltve;54705felügyelő/54789worker,session90309.
19:10:19HP18300igazolás,19:10:34frissképidő, hosszú távú stabilitás nem állított.
A remoteCIeredmény még külön igazolandó. Futó gyűjtőt ne állítsuk le a tesztekhez.

## Élő gyűjtés elsőbbsége és tartós felügyelete — 2026-10-30 (300–301)

A felhasználó nem kértSTOPot: a teszt/CIfejlesztés alatt aFreegyűjtést
folytatni kell. Tesztet külön másolaton végzünk, csak éles betöltéskor rövid
leállás; az utólagos élő igazolás kötelező. PusztaPID/running=true nem
bizonyít működést: friss lastCheckedAt és valódi átvétel kell.
Ne hagyjunk percekig régi képidővel futó folyamatot felügyelet nélkül.

Indító: scripts/start-free-rewards.sh [--resume-run], ELŐTÉRBEN tartott
tartós execsessionben, nem rövid parancsból leválasztott nohupgyerekként.
Pythonfelügyelő:30sfriss sikeres feldolgozás nélkül újraindítja kizárólag
a sajátFreeworkerét; induláskor45sgrace,5sSIGINTután szükség eseténkill.
Technikai újraindulás --resume-run, nem nullázza a statisztikát. STOPkor
stop-free-rewards.sh a felügyelőt is leállítja, nincs automatikus visszaindulás.
Utolsó igazolt felügyelet48519/session68833, jelenlegworker50644.
18:54:53élőVisionelakadást önállóan felismert,18:54:59újworker,
18:56:06újPierce540igazolás és18:56:28frissképidő. Nem kéziSTOPvolt.
19Swift+13statisztika+3Gitkapu+9felügyelet+5NodehelybenPASS.

301:a másodikCI már lefordult, de régebbiVision két esetben eltért:
593CutDefenseunknown és takart18Kösszegnil. Rögzített címkék változatlanok;
szűk±1/±2pixeles ikonillesztés, változatlan küszöbök, valamint számsor-only
fehér/feketeOCRtartalék. Külön regresszió mindkét ágra, nincs kitalált jutalom.

299:elsőGitHubCI valóban futott, de a Swift6.1.2fordító a régi bottargeten
még a tesztek előtt hibázott. Nem OCRhiba és nem pusztán runnerkapacitás.
Az@mainforrás BotMain.swiftnévre váltott, swipe-sugár explicitDouble/CGFloat,
ExpandedMapDetectorösszetett kifejezése azonos számítású ciklusra bontva.
A régi bot továbbraPAUSED, nincs új játékinput vagy stratégiamódosítás.
Bizonyíték és a helyi/távoli eredmények külön követése:docs/299.

## Klónozók és PR-ok kötelező ellenőrzése — 2026-10-30 (298)

Új klón után `make setup`; minden érdemi körben `make test` kötelező.
Ez egyben a helyi commit/push kaput is bekapcsolja. `make test-vision`
csak gyors részellenőrzés, nem helyettesíti a teljes csomagot.
A CONTRIBUTING.md és a PR-sablon ugyanezt kéri minden közreműködőtől.
A `.github/workflows/reward-tests.yml` minden pushra és PR-ra ugyanazt a
teljes tesztet futtatja macOSon, helyi hook nélküli beküldőknél is.
Stabil checknév: `Reward tests (macOS)`. A workflow sikerét ne állítsuk
csak a helyi PASS alapján; a GitHub-futás külön ellenőrzendő.
Fork-futás jóváhagyásra várhat. Automatikus merge-tilalomhoz külön repó-
required-check szabály kell, ezt nem állítottuk be és nem állítjuk aktívnak.
Ez érinthetné a közvetlenmain-push munkarendet, nem módosítjuk hallgatólagosan.

## Kötelező képi regresszió commit ÉS push előtt — 2026-10-30 (297)

Minden lezárt változtatási körben a `scripts/check-rewards.sh` összes
ellenőrzésének sikeresnek kell lennie. A verziózott `.githooks/pre-commit`
és `pre-push` ezt automatikusan megköveteli: commit előtt az index pontos
tartalmát, push előtt a feltöltendő commit tartalmát teszteli, külön ideiglenes
másolatban. Nem elég egy másik, esetleg nem stage-elt munkapéldány sikere.
Hibánál nincs commit/push; javítunk, újratesztelünk. A kaput nem kerüljük meg
`--no-verify`, kapcsolók vagy az ellenőrzések kikommentezése útján.
Új klónban kötelező `./scripts/install-git-hooks.sh`; a helyi
`core.hooksPath=.githooks` beállítás nem kerül át automatikusan Gitből.

A `tests/reward-reading-corpus.json` vizuálisan ellenőrzött, rögzített
elvárásokat tartalmaz: kép → HUD/kártyajelenlét, típus és normalizált összeg.
Minden új felismerési esethez és hibajavításhoz adjunk valódi mintaképet és
képből ellenőrzött címkét; típusonként legalább két külön kép maradjon.
A felismerő kimenetéből tilos automatikusan átírni az elvárt eredményt.
Valódi címkehiba csak dokumentált képi bizonyítékkal javítható. A kalibrációs
kép mellett külön ellenőrző kép is kell; a negatív/eltűnéses eseteket megőrizzük.
A helyi kattintási és utóképek továbbra minden próbához megmaradnak; a Gitbe
csak a kiválasztott, ellenőrzött tesztreferenciák kerülnek, nem a teljes napló.

297:27kép,20pozitív/7negatív;17Swift+13statisztika+3Gitkapu+5NodePASS.
Az új teszt önállóan felfedte az555CutDamage→unknown hibát; valódi current
sablonnal javítva, külön kalibrációs és ellenőrző képpel, változatlan küszöbökkel.
Régi átvételeket nem könyvelünk újra. Free-only kör és PAUSED heartbeat marad.
Friss sablonnal figyelő37802/session48218, --resume-run; korábbi29305leállítva.
A18:09:22Zmentett képen inventorynyitva, HUDnemlátható: a függő18300nem
igazolt. Nem gyártunk utólagos átvételt és nem zárjuk be a felhasználó paneljét.

## Kötelező automatikus commit ÉS push minden lezárt változtatási kör után — 2026-10-30

A felhasználó kérése: minden érdemi kód-, teszt-, konfiguráció- vagy
dokumentációváltoztatási kör végén készüljön egy áttekinthető Git-commit,
majd automatikusan `git push origin main`, külön felhasználói kérés nélkül.
Előtte releváns ellenőrzés, dokumentációfrissítés, diff- és staged-ellenőrzés.
Csak a körhöz tartozó módosításokat stage-eljük; más felhasználói munkát nem
foglalunk bele és nem írunk felül. Az induló commit kivételként a meglévő
projekt egyértelműen jelölt alapállapotát is rögzíti; nem találunk ki múltbeli
commitokat. Pusztán olvasási/megfigyelési körhöz nem kell üres commit.

Nyers felvételek, futó naplók, build és titkok nem kerülhetnek commitba;
a szükséges kis tesztreferenciák igen. Ha a commit akadályba ütközik, ezt
jelezzük, nem állítjuk sikeresnek. Git-szerzői identitást nem találunk ki.
Ez állandó felhasználói felhatalmazás a körhöz tartozó commit feltöltésére;
felülírja a korábbi „push csak külön kérésre” szabályt. Force-push és
idegen változtatás felülírása nincs engedélyezve. Eltérő távoli történet,
hitelesítési vagy hálózati hiba esetén jelezzük az akadályt, nem állítunk
sikeres feltöltést. A commit után a távoli mainnel való egyezést ellenőrizzük.
291óta minden lezárt változtatási kör automatikus push-célja:
https://github.com/dankhazipeter/butcher-hero. Egyetlen munkág egyelőremain,
upstreamorigin/main. AzoriginSSH-címegit@github.com:dankhazipeter/butcher-hero.git;
SSHdankhazipeterként hitelesít, aHTTPSmásik fiókkal403-at adott. Globális
hitelesítést nem módosítunk; új ág/PR jelenleg nem szükséges.
Részletek289–291. Egy pusztán Git-munkarendre vonatkozó kérés önmagában
nem oldja fel a játék STOP-ját; a mostani felhasználó viszont külön kérte
a program újraindítását is, az alábbi szűkFree-körben.

## ELSŐBBSÉG — FREE-GYŰJTÉS ÚJRA ENGEDÉLYEZVE, 2026-10-30 (291)

Legújabb296: a hiányzó4smash damage (688) és3smash defense (809)
valójában igazolt, deunknown típusú átvétel volt. Valódi aktuális HUD-
sablonok hozzáadva; a küszöbök nem lazultak. Aktuális futás7típusát
képből pontosítottuk, csakreward_corrected sorokkal, régi futásokhoz nem nyúltunk.
MostSmashDamage4db/2752,SmashDefense4db/3236,0ismeretlen az ellenőrzött körben.
15Swift+13Python+5NodePASS. Újfigyelő29305/session9371, --resume-run:
watcher_resumed nem nullázza a Mostani futást (kezdés16:50:44.381Z).
Típusjavítás csakreconcile --current-run. Statisztikaszerver-session72899.

Legújabb295:közös8vonalas grafikonnal az IGAZOLT ÁTVÉTELEK DARABSZÁMA
hasonlítható, nem a jutalmak összege.1átvétel=1db, újrapróbák nem külön;
ismert típus hiányzó összeggel is darab, ismeretlen típus külön megjegyzés.
Százalékok nevezője az azonosított, igazolt darabszám. ÚjAPImezők:
collectionCounts/collectionSeries/unclassifiedClaims.12Python+5NodePASS.
Statisztikaszerverexecsession85053; gyűjtő2444változatlanul futott.

Legújabb294:statkártyák és tengelyek közösK/M/B/T-kijelzése,100alatti
skálaérték egy tizedeslevágással,100-tól egész.2360000→2,3M,99800000→99,8M.
Ez felhasználói példákból választott megjelenítési szabály, nem biztos
játékbelső algoritmus. Pontos napló/API/táblázat/tooltip változatlan.
Új áttetsző UI-ikonok:dashboard/icons/, fehér CSS-háttérrel; a gyűjtő
felismerési sablonjait NE cseréljük le ezekre.5Node+9Python-tesztPASS.
Csak statisztikaszerver indult újra,execsession2939;gyűjtő2444változatlanul fut.

Legújabb292–293:élő helyi statisztika http://127.0.0.1:8765/ (read-only,
2sfrissítés), forrásdata/free-rewards/events.jsonl. Újgyűjtővision3:
PID2444/session79280. Zöld fű tévesFreejelenlét és18.3K→8.3/8300hibák
javítva,13Swiftteszt+9statisztikai tesztPASS. Csak az ÚJ futás adatai
az alapnézet. A felhasználó legújabb prioritása:mostantól legyen jó;
a múltat ne javítgassuk, ne találjunk ki utólagos átvételt. Történeti
reconcile nem futott. Dashboardexecsession86374; a gyűjtőt nem vezérli.
Friss folyamatadat:data/free-rewards/state.json, végponti bizonyíték293-ban.
293élőPASS:16:52:31.854ZHP18300kattintás,34.166Zigazolás, utóképen+18.3K.
18:54:28Bucharest:újfutás6igazolt/0függő,Health54900(3×18300).
API/CLIugyanazonidőablakraegyezett. Az új nézet2sfrissül, nincs kézi reload.

A felhasználó: „indítsd el a programot, újra fut a játék, gyűjtsük a
jutalmakat”. Ez felülírja288STOP-ját kizárólag a bal oldali event alatti
Free-jutalom figyelésére és átvételére.1s mintavétel, kézi húzásvédelem,
1s újrapróba, eltűnés utáni egyszeri könyvelés és helyi naplózás marad.
Mozgás, harc, bolt, vásárlás, reklám és ismeretlen modal kezelése nincs.
A régi heartbeatPAUSED; nem indítunk második figyelőt. Friss futási állapot:
data/free-rewards/state.json, részletek291. Az alábbiSTOP-történet megmarad.

291élő indulás:90423PID/session95760,16:09:56Zwatcher_started,
16:10:02.768Zelső593CutDefenseigazolva. Következőstats-pillanatkép:
2claim,CutDefense1186,0függő. Utókép ellenőrizve; figyelő futva marad.

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
