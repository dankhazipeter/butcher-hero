# Bot felépítése és döntések

## Aktuális felülvizsgálat — 2026-09-19

278:passzív bemutató lezárva628képpel. Új offlineaudit minden egymást követő
PNG-t mér; hibás/200pxfeletti képpárnál külön koordinátaszegmens. Két sikeres
lánc255–320(66kép) és334–460(127kép) JSON-ban, még nincs élőchartba kötve.
Kontaktlap-generátor csak az eredeti képek vizuális indexe. Nincs játékinput.

276:chart36nyugati táborkerítés északi átjárója mért képi pontokkal importálva.
Csak keleti/belső célra, szűk területi kapukkal; nyugatiIsland2célt nem térít el.
Eredeti bejárás élőben igazolt, importált folyosó ismétlése még nincs.

275:nagyobbHP-maximum konszenzusából K-n kívüli betűzaj kizárva; tiszta
régi/alacsonyabb szám cáfolja a függő emelést. AktuálisHP-parser változatlan.
212136/17hamis7400 a korábbi/következő7,06K képek alapján7060-ra korrigálva.

274:felhasználói új folytatás után heartbeatACTIVE; a273-beli szünet már
történeti. Passzív felvétel nem rögzítette az emberi kört, nincs új bemért út.

271–273:üres célHP-OCRnél két külön kivágás/nagyítás egyező tizedesK-ja;
színes térképi fegyver/fejfelismerés és chartonkénti célkatalógus, fegyverprioritás.
Világcél és harc továbbra elsőbbségi; piros/narancsfej nem vak tartalékcél.
`map-pan` csak igazolt nagy térképen; `record` kizárólag passzív PNG+időbélyeg,
vezérlő és OCR nélkül. A felhasználói bemutatóhoz heartbeatPAUSED.
Unit/build/célzottreplayPASS;210801fegyvercélág élőben működött,de a fal/
chartváltás miatt a teljes út nincs megoldva. Emberi bemutató még nincs.

270: kiter csak látott260px+célnál gyógyulási fázis; hiányzó cél nem999px.
Menekülés az induló megközelítés rögzített visszirányán, nem a mozgó boss
pillanatnyi ellenirányán. Halálmemória a kiter kezdőHP-jából, overlaynként
nem ismételt sávképzés. Unit/build/élőképsor-replayPASS, élőkitérés még nincs.
269: teljes felügyelt Island2déli kerülő képi pontjai JSON-ban; nincs még
automatikus folyosóaktiválás vagy fordítottútigazolás.

268: célterülethez kötöttfolyosó és szűkérkezési sugár; nyugati célhoz
mértE→S→SWsátorkijárat,chart63ésvégponti képi kalibrációvalchart47.
VisualOdometry apróarányos rasztereltérést elfogad a közös normalizálás előtt;
nagy/aszimmetrikusváltás és a hibás optika továbbra tiltott.

267: képi terrainchart mindig elsődleges az ikonorigóval szemben, checkpointnál
is. GolemApproachPolicy a friss narancsfej relatívirányából max18egységnyi
V2köztescélt ad (8pxalattnil), csak világcél/pirospont hiányában.
Egy navigációs vezérlő és változatlan harci/UIbiztonsági kapuk.
LocalWorldMaputolsóPNG+pozíciócheckpoint: leírók és kameramozgással igazított
terepkép alapján folytat, nem két tetszőleges régi kép rangsorától függ.
V2azonos,ellenőrzöttterraincharton6egységen belül megőrzi a kerülést.
200129/0élőazonosságPASS; a sátor körüli átjáró ettől még nem megoldott.

266: saját zöld csíkkal fedett közeli piros maradékcsík külön szűk mintája:
alsó hosszú fekete keret+felsőzöldátfedés+HUDgeometria. Ugyanezen mintának
45pxalatti cél is engedett; nincs általános kontaktus/harcierő lazítás.

265: narancs gólem irányát arc/szem sablon keresi minden irányban, nem NW
színfolt. Nagytérkép kizárva. Ez csak felismerés: V2 önálló gólemcélcsatorna
még nincs. Több azonos fej miatt a DustyGulch-horgony név nem egyedi azonosság.
Világos havas hátterű nagytérkép külön igazolt mínuszikon-mintát kapott;
a korábbi minta teljes téglalapjának háttérfüggősége miatt ezt nem ismerte fel.

263: kezdeti kerülőoldal célérintő+ismertakadály pontozással; forgásirány
checkpointban, régi mentésnél baloldali alap. A fal szabad oldalán frissen
látott cél törli az elavult kerülést, nem a mért térképet.

262: HPTimerOcclusionPolicy a csonka52s16:52K alakot takarásként ismeri
fel, kizárólag az egyszeri megfigyelési lépéshez. NemHPparser-lazítás.
261élő:185320/0–14mért folyosó önálló bejárása,16Steel26jutalom.

261: folyosók koordinátatérhez és opcionális aktiválási területhez kötve.
Az51-es chart északi ösvénye képi horgonnyal kalibrálva; eltérőchart kizárt.
Két sikertelen folyosólépés után5perces bizonyíték-hűtés és útmegszakítás.

260: aV2 a LocalWorldMap visszaazonosított chartját/pozícióját használja
landmarkhiánynál, nem futásonként újUUID-t. Chartazonos akadály/látogatás
és képi-egyezéses kerülőfolytatás; külön chartok összekeverése tilos.

259: új csakolvasó `tools/measure-route.swift` PNG-sorok képi elmozdulását
auditálja aVisualOdometry-val; hibás/nagy ugrásnál megszakad. Nem módosít
játékállapotot. A torony északi kerülője452px mért út, lokális adat, még nem globális él.

258: érvényes helyi pozíció mellett cél nélküliV2 rövid felderítő célt
választ nyolc négycellás jelöltből, A*elérhetőség/látogatottság alapján.
Nem régi szigetmakró; friss ellenség azonnal előzi, lokalizáció nélkül tiltott.

257: a büdzsézettHP-képtisztító lépés nem harci célváltás. Megőrzi aV2
célt/kerülőoldalt, abból nem tanul akadályt; falmenti irányban legfeljebb0,50s.
Korábban az általános handoffMovement eldobta a kerülést (182845/5–7).

249új élő bizonyíték182329/16–24: két sikertelen falirány után tartós déli
kerülés, nyugati réspróba, átjutás.27a túloldali fa tényleges aratása.
40s/két fa; navigációs szimuláció ismétPASS. Általános kész navigációt nem állítunk.

256: KnownHeartGuardianPolicy kizárólag a frissen azonosított4,31K/500szív
cél számára bővíti a szűk kutatási próbaágat. Teljes közeli csík, friss95%HP,
4000maximum, nincs lilaobjektum és nincs tiltott vesztes sáv; globális bossmódOFF.

255: szűk PassiveTreePolicy a800–1600HPközötti biztos fákat is normál
farmként kezeli; nagy/bizonytalan/rawHPeltérő cél nem kap kivételt.
Kisőrpróba nem vállal fát, a türkizsín-mozgásjavaslat isV2tulajdonába kerül.
HPObservationProbeBudget:két friss95%+HP-kép újraélesít, minimum8s;
ugyanazon igazolatlan takarási epizódban nincs ismételt próba.

254: célHP csak a piros csík saját sorába eső OCR-szövegdobozból.
TágROI képkontextus marad, jutalomsor geometriailag kizárva; Visionbbox
ROI-relatív.174156és174801replay, quick-farmPASS. SajátHPág változatlan.
Ugyanitt új rövidcsík-kapu: két párhuzamos keretnek a vörös maradékon túl
is folytatódnia kell. Cél a saját piros cipő kizárása, nem a DOCmaradék eldobása.

253: tört pajzsjutalom0.5/0.50ésszétszakadt0.+5sor nem célHP.
Teljes174156replayben a64HPőrök nem ragadnak5HP-ra; quick-farmPASS.

252: külön NavigationIntentPolicy a régi belső kerülők és célzár V2átadásához;
110px-nél távolabbi közelítés tervezett. Tizedes K-OCR-ből tilos új
nagyságrendet gyártani:15.9K→1590hiba kizárva, nem javítjuk találomra5900-ra.
Perces HP-takaráskor is legfeljebb egy biztonsági kapuzott0,30s megfigyelési
mozdulat/futás; a kritikus/gyógyulási állapotot ez nem oldja fel.

251: CloseContactPolicy kis, biztos, fenyegetésmentes fáknál2megfigyelés
után0,18s kontaktuskorrekciót ad7helyett. Más eset marad konzervatív.
173013/15és22cáfolta a teljes navigációs elkülönítést: a legelső
obstacleMap.adapt még rövid megközelítést is felülírt. Most ez a hívás is
kizárólag kitingTrial-ba került; normál V2mellett nincs régi képaláírásos kerülő.

249felülírja248irányvezérlését: NavigationV2 az egyetlen normál navigátor,
irányított rács,A*,6px-enkénti nyíláspróba és9px teljes kijutás,
bizonyított átjárók topológiai elsőbbsége. Régi helyi gráf csak mozgásmérő.
Támpontvesztéskor különlocal-UUIDrács, ellenőrzött képi elmozdulással;
globális térrel sosem keveredik, támpont visszatéréskor cél-reset (249).
250:800–1600HP-s közeli kisőr friss95%HP mellett szűk harci próba;
harci mozgás után régiV2terv törlése, mért térkép megtartása.

248: szigetfüggetlen MinimapFarmTracker és egyetlen helyi farmcél tulajdonos.
Ilyenkor LocalWorldMap csak akadálykerülő, célcsere/Island2-visszahúzás nélkül.

246: minden élő futás min-user-idle0, explicit felhasználói utasítás.
247: időmérővel takart kritikus HPnál egyetlen0,30s oldalpróba/futás,
fenyegetés és bosspróba nélkül; nem írja át a HP-t vagy gyógyulásállapotot.

245: képszéli csonkolt K-HP nem biztos bossérték; csíksor-nagyítás és
K nélküli kettőspontos ezresalak. Új mért házzseb→kapu célkaranténszabály.

244: közeli keretes csíkmaradék-felismerés, friss numerikus HP elsőbbsége;
400px-es olcsó safeTarget megelőzi a három szigetmakrót. Dustyminimaptámpont
csak legalább0,40narancslefedettségnél. Rövid célzott tesztciklusok.

243: friss LEVEL UP+Damage, közeli aktív kisőrpróba és fenyegetéshiány együtt
lezárja a harci visszakeresést. Timer vagy puszta eltűnés továbbra elégtelen.

239:12 végrehajtott navigációs input/80px nettó haladásőr; csak érvényes,
azonos helyi térképen, egészséges és fenyegetésmentes állapotban. Megálláskor
képi felülvizsgálat kell. Percenkénti, kontextusmegőrző felügyelet aktív;
ez nem képkockánkénti modellnézés. Felhasználói stop a felügyeletet is szünetelteti.
Élő hiba után külön minimap-haladásőr:12input/4pixel, chartváltástól függetlenül (239).
240: külön, farmhűtéstől független nyugati udvarkijárat két mért minimapponttal.
241: tartós, régióhoz kötött hibás távoli célirány kizárása; mért déli pont,
majd keleti felderítés. Közeli harcot nem ír felül, ismert farmcél elsőbbséges.

235:SIGINT/SIGTERMmegszakítás egérfelengedéssel és fókuszvisszaadással.
DOCszintkülönbséghez nyolc egymást követő közeli, sebzésmentes kép kell,
nem a megközelítés teljes időtartama. A sérülő4K+őr helyben támadható.

Új réteg: `VisualOdometry` kalibrált, képrészletekkel ellenőrzött optikai mozgás;
`LocalWorldMap` saját helyi koordináták, bejárt élek, akadályirányok és becsült
ellenfélhelyek. Sebességfüggetlen, képi visszacsatolású oldalirányú kerülő;
bizonytalan ugrásnál külön térképrész. Kétképes relokalizáció: terep+minimap.
Nem kész globális farmútvonaltervező. Teszt és korlátok:228.
236: iránymenti haladás és sebesség, nem puszta kameramozgás; a falnál
oldalcsúszás is sikertelen input lehet. Hét alternatív45°-os kerülőirány.
233: a zöld→narancs visszatérés is irányított gráfkeresést kapott, egyetlen
többcélú kereséssel. A bizonytalan14S/10W/16N makró teljesen kikerült.
238: külön mért DOCfolyosó minimap-waypointokkal és képi hivatkozásokkal.
Nem húzásszám, hanem friss helyzet teljesíti a szakaszt;180s keret és régiókapu.
Kiegészítés230: két minimapsablonhoz mért durva helyzet és különVenom-farmcél;
a minimapirány nem helyettesíti a helyi akadálygráfot. A Settings/pirosXszínfolt
önmagában nem szakítja meg a térképezést friss sajátHPés igazolt játéknézet mellett.
Külön, alapból kikapcsolt `BossKitingTrial`: `--kite-boss`, legfeljebb90s/3ciklus,
17,5–20Kkezdeti cél és friss95% sajátHP. A valódi bossHP-reset megszakítja;
eltűnés nem győzelem. Szimuláció és hipotézis232. Ez nem oldja fel globálisan
a két korábbi bossvereség tiltását.
232 élő próba vereség: feltétlen halálkori cancel, takartHP-nál azonnali
visszavonulás, nyolcképes közeli-fenyegetésmemória és akadálykerülő-felülírás
tiltása szükséges. A próba normál futásban továbbra kikapcsolt.

