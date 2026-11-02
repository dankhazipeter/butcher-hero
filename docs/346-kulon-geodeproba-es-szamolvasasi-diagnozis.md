# Külön geodepróba és számolvasási diagnózis — 2026-11-02

## Felhatalmazás és végső állapot

A user jóváhagyta a háttérkattintás próbáját, majd kifejezetten kérte az
egész normál program leállítását és egy egyszerű, külön geode-kattintót.
A felügyelő13:44:17.504188Z-kor állt le (14:44Budapest). Gyűjtő, supervisor,
közös runner és dashboard nem fut; nincs automatikus folytatás/új ütemezés.
A gyűjtés most maradjon leállítva új utasításig. Legacy bot/heartbeatPAUSED.

A user később kifejezetten engedélyezte a megtalált képek szerinti
naplójavításokat is. Ez pontosan az alábbi három igazolt claimre vonatkozott,
nem teljes történeti reconcile-ra és nem olvasófejlesztésre.

## A Free-próbák valódi eredménye

A kezdeti több elutasítás még küldés előtt történt. A kézi átadás túl lassú
is volt: BB28D4A6 friss565lefoglalása13:29:09, de a későbbi capture~13:29:40
már nem látott kártyát. Nincs belőle technológiai sikertelenségi állítás.
Ezután egyetlen helyi folyamat foglalta le a friss reward_detected jelöltet,
leállította a normál collectort, indította a sajátGUIharnesst, elküldte a
próbát és finally ágban visszaindította a normál collectort. Nincs OCR/keylog
a harnessben; csak saját billentyűszámláló, nem gépelt tartalom. Saját ablak
aktiválása teszt-előkészítés volt, a mérés csak utána kezdődött.

- 84C249AB-DBD7-46E1-9A05-10ABC0FC5F88,13:31:40Z: private CGEvent/PID
  down/up, Regen84.106minta3.4105s alatt, csak fixturePID52598,
  kurzoreltérés0, maxmintaköz0.259s. A kártya mind6utóképen megmaradt.
  Nem confirmed; normál C9D2F907 kör13:31:48-kor külön igazolta a84-et.
- CD2F767D-2643-4433-9402-CCDB5244263B,13:35:42Z: explicit célzott move+
  down/up.111minta;0.519s után kézi jellegű mozgás és másikappra váltás,
  max336.6px; ebből NEM vezetünk le tiszta fókusz/kurzor bizonyítékot.
  Kártya nem tűnt el; normál951293F3 külön vette át565-öt13:35:50-kor.
- BD739748-518B-463D-B0AD-EFE86D574F4A,13:40:51Z: publikus NSEvent
  ablakhoz rendelt packet→CGEvent→postToPid.108minta2.8472s alatt,
  csak fixturePID55442, kurzoreltérés0, maxmintaköz0.146s. Smash700kártya
  mind6utóképen ott maradt. Normál4DB09255 külön vette át utána.

Nominal20ms minták nem folytonos matematikai bizonyítékok; a szinkron
felismerés közben hosszabb mintaköz volt. Nincs igazolt háttérátvétel.
A3kísérleti claim_unconfirmed sor szándékosan nem növeli a statösszegeket;
nem írtunk be hamis sikert. Runtime/képek helyben a probeJSON és a normál
claim-evidence könyvtárban maradtak, nem kerülnek teljes tömegbenGitbe.

## A külön egyszerű program

`scripts/probe-geode-click.swift` csak az aktuális HUD kék geodeikonját célozza
egyszer; nincs OCR, Free-figyelés, crystalOpen/ütés/Continue, eladás/vásárlás,
megjelenítési ciklus, fókuszaktiválás, warp vagy globális tap/fallback.
Egyetlen játékPID/window és közös kizáró flock kell; a user az
`--hud-confirmed` flaggel manuálisan megerősíti a megfelelő kiindulóképet.
A háttérben lévő játék és elengedett egér követelmény. SIGINT/TERM a70ms
down/up pár közben átmenetileg figyelmen kívül hagyott a matchingupért;
SIGKILL ellen nincs garancia. Nem unattended/production mód.

```sh
swiftc scripts/probe-geode-click.swift -o .build/probe-geode-click
.build/probe-geode-click --permissions
# Csak explicit engedéllyel, LEÁLLÍTOTT collector és szemmel ellenőrzött HUD:
.build/probe-geode-click cg --hud-confirmed
# Másik külön próba, NEM automatikus fallback:
.build/probe-geode-click cg-move --hud-confirmed
.build/probe-geode-click appkit --hud-confirmed
```

