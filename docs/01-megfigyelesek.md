# Megfigyelések

## 2026-08-28 — kiinduló állapot

Biztos megfigyelések:

- A futó alkalmazás macOS-en iPad-alkalmazásként jelenik meg; a fő játékablak 623×863 képpont.
- A karakter a képernyő alsó-középső részén áll, induló kijelzett életereje 100.
- A mozgás vezérlője a képernyő alján, középen látható kör. A helyes bemenet érintést utánzó, kitartott swipe; billentyűzetes mozgás nincs.
- A macOS alkalmazásbeállítások között külön „Érintési alternatívák” mód van. Ez kezdetben ki volt kapcsolva; bekapcsolva a görgetést az egérmutató helyéről induló érintéses húzássá alakítja.
- A célpontok fölött piros, vízszintes életerőcsík jelenik meg. A kezdőképen egy 1-es szintű, 29 értékű fa-szerű célpont és távolabb egy 2-es szintű, 80 értékű humanoid látható.
- A játékos életerőcsíkja zöld és nagyjából a képernyő függőleges közepén található.
- Az első aktív felszereléshelyen egy fejsze és az 1-es jelzés látható. További helyek zároltak; az egyik „VIP 4” feltételű.
- Jobb oldalt bolt- és táska/felszerelés-gomb látható. Bal oldali terület „Island 4” eléréséhez kötött.
- A jobb felső minimap piros pontokkal jelöl ellenséges vagy támadható objektumokat; a sárga háromszög feltehetően a játékost és irányát mutatja.
- Rövid játékidő után megjelenhet egy „Having fun? Rate us!” értékelési felugró ablak, amely elsötétíti a HUD-ot. A középső panel jobb felső, rózsaszín X gombjával bezárható.

Munkahipotézisek:

- A támadás automatikusan indul, amikor a karakter megfelelő fegyverrel támadási távolságba kerül.
- Kezdetben a legközelebbi, 1-es szintű és alacsonyabb életerejű célpont biztonságosabb, mint a 2-es szintű ellenfél.
- A zsákmány felvétele közelségalapú lehet; ezért egy legyőzött célpont helyén rövid rámozgás várhatóan elég.

## 2026-08-28 — első sikeres mozgás és harc

Biztos megfigyelések:

- A működő mozgásbemenet: érintés/egér-lenyomás a virtuális kar közepén, lassú húzás, rövid tartás, majd felengedés. Négy visszacsatolt szakasz alatt a cél becsült távolsága 227-ről 140 képpontra csökkent.
- Az automata fejszetámadás legkésőbb 77 képpontos becsült célponttávolságnál aktív.
- Az 1-es szintű fa induló HP-ja 29. Az első fejszecsapás 12 sebzést okozott, így 17 HP maradt.
- A fa később eltűnt, a helyén kör alakú zöld visszaszámláló jelent meg 2 perc 47 másodpercről indulva. Ez nagy valószínűséggel az újratermelődés időzítője.
- A fa elleni harc alatt a játékos kijelzett életereje 100 maradt.
- A célpont piros HP-előterének szélessége a találatkor 58 képpontról 23 képpontra csökkent; ez megbízható, OCR nélküli sebzésjel.

Vezérlési korlát:

- A bizonyított swipe jelenleg az explicit előtér-módban működik. A közvetlenül PID-re küldött háttér-egér- és háttér-scroll eseményeket az iPad-kompatibilitási réteg figyelmen kívül hagyta.

## 2026-08-28 — veszélyzóna és regeneráció

Biztos megfigyelések:

- A kezdőterülettől felfelé 5-ös és 10-es szintű, 38 és 48 HP-s fák, valamint további ellenfelek jelennek meg. A pusztán „legközelebbi piros csík” célválasztás ide vezette a botot, ezért ezt a stratégiát elvetettem.
- A veszélyesebb területre érkezés után a játékos HP-ja 68 körül volt, majd rövid idő alatt 72, 73, 74 és 75 környékére emelkedett. A képen `+2` és szív ikon is megjelent; tehát van regeneráció vagy gyógyító hatás.
- A HP kijelzése animáció közben tizedeshez hasonló alakban is látszik (`68.2`, `72.3`, `75.1`), illetve időzítő takarhatja. Emiatt a puszta zöldcsík-szélesség nem elég stabil.
- A fa eltűnése után több kör alakú időzítő is látható volt; az egyik a korábbi célpont helyén maradt, míg egy másik a játékos közelében jelent meg. Az időzítők pontos jelentése még nem bizonyított.

Programdöntés:

- Vision OCR került a játékos-HP, a célpontszint és a célpont-HP régióira.
- A bot 80% alatt visszavonul, és csak 1-es/alacsony HP-s, illetve jó játékos-HP mellett 2-es szintű célt fogad el.
- A korábbi futásokon működő `replay` regresszióteszt igazolta, hogy a veszélyzónás kilenc képkockára az új döntő mind a kilenc esetben visszavonulást választ, miközben az első fa harci képkockáin továbbra is a fát követi és felismeri a találatot.

Ez az óvatos döntés történeti állapot; az automatikus, veszteségmentes újraéledés
ismeretében a v0.2 taktika felváltotta.

## 2026-08-28 — magasabb szintű fák és ismételhető fejlődés

Biztos megfigyelések:

- A játékos HP-ja a fejlődés során 100 fölé nőhet. A képen látott `102` értéket az OCR
  kezdetben `10`-nek, majd egy odaragadt képrészlettel `3102`-nek olvasta. A javított
  felismerő 2/3 jegyű részjelölteket képez, majd az előző HP-hoz legközelebbit választja;
  ugyanazon az öt képkockán ezután mindvégig 102-t adott.
- A 10-es szintű fa 48 HP-ról, 13-as fejszecsapásokkal négy találatból elfogyott. A
  képernyőn `+10` és szív ikon jelent meg, a játékos HP-ja 102-ről 112-re nőtt.
- Egy második 10-es fa után 117-ről 127-re, majd egy további automatikusan befejezett
  10-es cél után 127-ről 137-re nőtt a HP. A +10 tehát megismételhető, nem egyszeri
  képernyőeffektus.
- Az 5-ös szintű, 38 HP-s fa legyőzése után 112-ről 117-re, egy későbbi ismétléskor
  137-ről 142-re nőtt a HP. A jelenlegi legerősebb hipotézis: a fa szintje közvetlenül
  hozzáadódik a játékos maximális HP-jához.
- A stabil automata támadás 61–79 képpontos becsült távolságon biztosan működik. 86
  képpontnál egy futásban még nem indult támadás, ezért a megközelítési küszöb 82 px lett.
- A fák helyén kör alakú újratermelődési időzítő marad. Ugyanazon 5-ös és 10-es fák
  később újra támadhatók, ezért a terület ismételhető HP-farmot ad.

Útvonal-megfigyelések:

- A 5-ös fához vezető közvetlen út egy bokor/kő/üllő alakú tereptárgyon elakadt: tíz
  swipe mellett a cél 135 képponton maradt. Három, a célirányra merőleges kerülő swipe
  után a karakter kijutott, majd 137→102→91→79 képpontra zárkózott és megölte a fát.
- **Történeti, elvetett értelmezés:** a bal oldali köves út első közvetlen próbája
  akadályba ütközött, ezt tévesen az `UNLOCKS AT ISLAND 4` lezárt zónájának vettük.
  A `140735-play/frame-00242` másik bejáraton elérte a Dusty Gulch – 2-t; a bal
  negyed fegyverhely-HUD alapú kizárása megszűnt.
- Egy cél HP-csíkja kerülés, képszéli levágás vagy az utolsó találatok alatt néhány
  képkockára eltűnhet. Háromképes célmemória nélkül a bot ilyenkor rossz irányba fordult;
  a memória után távoli célnál folytatja az utolsó irányt, közeli célnál kivárja a jutalmat.

Még ellenőrizendő:

- Az automata támadás pontos hatótávja és üteme.
- A célpontok újratermelődése, a kapott tapasztalat/pénz, a szintlépés módja.
- Van-e passzív életerő-regeneráció, gyógyító tárgy vagy biztonságos visszavonulási pont.
- A bolt és a felszerelés fejlesztési gazdasága.
- Megválaszolt kérdés: a jutalmat a statikon jelzi. Szívikonos fa maximális HP-t,
  kékfejszés fa támadóerőt ad; a testforma önmagában egyik statot sem határozza meg.
- A 24 HP-s új célpont típusa és jutalma.
- A veszteségmentes halál és automatikus újraéledés képi állapotainak felismerése.

## 2026-08-28 — szabad swipe-kezdőpont, ellenségharc és újraéledés

Vezérlési felismerés:

- A játék a swipe irányát a játéktér bármely nem takart pontjáról elfogadja; nem kell a
  kirajzolt alsó körből indítani. Az alsó kör fölé mozgó küldetéspanel/időzítő miatt a
  régi, rögzített 50%/77,2%-os kezdőpont több futásban minden swipe-ot elnyelt.
- A program nyolc, a fegyversor fölötti jelölt 45×45 képpontos környezetében méri a
  fűszínű és a sötét/élénk UI-pixeleket, majd a legszabadabb pontból húz.
- Az első élő tesztben a kiválasztott 38%/66%-os pontról ugyanaz a korábban mozdulatlan
  cél 255→203→163→126→89→46 képpontra közeledett. Ez bizonyítja, hogy az ismételt
  „elakadások” jelentős része bemeneti takarás volt, nem terepakadály.

Ellenségharc és újraéledés:

- Két, 1-es szintű és 128 HP-s humanoid egyszerre támadta a játékost. A játékos fejszéje
  13-at sebzett; az ellenségek 10-es sebzésszámokat okoztak, több találat gyorsan
  egymás után érkezett.
- A képkockákon a játékos HP-ja 157→147→138→128→108→88→79→69→30 értékeken ment át.
  A javított OCR ezt a teljes sort reprodukálja; a régi stabilizáló a vezető `1`
  elvesztése és a tizedes animáció miatt hibázott.
- A halál után a karakter a zöld medencében jelent meg; az első tiszta leolvasás teljes
  157 HP volt. Egy következő hasonló harc után az első tiszta kép ismét teljes 160 HP-t
  mutatott. Ez történeti megfigyelés, nem bizonyít azonnali teljes HP-s respawnt: a
  `225111-play` később 45/340-ről induló medencés regenerációt mutatott. Pénz-, tárgy-
  vagy más látható büntetés továbbra sem jelent meg.
- Több közeli támadó esetén a v0.3 döntő 65% HP alatt visszavonulási módba lép, és 85%-ig
  nem fordul vissza. Egyetlen ellenfélnél továbbra is vállalja a 20%-os kritikus küszöbig.

Fejlődési és felismerési döntések:

- A 124 HP-s 5-szíves fa után +5 max-HP-jutalmat láttunk. A későbbi kék fejsze és
  26→27 sebzés nem ezt cáfolta, hanem külön támadóerő-jutalomágat bizonyított. Azonos
  statikonnál továbbra is az alacsonyabb HP-jú cél a jobb hozamú.