A program egy 8600+ soros Swift felismerő és állapotgép. Az alábbi régi fejezetek
fejlesztési történetet is tartalmaznak; az Island 4 miatti képszéltiltás elvetett.
A mostani javítás egyetlen összefüggő játéktér-OCR-rel váltja ki az öt hiányos
küldetésszöveg-régiót. Csonkolt potion mellett anti-stone + Deep Mines + 0/1 is
igazolja a kaput. A tárgypanelek szöveges azonosítása megelőzi a harci következtetést;
a SPECIAL ABILITY többé nem enged automatikus Bat Cleaver-felszerelést.
Részletes bizonyítékok: [203-as audit](203-ujrainditas-es-audit.md).
Közeli farmcél megelőzi a koponyanavigációt; ismert vesztes sáv után 120 döntéses
koponyahűtés. A HP-kerekítés a tizedesjegyek számát követi, K-alakból kis
maximumváltozás is ötképes megerősítést kér. [206](206-helyi-farm-elsoseg-es-kerekitesi-kapu.md).
Kis cél-HP-nál külön nagyított csíksor-OCR; observe csak olvassa a tudástárakat,
a végre nem hajtott döntések nem írhatják azokat. [207](207-kisablakos-hp-ocr-es-megfigyelesi-irasvedelem.md).
Mindkét ismert koponyaboss aktív vereséghűtése a távoli koponyaútvonalat is tiltja,
nemcsak a közeli kontaktust. A cél a helyi farm a következő újrapróbáig (208).
Ismert vereségsávnál a régi faljárás is törlődik, hatswipe-os kifelé memória
védi a visszavonulást. Replay külön, csak olvasható navigációs fixture-rel is
futtatható: `--replay-navigation-state` (210).
A replay HP-kezdőállapota is rögzíthető `--replay-player-state` kapcsolóval.
Külön tanultmaximum-mező és futáseredmény-összesítő segíti a HP/perc mérést (213).
Az órás timer + narancs + északnyugati koponya által indított 34 lépéses
16S/6W/12S makró kikerült: nem azonosította egyedileg a kezdőhelyet (215).
A 18,8K-s őr HP-jával indított 12 keleti rámpaswipe szintén kikerült: élőben
falnak vitt, bejáratot nem azonosított. Rövid általános kerülő marad (217).
A ládazónás teleportkivételek is hat sikertelen statikus fázist és 150
jutalommentes döntést igényelnek; narancs biom és régi flag nem helyazonosító (218).
Tartós bossvereség csak friss numerikus kritikus HP-ból vagy YOU DIED-ból
tanulható. Pixeles takarás biztonsági reakciót, nem tartós tiltást ad (219).
Saját HP-nál lokalizált nagyított zöldcsík-OCR, több ezres skálához igazított
eséskonszenzus; nagy boss takarásánál rövid harcmegszakítás. Halál után minden
útvonal előtt friss numerikus90% szükséges (220).
Egyszerre csak egy élő képrögzítő/vezérlő folyamat futhat; nem blokkoló
folyamatzár védi, míg a replay továbbra párhuzamosítható (221).
Külön `VisualRouteNavigator.swift` és `docs/route-graph.json` kezeli a képi
kezdő- és végponttal igazolt éleket; a lokális akadálymemória ettől külön él (222).
Nemcsak explicit próbaindítás, hanem közeli váratlan nagy humanoidkontaktus is
ellenfélmemóriát és kifelé menekülési irányt ad. Friss65% alatti HP-nál
ez a menekülés a normál felderítés elé kerül (223).
A saját HP fehér számai által különvágott zöld darabok szűk HUD-régióban
összeilleszthetők; teljes csíkból nem keletkezhet pusztán emiatt23% (224).
Az útvonalgráf opcionális további végpontjai külön helyi kijáratokat engednek,
nem kell minden részgráfot egyetlen globális célhoz erőltetni (225).
A kinagyított térkép mínusz-nagyítóját külön képi sablon azonosítja; ilyen állapot
nem ad inputot, nem léptet stratégiát, nem tanul HP-t vagy akadályt. Az általános
bosskerülőt is végigvisszük átmeneti takaráskor, a kontaktus nélküli feladott
kerülő pedig120döntéses helyi hűtést kap (226).
`ShopInspector` és `ShopAuditor` külön boltfelügyelet: valódi piros jelzés,
SHOP-azonosítás, zöld/pirosjelzettFree OCR, teljes lista végiggörgetése,
Free→fizetős ajánlat visszaellenőrzés és tartós hűtés. `--shop-only` módban
nincs játékmozgás. A régi, azonnal bezáró felületes Shop-audit törölve (227).

## Történeti architektúra és korábbi döntések

## Visszacsatolási hurok

1. A bot kizárólag a Butcher Hero legnagyobb, látható ablakát rögzíti a macOS ScreenCaptureKit segítségével.
2. Szín- és geometriaalapú komponenskereséssel felismeri a piros ellenséges és a zöld játékos-életerőcsíkokat.
3. A natív Vision OCR külön kis régiókban olvassa a játékos HP-ját, valamint a célpontok szint- és HP-számait. Az időbeli követés pótolja az animáció miatt átmenetileg olvashatatlan számokat.
4. A döntő legfeljebb 150 felismert HP-jú célpontokat értékel. Fát, távolságot, várható
   ütésigényt, szintet és a cél körüli klasztert együtt pontozza; magas játékos-HP mellett
   csak 150 képpontos körben társ nélküli humanoidot próbál ki. A bal oldali, Island 4 mögötti képernyőnegyedet
   elérhetetlen zónaként kizárja.
5. A játékos rögzített képernyőpozíciójához viszonyított irányt swipe-iránnyá alakítja.
   Nyolc játéktérpont közül képenként a leginkább fűszínű, takarástól mentes kezdőpontot
   választja; az alsó fegyversort és a sötét UI-paneleket kerüli.
6. Egy rövid, kitartott swipe után új képet készít; nyílt hurkú hosszú mozgás helyett minden szakasz után újratervez.
   Ha négy közel azonos távolságú megközelítés után sincs haladás, nyolc merőleges,
   célváltástól független swipe-pal követi az akadályt. Második sikertelen ciklusnál
   18 hosszú lépéssel kiszakad a célterülettől. Az átmenetileg eltűnő célpontot alapból három képkockáig
   követi; már sebzett passzív fán a maradék HP-ból hosszabb befejezési időt becsül.
7. Minden elemzést és döntést JSON Lines formában, a fontos képkockákat PNG-ként naplóz. A `replay` mód korábbi képeken input nélkül futtatja újra a teljes felismerő–döntő láncot.
8. A legnagyobb hiteles játékos-HP a `docs/bot-state.json` tartós tudásfájlban marad, így
   az új folyamat a pillanatnyi HP-t a valódi ismert maximumhoz viszonyítja.
9. A HP-OCR 100 alatt a tizedes kijelzés pont előtti egész részét használja. A tiszta
   háromjegyű értéket nem bontja automatikusan 2 jegyű részablakokra; a zöld csík
   tévesen felismert vezető `1`-ét csak tizedes szövegnél kínálja alternatívaként.
   Az előző képkockához képest 60-nál nagyobb lefelé ugrást először elutasítja, mert ez
   gyakran közeli ellenséges szám vagy a játékos fölötti időzítő OCR-szennyezése. Csak
   három egymást követő, egymáshoz közeli alacsony mérés után fogadja el; egy üres OCR-
   kép megszakítja a sorozatot. A normál, 30 körüli harci sebzésre ez nem késleltet.
10. Ha nincs cél a fő képen és a HP legalább 90%, a bot a minimap közepéhez legközelebbi
    sárga játékoskomponenst és ahhoz legközelebbi apró piros pontot keresi. A köztük lévő
    vektor irányítja a felderítést; a vak járőr csak felismerési tartalék.
11. Ha 24 cél nélküli döntésen át lényegében azonos marad a minimap-vektor, a bot nyolc
    merőleges swipe-pal kerítés-/akadálykerülőt végez; a következő esetben oldalt vált.
12. A játékos OCR minden felismert sort együtt pontoz, nem csak az elsőt. Nagy felfelé
    ugrást két közeli magas mérés hitelesít; nagy lefelé ugrást három közeli mérés igazol,
    a zöld csík pedig megvétózhatja, ha továbbra is legalább 65%-osnak látszik.
13. A `play` ciklus felhasználói aktivitásnál továbbra is képet elemez és naplóz, de nem
    hívja meg az állapotos stratégiai döntőt. Így kihagyott input nem fogyaszt célmemóriát,
    kerülőlépést, támadási kivárást vagy veszélyemléket.
14. A célpont-HP felismerő a `K` utótagot ezres rövidítésként bontja ki (`1.22K→1220`).
    Ismert, 300 HP fölötti humanoid normál farmban nem biztonságos; visszavonuláskor az
    utolsó üldözési irány és célmemória törlődik.
15. A cél fölötti keskeny régióból külön pirosszív- és kékfejsze-bizonyíték készül.
    Ez a jutalmat pontozza, míg a türkiz lombarány a passzív testtípust/fenyegetést.
    Közelharcban ugyanazon, már fának bizonyult cél 0,30-as hiszterézist kap. Ugyanazon
    cél HP-/csíkesése a 82 px-es megközelítési küszöbtől függetlenül harckezdetet rögzít.
16. A játékostól jobbra külön jutalom-OCR csak `+N` alakot fogad el. Az esemény 30
    elemzéses memóriát és monoton sorszámot kap; egy sorszám csak egy harcot zárhat le.
17. A taktikai HP-arány a képkockán elfogadott numerikus OCR-t használja elsőként.
    Ha nincs friss, elfogadott szám, a külön naplózott pixelcsík a tartalék; a temporális
    OCR-memória csak mindkettő hiányában marad. A konzervatív minimum elvetve, mert egy
    háttér-UI komponens 306 HP-n 79%-on tartotta a botot. A sebzésemlék 12 döntésig él,
    a regenerációs állapot 85%-ig ragadós, a minimap-vektor pedig HUD-bizonyíték.
18. A játékos-HP parser 999-ig fogad számot, miközben az aktuális tanult maximumhoz
    képesti +60-as jelöltszűrés megmarad. Az összeragadt egész OCR (`2181`) jelöltjeit a
    pixelcsík nem szűri; pixelalapú nagyságrend-választás csak a bizonyított tizedes
    csíkszél-hibánál fut. Az eseménynapló külön tárolja a pixelarányt és a forrást.
19. A játékos közvetlen OCR-régiójában megjelenő `m` és legalább két számjegy külön
    `nearbyRespawnTimer` bizonyíték; az `s` betűt a Vision gyakran 5-nek olvassa.
    Időegységet tartalmazó sor egyáltalán nem ad numerikus HP-jelöltet. Ha egy már sebzett passzív cél csíkja
    eltűnt, ez a jutalom-OCR-től függetlenül lezárja a harci memóriát; a kör csak a cél
    halála után jelenik meg. A maximális HP-/ütésszám-alapú kivárás tartalék marad.
20. A cél csíkja alatti testből külön magenta arány készül. Legalább 0,06-os értéknél
    a 200 HP-s lila rituálé-/portálstruktúra sem biztonságos cél, sem `nearestThreat`;
    ismert normál testeken az arány 0,000, a portálon 0,202.
21. Célváltás előtt három végrehajtott döntéses célzár fut. Azonos HP és testosztály
    nagy képernyő-eltolódásnál is azonos cél lehet; eltérő felvillanó jelölt röviden nem
    írja felül az előző üldözési irányt.
22. A jutalom-OCR-t 40 képig a legutóbbi cél statértéke hitelesíti. Ha az 1-es ikon
    melletti `+1`-et a Vision `+12`-nek ragasztja össze, az ismert célérték 1-re javítja.
23. Magas (legalább 85%-os) numerikus HP-memóriát 20 százalékpontnál nagyobb, friss szám
    nélküli pixelzuhanás csak közeli vörös csík bizonyítékával írhat felül. Így a timerrel
    vagy tereppel széttört teljes csík nem indít hamis menekülést; valódi közeli támadó
    mellett a pixel továbbra is azonnal érvényes.
24. A `play` ciklus a ScreenCaptureKit átmeneti hibáját nem dobja tovább. Számlálja,
    kiírja, fokozatosan 0,75–5 másodpercet vár, majd korlátlanul újrapróbál; siker esetén
    helyreállási eseményt ír és ugyanazzal a stratégiai állapottal folytatja.
25. A főképi akadálykerülő állapota nem célhoz, hanem végrehajtási folyamathoz kötött.
    Felvillanó másik csík nem nullázza; két stagnáló ciklus után a cél ellentett irányú,
    18 döntéses területelhagyás megszakítja a lezárt kerítéshez visszatérő hurkot.
26. A minimap-útvonal a teljes nyolclépéses kerülők számát is megőrzi. Második, azonos
    akadályhoz visszatérő ciklusnál – vagy már elakadt főképi megközelítés után – nem
    ismétel merőleges hurkot, hanem a minimapvektor ellentett irányába hagyja el a területet.
27. A kiszakadást kiváltó világirány 120 tényleges döntéses hűtőlistára kerül. Ugyanabba
    az irányba mutató főképi vagy minimap-cél helyett oldalirányú felderítés fut; kb.
    63 foknál nagyobb irányeltérés új célfolyamatnak számít és feloldja a hűtést.
28. A `sawCriticalHealth` állapotot csak `ocr-current` forrású, számszerű és legalább
    90%-os HP oldhatja fel. Kritikus állapot után memória- vagy pixelalapú magas értéknél
    a döntő helyben vár; friss 85–90%-os OCR-nél még folytatja a visszavonulást.
29. A `nearestThreat` legalább 800 HP-s tagja külön boss-őr. A kezdeti 220 képpontos
    határt az 59. döntés 360-ra emelte.
    Ez a normál célpontszűrésnél korábban fut, törli az üldözési memóriát és közvetlenül
    a fenyegetéssel ellentétes, hosszú swipe-ot ad teljes játékos-HP mellett is.
30. A lezárt világirány oldalirányú kerülője 12 tényleges hűtőswipe-os fázisokra oszlik.
    Minden fázis végén megfordul a merőleges oldal előjele; így a 120 döntéses hűtés nem
    tud egyetlen pályaszélnek feszülni. Más irányú cél a teljes folyamatot továbbra is
    azonnal feloldja.
31. Ha sem főképi cél, sem minimap-vektor nincs, a tartalék mozgás 4/4/8/8/12/12…
    hosszúságú, négy irányba forgó négyzetspirál. Főképi cél elfogadásakor 4-re
    áll vissza. A korábbi 4/4/4/4 járőr 16 döntésenként pontosan bezárta saját útját.
32. A minimap utolsó érvényes vektora három további tényleges döntésig gyorsítótárban
    marad. Egyetlen hiányzó képen így nem vált a döntő spirálra. A spirál állapotát csak
    főképi cél nullázza; minimap-felvillanás nem, mert a villogó két irány különben
    képenként kiolthatná egymást.
33. A közvetlen játékosrégióból frissen elfogadott `ocr-current` HP további 30 százalékpont
    HUD-bizalmat ad. Fal/kapu elfedheti a zöld csíkot, piros cél és minimap-vektor pedig
    egyszerre hiányozhat; az aktuális numerikus HP ilyenkor a képmérettel és OCR-sorral
    65%-ra emeli a normál játékképet. OCR-memória nem kapja meg ezt a bizonyítékot.
34. Legalább 24 tényleges, biztonságos főképi cél nélküli döntés és legalább 90% HP után
    a döntő egyszer megnyitja a jobb oldali, piros jelzésű felszerelésládát. Ezután külön
    inspeckiós állapotban kizárólag vár; ismeretlen menün sem swipe-ot, sem második tapot
    nem küld, amíg a képernyőt dokumentáltan meg nem tanultuk.
35. Az inventory képernyőt az OCR `INVENTORY` sora azonosítja. Első felismerésekor a bot
    egyszer kiválasztja a piros ponttal jelölt zöld fegyverkártyát, utána ismét kizárólag
    vár. A rózsaszín X-et a meglévő geometriai `popupClose` már `(404…476, 387…418)`
    képtartományban felismeri, de a részletkép dokumentálásáig nem zárjuk automatikusan.
36. A Bat Cleaver részletképernyőt a `TRIBUTE` vagy `SPECIAL ABILITY` OCR-sor azonosítja.
    Egyszer megnyomhatja a bizonyítottan ingyenes `EQUIP` gombot, majd statellenőrzésre
    vár. Mivel a modal `DAMAGE PER COPY 50` száma a harci HP-régióra fed, bármely biztos
    `popupClose` jelenléte teljesen letiltja az aktuális HP-jelöltek elfogadását.
