# Felszerelésláda biztonságos felderítése

Ez a folyamat akkor indult, amikor az elérhető kezdőterület legtöbb legyőzött célja
`2h 35m` körüli újratermelődési időt mutatott, miközben a még látható 192 HP-s humanoid
az Island 4 kerítés túloldalán maradt. A mozgás javult, de új farmcél nélkül a tiszta
pályajárás már nem adott tartós fejlődést.

## Képi jel

A normál játéknézet jobb szélén két fix gomb látszik:

- felül zöld-fehér boltponyva;
- alatta barna/arany láda, jobb felső sarkán piros értesítési pont.

A kísérlet az alsó ládát célozza, nem a boltot. A piros pont erős, de nem bizonyító jel
arra, hogy átvehető vagy még meg nem nézett játékbeli tartalom van benne.

## Hipotézisek

1. felszerelés-/inventory képernyő, amely megmagyarázza a fejsze 4-es szintjét;
2. ingyen átvehető jutalom vagy új tárgy;
3. zárolt fegyverhelyek fejlesztési felülete;
4. fizetős vagy reklámos ajánlat — ezt automatikusan nem aktiváljuk.

## Biztonságos kísérleti protokoll

1. legalább 24 tényleges döntésen át nincs biztonságos főképi cél;
2. játékos-HP legalább 90%, normál HUD felismerhető;
3. egyetlen tap a képernyő kb. 94,8% szélesség / 58,5% magasság pontján;
4. a program `equipmentInspectionMode` állapotba lép;
5. az új képernyőn kizárólag képet elemez és `VÁR` döntést ad, tehát nem vásárol,
   nem indít reklámot és nem nyom ismeretlen gombot;
6. emberi/szupervízori képelemzés után külön megtanuljuk a biztos bezárást és az esetleges
   ingyenes, kockázatmentes műveletet.

## Elfogadási feltételek

- a láda valóban megnyílik;
- legalább egy mentett PNG tisztán dokumentálja a képernyőt;
- az első megnyitás után nincs második tap vagy swipe;
- a képernyő elemei, erőforrásai, tárgyai és bezárása bekerülnek ebbe a fejezetbe a
  következő hosszú játékfolyamat előtt.

## Első eredmény — `232710-play`

A 46. esemény egyszer koppintott `(591, 505)` képpontra. A 47. eseménytől a program
folyamatosan csak várt; a protokoll szerint nem történt második tap vagy swipe.

A `frame-00050.png` képernyő tartalma:

- felső `Stats` panel: `DPS 62.3`, `HP 340`, `REGEN 6.5`;
- első statcella: fejsze ikon, `33` és zöld `+48`;
- további öt statcella: mind 0;
- `INVENTORY` panel, első fegyverfül nyitva, három további fül lakattal;
- `WEAPONS` részben egy zöld fegyverkártya, jobb alsó `2` és piros értesítési pont;
- `Equipped` sorban a barna jelenlegi fegyver `4`, a többi hely zárt;
- alsó utasítás: `Hold a slot to Pin it.`;
- rózsaszín X, amelyet a meglévő `popupClose` detektor biztosan megtalált
  `(404…476, 387…418)` tartományban;
- kék információs `i` gomb a Stats panel jobb felső részén.

Biztos következtetés: a láda inventory, nem közvetlen fizetős bolt. A `2`-es zöld kártya
és a `4`-es Equipped adat külön fegyverhez/állapothoz tartozik; nem lehet mindkettő
ugyanaz a globális fegyverszámláló.

## Második eredmény — `233041-play`

Az `INVENTORY` OCR-sor gépi képernyőazonosító lett. Első felismerésekor egyszer a zöld,
piros ponttal jelölt kártyára koppintottunk kb. `(172, 526)` képponton. A
`frame-00002.png` már egy tisztán olvasható tárgyrészletező modalt mutatott:

- név: `BAT CLEAVER`;
- ritkaság: `UNCOMMON`;
- típus: `CUTTING`;
- két példánynál `Damage 100`, a következő példánynál `150`;
- `DAMAGE PER COPY 50`;
- `ATTACK COOLDOWN 1.2s`;
- `WOOD TRIBUTE Locked`;
- `EVOLVE 2/130`;
- 130 példány kell egy új különleges képesség és statnövelés feloldásához;
- az alsó sárga gomb felirata `EQUIP`, nem ár, reklám vagy vásárlás.

A program a kártyakoppintás után ismét csak várt. A modal számai új képfelismerési
hibát is feltártak: a `DAMAGE PER COPY 50` belelóg a harci HP OCR-régiójába, ezért az
elemző hamisan 50/340 HP-t jelentett. A rózsaszín X ugyanakkor biztos modalbizonyíték;
ilyen képen mostantól egyetlen felugróablak-szám sem frissítheti a harci HP-memóriát.

## Következő kontrollált lépés

A `TRIBUTE` vagy `SPECIAL ABILITY` OCR-sor a Bat Cleaver részletképernyő biztos
azonosítója. Mivel az `EQUIP` ingyenes, visszafordítható felszerelésváltás és a kijelzett
érték a jelenlegi fegyvernél várhatóan jobb, egyszer megnyomjuk kb. `(396, 559)` ponton.
Utána megint kizárólag várunk és ellenőrizzük a Stats panelt, az Equipped sort, illetve
az első tiszta harci találatot. Vásárlás, reklám, evolve és más ismeretlen művelet továbbra
sem engedélyezett.

## Equip eredmény — `233539-play`

A 0. esemény pontosan egyszer koppintott `(396, 559)` pontra. A következő képen a modal
bezárult és az inventoryban ezek a változások látszottak:

- `DPS 111` — a számított 110,83 játékbeli egészre kerekítve;
- támadássor `33 +100`;
- HP változatlanul 340, regen változatlanul 6,5;
- az Equipped első helyén a zöld Bat Cleaver `2`;
- a régi barna, `4` példányos fegyver visszakerült a Weapons listába;
- a Bat Cleaver zöld állapotjelzést kapott, a piros értesítési pont eltűnt;
- egy további Equipped helyen `VIP 4` feloldási jel látszik; a többi hely lakatos.

Az elméleti DPS-képlet ezzel közvetlenül igazolt. A 62,3→111 változás 78,2%-os kijelzett
DPS-növekedés, miközben HP és regen nem változott. A kutatási folyamat kész; a bot új
folyamatokban nem nyitja újra 24 cél nélküli lépés után a ládát. Ha az inventory nyitva
marad, kizárólag a biztos rózsaszín X-et nyomja meg és visszatér a játéknézethez.

## Következő harci mérés

Az első elérhető, ismert célon rögzíteni kell a Bat Cleaver normál és kritikus lebegő
sebzésszámát, illetve a cél HP-csökkenését. Ez választja szét a nyers `33 +100` statot a
célvédelmi/egyéb harci képlettől.

## 2026-08-29-i aktuális újraaudit

A tíz Bat Cleaver és a második fegyverhely után az inventory már 517 DPS-t mutatott.
A kék info panel megnevezte a statforrásokat, a három fegyverkártya részletlapja pedig
a Damage/cooldown értékeket. A Steel Splitter 14-et a Savage Fang 1 helyére szerelve
a visszacsatolt DPS 693 lett. Az `EVOLVE 10/130`, `1/100`, illetve `14/100` nem
elkölthető gombállapot, hanem a special ability példányküszöbe. Teljes részletek:
`136-aktualis-statforrasok-es-693-dps-build.md`.
