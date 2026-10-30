# Architektúra és döntések — 2026-10-29

## Aktív — 2026-10-30 (282)

304:watcher_state külön stateKnown/processAlive mezőket ad. Hiányzó/hibás
adat vagy ellenőrizhetetlenPID nem bizonyítottleállás. dashboard/status.js
tesztelhetőállapotgép; élőfolyamat+frissképidő=Fut, hiányzóelsőkép=indulás,
10s-nálrégebbikép=figyelmeztetés, HTTPhiba/20selavulás=ismeretlen.1sUIóra
a válaszok között is öregíti az állapotot; az APIpoll marad2s/10sháttérben.

303FELÜLÍRÁS:az aktív core nemimportálVisiont/CoreMLt. Strukturáltbadge
jelenlét után csak aFREEszó kapTesseract7-es sorfelismerést, angolmodell,
egyetlenCPUthread,3shatáridő. Számmező: fehérglyphok összefüggő komponensei,
domináns számsor,24×32bináris alak+oldalarány, típusonként legjobb referencia,
0.30maxhiba/0.035margin.38glyph13kalibráltképből,29teljes regresszió.
Modelladat különResourceDigits; minden kártyaolvasáskor betöltődik, atomi
adatcsere leállítás nélkül lehetséges. Nem az aktuális OCRválasz címkézi a tesztet.

302:VNRequest.supportedComputeStageDevices alapján mindenCPUtámogatású
szakaszra explicitCPUeszköz, setComputeDeviceAPIval. Nem használunk
deprecatedusesCPUOnlyt, nem választunk nem támogatott eszközt. Különunit
igazolja a konfigurációt. Éles build előkészítése külön .build/reward-staging
könyvtárban, így a futó releasebinárist a fordítás nem cseréli le.

300:Pythonfelügyelő külön folyamatként a sikeres képfeldolgozás frissülését
ellenőrzi, nem aPIDlétét. Egyetlen sajátgyerek, különflock;35–50smértékű
maximális elakadási ablak a türelmi időkkel. SajátJSONLállapotnapló,
jutalomnaplóba nem könyvel. Tartós előtérsession kell; rövid execnohupja
nem maradt életben. KéziSTOPmindkét folyamatot leállítja.

301:ikonjelölt kis pixeles eltolási környezetben, típusonként összevont
legjobb referenciahiba, eredeti0.48/0.035küszöbök. Szám-OCRcsak sikertelen
eredeti próbák után kap fehérszöveg/feketeháttér maszkot, ugyanabban a
számsorROIban, ugyanazzal a szigorú értékparserrel.

299:SwiftPMa tesztcsomag mellett a régi executabletargetet is fordítja.
A Swift6.1CI main.swift+@main ütközését szabványosBotMain.swiftelnevezés
oldja fel; explicit numerikus típusok és egyszerűbb azonos képletű ciklus
csökkentik a fordítóverzió-függést. Nem hagyunk ki targetet/tesztet aCIzöldítéséért.

298:Makefileegységes setup/test/test-vision belépési pont. A teljes make test
beköti a helyi hookokat, majd a meglévő check-rewards.sh futtatót használja.
GitHubActions ugyanazt a parancsot futtatja macos-15gépen push/PR eseményre;
read-only jogosultság, nincs titok vagy pull_request_target. Minden action
ellenőrzött v7commitSHA-ra rögzítve, nem mozgó verziócímkére.

297:verziózott27képes, kézzel ellenőrzött ground-truth jegyzék a
tests/reward-reading-corpus.json-ban. RewardCorpusTests ugyanazt a
RewardVision láncot futtatja, mint az élő gyűjtő; típust, normalizált összeget,
HUD- és kártyajelenlétet ellenőriz. Típusonként minimum2külön képfájl/hash.
Git-kapuk az index/feltöltendő commit pontos, ideiglenes másolatán futtatják
a teljes jutalom- és statisztikateszteket; a munkafa és élő napló érintetlen.
Új cutting_damage_current valódiHUDsablon; küszöbök változatlanok.

