# Közös Terminal-indító

2026-10-31. A felhasználó saját Terminalból indítható, látható futást kért,
amely együtt kezeli a weboldalt és a gyűjtést. Fejlesztéskor továbbra is
leállítható és újraindítható legyen ugyanaz a rendszer. Ez nem új harci
automatizáció, nem automatikus játékindítás vagy bejelentkezési szolgáltatás.

## Használat

Az AGENTS.md teljes setupja, release buildje és engedélyezése után, a
repó gyökeréből:

```sh
make start
```

A parancs előtérben marad. A dashboard és a felügyelt gyűjtő kimenete
ugyanebben a Terminalban látható, 10 másodpercenként friss futásjelzéssel.
A kiírt http://127.0.0.1:8765/ címet lehet megnyitni; az indító nem nyit
böngészőt vagy játékot automatikusan. Ctrl+C mindkét saját szolgáltatást
leállítja. Másik terminálból `make status` / `make stop` használható.
Normál Terminalbezáráskor a SIGHUP is leállítási kérés. SIGKILL, gépleállás
és alvás melletti megszakításmentességet ez nem ígér.

Alapból --resume-run, tehát megmarad a logikai Current run kezdete és a
teljes történeti napló. Új logikai statisztikai futás csak explicit:

```sh
python3 scripts/butcher-hero.py start --new-run
```

Más port: `make start PORT=8766`. Az indító nem fordít felül futó release-t,
nem telepít csomagot és nem módosít jogosultságot. Hiányzó bináris,
Swift-resourcebundle, Tesseract vagy eng modell esetén teendőt ír ki.

## Bárhonnan indítható rövid parancs

Egyszer ebben a checkoutban:

```sh
make install-cli
```

Ez a ~/.local/bin/butcher-hero symlinket hozza létre az itteni Pythonindítóra.
Ugyanarra a forrásra idempotens; más meglévő fájlt/symlinket nem ír felül.
Sem PATH, sem shellprofile nem módosul. Ha a könyvtár szerepel a PATH-ban:

```sh
butcher-hero start
butcher-hero status
butcher-hero stop
```

Ha nem, a `~/.local/bin/butcher-hero start` közvetlenül használható; a
telepítő opcionális PATH-parancsot is kiír az aktuális Terminalhoz.
`butcher-hero start --port 8766` más portot ad. A checkout és buildje
megőrzendő: a symlink nem önálló telepített alkalmazás. A repó elköltöztetése
után az elérési út frissítendő; más checkout parancsát nem írjuk felül vakon.

Telepítés nélkül, tetszőleges könyvtárból szintén működik:

```sh
make -C "/Users/dankhazipeter/PythonProjects/Butcher hero" start
```

A fenti konkrét út a maintainer gépéé; más gépen a saját checkoutút kell.

## Életciklus és biztonsági döntések

Az indító útvonala __file__.resolve()-ból ered; a hívó aktuális könyvtára
nem választhat ki más naplót vagy programot. A data/local-app/runner.lock
csak egy közös indítót enged. A régi supervisor/live-capture lockot is
ellenőrzi indulás előtt; a natív worker saját lockja továbbra megmarad.
Aktív külön gyűjtő vagy foglalt HTTP-port esetén elutasítás történik,
nem átvétel. Az eredeti szolgáltatást a saját indítójával/termináljával kell
leállítani, és csak utána újraindítani a közös indítót.

Először a dashboard indul, saját HTTP-health ellenőrzéssel. Csak ezután a
meglévő Pythonfelügyelő és változatlan Swiftworker. Egyik kezelt szolgáltatás
kilépése a másik leállítását eredményezi, jól látható hibával. A meglévő
felügyelő továbbra a saját elakadt/crashelt workerét indítja újra; a közös
indító nem helyettesíti a képi felügyeletet és nem indít játékot.

Mindkét szolgáltatás saját processsession/groupot kap. STOPkor kizárólag
ezeket és saját leszármazottaikat jelzi, legfeljebb10s türelmi idővel,
szükség esetén a saját csoport erőltetett lezárásával. Nincs pkill vagy
idegenport-foglaló kilövése. A külső stop parancs runnerlockot, PID-et,
eredeti ps-parancsot, kezdési időt és checkoutazonosságot ellenőriz; elavult
JSON nem ad felhatalmazást idegenfolyamat leállítására. A ps-időformátumot
LC_ALL=C/TZ=UTC teszi a két Terminal környezetétől függetlenné.

