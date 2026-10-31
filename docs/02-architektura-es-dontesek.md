# Architektúra és döntések — 2026-10-29

## Aktív — 2026-10-31

324: csak a kalibrált számjegyadat bővült38→41glyphre,14képből. A kód,
0.30hibaküszöb/0.035karakterkülönbség és szigorú parser változatlan.
User567kalibráció mellett két független élő575held-out, különunit tiltja
a held-outnév felvételét a kalibrálóba.3új teljeskép-korpuszlabel;38összes.
Aktív/stagingresourceJSON atomilag cserélve, a következő olvasás már új
adatot tölt. Nincs kattintási/naplózási/főstatisztika-kódváltozás.324.

323kiegészítés: continuePending minden újresultnál újraélesedik; csak az
adott eredmény sajátproceed küldése oldja. KorábbiProceed nem átvihető a
következő eredményhez, cleanup sem számolhat kéziContinue-t sikernek.

323felülírja322ablakszélesség-skáláját: pinkX78px-es referenciához mért
tényleges szélessége adja a panelXYscale-t. Aranygombkomponensenként csak
pontosX1címke, pont a kiválasztott gombközepén; X2 nem választott. Saját
Continue→kétgeodekép után breaking, újOpen/büdzséreset nélkül.2újteszt,
5valódi külsőminta. Élő helyreállítás és Freevisszatérés igazolt.323.

322: CrystalNotificationMatcher összefüggőpiroskomponensből köralak,
méret/teltség,24szögből18fehérgyűrű+16sötétperem ellenőrzése; alatta kékikon
maradkötelező. InventoryCloseX komponenshorgony + két szövegcímke,
szélességalapúY-transzformáció. CrystalObservation closePoint/openPoint,
inventoryUnavailable konzervatívállapot; frissobservationből számoltinput.
CrystalInputPolicy kéziismertpanel esetén nem engedFreeinputot/igazolást.
Flow sajátüres/olvashatatlanOpen-panel cleanup, timeoutután egy max10ság,
megőrzött kattintási limitekkel. HiányzóContinue nem completed.322.

321: közös RewardInputGeometry tiszta ponttranszformáció+védelmek, natív
WindowInputGeometry CGWindowID/PID szerinti aktuálisQuartzkeret és aktív
CGDisplayBounds. AppKitframe/backingpixel nem bemenet. Free/kristály/event
mind ezt használja; warpreturn+kurzorpozíció+új geometriaiellenőrzés
mouse-down előtt, mouseMoved aCatalystnak. input_geometry a megfelelő
naplóban, nem click_sent és nem jutalom. Képarány1%/ablakkeret1pont/
kurzor2pont tolerancia; eltérésnél elutasítás, nincs régi koordinátafallback.
6új Swiftregresszió a kötelezőkapu bővített szűrőjében.321.

320: külön natív game-status CLI, AppKit/CGWindow metaadat képrögzítés nélkül.
GameControl 5s cache, szigorú boolvalidálás, hiba UNKNOWN. Külön game panel;
gyűjtő csak friss ismert hiányzó játék/ablak esetén vár arra. Új explicit,
tokenvédett same-origin POST csak fixbundleindításhoz; nincs statírás,
watcherstart vagy általános parancsfuttatás. Ez a korábbi teljes read-only
szerverhatárt szűken módosítja. 7Python+6Node új regresszió, részletek320.

319: statikus HTMLdialog, i-ikon a data-rangegombok mellett, de sajátadat-
választó attribútum nélkül. NatívshowModal/close/Escape/fókuszcsapda;
closeesemény visszafókuszál azikonra. Határolórecten kívüli háttérkattintás
zár, belsőpadding/fejléc nem. Kulcsok külön HU/EN katalógusban, i18n.apply
fordítja a tartalmat ésARIA-t is, nincs innerHTML. Backend/runhatár és
API változatlan; a meglévőadatból/időszakból semmit nem nulláz vagy ír át.
Teszt-DOM a valódiindex.html statikus kulcsait/attribútumait olvassa;
nyelvváltási/nyitás/zárás/nem-fetch regresszió+Python időszaktesztek.319.

318: CrystalFlow.abandonUnsentOpening csak opening és0openInventoryküldés
esetén enged idle-visszatérést,60scooldownnal. A nem-human preclickhiba
ága hívja; HumanInputBusy nem. Különcrystal_opening_abandoned diagnosztika,
a meglévő crystal_finished_no_reward terminál egyszer marad. Nem lesz
pendingclaim/siker abból, hogy az inputot valójában nem küldtük el.