## 2026-08-28 — óriásfa-boss és friss HP-val igazolt újraéledés

- A `225111-play/frame-00075.png` 500-as szívikonú, `4.31K` HP-s óriásfát mutatott;
  a `frame-00080.png` képen `YOU DIED` és vörös `170` jelent meg.
- A `frame-00085.png` már medencés respawn volt, de számszerű HP nélkül. A következő
  tiszta élő mérés 45/340, majd 139→…→317→340 regeneráció lett.
- Kritikus állapotot ezért csak friss, legalább 90%-os numerikus HP oldhat fel. A
  legalább 800 HP-s, 360 px-en belüli ellenfél teljes HP-n is megelőző menekülést kap.
- Részletes bizonyíték és regresszió: `21-ujraelesztes-es-bosselkerules.md`.
- A fa alatti 53×54 képpontos régió szigorúan türkizzöld aránya ismert fáknál 0,54–0,61,
  humanoidnál 0,00–0,07 volt. A célpontpontozás csak 0,25 fölött ad fa-bónuszt.
- A legnagyobb hiteles HP a `docs/bot-state.json` fájlban megmarad a rövid fejlesztői
  futások között. A maximum csak kezdeti betöltéskor legfeljebb 160-ig, utána egy
  lépésben legfeljebb +15-tel nőhet, így egy OCR-zaj nem írhatja 210-re.

## 2026-08-28 — 232 HP, fa-időzítő és összemosódó OCR

Biztos megfigyelések a `docs/runs/20260828-201932-play` futásból:

- A karakter ismételt fejlődés és regeneráció után stabilan `232` HP-t mutatott teljes
  zöld csík mellett (`frame-00340.png`, `frame-00355.png`, `frame-00365.png`). Egy rövid
  `234` olvasat is előfordult, ezért a gépi maximum jelenleg 234; ennek valódisága még
  külön ellenőrzendő.
- A 67 HP-s, 1-es fát a bot a kerítés–őrtorony sarkának megkerülése után elpusztította.
  Az eltűnés helyén fehér balta/csont ikon mellett `23`, a karakter közelében pedig
  körülbelül `4m 0s`-ról induló zöld köridőzítő jelent meg (`frame-00360.png`). A `23`
  pontos jelentése még nyitott.
- A köridőzítő ráfedett a játékos HP-jára. A Vision szövegének utolsó száma emiatt két
  egymást követő elemzésben `32` lett a valós `232` helyett; a régi kétméréses szűrő ezt
  hamis kritikus HP-ként elfogadta.
- A `20260828-202645-replay` javított visszajátszásban a problémás `frame-00360.png` és
  `frame-00365.png` is 232 maradt, a későbbi valódi `232→222→213→193` sérüléssor viszont
  továbbra is visszavonulást váltott ki.

Programdöntés:

- 60 HP-nál nagyobb lefelé ugráshoz három egymást követő, egymáshoz legfeljebb 25 HP-ra
  lévő OCR-mérés kell. Üres/takart köztes kép megszakítja a megerősítési sorozatot.

Következő élő bizonyíték:

- A `docs/runs/20260828-203027-play/frame-00000.png` tisztán 243 HP-t és teljes zöld
  játékoscsíkot mutat. A `docs/bot-state.json` is 243-ra frissült; ez felülírja a 234
  valódiságára vonatkozó bizonytalanságot, bár a 220→243 növekedést adó célok sorrendje
  még nem rekonstruált.

## 2026-08-28 — 252/255 HP, 24–25 sebzés és időzítő-összeragadás

- A `203326/frame-00000.png` teljes zöld csík mellett 252 HP-t mutatott. A későbbi
  naplósor stabilan 255-ig nőtt; ez volt az akkori gépi maximum.
- Egy 179 HP-s fa első mért ütése `179→155`, egy 174 HP-s 10-es fáé `174→149` volt.
  A jelenlegi fejsze tehát legalább ezekben a támadásokban 24–25-öt sebzett.
- A fa köridőzítője `252 3m 15`, `2523m 14`, majd `2521` alakban ragadt össze a HP-val.
  A régi időzítős ág csak az utolsó `14/21` részt választotta, noha a 252 is jelen volt.
- A `203914-replay` az érintett mentett képeken végig 252-t tartott, miközben a későbbi
  valódi 252→233 sérülést elfogadta.
- Felhasználói aktivitáskor a stratégia korábban elfogyasztotta a kerülőszámlálókat a
  ténylegesen kihagyott swipe-ok ellenére. Most az elemzés fut tovább, de a stratégiai
  állapot csak végrehajtható döntésnél lép.

## 2026-08-28 — humanoid +3 jutalom és 1.22K elit

- Az izolált 3-as, 41 HP-s humanoid legyőzése után `+3` szív jelent meg, a HP pedig
  `249→252` lett (`204458/frame-00040.png`). A szintnyi max-HP jutalom nem csak fáknál
  lehetséges.
- A lebegő fehér fejsze `26` normál találati sebzés; a narancs kitöréssel jelzett `39`
  kritikus találat, pontosan 1,5-szeres érték (`frame-00070.png`, `frame-00105.png`).
- A tábor bejáratánál álló páncélos HP-ja `1.22K`, találata 30. A régi OCR ebből csak
  22-t tartott meg és olcsó célként választotta; 271 HP-ról gyorsan kritikus állapotba
  kerültünk.
- A gyógyítómedence valódi menedék: 26.3-ról fokozatosan, majd 87 után gyorsan 271-re
  gyógyított. A medencénél az objektív továbbra is `0/7` volt.

## 2026-08-28 — két külön statikonos jutalomág

- A `205205/frame-00070.png` egy 1-es fa eltűnése után zöld `+1` kék fejszét és 27-es
  normál találatot mutat. Közvetlenül előtte a normál érték 26 volt.
- Ugyanebben a futásban a narancs kritikus 40 lett a korábbi 39 helyett. Ez megfelel a
  normál érték kb. 1,5-szeresének.
- A cél feletti kék fejszeszám támadóerő-jutalom, a piros szív maximális HP-jutalom.
  A későbbi képaudit bizonyította, hogy mindkét ikon előfordulhat fenyő testű célon;
  humanoidon eddig szívet láttunk. A testforma a veszélyt, az ikon a jutalmat jelzi.
- A 12→13→23–27 sebzésfejlődésben biztosan vannak kékfejszés jutalmak, de +5/+10
  támadóerőt még nem bizonyítottunk közvetlen képpárral.

Élő folytatás (`docs/runs/20260828-204159-play`):

- A 10-es, 174 HP-s fa megközelítése aktív géphasználat mellett is szabályosan csökkent
  238-ról 68 px-re; a köztes `VÁR` képek nem fogyasztottak mozgáslépést.
- Amikor a fa csíkja 44 HP-n eltűnt a biztonságos célok közül, a háromképes közeli
  célmemória kivárt. Az automata támadás közben befejezte a fát; a
  `204159/frame-00095.png` közvetlen `+10` szívet és 268 HP-t mutat. Ez biztos max-HP-
  jutalom, nem regeneráció.

## 2026-08-28 — 286 HP és szám nélküli, teljes csíkos állapot

- A `210202-play` első mentett képén a játékos zöld HP-csíkja teljes, miközben az OCR
  kizárólag `4h 57m` időzítőt látott. Az ebből képzett 57 nem lehetett valós HP.
- A következő képen tisztán 286 HP jelent meg, majd ismétlődően stabil maradt. A
  `docs/bot-state.json` hitelesített maximuma ezért 286.
- A `210417-replay` az időzítős képet számszerű HP nélkül, 100%-os pixelaránnyal kezeli,
  majd a következő képtől helyesen 286-ot olvas. A hiányzó szám jobb állapot, mint egy
  képpel ellentmondó, kitalált numerikus érték.

## 2026-08-28 — a harci memória első igazolt +10 eredménye

- A `213551-play/frame-00065.png` még 58 HP-s 10-szíves fenyőt, a 80. kép már annak
  `3m55s` újratermelődési körét mutatja. A bot közben nem mozdult el.
- A következő `213819-play` futás 141–145. eseménye stabil, teljes `296` HP-t olvasott a
  korábbi 286 után. A `docs/bot-state.json` maximuma is 296.
- Ez közvetlen élő eredmény: a hosszabb passzív-fa memória befejezte a célpontot és
  megszerezte a +10 max-HP-jutalmat.

## 2026-08-28 — 306/310 HP, 4-szíves humanoid és küldetésbuborék

- A `214936-play/frame-00245.png` teljes csíkon tiszta `306` HP-t mutatott. A régi
  parser 300-as felső korlátja ezt nem engedte be, ezért 299-es memória és 79%-os
  pixelbecslés mellett végtelen regenerációs várakozás alakult ki.
- Ugyanezen a képen a „Collect all gems to unleash the Titan's power” buborék `0/7`
  számlálóval látszott. A `215627-play/frame-00000.png` még mutatta, az első swipe-ok
  után a `frame-00005.png` már nem: a buborék nem igényel külön kattintást és nem
  blokkolja a mozgást.
- A `215627-play/frame-00005.png` egy izolált, 4 piros szíves, 43 HP-s humanoidot mutat.
  A harc után a `frame-00015.png` 301-re gyógyuló, a `frame-00020.png` teljes 310 HP-t
  mutat. Erős következtetés: a cél +4 max HP-t adott; ezzel újabb szintnyi humanoid-
  szívjutalom igazolódott, bár a közvetlen `+4` felirat az 5 képes mentési ritmusba esett.
- A harcban fehér fejsze mellett `32` jelent meg (`frame-00010.png`): a jelenlegi normál
  találati sebzés legalább ebben az ütésben 32.

## 2026-08-28 — 33-as sebzés, +10 szív és 320 max HP

- A `215627-play/frame-00070.png` egy 16-os, kékfejszés fenyőt még 43 HP-val és fehér
  `33` találati számmal mutatott. A `frame-00090.png` ugyanott már `3m 52s` újratermelődési
  kört: a hosszú harci memória sikeresen befejezte a 291 HP-ról indult célt.
- Egy későbbi 10-szíves, 174 HP-s fenyő után a 361. esemény `310→320` HP-t és `3m 59s`
  időzítőt rögzített. A jutalom-OCR `•10`, később `€10` alakot látott, ezért a csak
  pluszjelet elfogadó detektor kihagyta, de a pontos HP-lépés és a respawnkör közvetlen
  bizonyíték a +10 max-HP jutalomra.
- Az akkori tartós maximum 320 volt; ezt a későbbi `222253-play` 330-ra emelte.

## 2026-08-28 — lila Titan-portál, célváltási oszcilláció és +1 humanoidfejsze

- A `220154-play/frame-00500.png` közepén lévő lila rituálé-/portálobjektum 200-as
  csíkját a bot normál humanoidként támadta. A 274–706. esemény között többször közvetlen
  közelre állt és finomított, de a 200 HP egyszer sem változott.