37. A sikeres Equip és Stats-mérés után a ládafelderítés lezárt, egyszeri kutatás. Új
    folyamatban a 24 cél nélküli döntés már nem nyitja újra. Nyitva maradt `INVENTORY`
    képernyőn a döntő csak a geometriailag igazolt rózsaszín X-re koppint, majd folytat.
38. A ládafelderítés után tartós célhiánynál a következő egyszeri kutatási állapot a bal
    felső, piros jelzésű boríték. 24 tényleges cél nélküli döntés és legalább 90% HP után
    egyetlen tap nyitja; `mailInspectionMode` alatt minden további döntés passzív várakozás.
39. A Mailbox üresnek bizonyult, ezért a kutatási kapu lezárt. A piros pecsét nem aktív
    értesítés. Új folyamat nem nyitja újra; nyitva maradt képernyőn a közös, biztos
    rózsaszín-X detektor zárja be.
40. Következő célhiányos kutatási kapu a jobb oldali boltikon. 24 tényleges cél nélküli
    döntés és legalább 90% HP után egyetlen tap nyitja; `shopInspectionMode` minden
    további inputot tilt, amíg a boltot vizuálisan nem auditáltuk.
41. A bolt valódi pénzes gemcsomagokat mutatott, ezért kutatása lezárt. Felső X-e miatt
    a pink popup-komponensek keresése 6–68% magasság / 25–95% szélesség tartományra nőtt.
    Így a biztos X egyrészt bezárható, másrészt a bolti számok nem válhatnak harci HP-vá.
42. Piros főképi/minimap-cél hiányában a minimap legközelebbi 5–16 px-es zöld négyzetes
    landmarkja külön navigációs vektort ad. Piros cél elsőbbséges; a landmark ugyanazt
    a stagnálás–kerülő–kiszakadás–irányhűtő láncot használja, nem vakon követi örökké.
43. A 33 elemű, kvantált `sceneFingerprint` csak tényleges stratégiai döntések között
    méri a háttérmozgást. Hat statikus cél nélküli swipe után átlós kiszabadítás indul;
    ismételt kudarcnál az átló forog. A ciklushosszt az 50. döntés négyre rövidíti.
44. A cél-HP OCR-régió 48-ról 76 px-re nőtt, a K nélküli `4.31` tizedes alak is 4310-re
    bővül. Ettől független `bossEvidence` a cél fölötti legalább 100-as statérték (élő
    boss: 500 szív); boss sem farmcél, sem passzív fa. A történeti 220 px-es menekülési
    határt az 59. döntés 360 px-re emelte.
45. A maximális HP futások közötti emelési őre +15-ről +30-ra nőtt. Három 20-as szívfa
    közvetlen `340→360→380→400` és három `+20` képet adott, tehát ez legitim lépcső.
46. Külön dialógus-OCR olvassa az alsó-középső panelt. `Tap to continue` vagy
    `Cursed Girl` bizonyítéknál célzott tap léptet; a pink popup általános ága csak a kép
    jobb 40%-át fogadja el, ezért a lány piros hajdísze nem hamis bezárógomb.
47. Az alacsony HUD-bizalom többé nem állítja le önmagában a felügyelt folyamatot.
    Átvezető/ismeretlen képen a döntő input nélkül vár és tovább rögzít; ezt a Cursed Girl
    kővé válási jelenete és a felhasználó explicit nonstop kérése indokolja.
48. A türkiz Deep Mines-sín távolságnégyzettel súlyozott pixelvektort ad. Távoli farmcél
    helyett elsőbbséges, de a bossőr, visszavonulás és 110 px-en belüli harc megelőzi.
49. A kép felső 10%-ában lévő részleges célcsík nem kerülhet a `safeTargets` listába;
    ezzel a test nélkül látszó, kerítés mögötti 200-as Titan-portál kiesik.
50. A statikus háttérőr vak átlón 12 helyett négy tényleges swipe-ot tölt. Vízszintes
    kerítésnél így legfeljebb nyolc északi próbálkozás után eljut a déli átlókig;
    ezt később az ismert navigációs vektorra merőleges tízlépéses ág egészítette ki,
    majd az 59. döntés annak vak továbbfutása miatt újra négyre rövidítette.
51. A türkiz útvonal rövid felismerési rését hat döntéses iránymemória hidalja át.
    A memória ugyanazt a boss-, visszavonulás- és közeli-harc prioritást tartja be.
52. A türkiz pixel önmagában nem útvonal: legalább 100 px kiterjedésű, 80 pixeles,
    a játékos 175 px-es környezetét érintő összefüggő komponens kell. Ez kizárja a
    lila szikla peremét, a hidat és a szívfa körüli hamis irányt.
53. Statikus navigációnál az első kiszabadítás a kívánt vektorra merőleges. A történeti
    tíz swipe-os ág a Deep Mines kapujánál elérte a kapuszélt, de az 59. döntés szerint
    már minden ág négy swipe után újraértékel; következő alkalommal oldalt vált.
54. Az `1.22K→221` OCR-hiba miatt ismeretlen szintű, 150 fölöttinek olvasott nem-fa
    humanoid nem biztonságos. OCR nélküli széles csík sem választható pusztán a 400 HP-ra.
55. Pontos alsó `CONTINUE` OCR külön jutalomablak-állapot. A bot kizárólag ilyenkor
    koppint `(0,50; 0,80)` pontra; az általános HUD-hiány továbbra is passzív várakozás.
56. A kétfegyverhely-feloldás után a második aktív fegyver automatikusan megjelent.
    A kiváltó ok ismeretlen, ezért a bot nem nyit inventoryt és nem cserél automatikusan.
57. A narancs bányatábor közvetlen `+4` jutalmai legitim `400→…→420` maximumot adtak;
    a meglévő +30-as emelési őr ezeket helyesen elfogadta és tartósította.
58. Az általános jobb oldali pink-X csak 60% alatti HUD-bizalomnál kattintható. Normál
    HUD-ban a narancs sziklaív hamis X-komponenst adott; replayen már nem kap tapot.
59. A navigációs vektorra merőleges tízlépéses statikus kerülő túl sokáig futott vakon:
    a bányatető mellé vitte a karaktert, miközben 1.16K–1.6K ellenfelek jelentek meg.
    Minden statikus kiszabadítás összesen négy swipe-ra rövidült, a 800+ HP/boss
    megelőző távolodási küszöbe pedig 220-ról 360 képpontra nőtt.
60. A bossőr egyetlen képes takarás után elvesztette a veszélyt, a minimap pedig
    visszafordította az 11.4K/765 HP-s csoportba. Az első biztos távolodási vektor hat
    tényleges swipe-ig megmarad. Friss sebzés 95% alatt, illetve új folyamat 55% alatti
    HP-ja előzmény nélkül is visszavonulási/regenerációs módot aktivál.
61. A négyes falmenti ág a zöld, hosszú falú udvarból két oldalváltás után sem jutott
    ki. Ismert navigációs vektornál ezért ismét tíz a felső határ, de már megszakítható:
    HP-/bossőr minden képen előtte fut, 180 px-es biztonságos cél pedig lezárja. Vak
    iránynál változatlanul négy swipe marad.
62. A pixel-fallback 100→95%-os ingadozása két alkalommal hamis sebzésemléket és
    célponttól elfordulást adott, miközben a következő OCR 424/100% volt. Numerikus OCR
    esési küszöbe 2,5 pont marad; a pixeles tartaléké 10 százalékpontra nőtt.
63. A bossmenekülési memória élőben pontosan öt további azonos vektort tartott, de
    utána folytatta a félbehagyott faljárást. Boss vagy visszavonulási mód ezért törli
    a statikus kiszabadítás és minimap-kerülő állapotát; utána csak friss irány indul.
64. Az `1.22K` felirat új képen egyetlen `7`-re csonkolódott. A cél-HP régió felfelé és
    oldalra nőtt; ismeretlen szintű nem-fa 45+ px-es csíkján 20 alatti szám is tiltott
    csonkolás. A `011508-replay` már nem választja közvetlen célnak.
65. A bossmenekülés után ugyanaz a piros minimapirány többször visszavezette a veszélyes
    falrészhez. Bossészlelés most a legutóbbi minimapvektort 120 döntésre lezárja; a
    hatswipe-os memória után azonos javaslatnál oldalirányú hűtő-felderítés indul.
66. Az aktív lezártirány-hűtést a statikus háttérőr hét mozdulat után saját, ellentétes
    faljárással felülírta és újra bossba vitt. `blockedRouteCooldown` alatt ezért új
    statikus kiszabadítás nem indulhat; a hűtő 12-es oldalváltása kezeli az akadályt.
67. A hűtő 12 tisztán déli mozdulata nem vitte le a karaktert a határszikláról, az
    északi oldal bossba ért. A merőleges vektorhoz 0,55 súlyú, lezárt iránnyal ellentétes
    kifelé komponens adódik; így a falról lelépés és a falmenti haladás együtt történik.
68. A délkeleti kifelé-kevert szakasz ténylegesen nyílt terepre jutott, de a hűtő mégis
    oldalt váltott. Tizenkét lépés után mozgó háttérnél a lezárt irány feloldódik és
    friss tervezés következik; csak statikus eredménynél vált oldalt.
69. A 68. döntés első változata csak a 12. kép pillanatnyi statikusságát nézte, ezért
    elfelejtette a szakasz eleji mozgást. Külön `blockedRouteBypassSawMovement` jelző
    gyűjti, történt-e bármelyik lépésnél valódi kameramozgás.
70. A szakaszszintű jelző már feloldotta a hűtést, de az örökölt statikus számláló
    azonnal új faljárást indított. Sikeres hűtőfeloldás a statikus döntésszámlálót is
    nullázza, ezért új helyen hat friss sikertelen próbát kell mérni.
71. Boss után egy félbehagyott nyolclépéses közeli célkerülő újraindult. A boss- és
    visszavonulási ág ezért a `persistentDetour` és `blockedAreaEscape` állapotát is
    törli a statikus/minimap-kerülők mellett; régi célmozgás nem éledhet újra.
72. A nyílt világban megjelent fénylő láda nagy `OPEN` gombját a Vision `NEdU` alakra
    torzította. A bot csak együtt igazolt, mozgó narancssárga gombkomponens és annak
    saját `OPEN`/`NEDU` OCR-je esetén koppint a komponens közepére; tartós gombnál vár,
    majd legfeljebb egy késleltetett újrapróbálást enged.
73. A távoli világláda 40–90 px széles, ezüstfehér testét legalább 250 közeli mintavett
    aranyfénypixel hitelesíti. A minimap régiója kizárt. Biztos jel esetén a láda
    navigációs cél, de boss, friss sebzés és a statikus akadályőr továbbra is elsőbbséges.
74. A láda `REWARDS` képernyője `+10` szívet, `+2` kék fejszét és `+1%` szívet adott.
    Csak pontos `TAP TO CLAIM` OCR enged alsó-középső tappot; a claim után `424→438`
    hiteles maximális HP igazolta a tartós fejlődést.
75. **Elvetve a 217-essel:** az Island 4 perspektivikus zárfalának vélt célok 25% fölé nyúltak. Látható
    `UNLOCKS AT ISLAND 4` OCR-nél a bal 36% kizárt, balra mutató minimap helyett pedig
    a jobb oldali nyílt tér a navigációs szándék.
76. **Történeti helyi akadálymérés:** a zárfalnak hitt kiugró sziklán a tiszta jobb és függőleges swipe statikus maradt.
    Island 4-faljáráskor a tangenshez 0,55 jobbra-kifelé komponens adódik; a
    `015352-play/frame-00016→00030` átlója ténylegesen mozgott.
77. Bossészlelés nem a legutóbbi magas szintű navigációs szándékot hűti, hanem a boss
    közvetlen képi irányát. Határelhagyás, láda vagy küldetésút nem bossútvonal.
78. A játékos ezüst fegyvere és narancs teste hamis távoli láda lett. A ládatest-jelölt
    legalább 120 px-re legyen a játékos képi közepétől; a valódi távoli láda megmaradt,
    a `015645-replay` hamis jelöltje kiesett.
79. Az Island 4 kapu 21–22 px magas ezüst patkóvasalata a 120 px-es őrön kívül is hamis
    láda lett. A test minimum 25 px magas, és legalább hat külső fehér csillogásminta
    kell. Két valódi láda megmaradt; a `020202-replay` kapuja kiesett.
80. A fehér ponyvás szekér 51×34 px-es teste, 449 tág aranymintája és 18 csillogása
    átment a korábbi ládaőrön. A valódi ládákon 5/16, a szekéren 0 szigorú külső sárga
    ragyogásminta volt. Minimum négy ilyen minta kell; `020512-replay` megtartja a
    ládát, `020513-replay` kizárja a szekeret.
81. Az Island 4 felirat nem globális területzár. A bal 36% mögötti célok tiltottak, de
    az elérhető oldali 136 HP-s kaktuszok és 253 HP-s 4-szíves humanoidok farmolhatók.
    A `020635-play` sűrű csoportjánál a 95%-os frisssebzéses menekülés 392 HP-ról
    helyreállt, miközben a tartós maximum 459-re nőtt.
82. A tiszta jobbra Island 4-szándék két hosszú sziklaék-hurkot adott. A korábban
    bizonyított `(0,48; 0,88)` jobbra-le irány most már az első határdöntéstől aktív;
    `021246-replay` régi jobbra döntését `021323-replay` ugyanazon képen átlóra cserélte.
83. A `020635-play/frame-00376` közvetlen `+4` szívvel 463-as teljes HP-t mutatott.
    Az új `021337-play` friss OCR-je és a tartós állapot is 463-at igazol.
84. A normál kaktusz `94.1` HP-jából pontvesztéssel 941 lett, ami a 800-as bossőrt
    aktiválta. Azonos, legalább 8 px-szel rövidülő csíknál a 800–999 jelölt tizedként
    visszaállítható, ha a korábbi HP alá esik; külön felfelé-ugrásőr is készült.
85. A jutalom nélküli egyképes 464 két biztos 463 között tartósállapot-zaj volt. A
    +1/+2 maximum csak két azonos képen vagy jutalomemlékkel menthető; +3 fölött a
    bizonyított lépcsők miatt marad az azonnali elfogadás.
86. A `022045-play` élőben összekapcsolta a védelmi és fejlődési ágakat: valódi 1.16K
    bossoktól hathúzásos menekülés, azonnali jobbra-le Island 4-átló, majd 253 HP-s
    humanoid `+4` jutalma. A tartós maximum 467-re nőtt; a +4-et az őr helyesen
    azonnal elfogadta.
87. A respawnkör ugyanazon képen a zöld csíkot 13%-ra és a 467 OCR-t 7/37-re takarta.
    Pixel+OCR ezért nem automatikusan független. Távoli fenyegetés nélküli pixeles
    esés kétképes; timerrel szennyezett nagy OCR-esés nem gyűjthet megerősítést.
88. A `023210-play` egyszeri 523-as maximumjelöltjét a +30-as plausibility guard
    elutasította, miközben a 471 több mint száz eseményen stabil maradt. A későbbi
    `frame-00140` közvetlen `+4` jutalmát és 475-ös teljes HP-ját viszont azonnal
    elfogadta. A maximumőr így ugyanabban a futásban szűrt zajt és mentett valódi
    fejlődést.