Saját állapot: data/local-app/state.json, atomi írás. A Free/kristály/event
naplók, statisztikák, felismerők és inputkorlátok nem változnak. A terminál
frissképidő nélküli élőPID-et nem nevezi sikeres gyűjtésnek. Másik
Terminalhost külön macOS Screen Recording/Accessibility engedélyt kérhet;
az első valódi kép és átvétel ott külön ellenőrizendő.

## Ellenőrzés

19 új teszt a tests/test_local_app.py-ban, a make test / commit / push /
GitHub PR-kapu részeként. Függőség- és portelutasítás, aktív régi gyűjtő,
régi vagy újrahasználtPID, idegencheckout, sikertelen dashboardindulás,
alapértelmezett folytatás és explicit újrun, installeridempotencia és
idegenparancs-megőrzés, megszűntkimenet kezelése.

A sima make alapcélja változatlanul setup, nem start; külön dry-run teszt
őrzi, hogy puszta make ne kapcsoljon be váratlan képrögzítést/inputot.

Négy teszt valódi, de kizárólag ideiglenes álprojektbeli HTTP/felügyelő/
worker folyamatokkal ellenőrzi a Ctrl+C-t, külsőstopot, duplaindítást,
webszerverhiba utáni takarítást, máscwd-t és a symlinken át történő
vezérlést. A fake release bináris nem hajtható végre a tesztútban; nincs
valódi képrögzítés vagy játékinput. Ez az indító életciklusának ellenőrzése,
nem egy új élő játékos átvétel vagy többórás stabilitás bizonyítéka.

## Helyi átadáspróba

A make install-cli elkészült, a loginzsh megtalálja a felhasználói
~/.local/bin/butcher-hero parancsot, PATH/profilmódosítás nélkül. A régi
65062supervisor/64995dashboard sajátazonosságát ellenőriztük, az eredeti
gyűjtőstop után csak ezt a saját webszervert állítottuk le. Az új közös
runnerrel /tmp-ből a globális status és stop sikeres; worker/supervisor és
dashboard eltűnt, state.running=false és portfelszabadulás igazolt.

Az első gyors make -C restart tévesen foglaltportot jelzett listener nélkül:
a korábbi HTTP-kapcsolat TIME_WAIT állapota volt az ok. Külön minimális
TCP-regresszió reprodukálta a hibát. A preflightpróba most a HTTPServerhez
hasonló SO_REUSEADDR-t használ; nincs SO_REUSEPORT és nincs élő szerver
mellé bekötés. A valódi foglaltportteszt változatlanul elutasít. Utána
valódi stop és azonnali make -C start is sikeres lett, a /health válasz jó.

Utolsó indítás20:55:51Z: runner70886, dashboard70890, supervisor70891,
execsession2352; ezek történeti azonosítók, friss állapot a local-app és
free-rewards JSON-okból kérendő. Az első metaadatpróbákban a játék még
nem futott. A saját Terminalhost engedélye és az ottani gyűjtés ellenőrzése
még szükséges a felhasználói átadáskor.
Az itt futó átmeneti példány átvétele: butcher-hero stop, majd a felhasználó
saját Terminaljában butcher-hero start. Nem hagyunk két watchert futni.

## Új élő kristálykör az átmeneti runner alatt

A felhasználó közben újraindította a játékot; későbbi natívpróba futó,
látható ablakot ad, a worker friss képeket rögzít. Új E5662CA8 saját
tranzakció20:56:44.322Z indul: értesítésesHUD → saját openInventory →
openOne → 5strike → eredmény → sajátproceed → inventoryUnavailable →
sajátX → kétHUD,20:57:04.027Zcrystal_completed_ui. Ebben a körben nincs
--recover-crystal, workerrestart vagy közben végrehajtott kódmódosítás.
Az eredményképet és HUD-utóképet kézzel is ellenőriztük: zöld40kristály,
Lifesteal+10.5K; utána normálHUD, kristályikonon nincs pötty. Helyi
bizonyítékok data/crystal-rewards/evidence/E5662CA8-…-result-…png és
…-hud-F8E2A2D8-5B72-4413-9745-E6D86AEC825F.png. A számszerű eredmény
nem Free- vagy karakterstat-növekedés, nincs felszerelés vagy eladás.

Ez egy új, teljes önálló kör bizonyítéka a meglévő kristálykezelővel és
az új közös indítóval; a korábbi323helyreállított kör külön történet.
Nem bizonyít többórás futást vagy a felhasználó saját Terminaljának
jogosultságait. Az indító átadásánál továbbra ellenőrizendő az első élő kép.