- A portál testének magenta pixelaránya 0,202; ellenőrzött normál humanoidon, fenyőn és
  5-ös célon 0,000. A 0,06 fölötti lila struktúra ezért sem farmcél, sem fenyegetés.
- Ugyanebben a futásban két egyidejű cél képkockánként váltakozott, ezért ellentétes
  swipe-ok követték egymást. A stratégia most három tényleges döntésig tartja az előző
  célt; azonos HP és testtípus nagy kameramozgásnál is célazonosság.
- A `221123-play/frame-00000.png` egy 1-es kékfejszés, 128 HP-s humanoidot mutat. Ölés
  után a `frame-00010.png` vizuálisan zöld `+1` kék fejszét mutatott, miközben a Vision
  `+12`-t olvasott az ikonból képzett hamis záró kettes miatt. Biztos új tény: humanoid
  is adhat fejszés támadóerő-jutalmat.

## 2026-08-28 — 330 max HP, timerből képzett hamis 83/56 és Island 4 hurok

- A `222253-play/frame-00100.png` 320 HP mellett egy 10-szíves, 174 HP-s fenyőt mutat;
  a `frame-00110.png` már teljes 330 HP-t, zöld `+10` szívet és `3m 59s` kört. Ez újabb
  közvetlen bizonyíték a kijelzett szívértékkel egyező max-HP jutalomra.
- A következő két esemény `83m 565`, majd `33m 56s` nyers OCR-ből 83/56 HP-t képzett,
  noha nem volt vörös csík vagy támadó. A `frame-00115.png` teljes csíkja és a következő
  tiszta 330 bizonyítja, hogy a timer ráfedése, nem sebzés történt.
- A 275–645. eseményen a bot a lezárt Island 4 kerítés alól a túloldali 64/200 HP-s
  célokra fordult vissza. A rövid kerülők célváltáskor megszakadtak. Az új manőver nyolc
  megszakíthatatlan akadálykövető lépés, majd második kudarcra 18 lépéses kiszakadás.
- A `224139-play` hosszú kiszakadása után a bot elérhető 10-szíves, 174 HP-s fenyőt
  talált, 129→91→57 px-re közelítette és befejezte. A 131–132. esemény közvetlen
  `330→340` és `+10` jutalmat rögzített.
- Ennek a történeti szakasznak a tartós maximuma 340 volt; később három 20-as szívfa
  360-ra, 380-ra, majd 400-ra emelte (lásd a 2026-08-29-i megfigyelést).

## 2026-08-28 — 69-es normál, 104-es kritikus és 1→4 fegyverszámláló

- A `224139-play/frame-00180.png` egy 192-ről 54 HP-ra csökkent humanoidot és lebegő
  69-es fejszés találatot mutat. A 138-as csökkenés pontosan két 69-es ütés.
- A `frame-00130.png` 104-es erős találata a 69 kb. 1,5-szerese.
- A korábbi `215627/frame-00070.png` 33-as normál értéke óta az alsó első fegyver száma
  1-ről 3-ra, a humanoidölés után 4-re nőtt. A köztes 2-es állapot közvetlen `+1`
  kékfejsze mellett látszott a `221123/frame-00010.png` képen.
- A számláló és a sebzéslépcső kapcsolata erős hipotézis, de még nem bizonyított. A
  következő tiszta ütés dönti el, változott-e a 69 a 4-es állapotban.

## 2026-08-28 — Bat Cleaver példányszám, Equip és 111 DPS

- A `233041-play/frame-00002.png` zöld fegyvere Bat Cleaver: Uncommon, Cutting,
  példányonként 50 sebzés, két példánynál 100, cooldown 1,2 s, evolve `2/130`.
- A sárga Equip gomb nem jelzett árat vagy reklámot. A `233539-play` egyszer megnyomta;
  a következő képen a Bat Cleaver az Equipped sorban, a régi 4 példányos fegyver az
  inventoryban volt.
- A Stats `62.3 / 33+48` értékről `111 / 33+100` értékre váltott. Ez közvetlenül
  igazolja a `(33 + fegyverbónusz) / cooldown` DPS-képletet és kb. 78%-os javulást.
- A modal `DAMAGE PER COPY 50` szövege a harci HP-régióba lógott, ezért a korábbi
  elemző 50/340 HP-nak olvasta. Biztos popup-X mellett most már minden HP-jelölt tiltott.

## 2026-08-28 — üres Mailbox

- A `234301-play` 46. eseménye egyszer megnyitotta a bal felső piros pecsétes borítékot.
- A képernyő Mailbox, `You have no Mails yet` szöveggel, Inbox és Archive fülekkel.
- Nincs átvehető jutalom. A piros pecsét az ikon rajza, nem bizonyít aktív értesítést.
- A program a nyitás után kizárólag várt; a kutatás kész, automatikus újranyitás nincs.

## 2026-08-28 — Shop, forintárak és felső-X HP-szennyezés

- A `234543-play/frame-00050.png` Shopot mutat: VIP 0/20, 0 gem, hat valódi pénzes
  gemcsomag 999–44 990 Ft között, valamint több mint kétórás `FREE IN` időzítő.
- Alul Chests fül aktív; Souls és Crystals zárt. Damage-kártyákból +35/+152/+409 látszik,
  de semmit nem aktiváltunk.
- A felső X-et a régi popup-geometria kihagyta, ezért bolti számok 5/6 HP-vá váltak.
  A pink-X keresés kibővült; biztos modalnál továbbra sincs harci HP-frissítés.

## 2026-08-29 — három 20-as szívfa, 400 HP és Cursed Girl

- A `000247-play/frame-00034→00036` 187-es Bat3-találat után `340→360`, `+20` szívet
  és 3m59s timert mutatott egy 20-as szívikonú narancssárga fán.
- A `000913-play/frame-00020→00024` ugyanazt megismételte: 187/57, `360→380`, `+20`,
  3m57s. A 290→294. képen egy erősebb változat 191 után 240 HP-n állt, mégis +20-at
  adott és 400-ra emelte a maximumot. A szívikon jutalomérték, nem cél-HP.
- A zöld minimap-landmark Cursed Girlhöz vezetett. Három dialógus szerint a Deep Mines
  bányában lévő mágikus főzet fordíthatja vissza a kővé válását; az aktív számláló 0/1.
- A piros hajdísz hamis popup-X volt. Külön `Tap to continue` OCR és input nélküli
  átvezető-várakozás váltotta fel a véletlen tappot/HUD-stopot.

## 2026-08-29 — Deep Mines kapu, elitveszély és két fegyverhely

- A valódi türkiz sín egy fehér–türkiz kapun keresztül havas területre folytatódik.
  A kapu közepének nyomása statikus; a történeti jobb oldali tízlépéses kerülővel
  átjárhatónak bizonyult, de a vak hosszúságot később négyes, újraértékelő szakasz váltotta.
- A havas oldalon 1,92K és 7,15K HP-s ellenfelek állnak. Az első behatolás 400→51 HP-t
  okozott, de a bot kijutott és teljesre regenerált.
- A lila szikla türkiz pereme, a híd és a húszas fa hamis útvonal volt. Hosszú,
  játékosközeli összefüggő türkiz komponenssel a három hamis kép kiesik.
- Egy `1.22K` páncélost az OCR `221`-nek olvasott; az ellenfél veszélyes volt. Ismeretlen
  szintű, 150 fölötti humanoid és OCR nélküli széles csík többé nem próbacél.
- A `2 WEAPON SLOT UNLOCKED!` jutalomablak új aktív fegyverhelyet adott. `CONTINUE`
  után Bat Cleaver `4` és egy második, világos `1` fegyverikon látszott; a karakter
  két fegyvert viselt. A feloldás pontos kiváltója nyitott.
- A bot ezután narancs bányatáborba jutott. `1` fejszés kaktuszok, `4` szíves 253 HP-s
  humanoidok és kb. ötperces respawnkörök látszanak. Több közvetlen `+4` szív
  `400→…→424` max-HP fejlődést adott; a `bot-state.json` 424-et tárol.

## 2026-08-29 — fénylő helyszíni láda és `OPEN` gomb

- A `012951-play/frame-00068.png` nyílt zöld terepen fehér-arany, fénylő ládát mutatott
  közvetlenül a karakter alatt, nagy sárga `OPEN` gombbal.
- Ez nem az inventory jobb oldali ládaikonja, hanem a világban álló interaktív tárgy.
- A Vision a stilizált feliratot `NEdU`-nak olvasta. A javított detektor a játéktérben
  bárhol mozgó narancssárga gombot a saját OCR-jével együtt azonosítja, és annak
  tényleges közepére koppint.
- A `013448-play/frame-00548.png` jutalma `+10` szív, `+2` kék fejsze és `+1%` szív.
  A `014620-play` pontos `TAP TO CLAIM` után `424→438` max-HP növekedést igazolt.
- A láda egyszeri vagy ismételhető volta továbbra is nyitott.

## 2026-08-29 — Island 4 perspektivikus zárfal (történeti, elvetve)

- A `014620-play/frame-00220.png` képen a lezárt narancs sziklafal túloldali 136/253
  HP-s céljai 25% fölé nyúltak, ezért a régi fix kizárás ellenére célponttá váltak.
- A látható `UNLOCKS AT ISLAND 4` feliratot ekkor tévesen megbízható
  területállapotnak vettük. A 158-as fejezet bizonyítja, hogy fegyverhely-HUD.
- A tiszta jobb és függőleges swipe a kiugró peremen statikus maradt, a jobbra-le
  `(0,48; 0,88)` kevert átló viszont a `015352-play/frame-00016→00030` között mozgott.
- A karakter ezüst fegyvere és narancs ruhája hamis távoli ládajel volt; legalább
  120 px játékostávolság után a valódi láda megmarad, a hamis testjel kiesik.

## 2026-08-29 — elérhető narancstábor, +4/+5 lépcsők és 459 HP

- A `020221-play/frame-00078` és `frame-00130` két közvetlen `+4` szívjutalmat mutat;
  a világláda utáni maximum `438→442→446` lett.
- A `020635-play` 450-ről indult. A hiányzó `446→450` jutalomképet a mentés nem fogta
  meg; az előző azonos tábori +4-ek alapján ez erős, de nem közvetlen következtetés.
- A `020635-play/frame-00016` újabb `+4` feliratot, a `frame-00018` teljes 454 HP-t
  mutat. A sűrű csoport közben 392 pillanatnyi HP-ig sebzett, de a visszavonulás és a
  regeneráció sikeres volt.
- Egy 76 HP-n látott 1-es kaktusz eltűnése után a `frame-00022` már teljes 459 HP-t
  mutat. A maximum biztos; a köztes `+5` kaktuszjutalom erős következtetés.
- Az Island 4-felirat mellett a narancs tábor karakter felőli oldala elérhető. Nem a
  teljes narancs régió zárt, csak a perspektivikus sziklafal túloldala.