89. A vörös sziklaív vízszintes része öt képen hamis HP-csíkká vált, és a 124-es
    lebegő sebzést cél-HP-ként örökölte. A csík körüli fekete keretből számított
    `barOutlineConfidence` a hamison 0,000, a leggyengébb igazolt valódi csíkon 0,109;
    a 0,06-os célkapu replayen eltávolította a hamisat és megtartotta a valódiakat.
90. A regressziós replay nem része az élő tanulási csatornának: kiinduló
    `bot-state.json` értéket olvashat, de `readOnlyKnowledge` módban semmilyen tartós
    maximumot nem írhat. Ez megakadályozza a tesztsorrend állapotszennyezését.
91. A vörös HP-csík keresési régiója a kép 72%-áról 90%-ára bővült, mert a
    közvetlenül alsó képszélen álló 67.5K boss csíkja 85%-on teljesen kiesett. A
    `barOutlineConfidence` kapu az új régióban is kötelező.
92. A cél-OCR 46 pixellel néz a csík fölé, nyers sorait minden `visibleTargets`
    elemben naplózza, és K-s értéket 1 000 000-ig megtart. Az alsó 82% alatti
    részleges test nem `safeTarget`; a felismerhető 800+ HP viszont bossfenyegetés.
93. Island 4-jellel és narancsszikla-biomban a statikus kiszabadulás négy forgatott
    átlót jár be: bal-hátra, bal-előre, jobb-előre, jobb-hátra. A `025524-play`
    élőben 323→129 px célközeledéssel igazolta, hogy az egyik átló kijuttatott.
94. **Elvetve a 217-essel:** az `UNLOCKS AT ISLAND 4` OCR csak globális HUD-bizonyíték. A stratégiai bal 36%,
    zárfalátló és speciális faljáró most a legalább 16%-os narancs terepmintából
    számított `orangeRockBiomeVisible` feltételt is megköveteli.
95. Halál/kritikus átmenet után a döntő friss numerikus, legalább 90%-os HP-ig vár.
    A `025524-play` 475-ös OCR-je helyesen oldotta fel az állapotot; az ezt követő
    közvetlen +10/+5 és erős +2 fejlődést a maximumőr 492-ig megőrizte.
96. A `030113-play` közvetlen +10/+2/+3 szívjutalmait a maximumőr azonnal elfogadta,
    és 507-ig mentette. A 4,31K/500-as óriásfa felismerése ugyanebben a farmkörben
    megelőzte a következő célközelítést, tehát a hozam nem gyengítette a bossprioritást.
97. A `Target`-képzésből kikerült a bal képszéli guard; ugyanaz a határ csak
    `safeTargets`-szűrő. Ettől az 1.22K részleges páncélos veszély marad, de farmcél
    nem lesz. A 360 pixeles bossküszöb változatlan.
98. A statikus faljáró minden biomban négyfázisú. A korábbi nem-narancs kétmerőleges
    ág L-alakú sátorkerítésben hurkolt; az új replay célpontig jutott.
99. A `030113-play` 573-ig mentette a közvetlen és egymásra fedő szívjutalmakat. A
    pixel-fallback közelharci összeolvadása csak átmeneti védelmi hátrálást okozhat;
    friss numerikus OCR továbbra is azonnal visszaveszi az elsődleges szerepet.
100. A minden biomra kiterjesztett négyátlós faljáró `031754-play` élő futása kijutott,
     farmcélokat talált és 611 maximális HP-ig fejlődött; a replayeredmény így élőben
     is igazolt.
101. Az általános `+N` jutalom-OCR kék fejszénél és piros szívnél is azonos alakú.
     +1/+2 maximumjelöltet ezért a jutalomemlék sem gyorsíthat egyképes mentésre;
     két azonos friss OCR kell. +3-tól a bizonyított lépcsők azonnaliak maradnak.
102. A `+0.5C` OCR-ből a puszta számjegyszűrés hamis +5 jutalmat képzett. Az egész
     jutalom parser minden pontot/vesszőt tartalmazó alakot elutasít; a tizedes
     effektus később külön típusként tanulható meg.
103. A 923 HP-s fa képpozíció alapján egy korábbi 40 HP-s cél memóriáját örökölte.
     A simítás marad, de a tizedes-helyreállítás utáni aktuális 800+ `detectedHP`
     önálló bossbizonyíték; így a veszély nem lehet safeTarget.
104. A `032640-play` közvetlen +20/+3/+4/+4 effektusai 611→642 fejlődést adtak. A
     csoportos jutalmak külön HP-lépcsőként mentek el; a maximumőr a fedés ellenére
     mindet megőrizte.
105. A `033114-play` vizuális +1 kék fejszéjét az OCR +12-re ragasztotta össze.
     Egész jutalommemóriába csak a bizonyított 1/2/3/4/5/10/20 lépcsők kerülnek;
     az ismeretlen érték elutasítása nem akadályozza a friss HP önálló tanulását.
106. A 10-szívfa 182 pixelen két pixellel kiesett a questet megszakító kapuból.
     Megbízható 5/10/20-szívfa 300 pixelen belül, 90%+ saját HP-n kiemelt cél; törli a
     rövid navigációs kerülőket és közvetlen célközelítésre engedi a döntőt.
107. A kiemelés nem törölheti a cél saját stagnálásából indított `persistentDetour`
     állapotot. Teljes replayen ettől nyolclépéses kerülő helyett ismét falnak ment;
     csak a cél előtti régi quest-/hűtő-/általános statikus szándék nullázandó.
108. A nyers bossőr első élő próbája `033954/frame-00014`: külön 1.22K páncélos
     megszakította a 291 HP-s safeTarget közelítését. A teljes 666 HP megmaradt.
109. A kiemelt 10-szívfa ugyanezen futásban a bossmemória után visszavette a prioritást,
     közvetlen +10 és 676 HP lett. A következő statikus cél `persistentDetour` állapota
     nyolc lépésig megmaradt, majd a hosszú kiszakadás is szabályosan aktiválódott.
110. Egy második 174 HP-s, 10-szíves fa közvetlen +10 effektusa után két friss
     `ocr-current` mérés 686 HP-t igazolt. A kiemelt célprioritás ismételhető, ezért
     megtartandó.
111. Az aktív tízlépéses statikus faljárás nem tarthat vakon egy bizonyítottan rossz
     irányt. Három változatlan háttérrel végrehajtott swipe után azonnal a következő
     négyátlós fázis indul; tényleges kameramozgás mellett a hosszú szakasz megmarad.
112. A javított élő build egy újabb kiemelt 10-szívfával 686→696-ra fejlődött. Az
     effektusképen a timerátfedés miatt még nem írta át a maximumot; csak a következő
     friss numerikus OCR tartósított. Ez a bizonyítékkapu megtartandó.
113. Két sikertelen célkerülő után az alacsony hozamú fa HP±20 és testtípus aláírása
     360 döntésre hűtőlistára kerül. Újbóli megjelenése közvetlen üldözés helyett a
     meglévő oldalirányú útvonalhűtést indítja; 5+ szíves kiemelt cél kivétel.
114. Két átfedő +3, egy következő +3 és közvetlen +10 effektus 696→702→705→715
     fejlődést igazolt. Az effektus nélküli, képpel is ellentmondó egyképes 750 nem
     írhatja át a tartós maximumot; a jelenlegi ugrásőr ezt helyesen elutasította.
115. Az egyképes 715→745 zaj pontosan +30 volt, ezért a tág felső korlát mégis
     elmentette. Egyképes maximumemelés csak 3/4/5/10/20 elemi lépcsőn engedett;
     minden más összetett ugrás két egymást követő azonos OCR-t igényel.
116. A 745 visszajavítása után a friss élő kép többször, vizuálisan is 718-at mutatott.
     A megelőző 3-szíves cél 31→3 HP után eltűnt; a +3 végérték biztos, az effektus
     nélküli célhozzárendelés erős.
117. A bossmenekülési memória nem oldható fel pusztán azért, mert út közben olcsó
     farmcél kerül közel. A `040308-play` közben az automata harc mozgás mellett is
     befejezte a 41 HP-s humanoidot és +3-at adott, miközben a bot tovább távolodott.
118. A jutalom nélküli boss-hurok nem tarthat korlátlanul. Öt észlelés után, az Island 4
     zárhatáránál, 90%+ HP-n és értékes szívfa nélkül stratégiai respawn indulhat; a
     bizonyított Meadowlands-visszatérés miatt ez útvonal-rövidítés, nem veszteség.
119. A stratégiai respawnt bármely jutalomsorszám vagy két egymást követő, teljes HP-s
     új maximum megszakítja. A második őr azért kell, mert a közvetlen +3 effektus OCR-je
     a `040308/frame-00184` képen kimaradt, miközben a 721-es fejlődés biztos volt.
120. A `041440-play` két közvetlen +3 effektusa 721→724→727-et adott, de a jutalom-OCR
     nem jelent meg. A két teljes 727-es kép mégis lenullázta a boss-számlálót: a
     maximumalapú megszakítóőr így már élőben is igazolt.
121. A cél HP-jának 40+ pontos felfelé korrekciója két azonos nyers OCR után új
     célazonosságként elfogadható. Ez megőrzi az egyképes zajőrét, de kijavítja a
     képszéli appcím-1 után ismételten tiszta 291-et. A statérték bizonyított halmazos.
122. A statikus akadálykerülés négy relatív átló után közvetlen ellenirányt is próbál.
     Ha ez kiszakítja a karaktert, az eredeti navigációs vektort rögtön átadjuk a
     120 döntéses útvonalhűtőnek. Így az új akadálynál oldalirányú-kifelé kerülés
     következik, nem a sikeres mozdulat mechanikus visszafordítása.
123. Elérhetetlen cél hűtésekor a hozzá vezető piros minimapjelet csak hasonló helyi
     háttérnél némítjuk. A cél HP/test aláírásához elmentjük a 33 elemű ujjlenyomatot;
     legfeljebb 44 L1-eltérésnél spirálfelderítés fut, nagyobb eltérés új megközelítési
     oldalnak számít és újra engedi a célt.
124. A stratégiai respawn `sawDamage` jelzője csak történeti bizonyíték. Helyben várni
     kizárólag a rövid `recentDamageFrames` időablak alatt szabad; utána a legutóbbi
     bossirányt kell tovább tartani. Ezzel az első élő próbán talált korlátlan várás
     megszűnik anélkül, hogy a normál visszavonulás visszavenné a vezérlést.
125. A `045414-play` közvetlen +20 jutalma és tiszta 747 OCR-je új hiteles maximum.
     A tartós maximumőr helyesen azonnal elfogadta a bizonyított elemi +20 lépcsőt.
126. A zöld +1 kékfejsze-effektus nem minden esetben kezelhető puszta alapstatisztikaként:
     a `044329→045414` képsorban a zöld kártya 6→7-re váltott. A kártyaszám és a lebegő
     statikon külön mezőként értelmezendő; a pontos fegyverazonosság még mérendő.
127. A bossészlelés és a stratégiai respawn célkapuja szándékosan eltér. A lezárt
     Island 4-fal bal 36%-ában álló bossot veszélyként meg kell tartani, de felé
     szándékosan indulni tilos. Aktiválás előtt kizárjuk; aktív mód közben felismerve
     megszakítjuk a módot és a bizonyított kifelé átlóval újratervezünk.
128. A tap nélküli `You found 1/57 chests` külön közelségi kollekció bizonyítéka.
     Nem kezeljük `OPEN`/`CLAIM` modalnak és nem küldünk rá inputot; a normál mozgás
     folytatódik.
129. Az ismeretlen szintű humanoid merev 150-es kapuja erőfüggő kiegészítést kapott.
     700+ megtanult maximumnál, 98%+ aktuális HP-n, izoláltan és bossbizonyíték nélkül
     250 HP-ig próbacél lehet. A K-/nyers bossőr és a frisssebzéses visszavonulás
     változatlanul elsőbbséges. **Történeti, elvetve a 130. döntéssel.**
130. A `050827/frame-00058` a 192-nek látszó cél HP-ját 1927-re állította helyre és
     bossnak minősítette. A 151–250-es lazítást teljesen visszavontuk: ismeretlen
     szintű humanoidnál a K-csonkolási bizonyíték erősebb a magas játékos-HP-nél.
131. Ismeretlen szintű, nem-fa cél legalább 45 px széles csíkján minden 100 alatti
     OCR-HP tiltott. A `051233` 92-es olvasata ugyanazon 1,927K elit csonkolt vége;
     az ismert 1-es szintű, 67 HP-s fenyő a regresszióban továbbra is farmcél.
     Az egyképes 253-as bossjel-zajt külön mérjük, de bizonyíték nélkül nem gyengítjük
     a bossőrt.
132. A cél nyers statikon-OCR-je `levelOCRNumbers` néven naplózott. Háromjegyű
     statikon csak akkor bossjel, ha ugyanaz a szám nem szerepel a cél HP-régiójában;
     így a szomszéd 253 HP-ja nem válik 500-as ikonpótlékká. A mínusszal kezdődő
     cél-OCR lebegő sebzés, ezért nem HP. A 4.31K/500, 1.22K és 923 regressziók
     változatlanul bossmenekülést adnak.
133. Az ismert szintű, folytonos alacsony cél HP-jának 1–2 jegyű toldaléka egyszeri
     nagy OCR-ként nem bossjel (`253→2537`), amíg a megjelenített HP jogosan ragad.
     Ismeretlen szintű `192→1927` nem kap ilyen felmentést. A `nearestThreat` a
     360 px-en belüli legközelebbi bosst választja a normál célok előtt; így a
     `032640/frame-00058` 923-as bossát nem takarja el a közelebbi 5-ös OCR-cél.
134. A statikus kiszabadítás fázishibáit külön számláljuk; csak 44 fölötti képi
     eltérés vagy fázison belül igazolt kameramozgás törli. Hat sikertelen Island 4-
     fázis után a legutóbbi fal-jobb oldali támadó iránya stratégiai respawnt indít.
     A `054307-replay` 103. döntésénél aktiválta és nem kezdett új faljáró ciklust.
135. `h`/`m`/`s` időegységet tartalmazó OCR-sor cél-HP-ként is tiltott. A
     `054356/frame-00144` `24k 3m` sora egy 20h 13m időzítő torzulása volt, nem
     243K boss. A külön tiszta 253 megmarad; K-s boss időegység nélkül regressziózott.
136. Független boss-statikon alsó küszöbe 400, mert közvetlenül 500/501 bizonyított,
     míg a timer statikon-ROI-ban 202-t adott. A `054840/frame-00060` már normál
     határátló, az 501 statikon és az 1.22K/923 nyers HP továbbra is menekülés.
137. A független boss-statikon csak 400–699 között érvényes, és sűrű csoportban két
     azonos, 800 alatti simított HP konszenzusa felülírja annak 1–2 jegyű összeragadt
     alakját. A `055506-replay` így kiszűrte az `1253/2534` és `2531/8021/*253`
     hamis bossjeleket a valódi 500/501 tartalék ikon és 800+ nyers HP gyengítése nélkül.