317: EventEndVision+EventEndFlow külön, tesztelhető modul. Pink/goldgomb
pixelkapu után négy szűkTesseractsáv igazolja a konkrétDiamondLeague
offer/summary képernyőt. Ismert eventet aHUDszínheurisztika előtt kell
felismerni, mert az offer átmegy a régiHUD-kapun. Friss aktiválás utáni
preclick azonoswindow+legfeljebb3s kép+STOP+egérvédelemmel. Inputprioritás
event→kristály→Free; már az elsőeventképen függőFreeclaim érvénytelenítve,
nem következtetünk jutalomra egy köztes overlay eltűnéséből. Eventnapló
különJournal, state.eventEndPhase. DiamondLeagueeredményt nem olvasunk
be Freeösszegként. Rögzített pozitív és47korábbi negatív kép + tiszta
állapotsor/regresszió a közös commit/push/PR-kapuban. Részletek317.

313: CrystalVision szűk pixelkapuk+szöveghorgonyok alapján HUD/jelzés,
inventoryReady/Empty, geode és eredmény képernyőket különít el. Nem teljes
képes OCR: csak releváns kis sávok, Tesseract, nincs AppleVision. A változó
kristályszín/level/stat nem döntési feltétel. A repedt köztes kő külön lila
pixelmező+TAPhint; a kezdeti barna lap másik geodeág. CrystalFlow tiszta,
tesztelhető állapotgép: csak ténylegesen elküldött lépés után fogad következő
képernyőt;3/16próbakeret és90shatár. Action.permits friss aktiválás utáni
képen ellenőrzi újra a célt. Közöswatchkör egy inputgazdával, külön
kristályJournal; Freeclaim nem keveredhet kristályeredménnyel. Tényleges
képi és állapotsor-regresszió a teljeskapu része. Részletek313.

311: FreeBadgeMatcher elsődleges,3képből kalibrált48×24fehér/zöld/egyéb
maszk. FehérglyphDice>=0.82 és0.85fehér+0.15zöld súlyozottpont>=0.82;
±1pixeles környezet. Ez hasonlóság, nem valószínűség. Szűk belsőTesseract
ROI és régiROI csak tartalék. Strukturális zöldbadge+magas sötétkártyaszegély
a jelenlét külön pixelvédelme; ikonhorgony badgeRegion.maxY, nem OCRmagasság.
RewardPreclickValidation max3frissminta/1.2s, változásnál failclosed.
click_validated friss PNGt ment; click_sent e képet és aktuálisrewardot kapja.
Diagnosztikában konkrét ok, HUD/card/fingerprint és frissképminta,40kép/process.
Rövid olvasási hézag áthidalásakor sem kattinthat olvashatatlan aktuális képre.

310: két helyi, előre betöltött nyelvi katalógus + createI18n fordító.
data-i18n jelöli a statikus szövegeket/ARIA-t, dinamikus UI t(kulcs,értékek).
Az állapotgép fordítófüggvényt kap; a döntési logika nem nyelvfüggő.
A Decimal-szövegformázó locale-paraméteres, nincs új float-könyvelés.
localStorage hiba/érvénytelen kód magyar fallback; böngészőfrissítés nélkül
átfordul minden meglévő kártya/legenda/táblázat, szűrő és elrejtés megmarad.
A nyelvváltás nem minősíthet régi/hibás kapcsolatot egészséges gyűjtőnek.

309: orderedKinds másolaton rendez, minden stat-megjelenítő ezt használja.
A vonalminták típus→minta Mapben maradnak, nem a rendezett index alapján.
A jelmagyarázat kétoszlopos. Kirajzolási teszt a kártya/legend/vonal/tooltip
sorrendet és a nyolc változatlan vonalmintát is ellenőrzi, API mutálása nélkül.

308: app.js statOrder külön kártyarangsor, másolt kinds listán rendezve.
DOM-sorrend és vizuális sorrend egyezik, nem CSS order. A grid minden
szélességen kéthasábos; a közös grafikon és az adatréteg sorrendje változatlan.

307: helyi CountUp.js2.10.1 UMD + dashboard/animation.js adapter,
WeakMapban elemenkénti aktuális cél és animáció.0,65s easing, közös compact
formázás; csupán vizuális interpoláció. Scriptútvonalak explicit engedélyezve,
CSP továbbra self-only. Valódi vendor kódot tesztelő szimulált képkockaóra,
sem külső CDN, sem új csomagtelepítés nem kell a klónozóknak.

306: a lista numeric cellája is RewardFormat.formatCompactot használ.
Title és aria-label továbbra formatExact, a forrásadat változatlan.
A Node-regresszió vm-ben a valódi app.js-t futtatja minimális teszt-DOMmal,
nem pusztán a formázófüggvényt vagy egy forráskódrészlet jelenlétét teszteli.

305: a külön UI-only RGBA ikonok átlátszóságát a CSS is megőrzi:
.stat-head img, .entry-kind img és .frequency-key img background:transparent.
Nincs képfájl-/sabloncsere. A PNG-alfa és az összes ikonháttér-szabály
Node-regressziója a meglévő teljes commit/push/PR-tesztkapu része.

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