- Egy fehér ponyvás szekér harmadik hamis ládaosztály lett. A valódi testhez most
  legalább négy külső, szigorú sárga ragyogásminta is kell.
- A futás későbbi `frame-00376` képe közvetlen `+4` feliratot és teljes 463 HP-t adott.
  A régi tiszta jobbra Island 4-szándék hosszú sziklaék-hurkot ismételt; az első
  határmozdulat most rögtön a bizonyított jobbra-le `(0,48; 0,88)` átló.
- A `021337-play/frame-00034` kaktusza `94.1` HP-t mutatott, de az OCR 941-re húzta
  össze és hamis bossmenekülést okozott. Az azonos, rövidülő csík tizedes-helyreállítása
  replayen 94 HP-ra javította.
- Ugyanez a futás egyetlen jutalom nélküli 464-et adott két 463 között. Ez OCR-zaj,
  ezért a tartós maximum 463 maradt, a kis maximumugrás kétképes megerősítést kapott.
- A `frame-00108` részben levágott `2x Reward!` filmes ajánlatot mutat. Mechanikája
  nyitott, reklámgyanú miatt nincs automatikus interakció.
- A `022045-play` valódi 1.16K bossok közül a jobbra-le átlóval visszajutott a
  narancstáborba. A `frame-00044→00048` 253 HP-s humanoidölést, közvetlen `+4` szívet
  és `463→467` maximális HP-fejlődést mutatott.
- A `022045-play/frame-00178` 34 másodperces respawnköre 61%-os hamis pixel-HP-t,
  a `frame-00240→00250` ötpereces köre pedig 13% pixelt és 7/37 OCR-t képzett a
  valós 467-ből. Ugyanaz a takarás szennyezte mindkét mérést; nem volt valódi sérülés.
- A `023210-play` első képe és több mint száz további eseménye stabil, teljes 471 HP-t
  mutatott. A köztes `467→471` jutalom erős +4-következtetés, közvetlen felirat nélkül.
- Ugyanezen futás `frame-00136→00140` sorozatán a 253 HP-s, 4-szíves humanoid 34 HP-ról
  eltűnt, majd közvetlen zöld `+4` és teljes 475 HP jelent meg. Ez biztos új jutalom.
- Az egyképes 523-as játékos-HP OCR-zaj volt 471-es képek között; a +30-as maximumőr
  elutasította, így a tartós állapot nem sérült.
- A `frame-00248→00250` 252 HP-s kaktusza zöld, szív alakú `1` statikont, majd zöld
  `+1` jutalomeffektust adott. A teljes HP 475 maradt: ez nem piros max-HP szív.
- Ugyanott a vörös sziklaív HP-csíkká vált, és a lebegő 124-et cél-HP-ként örökölte.
  Fekete kerete 0,000 volt, míg a leggyengébb igazolt valódi csíké 0,109.
- A `024202-play/frame-00000→00098` alatt a karakter közvetlenül egy 67,5K HP-s,
  zöld `3` statikonú óriás fölött állt. A csík a kép 85%-án volt; a régi 72%-os
  cél-látómező ezért nem adta át a bossőrnek.
- A kiszélesített OCR nyers szövege pontosan `67.5K`; ez 67 500 HP. A statikon `3`
  külön érték, nem a HP része.

## 2026-08-29 — első képi újraéledés, Meadowlands és 492 HP

- A `025524-play/frame-00054→00068` sok 13 HP-s katona és 1,86K–3,06K HP-s lovas
  között 308→129 HP-ig fogyó játékost mutatott; a `frame-00074` már `Meadowlands – 1`
  visszahelyezés volt.
- A bot 90. eseményig friss numerikus HP-ra várt, majd a biztos 475 után folytatta a
  farmot. A megszerzett maximum tehát halálkor nem veszett el.
- Egy 10-szíves 48 HP-s fenyő közvetlen +10-zel 485-re, egy 5-szíves 38 HP-s fenyő
  közvetlen +5-tel 490-re emelte a maximumot. Egy későbbi 2-es cél után stabil 492
  jelent meg; ez erős +2 következtetés.
- Az `UNLOCKS AT ISLAND 4` felirat a zöld Meadowlands területen is látható. Ez globális
  HUD, nem önmagában helyi faljel; az Island 4-geometria csak narancsszikla-biomban él.
- A `030113-play` ismételt 10-szíves fája közvetlen +10-zel 502-re, majd 2-szíves
  80 HP-s és 3-szíves 96 HP-s humanoid közvetlen +2/+3 jutalma 507-re emelte a
  maximumot. A 3-as cél 9-et sebzett, amit a karakter gyorsan visszagyógyult.
- A futás folytatása több +5/+10 fát és együtéses +3/+4 humanoidcsoportokat farmolt,
  így a tartós maximum 573 lett. A 41–43 HP-s csoportok már kis kockázatúak.
- A bal képszélen álló 1.22K páncélos farmcélként kizárt, de bossfenyegetésként látható
  kell maradjon; 244 pixelen menekülést, 378 pixelen még csak megfigyelést vált ki.
- A zöld sátorkerítés L-sarka megcáfolta az általános kétoldalas merőleges faljárást;
  minden biom négy oldalsó-előre/hátra átlót kapott.
- A javított `031754-play` élőben kijutott a sátorkerítés környékéről, majd
  `576→578→583→586→595→600→605→611` teljes HP-mérési pontokat adott. A 611 tartós.
- Ugyanebben a futásban a kék fejsze ikonos `+1` és `+2` effektus nem növelte a
  maximális HP-t. A puszta `+N` OCR ezért statjutalom, nem automatikusan szívjutalom.
- A `031754-play/frame-00332` zöld `+0.5` effektusát az OCR `+0.5C`-nek látta, a régi
  számkinyerés pedig hibásan +5-nek naplózta. Tizedes jutalom nem egész statjutalom.
- A `032640-play/frame-00058→00064` friss OCR-je hét képen 923-at olvasott, de a
  célazonossági memória egy korábbi 40 HP-t örökített rá. A friss, helyreállított
  800+ cél-OCR-nek a simított HP-tól függetlenül bossnak kell lennie.
- A `032640-play/frame-00090` 431 HP-s fája 486-os találat után közvetlen +20-szal
  631-re emelt. A `frame-00130` +3-mal 634-re, a `frame-00164→00166` két külön +4
  effektussal 638-ra, majd 642-re emelte a maximumot.
- A `033114-play` stabil +5/+5/+3 lépcsőkkel 642→655 fejlődést adott. A
  `frame-00054` timerátfedése 27%-os hamis pixelcsíkot, a `frame-00058` vizuális +1
  fejszéje pedig `+12` összeragadt OCR-t adott; egyik sem max-HP esemény.
- Ugyanezen futás 4-es statikonú célja után a stabil maximum 655→659 lett; a végérték
  biztos, a +4 hozzárendelés közvetlen effektus híján erős következtetés.
- A `033451-play` 10-szíves, 174 HP-s fáját 182 pixelen a 180-as célkapu miatt a türkiz
  quest-út felülírta. A biztos, legalább 5-szíves fák 300 pixeles kiemelt prioritást kaptak.
- A `033451/frame-00248` közvetlen +3-mal 662-re, majd a futásváltás alatt eltűnő
  4-szíves 43 HP-s cél erős +4-gyel 666-ra emelt. A `033954/frame-00014` 1.22K
  páncélosa élőben azonnal aktiválta a nyers bossőrt.
- A `033954-play` bossmemória után közvetlenül visszavette a 10-szíves fát,
  203→140→93 pixelen befejezte, közvetlen +10-zel 676-ra emelt. A következő
  elérhetetlen cél tartós kerülője nem nullázódott, majd hosszú kiszakadás indult.
- Ugyanezen futás második 10-szíves, 174 HP-s fája 243→191→151→116 pixelen
  befejeződött, a 280. esemény közvetlen +10 effektusa után a friss OCR 686 HP-t
  igazolt. A prioritás így két külön célon ismételhető hozamot adott.
- A 351–363. eseményben az Island 4 hídsarkában változatlan maradt a teljes háttér,
  miközben a bot ugyanazt a falmenti vektort tartotta. Statikus kerülőn belül három
  sikertelen swipe már elegendő az adott átló elvetéséhez.
- A javított `034946-play` első 56 eseményében újabb 10-szíves, 174 HP-s fa
  146→107 pixelen eltűnt, majd a `frame-00050` közvetlen +10-et és vizuális 696-ot
  mutatott. A tiszta 56. esemény OCR-je tartósan is igazolta a 696 HP-t.
- A 291 HP-s, alacsony jutalmú fa több hosszú kiszakadás után is újra felbukkant az
  Island 4 falánál. HP+test aláírásos, lejáró hűtés kell, hogy a bot ne kezdje újra
  korlátlanul ugyanazt a bizonyítottan sikertelen üldözést.
- A `034946/frame-00244` két egymásra csúszó +3 szíveffektussal 696→702, a
  `frame-00250` harmadik +3-mal 705 HP-t adott. A `frame-00268` következő közvetlen
  +10 szíve 715-re emelt. A 270. esemény egyszeri 750 OCR-je vizuálisan is 715 volt,
  ezért helyesen elutasított zaj.
- Ugyanezen futás 451. eseményének egyszeri 745 OCR-je jutalom nélkül átcsúszott a
  korábbi +30-as maximumőrön, majd minden kép 715-re állt vissza. A tartós állapotot
  715-re kellett javítani; összetett, nem elemi ugrás két azonos OCR-t igényel.
- A `035832-play` 3-szíves célja 31→3 HP után eltűnt, majd késleltetve stabil 718
  jelent meg. A `040308-play` friss, javított állapotból vizuálisan is megerősítette;
  a 715→718 biztos, a célhozzárendelés effektuskép nélkül erős.
- A `040308-play` 180–186. képein a hatswipe-os bossmenekülés útvonala keresztezett
  egy 3-szíves, 41 HP-s humanoidot. A cél 41→17→0 HP-ra esett, a játékos 718→714
  pillanatnyi sebzést kapott, majd közvetlen `+3` szívvel 721-re állt. A maximum és
  a humanoid jutalma közvetlenül bizonyított.
- A `040308-play/frame-00486→00490` 67 HP-s, 1-fejszés fenyője közvetlen +1 kék
  fejszét adott. A max HP 721, a zöld fegyverkártya példányszáma 6 maradt; ez külön
  támadóstat. A jutalom előtti fehér fejszes találati szám 385 volt.
- Öt, fejlődés nélküli boss-találkozás a zárfal körül már ismétlődő, rossz hozamú
  régióhurkot jelez. A bizonyított büntetésmentes respawn ezért feltételes farmrövidítés;
  jutalom vagy két tiszta új maximum azonnal törli.
- A `041440-play/frame-00076→00082` két elkülönített 3-szíves, 41 HP-s humanoidot és
  két külön +3 szíveffektust mutatott: 721→724→727. A +1 fejsze utáni két normál
  fejszes találati szám 387, a nyílikonos kísérőérték továbbra is 24.