138. A jobb képszéltől 12 pixelen belül végződő célcsík részleges: hosszát és HP-ját
     nem bizonyítja a látható darab. Közvetlen farmcél nem lehet, de fenyegetésként
     megmarad. A `055128/frame-00234` 18 pixeles OCR nélküli csíkja ezért többé nem
     indít jobbra tartó célmegközelítést.
139. A 400–699-es független statikontartomány elvetve: élő zajértékei 410, 419, 505
     és 594. Csak a bizonyított pontos 500/501 marad önálló statikon-bossjel. A nyers
     és simított 800+ HP-őr független, ezért az általános bossbiztonság nem gyengül.
140. A `2531` első képes helyreállításához két, 150 pixelen belüli, ±3 HP-n belül
     egyező normál társ kell, és csak a lezárt Island 4 védett bal faloldalán érvényes.
     Ha a memória már 253-at tart, ugyanott egyedül is kiszűrhető annak 1–2 jegyű
     toldaléka. A fal farmelérhetetlensége miatt egyik ág sem indíthat téves támadást.
141. Lezárt, narancssziklás Island 4-en az ismeretlen szintű, 100 alatti humanoid
     csíkszélességtől függetlenül tiltott. A `060446` 92-es elitjének csíkját a jobb
     oldali HUD 19 pixelre takarta, ezért a geometriai rövidség nem biztonsági jel.
142. Island 4 elérhető jobb oldalán a 90–199 HP, ismeretlen szint, 0,03 alatti
     szív-/fejszeikon és nem-fa test együtt a dokumentált 1,927K elit helyi csonkolási
     aláírása. Bossként számít, így öt eredménytelen kör után respawnforrás lehet.
143. A helyi 92/192 elit bossjeléhez a lezárt Island 4 HUD elég; az orange biomjel
     kamerafüggő és elvetve. Stratégiai megközelítésnél hat, legalább 6 pixeles javulás
     nélküli lépés ötös függőleges oldalkerülést indít, majd friss célmérés következik.
144. A kite-oló elit 124–137 pixeles platójának áttörésére a stratégiai közelítés
     165 pixelen belül 1,10, kívül 0,72 másodperces swipe. Ez csak respawnmódban él;
     95 pixelen belül/sebzésnél a helyben váró harci ág változatlan.
145. A stagnáló respawn-oldalkerülés függőleges előjele ciklusonként vált. Az első
     lefelé, a második felfelé kerül, miközben az x-komponens a boss felé marad.
     Új mód elején az előjel alaphelyzetbe áll; ugyanaz az akadályoldal nem ismétlődik.
146. A zöld Island 4-kapunézet 92/192-es járőrénél a cél–képközép-távolság nem
     kameramozgás-mérő. Ha közvetlen közelítés és két oldalkerülés mellett is teljes
     HP marad, a respawn-üldözés helyett nyolc abszolút irány következik, irányonként
     hat hosszú swipe-pal. Közelség vagy sebzés azonnal harci kivárásra vált.
147. A nyolcirányú és hosszú átlós kapukísérlet lezárt, mert egyik kijárati vektor
     sem oldotta fel a zsebet. A bizonyított Settings/Unstuck az elsődleges mentés:
     menünyitás, egy Unstuck-tap, majd 30 inputmentes döntési ciklus a teleport és
     119→747 medencegyógyulás befejezésére. Hat statikus fázis ugyanezt indítja.
148. Az Unstucknak többperces időzára van; ezért a tap után nem szabad vakon sikert
     feltételezni. A Settings-X eltűnése vagy 90% alá eső HUD igazolja az átmenetet,
     amely után 30 inputmentes döntés következik. Öt képen át megmaradó X időzár:
     biztos Settings-X, majd 900 tényleges döntéses újrapróbálási hűtés. A régi, nyitott
     menü mögött mozgásra visszatérő változat elvetve.
149. A kameramozgás nem azonos a fejlődéssel. 150 tényleges jutalom nélküli döntés,
     Island 4 HUD, balra-zárt minimapirány és cél-/quest-/ládahiány együtt külön,
     legfeljebb 120 döntéses kifelé-oldalra területelhagyást indít. Négy statikus
     oldalváltás megszakítja, új prioritás azonnal felülírja, saját hűtése 360 döntés.
150. Hat teljesen sikertelen statikus Island 4-fázis Unstuck-kapuja a narancs biomjel
     helyett elfogadhat célhiány + erősen balra mutató minimap bizonyítékot is. Ez a
     biomdetektor élő kimaradását kezeli; bármely közbeni kameramozgás továbbra is
     nullázza a fázisokat, az Unstuck HUD-visszacsatolása pedig változatlan.
151. Az Unstuck kontrollált halál/újraéledés, nem pusztán kamera-teleport. A
     `072159/frame-00088` explicit `YOU DIED`, majd 134→717→747 medencegyógyulás.
     Ez megerősíti a harminc inputmentes ciklust; az átmeneti HP nem normál sebzés,
     a visszatérés után a 747 maximum és hét fegyver megmaradt.
152. A jutalomhiányos hosszú kiszakadás minimap-elfordulásos lezárása után 80 tényleges
     döntésig növekvő szabad felderítés fut, mert az első új irány élőben egy kerítés
     mögötti 499 HP-s célhoz vezetett. Biztos cél/quest/láda megszakítja; boss és
     sebzés a korábbi őrök miatt mindig megelőzi. Statikus abortnál rövidebb, 40-es ág.
153. Legalább 150 tényleges jutalom nélküli döntés és Island 4 HUD mellett a 44 fölötti
     háttérkülönbség és a faljárás közbeni kameramozgás sem nullázza a sikertelen
     statikus fázisokat. A `073131` híd–sátor zsebében két ujjlenyomat váltakozott,
     miközben jutalom és tényleges területelhagyás nem történt. Ebben a szűk módban
     csak új jutalom törli a bizonyítékot; hat fázis után Unstuck indul.
154. A jobb oldali 90–199 HP-s helyi Island 4-kapuőr azonnali Unstuck-azonosítója nem
     követeli az orange biomjel hiányát. A biomjel kameraállás; a fal elérhető oldalát
     az `x >= width*0,36` kapu, az ismeretlen szint, bossEvidence, ikonhiány és nem-fa
     aláírás együtt védi. A `074055/frame-00300` ezért közvetlen mentési kép.
155. A legutóbb igazolt, legfeljebb 300 pixeles szívfa háromdöntéses célmemóriája a
     türkiz quest-sínnel szemben is él. A `074813/frame-00204` egyetlen detektálási
     rés miatt dobta el a még látható 174 HP-s, +10 fát. A quest csak a rövid memória
     lejárta után törölhet; boss/sebzés továbbra is korábbi prioritás.
156. Az Analyzer tartós maximumőre által elfogadott új maximum ugyanúgy progress-reset,
     mint az OCR-es jutalomszekvencia. A `074813` 747→768
     lépcsőjén a látható +20 OCR-je kimaradt, ezért a futó hosszú mód tévesen maradt
     aktív. A maximumigazolás most nullázza a döntésszámlálót és minden drought-ágat.
157. Megkezdett, cél nélküli Island 4-kiszabadításnál már az első sikertelen fázistól
     megőrizzük a bizonyítékot a kis kamera-/karaktercsúszással szemben. Cooldownos
     Unstuck után így a teljes relatív iránykör továbbfut, ahelyett hogy minden második
     fázisnál újrakezdene. A fal eltűnése, cél vagy valódi progresszió továbbra is töröl.
158. Az Unstuck sikerének elsődleges jele a Settings-X eltűnése. A `075542/frame-00452`
     `YOU DIED` képe mellett a HUD-biztonság tévesen 100% maradt, de az X már eltűnt.
     A `081017/frame-00108→00112` valódi cooldownján az X megmaradt és az `01:45`
     számláló csökkent. Az állapotgép mindkét jelet külön kezeli.
159. Sikeres Unstuck után a spawn minimapja ugyanahhoz a zárt piros célhoz húzhat vissza.
     A 30 inputmentes gyógyulási ciklus lezárásakor ezért 120 döntéses növekvő
     négyzetspirál indul, amely figyelmen kívül hagyja a minimapjelet. Biztonságos
     cél, quest vagy láda megszakítja; a jutalomhiány-számláló nem nullázódik.
160. Boss által félbeszakított aktív célkerülő nem számít sikertelen kerülőciklusnak.
     A bossőr eggyel visszalépteti a hibaszámlálót, de megőrzi az oldalváltó jelet;
     így a következő próbán ténylegesen az ellenoldal fut le, nem azonnali kiszakadás.
161. A sikeres Unstuck helyzetfolytonosságot megszakító teleport. A gyógyulási várakozás
     végén minden régi statikus, minimapos, célkerülő és blokkoltútvonal-memória törlődik,
     és csak utána indul a 120 döntéses helyi spirál.
162. Tartós HP-maximumot csak a jelenlegi képen frissen szereplő OCR-jelölt igazolhat.
     A képközi HP-memória továbbra is simítja az életbecslést, de nem lehet egy
     többképes maximummegerősítés második mintája.
163. A központi 174 HP-s szívfa elérhetősége megközelítési oldalfüggő. A lila zóna
     felőli délkeleti íven 208→166→127 pixelre közvetlenül zárható volt, miközben a
     korábbi oldal 284/285 pixelen platózott. A zónakör ezért hasznos útvonal-váltás,
     nem puszta elveszett felderítési idő.
164. A Bat Cleaver-példányt adó 499 HP-s humanoid külön, csík bal felső sarkánál levő
     élénkzöld fegyverkártya-ikonnal azonosítható. A biztonságos engedmény csak 600+
     max-HP, 150 pixelen belüli, izolált és 45–65 pixeles teljes csík mellett él;
     távoli kerítésen túli példányt továbbra sem üldözünk.
165. Az Unstuck utáni 120-as helyi mód abszolút elsőbbséget kap a jutalomhiányos
     Island 4-területelhagyással szemben. A teleport törli a teljes drought-állapotot,
     és aktív szabad felderítés alatt új drought- vagy statikus kiszabadítási ág sem
     indulhat. Valódi cél, quest, láda és bossbiztonság továbbra is elsőbbséget kap.
166. A zöld landmark értéke hozamfüggő. Ha 150 döntés óta nincs progressz, piros
     minimapcél, quest-sín, láda vagy látható farmcél, a landmark 160 döntésre elveszti
     navigációs elsőbbségét a növekvő szabad spirállal szemben; 360 döntéses közös
     cooldown gátolja az azonnali újraindítást.
167. A pontos 499 HP-s, legalább 0,02 zöld fegyverkártya-bizonyítékú és teljes
     csíkos hordozó 270 pixelig felderítő farmcél lehet, ha legalább 15%-ra beljebb
     került a képszéltől. A közeli 150-es kapu megmarad; a korábbi 281–349 pixeles
     kerítésnézet továbbra is tiltott, az elakadást a normál kétkerülős célőr kezeli.
168. Az Island 4 jobb oldali `90...199` helyi elitcsonkolás csak zöld fegyverkártya-
     bizonyíték nélkül boss. Legalább 0,006 zöld jel kizárja ezt az egy bossforrást,
     mert a 499-es hordozó élőben 199-re csonkolódott; a többi nyers/bossikonos őr
     változatlan marad.
169. A kép bal 14%-ában és 67–72% magasságában lévő vörös csík rögzített `2x Reward`
     HUD-panel, nem világcél. A Target létrehozása előtt kizárandó, hogy se farmként,
     se `nearestThreat`-ként, se bossmemória-forrásként ne befolyásolja a döntőt.
170. A zöld fegyverkártyával igazolt 499 HP-s hordozó jobb oldali kerítéskerülőjét
     a torony–hordó sarok tizenkét swipe-on át teljesen blokkolta; a cél járőrözése
     nem kameramozgás. A bizonyítottan sarokig járható bal oldalon tizenkét merőleges
     swipe fut, majd cél-láthatóságtól függetlenül tizenkét rögzített beforduló swipe.
     Boss, sebzés és visszavonulás továbbra is korábban fut.
171. A +3 maximumnövekedés nem kaphat egyképes gyorsutat. A 778→781 OCR-zaj másodszor
     is egyetlen friss képből lett téves tartós maximum; ezért +1/+2/+3 esetén két
     egymást követő azonos friss OCR kötelező. Az egyképes elfogadás csak
     +4/+5/+10/+20 lépcsőknél marad.
172. Hat teljes statikus kiszabadítási fázis és látható Island 4 HUD mellett az
     Unstuck nem függhet narancsszikla-biomtól vagy balra mutató minimaptól. A lila
     barlang sín–szikla–csontív zsebében tizenegy fázis maradt mozdulatlan a régi
     kapu miatt. Célhiány, 90%+ HP, cooldownhiány és kiemeltfa-hiány elegendő;
     veszély- és visszavonulási őrök továbbra is korábban futnak.
173. Történeti, a 176. döntés által felülírt változat: a 499 HP-s zöld
     fegyverhordozó élő útvonala nem kétszakaszos L, hanem
     háromszakaszos U: tizenkét bal, tizenkét felfelé és tizenkét jobbra swipe.
     A `101003-play` az első két szakaszt fizikailag igazolta, majd megmutatta, hogy
     a harmadik nélkül a minimap a Deep Mines 1.92K/7.15K őreihez fordul. A rögzített
     út minden ágát továbbra is megelőzi a boss-, sérülés- és visszavonulási őr.
174. A hatfázisú Unstuck-kapu új tereptárgykombináción, a görbe kerítés–sátor–őrtorony
     zsebében is jogosan futott. A recovery alatt egy képen látható 352 HP OCR-hibája
     nem írhatja felül az inputtilalmat: a folyamat a teljes 778-as friss képig vár,
     majd 120 döntéses védett helyi felderítést indít.
175. A védett szabad mód továbbra sem indít teljes statikus faljárást, de nem lehet
     vak a hosszú spirálszár falnak ütközésére. Három változatlan, végrehajtott swipe
     után helyi 90 fokos fordulat és 4–12 lépéses oldalkitérés történik, miközben a
     védett idő és a minimaptilalom megmarad.
176. A hordozó 12–12–12 U-útja túlfut: a sarok 7–8 bal swipe után elérhető, a
     negyedik felfelé swipe-nál pedig az 1.22K-s őr teljes fenyegetéssé válik.
     A rögzített út ezért 8 bal → 3 fel → 8 jobb. Ez 36-ról 19 swipe-ra rövidít,
     és a visszatérést az őr aggrója előtt kezdi.
177. A 176. döntés történeti és élőben felülírt: a `104751-play` szerint három
     felfelé lépés után a jobbra visszatérés még a függőleges palánknak ütközik.
     A bal szakasz marad nyolc, az északi szakasz nyolcra nő. A pontos 1.22K-s,
     250–360 pixeles nyugati őrnél csak teljes HP-n és friss sebzés nélkül fut
     jobbra-felfelé a folyosóban; közelség, sebzés vagy erősebb boss továbbra is
     az általános menekülést indítja. Az OCR ugyanezt az őrt `122000`-ként adja;
     ezt csak az aktív hordozóút és legalább 0,04 fejszeikon-bizonyíték mellett
     kezeljük a helyi 1.22K-s aláírásként. Ugyanez a kapu a nyolc jobbra visszatérő
     lépést is védi, mert az közvetlenül az őrtől távolodik; a rögzített út végén a
     normál bossőr automatikusan visszakapja az elsőbbséget.