Permission-próba: accessibility=true, postEvent=true; nincs új TCC-grant.
Mindhárom élő változat után a mentett gamekép továbbraHUD, nem inventory.
CG és cg-move előtt/után foregroundPID/kurzor azonos; AppKitnál közben
kurzormozgás volt, ezért nem nevezzük zavartalansági bizonyítéknak. A cél
Quartz1466.735/477.13, window2198, frame878/37/623/863: a mentett képen
ténylegesen a kék ikonon belül. Helyi proof `.build/346-geode-*.png`.
Az API void, nincs dispatchACK: csak azt állítjuk, hogy ezekkel a kipróbált
nyilvános packetekkel nem nyílt ki a panel. Nem általános lehetetlenségi tétel.

Az integrált prototípus346közbeni saját, még nem commitolt variánsait
visszavettük a345állapotára. A bonyolult collector nem kap új backendmódot;
csak a külön kis tesztelő kerül mostGitbe. Aktívrelease sosem lett lecserélve.

## A számolvasó: változatlan kód, bizonyított pályaháttér-hiba

A normál bináris továbbraNov1-i, a NumberReader/Vision és a modellek ebben
a körben nem változtak. Source és aktív digits.json SHA256 ugyanaz:
`a8a20b416ee41f3354d3f609ec2d88d2a78369c515b42e422480187c9641dd9a`.
Az aktív release inspect a két konkrét eredeti képen továbbraamountnil.

Ugyanazt a RewardNumberReader forrást és JSON-t egy helyi diagnosztikai
programmal futtatva, ugyanazon CGDeviceRGB-konverzióval:

- Smash700: a választott fehér komponens x64/y548/w30/h35; a legjobb
  glyphhiba0.3605>0.30, margin0.00698<0.035, ezért nil.
- Pierce565: választott komponens x79/y548/w15/h23; hiba0.30091>0.30,
  margin0.01323<0.035, ezért nil.
- SmashDefense817: a háttérkomponens x79/y548/w15/h27 a1mintára
  hiba0.239375/margin0.0679167 mellett tévesen elfogadott, tehát1.

A fix számROI a kártya jobb oldalán fehér világfoltot is fog. A maxHeight
és baseline-szűrés a magasabb23–35pxháttérfoltot választja a valódi~16px
számok helyett. Ezért új glyph felvétele vagy küszöblazítás nem bizonyított
javítás.3eredeti diagnosztikaiPNG a `docs/references/2026-11-02` mappában,
kézzel ellenőrzött700/565/817címkékkel; NEM PASS-korpusz vagy kalibráció.
Olvasójavítás ebben a körben nincs, a későbbi felismerés továbbra érintett.

## Pontosan3engedélyezett naplópontosítás

Mindhárom kártya és az explicit lebegő+utókép vizuálisan egyezik:

- 4DB09255-93BB-4984-A549-1CE421F0F1E0: Smash Damage nil→700.
- C4F95838-026F-4091-9C4B-59A93D13955E: Pierce Damage nil→565.
- 68D3ABCF-8ED0-43E1-A543-5426D82CBF53: Smash Defense1→817.

Csak3reward_corrected append, natívval azonos flock/O_APPEND/fsync.
Az eredeti24,382,835byte változatlan prefixeSHA256
`3d4b95f91b238d06e0d483a36e2042af2e48bc15df1b5020c14d5b75cae3a4e6`.
Második futtatás0újsor. Sem kattintási/igazolási idő, sem claimszám nem
változott, nincs új jutalom vagy globális reconcile.

A dashboard aggregátorát offline a valódi naplón ellenőriztük, és a natív
CLI is egyezik13:38–13:43Z között:9confirmed,1unconfirmed,unknown2→0.
Egyedi korrekciók700/565/817; összegdelta+700Smash,+565Pierce,+816SmashDefense
(az1már benne volt). collectionCounts/confirmedClaims/pendingClaims/attempts
változatlan. A próba700-as unconfirmed sora továbbra nem duplázza az összeget.
Más történeti hibás/bizonytalan tételeket nem javítottunk automatikusan.

## Tesztkapu

4újofflinePythonCLIteszt fordítja a külön scriptet, de soha nem küld sikeres
élő inputot: help/hibásargumentum; érvénytelenmód; mindenmód külön izolált
flockblokkolása; fix game/geode és tiltott globális/aktiváló APIk forráskapuja.
Kötelező teljes kapu237teszt+7JS-szintaxis; nem változott régi képi elvárás.