- A képszéli 291 HP-s fa első részleges OCR-je appcímtöredékből 1 lett, és a
  pozícióalapú célmemória a következő tiszta 291-re is ráült. Két egymást követő azonos
  nyers nagyobb HP már új célazonosságot igazol; replayen 1→1→291-re javult.
- A `043036-play` híd–fa zsebében a négy relatív átló közeli képi állapotokat
  ismételt. A blokkolt irány pontos ellentéte elvitte a karaktert a sátorig, az eredeti
  irány visszavitte. A `043455-play` útvonalhűtős változata az ellenirány után három
  oldalirányú-kifelé swipe-pal nyílt udvarra jutott; a minimapvektor közel vízszintes
  balról közel függőleges felfelé fordult.
- A `044329-play` ugyanazt a 291 HP-s, 1-fejszés fenyőt új oldalról 272→90 pixelre
  közelítette és 580-as fejszes találattal befejezte. Zöld +1 kékfejsze-effektus jelent
  meg, majd a mögötte álló 1,22K páncélos bossőr sérülés nélkül eltávolította a botot.
  A cél tehát helyzetfüggően elérhetetlen, nem globálisan tiltandó.
- A `044928-play` első élő stratégiai respawn-próbája feltárta, hogy a már egyszer
  látott sebzés történeti jelzője végtelen helyben várást okozott. A javítás csak a
  friss sebzésmemória alatt vár, utána tovább tartja a bossirányt.
- A `045414-play` 431 HP-s, 20-szíves fája közvetlen +20 effektussal 727→747 HP-t
  adott. A fa helyén 4m 0s respawnkör maradt; a hiteles aktuális maximum 747.
- A megelőző 291 HP-s +1 fejszecél előtt a zöld fegyverkártya számlálója 6, a következő
  élő képen 7 volt. A friss 20-szívfa ölési képe 442-es fejsze- és 36-os nyílértéket
  mutatott; a pontos normál/kritikus felosztás még nyitott.
- Ugyanebben a futásban a hatfázisú statikus kiszabadítás a sátor–kerítés sarokból két
  fázissal nyílt mezőre jutott; a korábbi híd–fa zseb javítása más akadályon is működik.
- A `045414-play` második stratégiai respawnja már mozgott a korábbi helyben várás
  helyett, de a 632 HP-s veszély a lezárt Island 4-fal túloldalán állt. 317–395 között
  sem kameramozgás, sem sebzés nem történt; az ilyen cél stratégiai megközelítése tilos.
- A teljes futás javított replaye a bal 36%-os, narancsszikla-oldali veszélyeket továbbra
  is bossként kerülte, de egyikre sem indított szándékos respawnt.
- A `050324-play` zöld tábori emelvényénél `You found 1/57 chests` jelent meg mozgás
  közben, tap nélkül. Ez a fehér ládatípus erős következtetés szerint közelségi,
  automatikus világkollekció, nem az `OPEN` gombos világláda.
- Ugyanott egy izolált humanoid ismételten tiszta 192 HP-t mutatott. A régi 150-es
  ismeretlenszint-kapu kihagyta, noha a játékos 747 HP-s és a fejszeérték 442.
  Történeti kísérletként teljes HP-n 250-ig próbacél lett.
- A `050827-play` élő cáfolta a lazítást: ugyanaz a jobb képszéli cél közelebbről
  1927 HP-ra állt helyre, a nyers bossőr 230 pixelen sérülés nélkül elmenekült.
  A cél 1,927K-s elit, ezért a 150-es ismeretlenszint-kapu visszaállt.
- A `051233-play` ugyanennek a képszéli elitnek már csak `92` HP-t olvasott 57 px
  széles csíkon, majd ismét `192` részlet jelent meg. A 92 az 1,927K csonkolt
  végződése, nem olcsó cél; közelítése közben 747→741/742 pillanatnyi esés látszott.
- A `052132-play` 253-as célja egy-egy képre boss-jelölést örökölt, majd elvesztette.
  Ez valószínű célazonossági hiszterézis kameraeltolódáskor; egyelőre nyitott, mert
  csak óvatos menekülést okozott és a biztonsági őrt nem szabad korán gyengíteni.
- A részletes replay megcáfolta a puszta hiszterézis-hipotézist: `frame-00052` esetén
  a szomszéd `253` HP-ja a statikon OCR-régiójában is megjelent. Külön hamis bossforrás
  volt a mínuszát elvesztő `-3390` lebegő sebzésszám. Mindkét forrás célzottan szűrhető.
- Az első javított élő futásban az ismert 4-es szintű 253 HP-s cél `2537`-re ragadt;
  célazonosság- és szintfolytonossággal biztonságosan elválasztható a szint nélküli
  valódi 1927-től. Egy közelebbi normál cél a régi `nearestThreat` kiválasztásban
  egy 360 px-en belüli 923-as bosst is elfedhetett; a bossprioritás ezt javítja.
- A lezárt Island 4 jobb oldali keskeny sziklapárkányán több teljes, minden ismert
  irányt lefedő kiszabadítási fázis is mozdulatlan maradt. A jobb oldali 192/1927
  támadó korábban látható volt; iránymemóriája büntetésmentes respawnhoz használható.
- A `054356/frame-00122` nagy kameramozgással igazolta a természetes kijutást a híd
  jobb oldalára; a fázisszámláló helyesen nullázódott. A `frame-00144` külön hibája:
  a `20h 13m` időzítő `24k 3m`-ként 243K hamis cél-HP-t és bossjelet okozott.
- A HP-időegységőr után a statikonmezőben `202` timerdarab maradt. A bizonyított
  tartalék boss-statikon 500/501; a 100–399 statikon-OCR így nem önálló bossjel.
- Sűrű 253-as csoportban a nyers HP `1253`, a statikon `2534`, más képen pedig
  `2531|8021|*253` alakra is összeragadt. Két azonos simított HP-jú aktuális cél
  konszenzusa különíti el ezt a valódi több ezres ellenféltől.
- A jobb képszélen mindössze 18 pixeles, OCR nélküli csíkdarab nem bizonyított olcsó
  cél. Ugyanazon az oldalon él az 1,927K elit; a részleges csíkot előbb teljesen
  képre kell hozni, és csak utána szabad farmcélként osztályozni.
- A független statikon tartománykapuja élőben 410, 419, 505 és 594 zajértékeket is
  talált. Közvetlen tartalék bossikonként csak a pontos 500/501 bizonyított; minden
  800+ nyers HP ettől külön biztonsági forrás.
- A bal fali 253-as csoport nyers `2531` alakja első képen 2531-ként is bekerülhet
  a simított HP-ba, illetve egyedül maradó tagnál 253 mellett ismét felvillanhat.
  A közeli társak ±3 HP-s konszenzusa és a védett faloldal együtt biztonságos szűrő.
- A jobb oldali kezelőgombok egy teljesen látható 1,927K elit vörös csíkját 19 pixelre
  takarhatják; az OCR ekkor 92-t ad. Island 4-en a rövid látható csík sem bizonyít
  gyenge célt, ha a szint ismeretlen.
- A jobb oldali 92/192, szint és jutalomikon nélküli fegyveres cél ismételten ugyanaz
  az 1,927K elit. Helyi bossazonosítóként már nemcsak farmtiltás, hanem az öt találkozás
  utáni büntetésmentes respawn lehetséges célja is.
- Az első élő respawnközelítés 258→165 pixelre javult, majd a zöld nézetben elvesző
  biomjel és a láda/korlát miatt 165–203 között ingázott. A lezárt HUD stabilabb helyi
  azonosító; stagnáláskor külön függőleges oldalkerülés szükséges.
- Folyamatos újracélzással az elit 124–137 pixelre közelíthető, de onnan egy képpár
  alatt 180–206 pixelre kite-ol. 165 pixelen belül hosszabb, 1,1 másodperces sprint
  kell a közelharci tartomány átlépéséhez.
- Több hosszú sprint alatt az elit pontosan azonos 150 pixeles koordinátán is maradt:
  ez statikus akadály, nem kite. Az azonos irányú kerülő ismétlése nem elég; a
  függőleges kerülőoldalt ciklusonként váltani kell.
- A `063020-play` 43–201. eseménye között a zöld Island 4-kapunézet háttere és a
  játékos HP-ja változatlan maradt, miközben a 192-es elit járőrözött. A 155–237
  pixeles céltávolság-ingadozás ezért nem játékosmozgás-bizonyíték; a kapuzsebhez
  teljes nyolcirányú, irányonként hat swipe-os kijáratpróba szükséges.
- A nyolc irány és a hosszú kifelé átló sem oldotta fel a kapuzsebet. A Settings
  panel explicit Unstuck gombja a zöld medencéhez teleportált; 119→614→672→747 HP
  gyógyulás következett, maximális HP- vagy felszerelésvesztés nélkül.
- Az Unstuck első használata után a következő automatikus próbán a gomb helyén
  `05:24→04:48` visszaszámlálás látszott. A HUD 100%-os maradt, a teleport nem indult;
  ez biztos többperces újrahasználati időzár.
- A hosszú célterület-kiszakadás 17 tényleges swipe-ot számol, nem nyers képkockát.
  A `070657/frame-00198→00240` képpár jelentős elmozdulást igazolt, miközben a köztes
  felhasználói aktivitásos várakozások helyesen nem léptették előre a stratégiát.
- A `070657-play` több mint 700 képkockán át érdemi kameramozgást, de nulla új jutalmat
  adott. A zöld előtérben balra mutató minimap és a zárfalőr együtt nagy területű,
  mégis hozam nélküli visszatérési hurkot képezhet.
- A `071943/frame-00034→00062` a bedőlt sátor zsebéből biomjel nélkül is kijutott.
  Ugyanott a narancs szikla képen látható volt, de a gépi biommező hamis `false` maradt.
- A `072159/frame-00088` explicit `YOU DIED` feliratot mutatott közvetlenül az
  Unstuck-tap után. A medencében 134, majd 717 és 747 HP következett; a hét fegyver
  megmaradt. Az Unstuck tehát a büntetésmentes halál/újraéledés saját UI-gombja.
- A `072159` első jutalomhiányos ágán a minimap balról felfelé fordult, miközben a
  karakter a sátortól a Titan-portálig jutott (`frame-00258→00302`). Az új irány
  azonban egy kerítés mögötti 499 HP-s humanoidhoz 335→164 pixelre közelített, majd
  statikussá vált. Az irányváltozás önmagában sem bizonyít járható vagy hasznos utat.
- A `091457/frame-00285→00290` sorozatban a 29m59s cooldown után újratermelődött
  499 HP-s, zöld fegyverkártyás hordozó 293→260→252 pixelen látszott, majd az
  általános ismeretlencél-kitérés 395 pixelre távolította. A felismerés helyes volt;
  külön, 270 pixelig engedett óvatos megközelítési sáv hiányzott.