178. A `104751-play` feldolgozását nem szabad a kerítéspróba első kudarcánál lezárni.
     A 861–877. esemény később közvetlen Bat Cleaver `9→10`, `Damage 450→500`
     jutalmat adott. A részút kudarca és a futás végső progressionje külön tény;
     teljes napló- és képaudit kötelező.
179. A rendszer-idle mérés a bot saját CGEventjeit is emberi inputként látta, ezért
     minden swipe után téves várakozás keletkezett. A vezérlő megőrzi a szintetikus
     input előtti idle-időt, és csak addig folytatja, amíg nem érkezett frissebb,
     rövidebb nyers órával igazolt valódi felhasználói input.
180. A 800+ HP nem önmagában harci kimenetel. Külön kapcsolható bosskutatási mód
     778 saját HP és 500 fegyversebzés mellett 800–8000 HP-sávokat próbál egyszer,
     más ellenfelektől izolálva és támadási távolságban oldalkite-tal. 45% saját HP
     alatt a normál visszavonulás kötelező; alapmódban a régi bossőr változatlan.
181. Az `OPEN QUESTS` tartós külső betöltést indíthat. Egy beragadt `Loading...`
     után sem X, Escape, sem AX Cancel nem működött; a folyamat újraindítása jogi
     Continue képernyőre vitt. Ezért küldetéskapcsoló UI automatikusan csak watchdog,
     biztos visszaút és az esetleges jogi jóváhagyás külön kezelése után használható.
182. Fegyverválasztásnál a kijelzett DPS-t támadástípusonként kell számolni. A két
     Cutting fegyver ugyanazt a 92-es Cut alapstatot használja, de saját Damage és
     cooldown tartozik hozzájuk. Bat10 + Steel14 pontosan 693,3, kerekítve 693 DPS.
183. Tele inventorynál az Equip nem cserélhet automatikusan: meg kell várni a
     `SELECT SLOT TO EQUIP` állapotot, majd explicit a gyengébb helyet választani.
     Így a Savage Fang cserélődött, a Bat Cleaver megmaradt; visszacsatolt statpanel
     igazolta a `517→693` eredményt.
184. A stat-info panel a tartós fejlődés forrásait is megnevezi (`Enemy`, `Secret
     Chest`, `Base`). A jutalommodellt ezért nem csak képi +N effektusból, hanem
     időszakos inventory-auditból is konzisztencia-ellenőrizni kell.
185. Az 1.22K-s páncélos élő, kontrollált próbája győzelemmel zárult: 778-ról csak
     kb. 751-ig esett a saját HP, majd teljesen regenerálódott, a cél pedig Savage
     Fang `1→2`, Damage `8→16` jutalmat adott. Ezt a sávot a 693 DPS buildnél nem
     szabad többé pusztán a cél HP-ja miatt elutasítani.
186. Ezresre kerekített boss-HP-nál a rövid harc köztes felirata nem feltétlenül
     változik. Ölésbizonyítékként az entitás eltűnése, a helyén induló cooldownkör
     és a közvetlen jutalom együtt erősebb, mint a köztes OCR-szám.
187. A medencés `418→584` gyógyulás közben megjelent egyszeri OCR `841` nem
     maximumnövekedés. A maximumőr csak egymást követő, friss numerikus mintákat
     fogadhat el; a memóriából tartott 778 és a gyógyuló aktuális HP nem keverhető.
188. A minimap lila, kb. 9×9 pixeles ikonja külön `specialLandmarkDirection`: a
     Titan-oltárhoz vezet. Piros cél és általános zöld landmark nem írhatja felül,
     amíg az ikon távol van és a célzott felderítés tart.
189. A lila ikon pulzálása egyképes felismerési rést okoz. Öt döntéses külön memória
     hidalja át; a Titan `0/7` feladatbuborékának felismerése azonnal törli, mert az
     oltár elérése már bizonyított.
190. A Titan-feladatbuborék külön OCR-régiót és HUD-bizonyítékot kapott. Amíg a
     buborék takarja a játékos HP-ját, az OCR-jéből képzett `7il0`/70 nem használható;
     a legutóbbi hiteles HP marad, és a botnak el kell tudnia mozogni az oltártól.
191. A Titan-feladat élő felismerése 600 tényleges döntéses oltárhűtést indít. Ez
     alatt a pulzáló lila ikont nem szabad új úticélként visszavenni; az ismét látható
     feladatbuborék a hűtést megerősíti.
192. **Elvetve a 217-essel:** aktív 0/7 gemkeresésnél az erősen balra mutató piros minimapirány és a látható
     `UNLOCKS AT ISLAND 4` együtt bizonyított zárfal-aláírás. A piros cél helyett
     növekvő szabad felderítés fut, de valódi képi ellenfél vagy jutalom felülírhatja.
193. A narancsszikla-biome kameranézettől villoghat. Tizenkét döntéses frissességi
     memória simítja a Dusty Gulch területazonosságát; ez ma a stratégiai respawn
     tiltását védi, nem egy feltételezett zárhatár kifelé vezető irányát.
194. Aktív kontrollált bosspróba nem választhat minden képen új `nearestThreat` célt.
     A kezdő HP-sávhoz normalizált szám- és OCR-aláírással ragaszkodik; más HP-sávú
     boss taszító veszély, nem átvehető cél.
195. Kontrollált próbában öt, 3,5 pixelen belül stagnáló távolság után hétlépéses
     oldalkerülő indul. A közvetlen megközelítést csak ezután próbáljuk újra, az
     oldalt következő ciklusban váltva.
196. A Titan-buborék függőlegesen mozog, ezért `/7` nem lehet kötelező felismerési
     feltétel. A `Titan/power` + `gem` + `collect/unleash` mondatszerkezet önmagában
     biztos állapot; az OCR-ROI a kép 29%-áig ér lefelé.
197. Aktív oltárhűtésben a lila minimapirány nem eldobandó, hanem megfordítandó.
     Az ellenirányt hat döntéses kijárati memória tartja; csak az ikon eltűnése után
     tér vissza a szabad gemfelderítés.
198. A 197. döntés korlátlan lezárása történeti: a lila ikon távoli iránytűként
     megmarad. Az aktív ellenirány legfeljebb 28 végrehajtott swipe-ot kap; utána az
     oltárhűtés marad, de a normál cél- és gemfelderítés visszatér.
199. A 28-as kijárati keret csak a Titan-hűtés 0→600 átmenetén tölthető. Ugyanazon
     aktív hűtés alatt újra felvillanó feladatbuborék HUD-bizonyíték marad, de nem
     indíthat második kijárati menetet.
200. `K` utótagú cél-HP-ban a Vision kettősponttal is olvashatja a tizedespontot.
     A normalizálás ezért vessző és kettőspont esetén is pontot használ: `4:31K`
     pontosan 4310. A `131225-replay` így a korábbi 431000/7500 ingadozás helyett
     a 4.31K-s óriásfát a saját 4310-es kontrollált sávjában indította.
201. Aktív kontrollált bosspróbában a nagy pixeles HP-esés nem kaphat távoli,
     kétképes megerősítést csak azért, mert a boss csíkja közelharcban röviden
     kiesett. A próba ténye önálló fenyegetésbizonyíték; a 33%-os esés azonnal
     sebzésemléket és visszavonulást indít.
202. Boss-burst után OCR-memória nem igazol regenerációt. A visszavonulás csak
     friss numerikus, legalább 85%-os HP-n oldható. Ugyanazon boss csökkenő HP-ja
     test-/statikon-, irány- és közelségi egyezéssel megtarthatja a célazonosságot.
203. Kontrollált boss és játékos között álló, közelebbi, azonos iránykúpú objektív
     struktúra egyszeri hétlépéses tangenciális kerülőt indít. Ezzel a 200 HP-s
     Titan-objektum nem nyelheti el korlátlanul a közvetlen bossközelítést.
204. Normál HUD-os aktív bosspróbában a kritikus pixeles mérés + hiányzó friss HP
     nem helyben várás. A tárolt bossiránnyal ellentétes-tangenciális swipe fut;
     HUD-hiányos valódi halál/átvezető továbbra is inputmentes marad.
205. Ha a Deep Mines-sín végén álló `1.92K`/`7.15K` csoport felé a közvetlen és
     mindkét oldalváltott közelítés is stagnál, a helyzet zárt kapu. Hatszáz
     végrehajtott döntésig el kell nyomni az ugyanoda vezető quest-sínt, kontrollált
     bosspróbát és stratégiai respawnt, miközben a bot eltávolodik.
206. Aktív bosspróba laza OCR-utótagos célazonossága csak saját bossbizonyítékot
     hordozó vagy legalább 800 kijelzett HP-jú aktuális célra alkalmazható. Ezzel
     közeli 1–15 HP-s normál cél nem válhat hamis `1920→2` bossfolytatássá.
207. Az 1–3 pontos maximumemelkedéshez öt egymást követő friss numerikus OCR-kép
     kell. A `778→779→779→779→778` sor Vision-zaj, ezért nem írható tartós állapotba;
     a hiteles maximum e történeti mérésben 778 maradt. A későbbi, külön jutalommal
     bizonyított Dusty Gulch – 2 növekedések után előbb 802, a későbbi 10-szíves
     kaktuszgyőzelem után pedig az aktuális tartós maximum 812.
208. Az `anti-stone potion` szövegpár külön Deep Mines-feladatoverlay. Jelenlétében
     a HP OCR teljesen tiltott, mert a `0/1` 1 HP-t, egy másik szövegtöredék 824-et
     adott teljes csík mellett. Az overlay külön HUD-bizonyíték marad.
209. Ha a bossjelölt konkrét HP-ja `max(250, kezdő boss-HP / 8)` alatt van, a laza
     OCR-utótagos azonosság akkor sem használható, ha szomszédos ROI-átlógás miatt
     a cél pillanatnyilag bossEvidence-et kap. A valódi csökkenést a szigorú közeli
     harci azonossági ág kezeli.
210. Deep Mines-zárás két teljes oldalkerülő után is indítható, ha a cél 300 px-nél
     távolabb kerül és az `anti-stone potion 0/1` alsó táborbuboréka visszatér.
211. A kontrollált bossvonalban újra megjelenő objektív struktúra legfeljebb három,
     váltott oldalú, kilencképes tangenciális kerülőt kaphat. Az egyszeri próbát a
     közvetlen megközelítés élőben visszavezette a 200-as Titan-objektumba.
212. Változatlan kontrollált bossminimum, 140 px-en belüli struktúra és kizárólag
     pixeles 55% alatti HP együtt takarási aláírás. A stratégia az utolsó hiteles
     arányt használja; friss numerikus esés vagy valódi bossprogresszió felülírja.
213. Tervezett struktúrakerülő közben a boss képi eltűnése nem válthat a régi
     bossirányú visszakeresésre. Előbb a teljes tangenciális láb fut le; utána a
     célmemória igazolt objektumkerülésnél nyolc, normál esetben három kép.
214. A Titan- és Deep Mines-kapuhűtés külön `navigation-state.json` falióra-
     lejáratot kap. Élő újraindítás a hátralévő időt folytatja; replay teljesen
     írás- és olvasásmentes. Így a kódjavítás nem válik ismételt oltárjárattá.
215. A 15–29-re csonkolt cél kanonikus 1220 HP lehet, de csak 45+ px csík,
     0,15+ fejszeikon, saját bossEvidence és `122` OCR-számjegyaláírás együtt.
     Aktív próbában a test/irány rövid OCR-kimaradást áthidal; általános 22 nem.
216. **Történeti köztes döntés:** a globális `UNLOCKS AT ISLAND 4` HUD nem zárhat
     ki önmagában piros minimapcélt.
     Az élő piros vektor megelőzi a Titan-kijárati memóriát; csak a bizonyított
     Deep Mines-kapuhűtés vagy a helyszíni narancsszikla-fal igazolhat kerülést.
217. **Aktuális, a 216-ost felülíró döntés:** a `frame-00242` alapján az
     `UNLOCKS AT ISLAND 4` egy fegyverhely-felirat,
     ezért még helyszíni narancssziklával együtt sem földrajzi bizonyíték. A mező
     neve `island4WeaponSlotLockVisible`, és minden térbeli döntésből kikerült.
218. A Dusty Gulch – 2 piros vektorát jutalomhiány miatt sem szabad fixen kifelé
     fordítani. Csak képi statikusság, általános faljárás és konkrét cél-aláírásos
     hűtés állíthat meg egy útvonalat.
219. Dusty Gulch narancssziklás képi bizonyítéka alatt az öt boss-találkozás utáni
     stratégiai respawn nem indulhat. A +4 farm hozama elsőbbséget élvez a
     Meadowlandsra visszavivő, büntetésmentes rövidítéssel szemben.
220. A Dusty Gulch területjel 8% narancs mintaarányt és 12 döntéses memóriát kap,
     mert a belső zöld oázisfolt különben egyetlen képen visszakapcsolná a 67.5K
     bossra irányuló stratégiai respawnt.
221. Dusty Gulch narancsszikla-memóriája alatt minden harmadik, fejlődés nélküli
     bosskontaktus 120 döntéses védett szabad felderítést indít. Már aktív ablakot
     nem tölthet újra, mert az önfenntartóvá tenné a kerülést. Ez megelőzi a
     visszahúzó piros minimapvektort, de nem tiltja le az új, 800–8000 HP-s sávok
     egyszeri kontrollált próbáját. A mód általános neve
     `protectedFreeExploreFrames`; nem feltételez Island 4-zárat.
222. A kontrollált próba nem normalizálhat tetszőleges, 8K fölötti pont nélküli
     K-alakot ismételt /100 osztással. A `114K` élőben 11.4K volt, nem 1140; a
     `272K` értéke pedig ismeretlen. Nagy alak csak veszélyőr, amíg biztosabb OCR
     nem érkezik. Kivétel a széles, fejszeikonos, `122/1122` aláírású ismert
     páncélos, amely szűken 1220-ra kanonizálható.
223. Ugyanazon cél előző 1000+ HP-ja és vezető ponttal/kettősponttal kezdődő,
     1000 alatti K-OCR-je esetén az előző ezres rész visszailleszthető, ha az
     eredmény 300 HP-n belül marad. Ezzel `1220→.22K/:22K` nem válik 220-ra,
     miközben az explicit `2.18K` valódi sebzés továbbra is elfogadható.
224. Az Unstuck utáni általános védett helyi felderítés 120-ról 24 döntésre rövidül.
     A teleport közvetlen tárgyainak elhagyásához marad rövid spirál, de utána a
     piros minimapcél ismét elsőbbséget kap. A Dusty Gulch három progressz nélküli
     bosskontaktusára adott, külön 120-as védelem nem változik.
225. Többcélos távoli bossközelítésnél a stagnálást a próba eddigi legjobb
     távolságához kell mérni, nem az előző képen véletlenül kiválasztott csoporttaghoz.
     Csak legalább 8 px-es új rekord bizonyít közeledést. Három, 220 px fölött
     eredménytelen oldalláb után falmenti bejáratkeresés indul; a távoli csoporton
     látható idegen sebzés nem számít saját harci progressznek.
