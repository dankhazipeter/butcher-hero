# Élő jutalomstatisztika — 2026-10-30

## Kérés és megoldás

A felhasználó folyamatosan frissülő, megnyitható nézetet kért arról,
mikor mennyit gyűjtöttünk. A beszélgetéses vizualizációs felület nem
olvashat folyamatosan helyi fájlt; ezért helyi, projektben verziózott
nézet készült a Sites helyi munkafolyamatával. Nincs felhő, hosting,
külső betűtípus, CDN vagy új csomagfüggőség.

Megnyitás: http://127.0.0.1:8765/ . A nézet aCodexböngészőben megnyitva.
Indítás: `./scripts/start-reward-dashboard.sh`; ez önálló, előtérben futó
parancs,Ctrl+Cállítja le. A felület addig frissül, amíg a helyi kiszolgáló
fut. A gyűjtőt nem indítja és nem vezérli. Külön felügyeleti heartbeatnincs.

## Felület és forrás

Nyolc jutalomtípus külön összege és darabszáma, külön skálájú halmozott
diagramok; átvételi időlista, nem igazolt tételek és gyűjtőállapot.
Alapértelmezés: Mostani futás, tehát a legutóbbi `watcher_started` óta.
További időszakok:ma,utolsóóra,24óra,minden,egyedi kezdet/vég.
IdőzónaEurope/Bucharest, a naiv egyedi időpontokat is ebben értelmezzük.
Látható lapon2s-onként, rejtett lapon10s-onként frissít; előtérbe kerülve
azonnal újraolvas. Nincs kézi oldalfrissítési igény.

Forrás:`data/free-rewards/events.jsonl` és `state.json`, csak olvasva.
`dashboard/server.py`:Pythonstandardkönyvtáras HTTPkiszolgáló,
`dashboard/index.html`, `app.js`, `style.css`: saját, buildmentes felület.
Csak127.0.0.1-re figyel. Host/Originellenőrzés, útvonalengedélylista,
nem szolgál ki tetszőleges fájlt vagy nyers naplót. Nincs módosító API.

Az append-onlynapló teljes sorait növekményesen olvassuk; fél sorra várunk,
hibás teljes sort külön számlálunk; cserélt/csonkolt naplónál újraépül a cache.
OCRnyers szövegei nem maradnak a szerver memóriabeli naplóvetületében.
Legfeljebb100friss tétel és kb.96időbeli vödör/stat kerül a böngészőbe.

## Könyvelési egyezés

A gyűjtő statisztikájával egyezően az utolsó `click_sent` időpontjára
szűrünk, alsóhatár beleértve/felső kizárva. Csak `claim_confirmed_ui` ad
jutalmat, claimID-nként egyszer, a legutolsó `reward_corrected` adatával.
Újrapróbák külön inputdarabszám, nem külön jutalmak. Az ismeretlen vagy
hiányos igazolt tétel külön jelzés, nem találunk ki hozzá összeget.
Decimalalapú összegzés és JSONszövegértékek védik a pontosságot.
A grafikonrajzolás közelítő számkoordinátái nem módosítják az összesítést.

## Teszt és éles ellenőrzés

9PythonunittestPASS:növekményes/hiányos/csonkolt/cserélt napló,
egyszeri elszámolás, korrekció, ismeretlen érték, tizedesösszeg, időablak,
Bucharestnapváltás, legújabbfutás, helyiAPIbiztonság és élő hozzáfűzés.
`node --check dashboard/app.js`PASS.

Böngésző:8diagram és összes ikon betöltött; nincs konzolhiba;
360és735pxmért szélességnél nincs teljesoldalas vízszintes túlcsordulás.
12:31–12:32egyedi időszak pontosan2korábban igazolt átvételt mutatott.
Az összes történeti adat a CLI-vel összevetve194igazolt/33nemigazolt
pillanatképet és azonos8statösszeget adott. Az új naplósorok és a frissítés
órája böngészőújratöltés nélkül is változtak.

## Adatforráshibák és prioritásváltás

A felhasználó a nézeten észlelte a293-ban dokumentált gyűjtőhibákat:
tévesHealthnagyságrend és zöld fű miatt elmaradó visszaigazolás. A nézet
ezeket helyesen a napló szerint mutatta, nem böngészőcache-hiba volt.
A felhasználó ezután kifejezetten a MOSTANTÓL jó adatokra helyezte a hangsúlyt.

Nem írtuk át a múltat, nem futott történeti reconcile és nem készült
kitalált visszaigazolás. Az új `vision3` futás külön alapnézet. Régi
futást is tartalmazó szűrés adatminőségi figyelmeztetést mutat;
az új futás számítása nem keveredik a régi hibás tételekkel.
Aktuális futási bizonyíték és végpont:293.
