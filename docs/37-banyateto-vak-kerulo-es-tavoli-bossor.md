# Bányatető, vak kerülő és távoli bossőr

## Élő anomália — `20260829-005645-play`

A narancs bányatáborban a háttér-ujjlenyomat statikusnak minősítette a cél felé vezető
utat. Az ismert navigációs vektorra merőleges, tízlépéses kerülő ezután akkor is végigfutott,
amikor a kamera már mozgott. A `frame-00166.png` képen a karakter egy fa bányatető és a
sziklafal közé került; a kép felső szélén több `1.16K–1.6K` körüli ellenfél látszott.

Ez nem bemeneti hiba volt: a változó háttér és célpozíciók bizonyítják, hogy a swipe-ok
végrehajtódtak. A hiba a túl hosszú, köztes újraértékelés nélküli manőver volt.

## Kockázati bizonyíték

Ugyanebben a futásban a játékos egyszer `420→404→148` HP-ra esett, majd a friss
sebzésőr kimenekítette és a regeneráció visszahozta 420-ra. Nem bizonyított, hogy ezt
pontosan melyik ellenfél okozta, de a helyzet igazolja: az 1K fölötti ellenfelek
közelében a 220 képpontos régi bossküszöb túl késői.

## Programdöntés

- A statikus akadálykerülés ismert és ismeretlen navigációs iránynál is összesen
  legfeljebb négy 0,70 másodperces swipe.
- A korábbi tízlépéses változat történeti taktika: a Deep Mines kapuszélének elérését
  bizonyította, de nyílt terepre jutva túl sokáig vakon folytatta a mozgást.
- A `bossEvidence` vagy legalább 800 kijelzett HP már 360 képponton belül megszakítja
  a célkövetést, a küldetésutat és az aktív kerülőt; a bot az ellenkező irányba söpör.
- A biztonsági módosítás után a `20260829-010055-play` futás indult el azonnal. A
  karakter 420 HP-ról folytatta, és az első észlelt sebzésre 81%-nál visszavonult.

## Boss-visszafordulási hurok és második javítás

A `010055-play/frame-00164.png` új veszélyt igazolt: a karakter mellett 13-as szintű
ellenfelek, balra `11.4K` HP/300 szív, feljebb 765 HP/10 szív látszott. A 360 px-es
őr a 91., 162. és 164. eseménynél helyesen menekült, de amikor a boss egy képre
eltűnt, a minimap a 166–169. eseménynél visszavezette a csoportba. Ezután a játékos
`424→370→325→…→162` HP-ra esett, mielőtt a folyamatot javításra megszakítottuk.

Második döntés:

- az első biztos boss-távolodási vektor az aktuális mozdulattal együtt hat tényleges
  swipe-ig megmarad; egyképes takarás és minimapcél nem írhatja felül;
- friss sebzés már 95% HP alatt azonnal visszavonulást ad (korábban 85%);
- új folyamat 55% alatti HP-n előző képkockás sebzésemlék nélkül is regenerációs módba
  lép, így javítás utáni újraindítás nem kezd célkeresésbe sérülten.

A `20260829-010445-play` ezzel a változattal, teljesen regenerált 424 HP-n indult.

## Négyes kerülő élő cáfolata és megszakítható faljárás — `010445-play`

A négyes változat a zöld terület hosszú sziklafala és alsó kerítése között nem találta
meg a kijáratot. A 90–200. esemény között több négyes oldalváltás után is ugyanaz a
kb. 52–54 perces respawnkörökkel jelölt udvar maradt a képen. A rövidítés tehát
biztonságosabb volt, de önmagában nem volt elég hosszú falak bejárására.

Az új megoldás nem a régi vak tízes ág:

- ismert minimap-/sínvektornál legfeljebb tíz falmenti swipe, vak iránynál továbbra is négy;
- minden képen előbb fut a HP-/frisssebzés-őr és a hatswipe-os bossmemória;
- 180 px-en belüli biztonságos farmcél azonnal lezárja a faljárást;
- a tízes szakasz csak addig folytatódik, amíg nincs bizonyított veszély vagy elért cél.

A módosított élő futás: `20260829-010847-play`.

## Következő mérés

Figyelni kell, hogy a megszakítható tízes faljárás megtalálja-e a zöld udvar kijáratát,
és valóban felülírja-e a bossmemória vagy a közeli farmcél.

Külön élő elfogadási feltétel: boss észlelése után az ezt követő öt végrehajtható döntés
mind ugyanazt a bizonyított távolodási irányt tartsa, és csak ezután térhessen vissza
minimap-navigációhoz.

## Bossmemória élő igazolása — `011133-play`

A 26. esemény bossészlelése `(-0,76; +0,65)` távolodást adott. Az ellenfél ezután
takarásba került, de a 28., 30., 32., 34. és 36. végrehajtható döntés pontosan ugyanazt
az irányt tartotta; a köztes felhasználói aktivitásos várakozások nem fogyasztották a
számlálót. A HP végig 424 maradt. Az elfogadási feltétel teljesült.

Utólagos finomítás: a memória után a félbehagyott faljárás két mozdulatra újraindult.
Boss vagy friss sebzés most már az aktív statikus kiszabadítást és minimap-kerülőt is
törli. A menekülés után kizárólag friss képből számított útvonal indulhat.
