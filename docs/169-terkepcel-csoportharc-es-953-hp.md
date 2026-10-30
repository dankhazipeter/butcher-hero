# Belső térképcél, csoportharc, nagy kaktusz és 953 HP

## A térképjel helyes prioritása

A `162633-play` képei cáfolták, hogy minden, a minimapkör mellett látható piros
fegyveralak önálló távoli cél. A körön belüli piros pontok közben három 672 HP-s
lovagot jeleztek jobbra-felfelé, a bot mégis a külső piros komponens alapján balra
nyomta magát egy épületnek. Az aktuális szabály ezért:

1. a körön belüli legközelebbi piros ellenfélpont az elsődleges;
2. külső piros irányjel csak akkor használható, ha nincs belső piros pont;
3. egy látható nagy ellenfél csak akkor írhatja felül ezt, ha képi iránya egyezik
   a térképen kijelölt iránnyal.

## A 672-es lovagcsoport eredménye

A `162945-play/frame-00023` három, 10. szintű, egyenként 672 HP-s lovagot mutatott
a karakter előtt. A korábbi célbiztonsági szabály csak teljesen izolált humanoidot
engedett, ezért a csoportot tévesen kerülte. A büntetésmentes újraéledés és a 938
körüli saját maximum mellett ez indokolatlanul óvatos volt.

A futásban a bot végül közelharcba került velük, a csoport eltűnt, majd a
`frame-00038` már 938 maximális HP-t mutatott a korábbi 908 helyett. Ez erős képi
bizonyíték három darab +10 szívjutalomra. Új taktikai szabály: teljes HP-n, legfeljebb
három közeli társ mellett a saját maximumnál nem erősebb humanoid tudatosan
vállalható csoportcél.

## A 11,4K-s szívkaktusz valódi harci modellje

A `163416-play` igazolta, hogy a 11,4K HP önmagában nem jelent erősebb ellenfelet.
A 300-as szívikonú kaktusz passzív maradt, miközben a karakter helyben állva
automatikusan támadta:

- `frame-00008`: kb. 11K HP;
- `frame-00013`: 9,96K HP;
- `frame-00019`: 8,81K HP;
- `frame-00024`: 7,96K HP;
- saját HP közben 938 közelében maradt;
- a képen külön 444 és 130 sebzésértékek jelentek meg.

Ez bizonyítja a felhasználó felvetését: a saját és ellenfél-HP puszta összevetése
nem elég; a sebzés, a támadási ritmus és az számít, hogy az objektum visszaüt-e.
A kaktusz regenerálódik, ha a karakter eltávolodik, ezért támadótávolságban helyben
kell maradni a befejezésig.

Az első helyben tartási őr 12 takart képkocka után tévesen feladta a harcot, noha
a mentett képen a csík továbbra is látszott és csökkent. Az új őr 48 elemzési képig
megtartotta a közeli passzív nagy kaktuszt; jutalom, újratermelődési időzítő, valódi
sebzés vagy halál ezt továbbra is megszakítja.

**Későbbi helyesbítés:** a 48 kép sem volt elég: a következő futás 1,57K HP-nál
mozdult el, majd a kaktusz 10,1K-ra regenerálódott. Az aktuális 120 képes szabályt
és a 984 HP-s későbbi állapotot a 170. fejezet rögzíti.

## HP-felismerés és új maximumok

A teljesen zöld 908-as csíkot az OCR sok képen 806-nak olvasta. A 97% fölötti
pixeles csík most felülbírálja az olyan numerikus jelöltet, amely 94% alattinak
látszana; ezzel megszűnik a fantomsebzés miatti menekülés.

A dokumentált állapotsor ebben a ciklusban:

- 878 → 893: közvetlen +15 szív;
- 893 → 908: újabb közvetlen +15 szív;
- 908 → 938: a három 672-es lovag után +30 összesen;
- 938 → 953: egy további +15-ös cél után stabil, friss OCR.

A fejezet végén mért tartós maximum: **953 HP**. A későbbi aktuális maximum 984.

## A 4,4K-s erődőr nyitott útvonalproblémája

A `161327-play` 8–34. képei egy 4,4K-s páncélost mutattak a Dusty Gulch rózsaszín
erődfala mögött. Három iránypróba sem okozott HP-esést; ez útvonalhiba, nem harci
vereség. A cél HP-sávját a bot most rögzíti, más kaktusz nem veheti át a próbát,
és kontaktus nélküli útvonalmegszakítás után ugyanaz a 4,4K-s sáv később újra
próbálható. Nyitott feladat az erőd bejáratának képi felderítése.

## Aktuális következő kísérletek

- A 11,4K-s kaktuszt az új 120 képes helyben tartással ténylegesen befejezni és a
  300-as szívjutalmat ellenőrizni.
- Új belső piros térképpontnál közvetlenül a jelzett ellenfélhez menni, nem a
  külső stat-/fegyverikonhoz.
- A 4,4K-s erődőr fizikai bejáratát megtalálni, majd külön mérni a kiosztott és
  kapott sebzést.

## Felügyeleti utóteszt: lila ikon és külső piros villogás

A `163736-play` 62–176. döntése a lila minimaphely két ellentétes iránya között
ingázott. Az `164233-play` strukturált naplója elkülönítette az okot: a lila irány
stabilan kb. `(0,80; 0,60)` maradt, de minden második képen egy külső piros
komponens `(-0,76; -0,65)` irányban `edgeObjectiveVisible` lett és megelőzte.

Javításként a belső piros pont továbbra is közvetlen elsőbbségű, a bizonytalan
külső komponens viszont a türkiz út és a lila landmark mögé került. A lila ikon
valódi oldalváltásához ezen felül három egymást követő, egyező irány kell. A
`164445-play` első 9 döntése stabilan a lila helyhez tartott; a korábbi minden
képes oda-vissza fordulás megszűnt.
