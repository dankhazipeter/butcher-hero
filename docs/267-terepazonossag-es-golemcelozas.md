# Terepazonosság és gólemcélzás — 2026-09-19

## Kiinduló bizonyíték

194412/14: LocalWorldMapchart62 képi egyezéssel, V2mégorange-skull;
a sátorhoz visszavezetőfrontier nem stratégiai fejlődés.194800-418a6ec2-observe/0
friss7,06K, sátor keleti oldalán, Deep MinesNPCészakkeletre. Nincs új jutalom.
A265-ben bizonyított két azonos narancsfej miatt az ikon önmagában nem lehet
egyetlen globális koordinátarendszer origója.

## Javítás

1. A V2 mindig a LocalWorldMap képi/minimap/képi-elmozdulási ellenőrzéséből
   származó terrainchartot használja, ha elérhető, már az első képen is.
   Ugyanez a koordinátarendszer elsődleges checkpoint-visszaállításkor.
   A korábbi feltételes terrain-elsőbbség és `anchor ?? atlasPosition` keverés
   megszűnik. Máschart nem örökli a régicélt/kerülést. Az archívikon-térkép
   megmarad, de nem írhatja felül a bizonyítottterepet.
2. Új `golemMapOffset`: friss, sablonnal felismert narancsfej RELATÍV
   eltolása a minimap játékosjeléhez képest. Nem egyedi helyazonosító.
   Kinagyított térképen és szürke/halottfejnél nincs ilyen cél.
3. Célprioritás: látható kiválasztottvilágcél → pirosfarmpont → friss
   narancsfej megközelítése → általános helyifelderítés. A gólemirányból
   legfeljebb18helyitérképi egységnyi köztescél képződik;8pxalatti ikont
   már nem üldözünk. Ez folyamatos képi visszacsatolás, nem swipe-makró.
4. Ugyanaz az A*/akadálymérés/kerülés kezeli az új célcsatornát.
   Közeli fenyegetés, harc/gyógyulás, UI és helyzetbizonytalanság kapui
   változatlanok. A célhoz odakeresés NEM általános támadási engedély.

## Tesztek és korlátok

V2tesztek: elsőképen együttjelenlévő terep+tévesikon; újraindulásmásik
ikoneltolással, azonoscharttal megtartottkerülés; ugyanazikon újcharton
nem viszirégiútvonalat. Régi fal39/37lépés gyorsításnélkül/gyorsítással,
szűkkapu18lépés, kihagyottinput, folyosók, fordulásirány:PASS.
ÚjGolemApproachPolicyE/Wirány,18korlát,8pxkontaktus,NaN/infinity:PASS.
Build,gólemikon/nagytérkép/szürkeikon,átfedőkontaktus ésquickfarm:PASS.

Nem kész teljes globálisSLAM vagy igazoltút a nyugatibosshoz. Az atlas
is lehet több helyi chart; ezek között csak mért kapcsolattal járhatunk.
A puszta rövid felderítő cél nem tanít magassági átjárót. Élő25s ellenőrzés
következik ugyanabból a frissen látott sátor melletti kezdőpontból.

## Első élő eredmény és második ok

195148-16623b89-play/0–4: terrain-chart-63,5–13képi visszaazonosítással
terrain-chart-54. Tehát az ikon már nem írja felül a terepkoordinátákat.
13: frissgólemeltolás−65/+7,5;V2cél−76,80/−53,78,poz−58,92/−55,85.
Ez már a nyugati gólemhez irányuló cél, nem véletlenfrontier.
Az út még nem sikerült: a sátor mellől csak a keleti oldal felé került.

195334-d831c32f-play/0–11újraindítva **chart64** keletkezett. Újonnan
tanulja a közel azonos sátorfalat, így a terrainelsőbbség önmagában kevés.
Nincs új jutalom, saját7060. A195148/13→194313régi képek közötti
útösszekötést aVisualOdometry audit elutasította; ezért abból nem készült
kitalált átjáró/koordináta. Változatlan futást nem ismétlünk.

## Utolsó képkockás folytatás

A LocalWorldMap eddig két, leírók alapján rangsorolt történeti képből próbált
visszaazonosítani; a futás utolsó megfigyelését nem részesítette előnyben.
Új opcionálischeckpoint:chart,pozíció,terep/minimap-leíró és az utolsó PNG.
Folytatáshoz mindkét leíróegyezés és képi-elmozdulási mérés kell
(legalább15egyezőpont,3,5alatti hiba,160pxalatti elmozdulás). UI/inaktív
képből nem tanul, ismeretlen kép nem kapja meg a régi koordinátákat.
A végsőswipe utáni új kezdőkép helyét így az utolsó mentett képből mérjük,
nem a korábbi koordinátát másoljuk rá.

V2: ugyanazon, fent ellenőrzött terraincharton legfeljebb6egységnyi utolsó
swipe-elmozdulásnál megtartja a kerülőoldalt; nem követel újra képi pixelazonosságot.
Terepellenőrzés nélküli ikonmódban marad a régi3egység+szigorúképegyezés.
Teszt:10pxeltolt első képen ugyanazchart,mért−10/−10hely; idegen üreskép
nem örökli. Régiolvasási/nemírási,akadály,útvonaltesztek továbbraPASS.
Élőképes folytonossági ellenőrzés még következik.

## Valódi újraindítási regresszió és helyesbítés

195734-17926fcb-play/6→195800-71979fb3-play/0: a kezdeti checkpointváltozat
még elbukott, chart64helyett63-ra tért át. A képi-elmozdulás külön mérve
érvényes:playerdx−59,13/dy−1,60,105egyezőpont,2,772hiba. Viszont a nyers
terepképek átlagkülönbsége20,606, éppen a20-as kapu fölött; minimap8,02.
Tehát a kamera rendes utolsó mozgását tévesen új helynek minősítette.

A véglegescheckpointvizsgálat a régi képet a mért kameramozgással eltolja,
és az így igazított terepképet hasonlítja12-es küszöbnél; a nyers különbség
csak40-es előszűrő. A minimap<18,legalább15pont,hiba<3,5és160pxmozgáskorlát
megmarad. Nem pusztán feljebb állítottuk az azonossági kaput.
Az új, valódi59pxképpáros regresszió ugyanazchartot és mért helyet állít vissza,
az üres idegen kép továbbra különchart. LocalMap/V2tesztek ésbuildPASS.
195734/0már a korábbiV2kerülőoldalt megőrizte a chart64-en; a geometriai
sátorkerülés ettől még nem teljes. Az utolsó élőpróba külön következik.

## Élő végellenőrzés — 20:01

200129-6baf4fd1-play/0: **checkpoint + scene + minimap + verified motion
relocalized**, ugyanazchart63, képi korrekció+3,76/+25,95világpixel.
V2terrain-chart-63,poz−8,13/−3,26.1mértfolytatás, nincs újchart,
saját7060. Ez az újraindítási folytonosság élő bizonyítéka.

**Nem oldódott meg a sátor geometriai kerülése.** A1-es képen továbbra a
sátor keleti oldala/palánk melletti zsebben vagyunk, a nyugati cél a fal túloldala.
A közvetlenWpróba xirányban0,csak4pxkameracsúszást adott. Az utolsóinput
dél felé történt; friss kezdőkép kell. Nincs új ölés vagy jutalom ebben a ciklusban.
Következő: az előzőleg ténylegesen bejárt **kelet/délkelet → dél → délnyugat**
kerülő képi pontjainak friss bemérése és a stabilchartba kötése, célhoz kötött
folyosóként. Ne indítsuk változatlanul percekig a nyugati ikont követő faltapogatást.