296: a típusonként összevont sablonillesztés aktuális HUD-mintákat is
használ, változatlan küszöbökkel. Technikai --resume-run különválasztja
a folyamat újraindítását a gyűjtési időszak kezdetétől. A --current-run
képi típuskorrekció nem módosít igazolást, nem írja át a régi naplósorokat.

295:érték- és darabsorozat külön APIcsatornán. A collectionSeries ismert
típusú, igazolt claimenként1-et számol akkor is, ha az összeg hiányzik.
Az ismeretlen típus unclassifiedClaims, az arányok nevezője az azonosított
darabszám. Ugyanaz a végső kattintási idő/időablak és claimID-deduplikálás.

294:dashboard/format.js közös, szövegalapú K/M/B/T megjelenítési formázó,
az adatréteget nem érinti. dashboard/icons/ különRGBA UI-képek;
a felismerési erőforrások megmaradnak. Ikoncache1óra, API továbbra no-store.

292–293:read-onlyPythonHTTPstatisztika csaklocalhoston, növekményes JSONL-
olvasás, Decimalösszegek, claimID/finalclick szerinti könyvelési egyezés.
Buildmentes böngészőfelület2sfrissítéssel. A gyűjtővision3strukturált
Free-jelzést keres, nem puszta zöld pixelt; teljes nagyságrend/kezdőszámjegy
elsőbbséges.8sblokkolás egyszeri képi diagnózist ment. Régi adatokhoz nem nyúltunk.

286FELÜLÍRÁS:éles módbanRewardClaimVerificationváltja a végleges foglalást.
Kézi gomb/húzásvédelem, elengedés után friss validálás;1s után megmaradt
Freeújrapróbálható. Két HUD-képen hiányzó kártya igazol, külön pixeljelzés
OCRhibánál is jelenlétet tart fenn. Újrapróbák azonosclaimID, egyetlen
könyvelés; statisztika utolsópróba-idő és külön click_attempts.11tesztPASS.
Az alábbi284-es elküldött-input-blokkolás már történeti.

284:szám-OCRsaját számsor/karakterdoboz alapján különül el a háttéridőzítőtől.
Kattintás előtt elutasított input feloldja a foglalást; elküldött input
továbbra blokkol. Aclick_sentírás elkülönül az input előtti hibakezeléstől.

ButcherHeroAutomationkülön futtatja az1sFree-jutalom figyelőt, a régi
játékstratégiától függetlenül. Nyolc címkézett statikon+ellenőrzött valódi
Free-kártyák alapján alak- és színillesztés, külön numerikusOCRtartalékkal.
Kattintás után képi visszaigazolás; JSONLappend-onlynapló, Decimalösszegek,
időintervallumos összesítés. Bizonytalan régi sor offlineképből külön
reward_correctedeseménnyel javítható. Részletek és élő bizonyítékok:282.
A régi heartbeatPAUSED, csak aFreeautomatizáció fut; nincs mozgás vagy harc.
Az alábbi281-esSTOPmár történeti.

281:különButcherHeroAutomationésRewardAutomationCorealap készült,JSONL
jutalomnaplóval. Csakdry-runig tesztelt; a típusfelismerés javítandó,
valódi kattintás nem történt. FelhasználóiSTOP,játék bezárva,nincs futófigyelő.

A korábbi Swift-kód és eszközök megmaradtak; az új rendszer részleteiről még
nem döntöttünk. A21régi felső szintű JSON a visszaállítható archívumban van:
`archive/2026-10-29-before-restart/state/`. Az aktív állapot: `session-state.json`.

Egyetlen `observe --frames 1` készült, input nélkül. A régi elemző7660HP-t
és Island2-mozgást javasolt, miközben a friss képen473Més új UI látható.
Ezért a régi felismerés és stratégia új ellenőrzés nélkül nem dönthet.

A heartbeatPAUSED. Új megfigyelésre felhasználói jelzés kell.