- A `092709/frame-00038` 184 pixelen teljes 499-es hordozót mutatott. A következő
  OCR-minta `199` lett, de a célazonosság 499 és a zöld fegyverikon `0,037` maradt;
  a helyi 92/192/199 bossőr ezért fegyverikon jelenlétében nem alkalmazható.
- A `093024/frame-00718` bal `2x Reward` panelje két fekete kontúros vörös UI-csíkot
  adott 132 és 2 hamis HP-val. Farmcél nem lett, de `nearestThreat`-ként torzította
  a mozgást és egyszer hamis bossjelet is kapott; a rögzített HUD-zóna kizárandó.
- A `094545/frame-00180` a 499 HP-s hordozót a vízszintes tábori kerítés fölött,
  a játékost közvetlenül alatta mutatta. A 182 pixeles platóról induló nyolc bal
  oldali swipe elérte a kerítéssarkot, de a minimapos folytatás a
  `frame-00234` 1.22K-s őréhez vezetett. Az ebből felállított jobb oldali
  L-hipotézist a következő élő futás később megcáfolta.
- A `095752-play` megcáfolta a jobb oldali L-kerülőt: tizenkét jobbra swipe alatt
  a torony, hordó, kerítés és játékos mozdulatlan maradt. A 185–228 pixeles
  változás a hordozó járőrözése volt. A következő próba a járható bal oldalon
  tizenkét oldal + tizenkét kötelező befordulás.
- A `094545-play` 649. képe egyszer 781-nek olvasta a 778-as teljes HP-t, és a +3
  egyképes gyorsút tévesen tartós maximumot tanult. A 651. képen már 778 volt,
  jutalom nélkül; +3 mostantól két friss azonos OCR-t igényel.
- A `100443/frame-00163` lila barlangjában a karakter sín, sziklafal és csontív
  közé szorult. Tizenegy teljes statikus fázis sem mozdította, de a régi Unstuckot
  a hiányzó narancsszikla/bal minimapjel blokkolta. A hatfázisú kapu most minden
  cél nélküli, teljes HP-s Island 4-biomban működik.
- A `101003/frame-00572→00618` képsor igazolta, hogy a 499 HP-s hordozó kerítésének
  bal vége és külső oldala járható: tizenkét bal, majd tizenkét felfelé swipe valódi
  pályamozgást adott. A második láb után a minimap a Deep Mines 1.92K/7.15K őreihez
  térített, ezért a teljes kerülőhöz harmadik, jobbra visszatérő láb szükséges.
- A `102651/frame-00183→00228` újabb biomfüggetlen Unstuckot bizonyított a görbe
  kerítés, sátor, őrtorony és sziklafal zsebében. A karakter összeesett, majd a zöld
  medencében 352-ről 778 HP-ra gyógyult, és a 120 döntéses védett felderítés kijutott.
- A `102651/frame-00300→00449` védett spirál nagy kört tett, de végül visszatért a
  sátor–kerítés zsebébe. A lejáratkor már hat statikus swipe gyűlt össze: a védett
  módnak is kell könnyű, háromképes negyedfordulata, teljes faljárás nélkül.
- A `103900/frame-00330` a hordozó kerítéssarkát már a hetedik bal swipe-nál
  megmutatta. A tizenkettedik túlfutott, majd a negyedik felfelé mozgásnál az
  1.22K-s őr teljesen láthatóvá vált. A kompakt kerülő ezért 8 bal, 3 fel, 8 jobb.
- A `104751/frame-00252→00283` élőben megcáfolta a 8–3–8 út fizikai sikerét.
  Nyolc bal swipe elérte a délnyugati sarkot, három felfelé valóban északra
  mozgott, de a nyolc jobbra swipe a hosszú függőleges palánknak ment. A helyes
  útvonalnak hosszabban kell északra tartania, miközben a nyugati 1.22K-s őrtől
  kelet felé távolodik.
- Ugyanennek a `104751-play` futásnak a 866–877. képeit utólag végignézve a karakter
  mégis 59 pixelre zárt a hordozóra és megölte. A jutalom Bat Cleaver `9→10`,
  `Damage 450→500`; a 8–3–8 részút kudarca tehát nem volt a teljes futás végeredménye.
- A 10. jutalom pillanatában 20 kapott sebzés, majd gyors 769→778 gyógyulás látszott.
  Egy külön fehér 24 harci szám szerepe még nem azonosított.
- A Shop új `OPEN QUESTS` gombja tartós `Loading...` képernyőt okozott. X, Escape és
  Cancel sem zárta be; újraindítás után jogi Terms/Privacy `Continue` jelent meg.
- A mozgás minden második üres ciklusának oka a bot saját egéreseménye volt, amelyet
  a rendszer-idle mérés emberi aktivitásnak számított. Ez technikai önfékezés, nem
  játékbeli akadály.
- A `140735-play` első piros minimap-útja a 72. képen helyi szikla–víz–kerítés
  akadályhoz ért, de ez nem területhatár. A 242. képen másik útvonalon megjelent a
  `Dusty Gulch – 2` felirat, majd legalább hat 253 HP / +4 szíves cél 778→802-re
  növelte a hiteles maximumot. Az `UNLOCKS AT ISLAND 4` a fegyverhely HUD-ja.
- A `143131-play` 197–258. eseményei a Dusty Gulch oázisánál periodikus hurkot
  mutattak: bossmenekülés, rövid oldaljárás, piros minimap-visszakövetés, majd újabb
  azonos több tízezer HP-s bosskontaktus. A `143954-play` 6/13/19. kontaktusa után
  az új, harmadik találkozásos kapu a 32. képtől védett helyi felderítést indított.
- A `143131-play` 259–266. eseménye egy 1400 HP-s célon külön kontrollált próbát
  végzett. A saját HP 100→88%-ra esett, a bot eltávolodott, majd 100%-ra gyógyult;
  az erősebb, de mérhető ellenfelek kipróbálása tehát továbbra is aktív.
- A `143954/frame-00148` vizuális `11.4K` feliratát az OCR előbb `114K`-nak
  olvasta, a régi /100 kanonizálás pedig hamis 1140-es bosspróbát indított. A
  149–152. képen a 11.4K helyreállt és két külön 765-ös kaktusz is látszott.
  A pont nélküli 8K+ K-alak mostantól nem kontrollált próbaalap; az 1.22K-s
  fejszeikonos páncélos bizonyított aláírása az egyetlen szűk kivétel.
- A `144933-play` harmadik 1.22K-próbája valódi 1220→796 bosssebzést adott, miközben
  a játékos 802→776-ra esett. A bot a köztes `.22K/:22K` OCR-t téves 220-nak
  vette és megszakította a nyerhető harcot. Az előző ezres résszel végzett
  helyreállítás a `145530` és kontrollált `145713` replayben megtartotta a célt.
- A `145639-play` 14–26. döntése ténylegesen követte a piros minimapjelet, a 137.
  képen pedig 357 px-ről felismerte a 4.31K-s óriást. A közvetlen útvonalat a 200 HP-s
  lila Titan-oltár és sziklafalak keresztezték; 31 próbakereső döntés alatt a boss
  4.31K maradt, tehát támadási kontaktus nem jött létre. A későbbi Unstuck után a
  120-as helyi mód már indokolatlanul sokáig némította a piros jel követését.
- A `150906-play` 123. képétől a havas fennsíkon sok, egymásra fedő 1.16K-s cél
  látszott a karakter fölötti sziklafal túloldalán. A rajtuk megjelenő 30/120 sebzés
  saját támadási távolságon kívül történt, ezért nem a bot sebzése. A járható alsó
  út később egy külön 3.06K-s páncélos fegyverhordozóhoz vezetett. A bot 802→566
  numerikus HP-mélyponttal megölte; a jutalom új zöld fegyvert `2` példányra és
  `Damage 35→70` értékre emelt. A helyén kb. `29m 54s` cooldown indult, a játékos
  a 254. képre ismét 802 HP-ra gyógyult.
- A `152922-play` első hét döntése követte a piros minimapjelet, majd 314 px-re
  felismerte a 300-szíves, 11.4K HP-s kaktuszt. A visszafordulást a régi 8K-s
  kutatási plafon okozta, nem a térkép vagy a swipe hibája.
- A `153119-play` 44–58. képe kontrolláltan 11.4K→10.4K sebzést adott a nagy
  kaktusznak saját HP-veszteség nélkül; eltávolodás után a cél ismét 11.4K lett.
  A `153504-play` helyben tartva 11.4K→10.1K-t ért el 822/822 HP mellett, tehát a
  statikus cél folyamatosan támadható, de a harcon kívüli regeneráció gyors.
- A `153119/frame-00075` közvetlen +10 effektussal 812→822-re, a következő futás
  két további jutalomszakasza 842-re, majd `frame-00087→00088` újabb biztos +10-zel
  852-re emelte a tartós maximumot. A 822→842 közvetlen céltípusa még nem biztos.
- A `153504/frame-00090→00097` egy 765 HP-s, 15-szíves kaktuszt és közvetlen
  `+15` effektust mutatott; a következő képeken a hiteles teljes érték 868. A
  `153810-play` 898-as olvasatai ugyanennek a vizuális 868-nak 6→9 OCR-hibái.
- A `155618/frame-00119` egy 10-szíves kaktusz befejezésekor közvetlen `+10`
  effektust mutatott; a következő kép és a későbbi futások hiteles teljes értéke
  878. A köztes 898 és 929 nem stabil és nincs hozzájuk jutalombizonyíték.
- A Titan-terület nagy térképének bal felső peremén a piros fegyverjel a kör
  sugarán kívülre lóg. A régi kis-pont detektor ezért nem látta, noha a felhasználó
  számára egyértelmű ellenféljel volt. A `160206-play` új detektora már követte.
- A `160521/frame-00056` útvonal végén több 1.92K-s havas ellenfél jelent meg a
  párkány túloldalán. Hat kerülőfázis sem adott támadási kontaktust; ez jelenleg
  fizikai útvonal-/küldetéskapu-probléma, nem harci vereség.
- A `161327-play` 8–34. képein egy 4.4K-s páncélos állt a rózsaszín erődfal
  mögött. Három kerülő sem okozott HP-esést, ezért a bejárat továbbra is nyitott
  útvonalprobléma; a 4.4K-s célzár más bossnak nem adható át.
- A `162220/frame-00025→00029` képein a játékoscsík vizuálisan teljes és 908 volt,
  miközben az OCR 806-ot adott. Ez fantomsebzés: 97% fölötti pixeles csík mellett
  a 94% alatti numerikus jelölt nem indíthat menekülést.
- A `162945-play` három 672-es, 10. szintű lovagjának legyőzése után 908→938
  maximális HP jelent meg. A csoport egyedi tagjai a saját maximumnál gyengébbek;
  teljes HP-n az izolálási tilalom túl óvatos volt.