226. A tartós maximum közvetlen `802→812` ugrása és a két friss, kb. ötperces
     cooldownkör valódi progressz. A botállapot 812-re frissül; a környező 765 HP-s,
     10-szíves kaktusz a +10 jutalom legerősebb képi forrása.
227. A 120-as Dusty-védelem aktív állapotban nem tölthető újra újabb bossészleléssel.
     A `150906-play` 485–620. döntése között saját kitérései közben legalább négy
     bossmenekülés történt, és a régi újratöltés miatt az ablak 136 döntés után is
     futott. A számláló csak lejárt/inaktív állapotból indulhat újra.
228. **Történeti köztes döntés:** a kontrollált próbaplatform explicit tizedes +
     `K` OCR esetén először 15K-ig engedett egyszeri mérést. A pont nélküli `114K`
     továbbra sem kanonizálható; az explicit
     `11.4K` igen. Magas próbánál a csökkenő, de százra végződő HP-t nem szabad a
     régi alacsony-sávos /100 javítással 111-re vagy 104-re osztani.
229. Nyolcezer HP fölötti, 0,25+ faaláírású kontrollált cél 100 px-en belül nem
     oldalkite-ol: helyben vár, hogy az automata fegyverek megszakítás nélkül
     sebezzenek. A `153504-play` így 11.4K→10.1K-t adott saját sebzés nélkül.
230. Ugyanebben az állapotban legfeljebb negyvennyolc képi célvesztés alatt is
     helyben kell maradni. Az első 12-es korlát a `163416` futásban 7,96K-nál
     megszakította a még zajló támadást; az irányos keresés regenerálni hagyná a célt.
231. A pontos +30 maximumnövekedés külön jutalomkaput kap. A 868 vizuális alakot
     a Vision ismételten 898-nak olvasta, ezért puszta időbeli ismétlődés nem elég:
     közvetlen 30-as jutalom-OCR vagy előre ismert 30-as statikon és öt aktuális,
     egyező HP-kép szükséges. A hibás tartós 898-at 868-ra kell visszaállítani.
232. Az explicit tizedes K-alak kontrollált felső plafonja 20K. A `154552-play`
     piros minimapútja 18.8K-s, 25-ös statikonú páncélost talált; pont nélküli
     alak továbbra sem engedhető. A statikus növényi helyben tartás csak erős
     faaláírásra érvényes, a 18.8K-s cél normál kite-ot és sérüléskaput kap.
233. Az explicit tizedes K-kapu ugyanazokat a jeleket fogadja el, mint a HP-parser:
     pontot, kettőspontot és vesszőt. A `155228-play` helyesen 18800-ra elemezte
     az `18:8K` alakot, de a csak pontra épülő második kapu még elutasította.
234. **Történeti köztes döntés:** a minimap körén kívüli piros fejsze/kalapácsot
     külön ellenfél-irányjelzőnek tekintettük. Az első 0,78–1,45 sugaras kaput
     később 1,10–1,45-re szűkítettük; a 237/242. döntés további korrekciója az aktuális.
235. **Felülírva a 242. döntéssel:** a peremfegyverjel először megelőzte a lila
     oltárt és a türkiz sínt. Élőben világ-UI statikont is befogott, ezért már nem
     abszolút prioritás; a belső piros pont, a sín és a stabil lila hely előtte áll.
236. A `155618-play` közvetlen +10 szíveffektusa és az utána ismétlődő 878
     a hiteles maximumot 868-ról 878-ra emelte. A 898/929 alak jutalom nélküli
     OCR-zaj, és nem írhatja felül a tartós állapotot.
237. A peremdetektor valódi komponense 1,27–1,31 térképsugárra, egy belső piros
     pont 0,91-re esett; ezért a geometriai alsó kapu 1,10. A komponens ettől még
     világban rajzolt statikon lehet, így a körön belüli piros pont elsőbbséget kap.
238. A teljes 908-as játékoscsíkot 806-nak olvasó OCR ellen 97%-os pixeles
     telítettségi őr készült. A teljes csík ilyen eltérésnél felülírja a fantom-
     numerikus sebzést, ezért nem indul 90%-os téves menekülés.
239. Teljes HP-n legfeljebb három társ mellett a saját maximumnál nem erősebb
     humanoid csoportcél lehet. A három 672-es lovag 908→938 fejlődése igazolta,
     hogy a korábbi kötelező izoláció túl óvatos.
240. Belső piros térképpont mellett nagy cél csak akkor indít kontrollált próbát,
     ha képi iránya legalább 0,55 skalárszorzattal egyezik a térképvektorral.
     Így a jelzett 11,4K-s kaktusz vállalható, az ellenkező oldali 1,28K-s nem térít el.
241. A passzív 8K+ kaktusz helyben tartási memóriája 12-ről 48 takart képre nőtt.
     A `163416` futásban a csíkdetektor eltűnt, miközben a mentett kép 7,96K-ig
     igazolta a további sebzést.
242. Navigációs prioritás: világláda, belső piros ellenfélpont, türkiz küldetésút,
     stabil lila hely, bizonytalan külső piros komponens, majd egyéb landmark.
     A lila irány valódi megfordulásához három egyező kép kell.
243. A jelenlegi tartós maximum 953; a dokumentált friss sor 878→893→908→938→953.
244. A passzív 8K+ kaktusz takarási memóriája 120 kép, a kontrollált időkerete 180
     döntés. A helyben tartás alatt a statikus háttérszámláló nullázandó.
245. Igazolt közeli nagy szívkaktusznál a kizárólag pixeles, friss numerikus esés
     nélküli saját HP-zuhanás átfedési zaj. Más cél és numerikus esés nem kap vétót.
246. Közel ellentétes piros minimapirány csak három egymást követő, egyező képen
     cserélheti le a stabil irányt; ezzel megszűnik a több piros pont közötti inga.
247. A `PersistentObstacleMap` képi csomópontonként nyolc irány kísérletét,
     blokkolását és sikerét tárolja a `docs/world-map.json` fájlban. Két nettó
     blokkolás után legfeljebb 90 fokos, jobb pontszámú kerülőirányt választ.
248. A magaslati különleges ládazóna szemantikai állapota egyszeri: felderítés és
     ládanyitás után új jel nélkül nem visszatérő farmhely. A 984 HP-s állapot több
     képi/OCR-megerősítéssel az új tartós maximum.
249. A lokális kerülő nyolc tényleges swipe-ig zárolt. Négy blokkolás és nulla
     siker után az irány tartós zsákutca; későbbi bizonyított helyváltozás feloldja.
250. Látható láda után az `OPEN`, `TAP TO CLAIM`, `CONTINUE` vagy közeli jutalom
     az adott képi csomópont irányát begyűjtött egyszeri célként tárolja.
251. A 18,8K-s sáv 984-es maximumon tartós sikertelen bosspróba. Új mérés csak
     legalább 20%-os hiteles fejlődés után engedett; addig területelhagyás fut.
252. Az Unstuck előtt a Settings saját X-ének megjelenése kötelező, a sikerét csak
     ugyanennek az X-nek az eltűnése igazolja. A 80%-os ál-HUD nem siker; az öt
     képen át megmaradó panel bezárandó.
253. Belső piros minimapponttal legalább 0,55 irányegyezésű bossjelölt kontrollált
     megközelítési kapuja 520 pixel; térkép-igazolás nélkül 420 marad. A vesztes
     bossmemória ugyanezen tágabb körön belül már távolról eltérít.
254. Visszavonulásban lejárt sebzési memória, nulla közeli fenyegetés és nyolc
     egymást követő legalább 97%-os pixeles HP-kép feloldhatja a bosspróbát akkor
     is, ha az időzítők takarják a numerikus OCR-t. Ez új maximumot nem igazol.
255. A `174731-play` teljes csík fölötti vizuális 999-e a 984-hez képest pontos
     +15, ismert jutalomlépcső; ez az új tartós maximum.
256. A 11,4K-s, 300-szíves kaktusz első teljes győzelme 999→1299 maximális HP-t
     adott; a játék ezt egy tizedesre kerekítve `1.3K`-ként rajzolja.
257. A saját K-formátum közelítő érték. Ha 60 HP-n belüli, jutalommal bizonyított
     pontos maximum létezik, a parser azt tartja meg; a kijelzés nem írhatja 1300-ra.
258. Eltűnt, sebzett kaktusznál a játékos alatti kis zöld körív és középső,
     óra nélküli perces timer együtt azonnali harczár. Távoli 8 órás kör nem elég.
259. Teljes HP-n legfeljebb 5K-s, 360 pixelen belüli, biztos bossjelölt a belső
     minimapponttal való irányegyezés nélkül is kontrollált próbát kap. Nagyobb
     sávnál megmarad a térkép-azonosítás.
260. Változatlan kontrollált boss-HP mellett az első nagy pixeles saját HP-esés
     csak átfedési gyanú. Sebzés nélkül elvesztett boss után nyolcképes pixeles
     türelem fut; friss numerikus HP ezt nem használja.
261. A `180420-play` új ládájának biztos nyitás–átvétel sora az adott hely és irány
     `collectedChestDirections` állapotát tartósan lezárja, nem a teljes biomot.
262. A narancssziklás DOC-őrnél a már elért 112 pixeles vetület, legalább tizennégy
     változatlan mérés és kölcsönös sebzéshiány helyi magassági szintkülönbség.
     Ez nem harci vereség és nem írhat tartós vesztes boss-sávot.
263. Szintkülönbségnél a topologikus térkép a boss felőli helyi irányt lezárja,
     a döntő pedig közvetlen ellenirány helyett falmenti, enyhén kifelé tartó
     bejáratkeresést végez.
264. Hetvenkét eredménytelen magassági faljáró lépés az Unstuck számára hat
     statikus fázissal egyenértékű. A mozgó ellenfél és timer nem álcázhatja
     tovább a ténylegesen azonos házsarkot.
265. Explicit `4.4K`/`4:4K`/`4,4K` OCR felülírja az előző hibás egyjegyű HP-
     simítást és kanonikusan 4400. Ugyanez az ismert `18.8K` alaknál 18800.
266. Kifosztott különleges láda iránya végleg lezárt egyszeri cél; visszaszámlálós
     erőforráshely csak az időzár végéig lezárt, utána ismét farmolható.
267. Bizonyítottan sebzett, 112 pixelen belüli boss a karakter másik oldalára
     kerülve is ugyanaz a cél. A közeli HP-csökkenés felülírja az irányfélsíkot.
268. Sebzett közeli boss teljes csíktakarásánál negyven álló képig tartsd az
     automata kombót, ha a numerikus saját HP legalább 45%; a jutalom- és halálőr
     továbbra is azonnal megszakíthatja.
269. Nagy szívkaktusz biztos ölését friss közeli respawn-kör vagy kontextusban
     +250…+380 közötti explicit K-s saját növekedés lezárhatja. A 300-as ismert
     szívjutalmat ekkor a tartós maximumra kell vezetni.
270. A játékos két tizedesjegyes `1.64K`/`1.94K` kijelzését 1640/1940-ként kell
     olvasni; aktív kaktuszpróbában a `1164K`/`1194K` vezető csík-artefaktum is
     ugyanilyen kanonikus érték.
271. A Deep Mines türkiz sínjének tengelyét mindig a havas, negatív Y irányba
     tájold; az U-kanyar két látható ága nem váltogathatja az előre/hátra irányt.
272. Csökkenő boss-HP csak jelenléti és hiány-aláírás egyezésével tarthatja meg a
     célzárat. Nem-szíves 7,15K-s cél nem válthat 1,92K-s, 20-szíves fára.
273. A karakterközeli küldetésbuborék OCR-je a középső és bal felső területen
     kívül külön bal és jobb oldalsó területet is olvas. Replayen a Deep Mines
     potion- és a Titan gemfeladat egymástól függetlenül felismerhető.
274. A helymemória három szemantikát különít el: végleg begyűjtött egyszeri ládairány,
     időzár után újratermelődő farmhely, valamint progresszfüggően visszatérhető
     küldetéshely. Egyik állapot sem tilthatja le automatikusan a teljes biomot.
275. A magaslat külön topológiai réteg. Statikus háttér és kölcsönös sebzéshiány
     esetén a vetületben közeli cél iránya lezárható, de más rámpa-/hídirányok
     felderítése folytatódik; Unstuck csak a helyi iránykészlet kimerítése után jön.
276. Aktív Deep Mines-kapuhűtés törli az előző peremcél-sín kerülőt és a lila
     kapujelet is. Nyers quest-vektor nem kerülheti meg a lezárt út effektív hűtését.
277. Oldalsó, 18–19,5K közötti magaslati őrnél a próba már induláskor tíz döntéses,
     céloldali-felfelé tartó pallóívet rögzít; a boss rövid képelhagyása nem szakítja meg.
278. Látható, befejezetlen Deep Mines potion-feladat és aktív kapuhűtés esetén
     azonnali déli területelhagyás írja felül a távoli HP-csíkokat. Biztos `1/1`
     állapotban a hűtés nem blokkolhatja a kapu újbóli megközelítését.
279. Az egyszeri láda végleges tudása nem maradhat a 400 csomópontos geometriai
     LRU-ban. Külön `semantic-map.json` őrzi; védett csomópont nem eviktálható.
280. Új ládajutalom a lokális `collectedChestDirections` mellett a tartós
     szemantikus aláírást is frissíti. Visszatéréskor a két irányhalmaz uniója dönt.
281. Narancssziklás, cél nélküli magaslaton három külön statikus kiszabadítási
     fázis után engedélyezett az Unstuck; normál terepen a küszöb továbbra is hat.
282. Az Unstuck újrapróba-ideje abszolút `unstuckRetryUntil` lejáratként megmarad
     az újraindítások között. Sikertelen panel, aktív gombtimer és sikeres teleport
     egyaránt menti; fejlesztési újraindítás nem nullázhatja a játék saját időzárát.
283. A Settings Unstuck gombjának `mm:ss` OCR-je a gomb szűk területéről pontos
     másodpercet ad; a tartós lejárat az olvasott érték plusz öt másodperc.
284. Zárt Deep Mines-kapu után 36 döntéses, buborékfüggetlen déli kijutási állapot
     tiltja le a piros/lila/türkiz visszacélzást. Egyetlen déli swipe nem területelhagyás.
285. Két bizonyított blokkolás után a tartós akadálytérkép mind a hét másik irányt
     pontozza; konkáv zsebben 135–180 fokos eltávolodás is lehet a helyes út.
286. Számláló nélküli, még látható Settings panel csak tizennégy kép után jelent
     sikertelen Unstuckot. Az öt képes határ kizárólag olvasható időzárnál marad.
287. Az egyszeri magaslati ág befejezése nem harci vereség. Külön, HP-sávhoz kötött
     tartós útvonalhűtés zárja le, ezért erőnövekedés önmagában nem indítja újra.
288. A kimerített magaslati útvonal utolsó lába húsz délkeleti swipe; ez kétszer
     bizonyítottan visszaért a zöld területre. A felső réteg felé forduló régi láb törölve.