- A `163416-play` nagy kaktuszpróbája 11K→9.96K→8.81K→7.96K HP-s sort adott,
  saját 938 HP-veszteség nélkül. A képen 444 és 130 sebzésérték látszott. A régi
  12 képes célvesztési őr túl korán megszakította a még zajló automata támadást.
- A következő stabil jutalmak után a tartós maximum 953. A `164233-play` külön
  megmutatta, hogy a külső piros fegyverkomponens minden második képen a lila
  minimapikon ellenirányába villanhat; a körön belüli piros pont a megbízhatóbb
  ellenféljel.
- A `165856-play` a 11,4K-s passzív kaktuszt 9,68K-ról 2,44K-ra, majd 1,57K-ra
  sebezte saját HP-veszteség nélkül. A 48. takart képnél elmozdult, ezért a cél
  10,1K-ra regenerálódott: a cél nyerhető, a megszakítás volt hibás.
- Ugyanebben a harcban az átfedő test és fegyvereffektus egy képre 14%-os hamis
  saját pixelcsíkot adott; a környező friss numerikus képek teljes HP-t mutattak.
- A narancssziklás magaslat keskeny, hidakkal összekötött egyszeri ládazóna. A
  ládák begyűjtése után nincs ismételhető farmértéke. A közeli 18,8K-s páncélos
  egy kontaktusban 984→94 HP-t okozott; a kézi Unstuck ezután a zöld medencéhez
  vitt vissza. A teljes érték több képen 984 volt.
- A `world-map.json` első élő csomópontjai már ugyanazon háttérnél külön rögzítettek
  sikeres és blokkolt irányokat; a döntő ezek alapján oldalirányú kerülőt adott.
- A `172808-play` a magaslati kitérő után normál zöld terepre jutott, de az íves
  fakerítés–sátor zsebben ismét statikussá vált. Az automatikus Unstuck megnyitotta
  a Settings panelt, ahol `04:39` időzár futott; a panel sötétített háttere 80%-os
  ál-HUD-ot adott, ezért a régi sikerfeltétel nyitott menüre küldött swipe-okat.
- A különleges magaslati láda egyszeri. A kifosztott hely csak új láda-, küldetés-
  vagy ellenfélbizonyítékkal válhat ismét célponttá; puszta korábbi térképirány nem
  ismételhető farmérték.
- A `174104-play` narancssziklás folyosóján a régi ládahelytől függetlenül több
  1,16K-s csík és velük egyező belső piros pont látszott 423–502 pixelen. Később
  egy 3,06K-s próba 984→928→905 numerikus HP-sort adott; közeli új cél mellett
  a 33%-os pixeles esés biztonsági visszavonulást indított.
- A `174731-play` már 1,28K-s és 2,49K-s kontrollált próbát indított. A harci
  szakasz után a teljes csík fölött vizuálisan 999 állt, pontosan +15 a 984-hez
  képest. A numerikus OCR hiánya miatt a visszavonulás 60+ teljes pixeles képen
  át bent maradt; nyolcképes, fenyegetésmentes feloldás készült.
- A `175358-play` a 11,4K-s, 300-szíves kaktuszt végig helyben tartva legyőzte.
  A 95. képen `5m49s` cooldown és teljes `1.3K` saját HP látszott: 999+300=1299.
  A régi harczár csak a 120-as memória végén indult tovább, mert a timer nem a
  szűk HP-ROI-ban volt; zöld körív + középső rövid timer detektor készült.
- A `180120-play` kezdetén a karakter a rózsaszín sziklaépület magas peremén,
  egy 4,4K-s fegyverjutalmas boss fölött állt. A minimap-irányeltérés miatt a régi
  döntő ismételten távolodott; 5K alatt, 360 pixelen belül közvetlen próbát engedünk.
- A `180420-play` 9–18. döntése egy új különleges láda `OPEN`→`TAP TO CLAIM`
  sorát bizonyította. A hely és az 5. iránybin `collectedChestDirections=1`
  állapotban bekerült a tartós világtérképbe.
- A 4,4K-s őrrel átfedő teljes `1.3K` zöld csíkból a komponensdetektor 22 pixeles
  részletet és hamis 32%-ot mért. Az őr HP-ja változatlan maradt, a következő tiszta
  saját mérés ismét 1299 volt.
- A `181257-play` több helyben álló támadási ablaka alatt egyik fél HP-ja sem
  változott. A 106/212. képek igazolják, hogy az őr a belső DOC-udvarban, a játékos
  a külső párkányon állt: a képi közelség ellenére eltérő magassági rétegen voltak.
- A magaslati Unstuck 0 HP-s átmenet után a zöld központi medencéhez vitt, majd a
  bot nyílt csontmezőn át elérte a `Dusty Gulch – 2` területet. A belépőoverlay
  külön `Enemy weapon` és `Weakness` ikont mutat; ez taktikai információ, nem HP.
- A `183754-play` 3,06K-s őrén a karakter egy váltásban körülbelül 490-et sebzett,
  miközben csak 60-at kapott. A cél tehát nyerhető; a régi célazonosság azért
  szakadt meg, mert az őr közelharcban átkerült a karakter másik oldalára.
- Ugyanebben a futásban a második 11,4K-s, 300-szíves kaktusz 699 HP alá, majd
  cooldownra került; a maximum 1299→1599 lett. Későbbi kisebb jutalmak után
  `1.64K`, egy újabb nagy kaktusz után `1.94K`, végül pontos 1940/1940 látszott.
- A különleges láda egyszeri; a normál farmpont visszaszámlálós és ismételhető.
  A kettő tartós térképállapotát külön kell vezetni.
- A `185715-play` 143. képe tisztán mutatta a Deep Mines lila köves kapuját és
  a rajta átvezető türkiz sínt. Fölötte 1,92K-s, 20-szíves fák és egy 7,15K-s
  objektum vannak; a 0/1 anti-stone potion mellett a kapun nem lett kontaktus.
- A sín U-kanyarjának két ága előre/hátra billentette a korábbi vektort. Az
  északi tájolás megszünteti az ingázást. A 7,15K→1,92K érték másik, szíves fa
  téves átvétele volt, nem valódi 5230 sebzés.
- A Deep Mines `Find a magic anti-stone potion ... 0/1` buboréka bal, a Titan
  `Collect all gems ...` buboréka jobb képszélre is kerülhet. A `191141-replay`
  és `191112-replay` külön oldalsó OCR-területekkel helyesen szétválasztotta őket.
- A `190457-play` 307–338. döntése bizonyította az automatikus magaslati
  helyreállítást: hat sikertelen statikus irányfázis után a bot megnyitotta a
  Settings panelt, megnyomta az Unstuckot, kivárta az áthelyezést és a medencés
  gyógyulást, majd önállóan folytatta a területelhagyást.
- Az egyszeri láda lezárása csak az adott képi csomópont adott irányára vonatkozik.
  A teljes magaslati biom továbbra is hosszú távú felderítési terület.
- A `191302-play` két oldali 1,92K-s megközelítése kontaktus nélkül a `0/1`
  táborba ért vissza; ez újabb biztos bizonyíték a zárt Deep Mines-kapura.
- A `192249-play` 60. képe teljesen megmutatta a rétegeket: a játékos a zöld
  alsó táborban, a 1,92K-s szívfák és a 7,15K-s őr a lila híd fölötti havon álltak.
  A távoli csíkok `2`/`20` HP-olvasata szint- és szívikon-szennyezés volt.
- A `192300-replay` 109–118. döntésében az új 18,8K-s pallóív tíz képen át
  megmaradt a célcsík eltűnése mellett is; a korábbi háromképes feladás megszűnt.
- A `world-map.json` 400 csomópontnál már 2938 próbát, 946 blokkolást és 222
  kerülőt tartalmazott, de a régi ládacsomópont LRU-evikcióval elveszett.
- A `180420-play` 4. képéből a második láda 33 elemű háttéraláírása és 5. iránybinje
  hitelesen helyreállítható volt. A külön `semantic-map.json` ezt újraindítás után
  is egy begyűjtött helyként őrizte; a legelső, naplózás előtti láda nem rekonstruálható.
- A `192554-play` 103–134. döntése újabb teljes automatikus
  Settings→Unstuck→áthelyezés→gyógyulás láncot bizonyított 1940 maximumnál.
- A `193049-play` három magaslati fázis után már a 48. döntésben Unstuckot próbált.
  A gomb visszaszámlálós volt; az 54. döntés bezárta a panelt. Ez bizonyította,
  hogy az Unstuck játékoldali cooldownját újraindítások között is tárolni kell.
- A `193049-play/frame-00054.png` `06:25` Unstuck-felirata a szűk gomb-ROI
  replayében pontosan 385 másodperc. A tényleges lejárat utáni kézi Unstuck a
  zöld medencéhez vitt, ahol a karakter 426-ról 1940-re gyógyult.
- A `194114-play` újra bizonyította a Deep Mines-kapu elérhetetlenségét, de az
  egyszeri déli swipe után a villogó `0/1` buborék réseiben a piros minimapjel
  több mint száz döntésre visszahúzta a kapu köré.
- A `194735-play` konkáv szikla–ház zsebéből a célhoz képest lefelé forduló út
  adott valódi mozgást; a legfeljebb 90 fokos térképi alternatívakészlet kevés.
- A `195052-play` Unstuckja sikeres volt annak ellenére, hogy a Settings öt képen
  át megmaradt. A hatodik kép már a zöld medencét mutatta: számláló nélküli panelnél
  az öt képes sikertelenségi küszöb túl rövid.
- A magaslati különleges ládahely egyszeri hozamú, de a teljes magaslati hálózat
  későbbi felderítése továbbra is szükséges. Az ottani korlátozott mozgás külön
  magassági réteg, nem pusztán rosszul választott swipe.
- A `202322-play` a sikeres Unstuck után teljes 1940 HP-val indult a zöld medencénél,
  majd az északnyugati piros minimapjel 64 döntés alatt visszavitte ugyanabba a
  narancssziklás magaslati zsebbe. A 65–81. délkeleti kiszakadás újra zöldre ért.
- A `202055-play` gépi gear-koppintása nem nyitott Settingset, a friss UI-állapot
  utáni közvetlen kattintás viszont igen. A koordináta helyes; az ablakaktiválás
  és az első down esemény között időzítési verseny van.
- A kézzel megnyitott teljes térkép a zöld–narancs határon álló karaktert, egy
  északnyugati piros koponyát és narancs ellenféljelet, egy északkeleti zöld oldali
  ellenféljelet, keletre a lila Titan-jelet, valamint türkiz és zöld átjárójeleket
  mutatott. A világ nem egyetlen sík: a térképi közelség topológiai kapcsolat nélkül
  nem járhatóság.
- A `211939-play/frame-00098→00100` bizonyította a Dusty Gulch-kaput: a zöld
  határról nyugat–délnyugatra kell kerülni, majd tisztán nyugatra áthaladni. A
  `Dusty Gulch – 2`, `Enemy weapon`, `Weakness` overlay biztos területváltás.
- A `211939-play` 114. képe több körülbelül 1,16K-s havas ellenfelet, a 125. kép
  18,8K-s páncélost mutatott. A `212644-play` 85. képén egy külön 4,4K-s
  fegyverjutalmas őr állt a DOC-udvarban.
- A `212644-play` 45–58. képein a közvetlen északnyugati mozgás a nagy kaktusz és
  sziklafal miatt teljesen statikus maradt. A 4,4K-s őr a rózsaszín ív mögött,
  másik magassági rétegen volt; HP-ja nem csökkent.
- A `213307-play` 49–123. képe a városi felső ládaplatót mutatta. A karakter
  körül 79–82% narancsszikla és középső órás időzítők látszottak, miközben a
  4,4K-s őr alul maradt. A 123. döntés automatikusan megnyitotta az Unstuckot.
- Az Unstuck után a zöld medence 690 HP-ról 1940-ig gyógyította a karaktert. A
  `214244-play` már normál zöld járószinten indult; ott újabb Unstuck nem kellett.
- A `214244-play` alsó városi útja 87% narancssziklát és több középső órás kört
  is adott. A régi háromfázisos narancsőr a 80. képen tévesen Settingset nyitott;
  a `02:43` Unstuck-időzár miatt nem történt teleport.
- A nagy térkép a jelenlegi orange pozícióból egy új arany ládát mutatott messze
  északon. A közeli türkiz négyzet balra-délnyugatra, a piros ellenfél északnyugatra
  állt; a rétegváltót a boss helyett előbb a türkiz kapupont felől kell keresni.
- A `220041-play` délnyugat→nyugat→észak útja a 4,4K-s DOC-őrt
  427→332→237→167 pixelre hozta. A végpontnál házfal-létra, szekér, rövid
  fakerítés és rózsaszín ív rajzolta ki az udvar valódi kapuzónáját.
- A 4,4K HP-ja 167 pixelen is változatlan maradt, és saját sebzés sem történt.
  A szekér/fakerítés mikrokapu még útvonalpróba, nem harci vereség.
- A `220041-play/116` nyers `4:4` felirata `4` HP lett, miközben a 71 pixeles
  csík és az őr teste azonos maradt. Ez kanonikusan 4400, nem alacsony farmcél.
- Az általános akadálytérkép a 99–106. képen felülírta a kontrollált bosspróba
  oldallábát. A harci próbák és a nagy térképből levezetett fix útvonalak most
  kivételek az általános adaptáció alól.
- A `220802-play` 237–256. képe bizonyította, hogy a navigáció a kifosztott
  magaslati ágra ismét visszajuthat. A 75% fölötti narancsszikla és a karakter
  melletti felismert `3h44m` visszatöltési kör együtt erős rétegjel; ugyanaz a
  közeli timerjel az alsó narancs ellenpéldán végig hiányzott.
- Az ismételt kézi Unstuck a zöld Meadowlands gyógyítómedencéhez vitt, a karakter
  teljes 1940 HP-val érkezett. A hely ezért kifosztott mellékág, nem aktív farmkör.
- A `222821-play` 82. képén a déli falvégi út egy fapallós magaslati platformon
  `You found 2/57 chests` üzenetet váltott ki. Külön OPEN/CLAIM nem jelent meg;
  a 2/57 számlálónövekedés önmagában biztos, közelségi világ-ládaprogresszió.
- A fapallós hely zöld fedettségű, mégis korlátozott topológiai mellékág. A láda
  beszámítása után az automatikus Unstuck teljes 1940 HP-val Meadowlandsre vitt.
- A `224235-replay` a `You found 2/57 chests` képből automatikusan pontosan `2`
  felfedezett ládát olvasott; a tartós számlálódetektor élőképes.
- A `224547-play` északkeleti zöld útja 4,31K HP-s, 500 szívjutalmas nagy fához
  vezetett. A Titan-kőobjektum mögött 412→291 pixelre közelítettük, de kétoldali
  sebzés nem történt; a jobb oldali völgy további topológiai kerülőt igényel.
- A `225035-play` Deep Mines-kapujánál több 1,92K/20-szíves ellenfél és egy
  7,15K-s fegyverhordozó áll a havas felső oldalon. A `magic anti-stone potion
  0/1` feladat zárja a hidat; a célok vetületi közelsége nem járhatóság.
- A Deep Mines déli kijárata a járható zöld Island 4-táborba vitt, ahol az OCR
  biztosan felismerte a `Collect all gems ... Titan's power 0/7` küldetést.
- A tábor sátor–fakerítés sarka alsó szintű navigációs zsákutca, nem magaslati
  réteg. A kézi Unstuck `YOU DIED` átmenettel a közeli gyógyítómedencéhez vitt,
  teljes 1,97K kijelzett HP-val és továbbra is látható Titan `0/7` állapottal.
- A medencétől az északkeleti út új futásban 24 döntés alatt ismét elérte a
  4,31K/500 szíves fát; ez rövid, reprodukálható gráfél.
- A `230318-play` 0–3. képén a 4,31K-s fa 373→284→222→133 pixelre került, majd
  eltűnt. Később stabil `2.47K` saját HP és körülbelül 59 perces helyi cooldown
  jelent meg: az 1.97K→2.47K pontosan a kiírt +500 szívjutalom, tehát biztos győzelem.
- A `230959-replay` a javított nagymaximum-konszenzussal automatikusan 2470 HP-t
  és maximum-növekedési eseményt adott; a tartós gépi maximum most 2470.
- A nagy térkép Island 2-n két külön koponyát mutat: egy narancsot és egy
  északnyugatabbra álló rózsaszínt. A lila jel a zöld Titan-portál, nem ellenfél.
- Narancs biomon a lila jel követése egy swipe alatt visszateleportálhat a zöld
  oltárhoz. Island 2 küldetésben ezért a piros cél mindig elsőbbséget kap.
- A Mailbox két tapra nyílik és jelenleg üres. A Shop egy tapra nyílik;
  `FREE IN 23h 53m` mellett nincs átvehető napi jutalom.
- A 4,4K-s DOC-őr ismét megtalálható volt, de a `4.4K` rövid OCR-képe `4`.
  Ez nem 4396 sebzés; kanonikusan továbbra is 4400.
- A `015923-play` Island 2-s útja kis helyi célokat ölt és több jutalmat
  szerzett. A további keleti átjáró azonban zöld területre vitt, ezért az
  Island 2 útvonalának szigetazonosító védelem kell.
# 2026-08-30 – Island 2 alsó tábor

- A saját kijelzett maximum legalább 3,27K, az aktív build Bat Cleaver 11 és
  Steel Splitter 17.
- A 3,06K-s páncélos a járható alsó táborban közvetlen kontaktusba kerülhet,
  miközben a 4,4K-s DOC-őr ugyanazon a képen más magassági rétegen látszhat.
- A nagy térképi koponya célzónát jelöl; a képen látható legnagyobb HP nem
  feltétlenül a következő fizikailag elérhető ellenfél.
- UI-ellenőrzés: 796 DPS, 3,27K HP, 39 regen; Shop free 20h55m múlva;
  Mailbox üres; Bat 11 + Steel 17 maradt felszerelve.
- Az alsó arénában a maximum hitelesen 3,30K-ra nőtt. A 3,06K-s őr járható;
  a 4,4K-s DOC jobb oldali kerülője viszont magaslati csapdába vezet.
- A további alsó arénás farm alatt a Steel Splitter 18-as szintre nőtt,
  a saját maximum pedig vizuálisan 3,38K-ra emelkedett.
- A 3,38K-s feliratot a Vision egymást követően `BET`, `X8ET` és `8E`
  alakban is adta vissza; a pusztán kinyert 8-as ezeken a képeken nem valódi HP.
  Ugyanekkor a saját zöld csík vizuálisan teljes volt.
- A következő élő arénakörben két 2,49K-s, 15-szíves őrrel kerültünk
  kontaktusba; legalább az egyik 151 HP-ig csökkent, majd +15 effektus látszott.
- A 27,7K-s lovag 320-as sebzéseket osztott. A saját sor
  `2,95K → 2,69K → 2,43K → 1,59K → 1,34K → 767 → 514 → 261 → halál`,
  a lovagé legalább `27,7K → 23,7K` volt.
- Az automatikus újraéledés után a teljes saját kijelzés 3,43K, a Steel
  Splitter pedig 19-es lett. Az 50 HP pontos forrása több egyidejű kis cél miatt
  még nem köthető egyetlen ellenfélhez.
- Friss teljes UI-audit: 823 DPS, 3,43K HP, 44,5 regen, `118+778`, `54+1%`;
  Bat Cleaver 11 + Steel Splitter 19 felszerelve, tartalékok 1/8/13.
- A piros jelzésű Mailbox panel ismét `You have no Mails yet`; a Shop
  `FREE IN 19h 52m`, ezért most nincs ingyen átvehető napi jutalom.
- A Titan-medencétől induló közvetlen nyugati makró a hajótest/rámpa konkáv
  zsebébe tért vissza. A reprodukált kijutás `12 N → 14 W → 10 E → 18 N`,
  amely közvetlenül a Deep Mines 0/1 kapu elé vitt.
- A határzsebben automatikusan legyőzött 192 HP-s kis ellenfél után a Steel
  Splitter 19-ről 20-as szintre fejlődött.

# 2026-08-30 – 4,41K HP, ismétlődő nagy kaktusz és Island 2 visszaút

- A nagy `300` szíves kaktusz többször újratermelődött, nem sebzett és minden
  biztos győzelem tartós +300 maximumot adott. A megfigyelt újratermelődés
  körülbelül 4–6 perc; a hiteles saját maximum most 4,41K.
- A `451K`, `4.11K` és `4.11Kg` alakok ugyanazon vizuális `4.41K` csík OCR-hibái.
- A közönséges 1,28K-s kaktusz eltűnése után nem nőtt a 4,41K maximum; külön
  célosztály a nagy, szívikonos farmkaktusztól.
- Az 1,22K-s és 3,06K-s őrök járhatók; utóbbi 3,77K saját HP mellett csak kb.
  60 HP-t sebzett. A 18,8K-s boss ugyanennél az erőnél gyorsan megölt.
- A Shop `FREE IN 19h 20m` állapotú volt; fizetős Squire/Warrior ládákon kívül
  nem volt átvehető jutalom. Az audit 832 DPS-t, 44,5 regent és `118+790`
  támadást mutatott; a későbbi farm végére Steel Splitter 22 lett.
- A teljes Titan→Island 2 útvonal és a 16S→6W→12S alsó kanyonél élőben ismét
  bizonyított. A 4,4K-s DOC-őr továbbra is más magassági rétegen látszik.
- A 27,7K-s lovag 4,41K saját maximum mellett 20,1K-ig sérült, majd 320-as
  találatokkal megölt. A `YOU DIED` biztos OCR-je ellenére a régi HP-memória
  teljesnek látta a játékost; külön haláloverlay-alapú bossmemória készült.