289. Aktív magaslati hűtésnél, zöld terepen az északnyugati piros minimapirány
     elnémul, mert a `202322-play` ezt ugyanahhoz az egyszeri zsebhez kötötte.
290. A globális koppintás ablakaktiválás után 160 ms türelmi időt kap. Ez kizárólag
     a ritka UI-koppintást érinti; a folyamatos swipe vezérlés tempója változatlan.
291. A teljes térképen látott régiókaput rögzített topológiai élként modellezzük:
     zöld határ → negyven nyugat–délnyugati → tizenkét nyugati lépés. Az általános
     képaláírásos akadályadapter ezt a bizonyított folyosót nem írhatja felül.
292. A Dusty-belépést 68% narancsszikla-arány igazolja. A határ 10–35%-os
     narancsszíne még nem belépés; a kapuoverlay viszont közvetlen bizonyíték.
293. Az egyszeri magaslati ládaállapot nem kapcsolható a 18,8K-s boss HP-sávjához.
     Külön tartós `exhaustedOneShotHighlandBranch` jelző őrzi a kifosztott platót;
     a bossok erő- és útvonalmodellje ettől független.
294. A kifosztott városi plató gyors helyosztályozása legalább 75% narancsszikla,
     középső órás időzítő, biztonságos lokális cél hiánya és külön
     `pendingOneShotHighlandExit` szándék. Ez utóbbit biztos OPEN vagy platólezárás
     állítja, sikeres/sikertelen Unstuck pedig törli. Kifosztottság önmagában nem elég.
295. Az Unstuckot csak a felső réteg biztos jelkapcsolatánál használjuk. A
     `214244-play` normál zöld szintjén nem ismételjük meg, így a ritka gomb
     játékoldali hűtése megmarad valódi csapdahelyzetre.
296. A 18,8K-s rétegút első közvetlen északnyugati lába bizonyítottan blokkolt.
     A javított út délnyugat → nyugat → észak sorrendben kerüli a városi sziklát;
     a `220041-play` ezt már a DOC szekeres kapujáig igazolta.
297. A `214244` ellenpélda miatt a tág orange-biomszűrő önmagában nem rövidítheti
     háromra a statikus Unstuck-küszöböt. Három fázis csak függő, biztos
     egyszeri-plató kijutásnál; minden más terep hatfázisos marad.
298. A kibontott nagy térkép türkiz négyzete topológiai kapupont. Magassági
     ellenfélhez előbb ezt kell elérni, nem a vetületben közvetlen piros jelet.
299. A 18,8K-s próba első rétegútja délnyugat → nyugat → észak. A
     `220041-play` ezzel találta meg a külső ház/létra oldalt és 167 pixelre
     közelítette a 4,4K-s udvarőrt; a korábbi keleti szakasz törölve.
300. A DOC kapu második szintű mikrotopológiája szekér/fakerítés: balra a szekér
     körül, északra a kerítés végénél, majd jobbra az udvarba. A szakasz cél
     eltűnésekor sem szakítható meg.
301. Aktív 4,4K-s próbában a széles csík `4:4`/`4,4` csonkolása kanonikus 4400,
     még K nélkül is. Nem válthat 4 HP-s normál célra és nem indíthat bossvesztést.
302. A `PersistentObstacleMap` nem adaptálhat `Kontrollált bosspróba`,
     `DOC kapupont` vagy `18,8K-s magaslati őr` döntést. Ezek saját visszacsatolt
     állapotgéppel vagy konkrét nagy térképi bizonyítékkal rendelkeznek.
303. A nagy térképen messze északon látott arany láda új egyszeri helyszínjelölt.
     Nem örökli a régi plató lezárását; külön OPEN/CLAIM és helyaláírás szükséges.
304. A tartósan kifosztott magaslati ágon a közeli hosszú visszatöltési kör erős
     rétegjel. Legalább 75% narancssziklával együtt friss OPEN nélkül is azonnali
     Unstuckot indíthat; a puszta középső timer-OCR továbbra is csak függő
     OPEN-utáni kijutási szándékkal fogadható el.
305. A Dusty-bejárat fix útvonala 26 döntés: 14 WSW és 12 W. Az 52 döntésre
     nyújtott változat élőben negyven lépésig ugyanazt a határfalat nyomta, ezért
     az útvonalhosszt nem lehet a helyi kameraeltérés miatt önkényesen duplázni.
306. Ha a 26 döntéses bejárat után a játékos még a zöld–narancs függőleges fal
     jobb oldalán marad, a nagy térkép sárga délnyugati átjárójele külön gráfélt
     indít: 12 tiszta dél, majd 12 tiszta nyugat. A diagonális falnak ütközés nem
     tekinthető falmenti mozgásnak.
307. A `You found N/57 chests` számlálónövekedés külön világ-ládaprogresszió,
     akkor is, ha nincs OPEN/CLAIM gomb. Az N növekedését tartósan meg kell őrizni,
     és a helyet egyszeri, újra nem célzandó mellékágként kell lezárni.
308. A konkrét narancs határgráf futása alatt az általános statikussági és
     akadálykerülő ágak nem térhetnek vissza előbb. A dedikált route maradékának
     nullának kell lennie, mielőtt a generikus hatfázisos kiszabadítás indulhat.
309. A biztos 2/57 és a kifosztott magaslati ág együtt tartósan némítja a zöldről
     északnyugatra vezető régi piros minimapirányt. Ez helyhozam-zár, nem időzített
     bossvereség; az alternatív északkeleti zöld cél és más ládák elsőbbséget kapnak.
310. A konkrét északkeleti zöld ellenfél-útvonal ugyanúgy védett az általános
     akadálytérképtől és statikussági őrtől, mint a DOC/Titan bosskapuútvonalak.
311. A 4,31K-s szívfánál 340 pixel alatti legjobb távolság, nulla sebzés és 20%
     alatti narancsfedettség külön Titan-fa kapugráfot indít: észak a jobb oldali
     völgyben, majd nyugat a középső szikla felső vége mögött.
312. A `magic anti-stone potion 0/1` buborékkal együtt visszatérő, két oldalról
     nulla sebzéses havas célok zárt Deep Mines-rétegen vannak. A potion hiányát
     tárgy-/küldetéskapuként, nem bossvereségként kell tárolni.
313. A frissen felismert Titan `0/7` állapotból felépített kijárat explicit
     gráfszándék. Távoli piros minimapjel nem tilthatja le; csak a korábban futó
     veszély-, cél-, láda- és Deep Mines-őrök szakíthatják meg.
314. Titan-buborékot új folyamatban is élként kell felismerni akkor is, ha a
     tartós oltárhűtés aktív. Az újrafegyverzéshez legalább tizenkét buborék
     nélküli kép kell, hogy az OCR-pulzálás ne indítson végtelen kijáratot.
315. A magaslati ládaág miatt némított piros irányhoz tartozó alternatív zöld
     útvonal csak cél és aktív Titan-kijárat nélkül indulhat. Látható 4,31K-s fa
     vagy friss 0/7 kijárat mellett a helyi, visszacsatolt állapot az erősebb.
316. Egy folyamatban már látott világcél után nem indulhat újra az egyszeri
     56 lépéses zöld területi belépő pusztán azért, mert a cél néhány képre
     eltűnt. A területi belépő helyett a cél-/jutalomlezárást kell kivárni.
317. Stabil, nagy saját maximumugrás nem fér át a kis +30-as jutalomőrön.
     Külön ötképes K-OCR konszenzus kell biztos saját csíkkal, +800 és 1,6×
     felső korláttal; tizenkét köztes OCR-hibát tolerál, popupot nem.
318. A 4,31K/500 fa legyőzése újraértékeli a bosskockázatot: az 1.97K saját
     maximum ellenére 133 pixeles valós kontaktus után eltűnt és 2.47K lett a
     saját maximum. Nulla sebzéses korábbi próbája topológiai hiba volt.

## Miért Swift

- A bot harmadik féltől származó futtatókörnyezet nélkül használhatja a natív ScreenCaptureKit és CoreGraphics API-kat.
- A kitartott swipe az iPad-kompatibilitási réteg folytonos, pixeles scroll-eseményeiből áll; az „Érintési alternatívák” ezt a mutató helyéről induló érintéses húzássá alakítja.
- A képfelismerés helyben történik, hálózati szolgáltatás nélkül.

## Háttérben futó vezérlés

- A tiszta háttérmegoldás az elsődleges fejlesztési cél, de még nem bizonyított: a játék PID-jének küldött egér- és scroll-eseményeket az iPad-kompatibilitási réteg figyelmen kívül hagyta.
- A működő `--foreground` mód egy swipe idejére aktiválja a játékot és a kart húzza, majd visszaállítja az egér előző helyét és az előző alkalmazás fókuszát.
- Az alapértelmezett együttműködő korlát 1,5 másodperc; a jelenlegi felügyelt kísérlet
  0,6 másodpercet használ. Aktív géphasználatnál a bot képet elemez és vár, de nem veszi
  át az egeret. A küszöb a folyamatos haladás/fókuszkímélés mérhető kompromisszuma.
- A program fókuszmentes játékmódot nem állít működőnek, és `play` módban explicit `--foreground` kapcsolót kér.

## Biztonsági korlátok

- A `observe` mód soha nem küld bemenetet.
- A `play` mindig explicit másodperc-korlátot kap; alapértéke 15 másodperc.
- Ha a játékmenet HUD-ja tartósan nem ismerhető fel, a bot input nélkül vár és folytatja
  a képrögzítést; explicit felhasználói stop nélkül nem fejezi be magától a felügyelt
  folyamatot. Menün, reklámban vagy ismeretlen képen továbbra sem kattint vakon.
- Kivétel csak külön megtanított állapot lehet: ilyen az értékelési ablak jobb oldali
  rózsaszín X-e és az OCR-rel igazolt `Tap to continue` küldetéspárbeszéd.
- Az input kizárólag a játékablak lenti virtuális karjának környékére indul.
- Azonnali kézi vészleállítás: `Ctrl+C`.

## Felügyelt hosszú futás

- Az egyórás folyamat technikai időkorlát, nem a kutatás vége: explicit felhasználói
  leállítás hiányában a felügyelő újraindítja.
- A konzolt rövid időközönként, a mentett képet és strukturált eseményeket
  ellenőrzőpontokon vizsgáljuk. A szabályokat a `07-folyamatos-felugyelet.md` rögzíti.
- Ismétlődő azonos döntés, valószínűtlen HP-ugrás, nem csökkenő céltávolság, ismeretlen
  képernyő vagy váratlan folyamatvég javítási ciklust indít.

## Következő fejlesztési rétegek

- életerőcsík-szélesség időbeli követése a sebzés és a harci eredmény mérésére;
- zsákmány-, pénz- és szintfelismerés Vision OCR-rel;
- a már működő lokális akadálytérkép fölé szemantikus útvonalgráf: ismeretlen,
  láda látható, láda begyűjtve, egyszeri helyszín lezárva;
- ellenfelenkénti kockázat/hozam modell;
- a statikononként mért `+szint` hozam alapján célpontpontozás és farmkör;
- automatikus halál/újraéledés-detektor és külön eseménytípus a naplóban;
- bolt- és felszerelésfejlesztések külön, csak biztos képernyőállapotban futó döntője.

## Island 2 küldetésállapot és jelzett UI

- Narancssziklás képi állapotban a lila portálvektor tiltott; a normál piros
  minimapvektor is a lila jel előtt áll a navigációs sorrendben.
- A Mailbox és a Shop külön, csak olvasási UI-állapotgép. A Mailbox első tapja
  csak az ikont váltja, a második nyitja a panelt. Mindkét panel kizárólag a
  felismert X-szel zárható; vásárlás, reklám és felszerelésváltás tilos.
- Sikeres ellenőrzés után 2572 döntéses, körülbelül félórás hűtés fut.
- A 4,4K-s kontrollált próba legkisebb HP-ja a kanonikus cél-HP-ból készül, így
  a csonkolt `4` nem lehet hamis bossgyőzelem.
- A `nudge` futásmód mért `dx/dy/steps/duration` swipe-sorozatot ad, miközben
  megőrzi a kurzor- és fókuszvisszaállítást.

## 3,38K-s HP OCR-védelme

- Az Analyzer induláskor a tartós `maximumDisplayedHP` értéket az utolsó hiteles
  saját HP-ként is felveszi. Egyetlen hibás első kép nem nullázhatja az előzményt.
- Ezres ismert maximumnál a csak nagyon kis számot adó, ugyanakkor váratlan
  betűket tartalmazó és K-/idősuffix nélküli OCR-t elvetjük. A pusztán számos
  kritikus HP-t nem vetjük el.
- Pixeles HP-esést passzív növényi takarásnak veszünk, ha a numerikus memória
  legalább 85%-os és 170 pixelen belül nincs nem-növényi támadó. Őrkontaktus
  vagy friss numerikus esés továbbra is azonnali harci jel.
- A K-alak `2169K`/`2143K` csíkél-artefaktumából 2,69K/2,43K készülhet:
  a második helyre ragadt plusz 1-et is javítjuk, és a háromjegyű kompakt
  K-alak már nem csak 1-gyel kezdődhet.
- A tartós maximumhoz 40–60 HP-val közeli, de egyértelműen magasabb K-kijelzést
  nem pattintjuk automatikusan vissza a régi maximumra. A meglévő többképes
  maximumőr erősíti meg, így a stabil 3,43K tanulható, az egyképes zaj nem.
# 2026-08-30 – Koponyazónán belüli elérhetőség

Aktív Island 2-koponyánál a stratégiai célválasztó először a 155 pixelen belüli,
nem növényi bossjelölteket vizsgálja. Ez a képi közelséget járhatósági
bizonyítékként használja a távoli, másik rétegen vetülő HP-csíkkal szemben.
Kontaktust sem elérő, nulla sebzéses célvesztéskor a próbált HP-sáv újranyílik;
az aktív koponyás nem növényi célt az általános területelhagyás nem írja felül.

A nagy narancs kőhíd csomópontja külön útvonalállapot: statikus, erősen északra
mutató koponyavektornál `16 S → 6 W → 12 S` fut. A teljes gráfélt a közben
újramért koponyairány nem szakíthatja félbe.

## 2026-08-30 – Animációfüggetlen Island 2 topológiai kapu

- A teljes jelenet ujjlenyomata nem alkalmas egyedüli elakadásjelnek az órás
  tereptárgyak és a karakteranimáció miatt. A `083724-play` falnak ütközött,
  miközben a statikus számláló nem érte el a négyet.
- A `16 S → 6 W → 12 S` gráf most >=80% narancs fedettség, órás tereptárgy és
  `skullDirection.y < -0,52` esetén azonnal indul. A `084413-play` élőben az
  alsó arénába jutott vele.
- A tartós harci memória erőszinthez kötött: 18,8K/3770 vereségnél a következő
  próba küszöbe 4524. A 4,4K nulla sebzéses, másik rétegbeli megközelítése nem
  kerül ebbe a vereségmemóriába.
- A nagy kaktusz jutalmát `ismert maximum + szívérték` becslés védi a K-OCR
  csíkélhibáitól. A botállapot jelenlegi hiteles maximuma 4410.
