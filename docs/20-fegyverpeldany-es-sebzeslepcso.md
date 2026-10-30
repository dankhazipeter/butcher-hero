# Fegyverpéldány-számláló és 33→69 sebzéslépcső

Ez a fejezet a `224139-play` új sebzésadatait választja szét a korábban bizonyított
`+1` kékfejsze-jutalomtól. A biztos képi tény jelenleg erősebb, mint az egyszerű
„+1 ikon = pontosan +1 végső sebzés” modell.

## Közvetlen képi adatok

| Futás/kép | Alsó első fegyver száma | Normál | Erős/kritikus | Megjegyzés |
|---|---:|---:|---:|---|
| `215627/frame-00070.png` | 1 | 33 | – | 16-os fenyő 43 HP-n |
| `221123/frame-00010.png` | 2 | – | – | közvetlen zöld `+1` kék fejsze |
| `224139/frame-00130.png` | 3 | – | 104 | 174 HP-s fenyő befejezése |
| `224139/frame-00180.png` | 3 | 69 | – | 192 HP-s humanoid 54 HP-n |
| `224139/frame-00230.png` | 4 | még nem mért | még nem mért | humanoidölés után |

A 192 HP-s humanoid a megközelítés előtt teljes csíkon 192 volt. A mentett harci képen
54 maradt és egy 69-es fehér fejszés találat látszott. A különbség `192−54=138`, vagyis
pontosan két 69-es normál találat. A 104-es szám `69×1,507`, ezért nagyon jól illeszkedik
a korábban látott kb. 1,5-szeres kritikus/erős találathoz.

## Biztos állítások

- A jelenlegi normál találat 69, az erős/kritikus találat 104.
- A korábbi biztos normál találat 33 volt; közben nagy, nem egyszerű +1-es lépcső történt.
- Az alsó első fegyver ikonjának kis száma 1→2→3→4 sorrendben nőtt.
- A `+1` kékfejsze jutalom és a számláló 1→2 lépése ugyanazon eseménysorban látszott.

## Munkahipotézisek

1. **Fegyverhez kötött szint-/progresszióhipotézis:** a `+1` kék fejsze fejlesztési
   egységet ad, az Equipped sor kis száma pedig az aktuális fegyver szintje. A nagy bal
   panel és az Equipped sor egyaránt 4-et mutat, de az inventory másik zöld
   fegyverkártyája külön 2-t; így nem globális számlálóról, hanem kártyánkénti adatról
   lehet szó.
2. **Ideiglenes szorzó hipotézis:** a bal oldali `2x Reward` állapot vagy más, még nem
   olvasott bónusz a sebzést is szorozza. Ennek nincs közvetlen bizonyítéka.
3. **Kombinált modell:** a fegyverszámláló és egy százalékos alapstat együtt adja a 69-et.

Egyelőre egyik ok-okozati modell sem biztos. A taktika csak azt használja ki, hogy az
aktuális ütésigény a korábbinál lényegesen kisebb; a passzív célok várakozási becslése
amúgy is konzervatív plafonnal működik.

## Új UI-bizonyíték — `231447-play`

A `frame-00040.png` bal szélén egy reklám/clapper ikon fölött nagy kék fejsze, mellette
`4`, alatta kb. félig töltött zöld csík látszik. Mivel az alsó aktív fegyverhelyen is
fejsze és `4` szerepel, a „puszta példányszám” elnevezés már kevésbé valószínű. A zöld
csík tipikus szint-/fejlesztési előrehaladást jelezhet. Biztos ok-okozat csak akkor lesz,
ha egy jutalom után a csík vagy a 4-es szám képen mérhetően változik.

## Inventory-bizonyíték — `232710-play`

A `frame-00050.png` Stats értékei: `DPS 62.3`, `HP 340`, `REGEN 6.5`; a fejszés sor
`33 +48`, öt másik stat 0. Ugyanazon képen a zöld, még meg nem nézett fegyverkártya `2`,
az Equipped sor barna fegyvere `4`. Biztos: a két kis szám nem ugyanannak az egyetlen
globális számlálónak két megjelenése. Nyitott, hogy a 2 fegyverszint, ritkasági fok,
darabszám vagy támadásszám; a kontrollált kártyakiválasztás ezt méri.

## Bat Cleaver példánymodell — `233041-play`

A zöld kártya részletképe megválaszolta, mit jelent a jobb alsó `2`: a Bat Cleavernek
két példánya van. A képernyő egyszerre írja ki a `DAMAGE PER COPY 50`, a jelenlegi
`Damage 100` és a következő `150` értéket, tehát ennél a fegyvernél a biztos képlet:

`fegyversebzés = példányszám × 50`.

Az `EVOLVE 2/130` ugyanazt a példányszámot használja; 130-nál külön képesség és
statnövelés nyílik. A jelenlegi barna fegyver `4` száma ezért nagy valószínűséggel annak
a saját példányszáma, nem általános játékosszint.

A Stats panel `33 +48` sora és `DPS 62.3` értéke matematikailag pontosan illeszkedik a
`(33 + 48) / 1.3 = 62.307…` képlethez. Erős következtetés: 33 a tartós alap támadóstat,
48 a jelenlegi fegyver hozzájárulása, a jelenlegi fegyver cooldownja pedig 1,3 s. A Bat
Cleaver két példánnyal és 1,2 s cooldownnal, ha azonos módon adódik az alapstathoz,
`(33 + 100) / 1.2 = 110.83… DPS` értéket adna, vagyis kb. 78%-os javulást. Ezt az Equip
utáni Stats panelen kell közvetlenül igazolni.

## Következő döntő mérés

A számláló most 4. A következő tisztán mentett, teljes HP-ról induló célon mérendő:

- marad-e a normál 69 és a kritikus 104;
- változik-e a számláló újabb `+1` kékfejsze után;
- van-e köztes szintlépési animáció vagy külön bal oldali bónusz;
- a cél HP-csökkenése és a lebegő találati szám továbbra is pontosan egyezik-e.

Az első mérés a Bat Cleaver felszerelése utáni Stats panel. Ezután egy teljes HP-ról
induló, ismert célon rögzítendő a lebegő találati szám és a cél HP-csökkenése. A régi
81 nyers stat mellett látott 69 találat arra utalhat, hogy a cél 12 fix védelmet von le;
ebben az esetben 133 nyers stat mellett 121 normál és kb. 182 kritikus találat várható.
Ez csak mérendő hipotézis, nem taktikai tény.

## Equip utáni közvetlen igazolás — `233539-play`

A felszerelés utáni `frame-00001.png` `DPS 111` és `33 +100` értékeket mutat. A
`(33+100)/1.2 = 110.83…` képlet tehát a játék saját kerekítéséig pontos. Az Equipped
első helyén a Bat Cleaver `2`, a régi fegyver `4` értékkel visszakerült az inventoryba.
Ez közvetlenül igazolja, hogy a kártyaszám fegyverenkénti példányszám, és hogy a
felszerelés a fegyverbónuszt cseréli, az alap 33-at nem.

## Harmadik Bat Cleaver-példány — `235416-play`

A kétpéldányos Bat Cleaver első tiszta normál találata 133; egy 499 HP-s humanoid két
ilyen ütés után pontosan 233 HP-n állt. A harmadik automata találat ölte meg. Közvetlenül
utána `LEVEL UP`, `Damage 100 > 150`, kártyaszám és alsó Equipped szám `2→3` jelent meg.
A fegyverpéldány tehát nem csak inventoryadat: célpontjutalomként megszerezhető és minden
példány azonnal +50 fegyversebzést ad. Bat3 várható nyers találata `33+150=183`, kijelzett
DPS-e `(33+150)/1.2=152.5`; a következő tiszta találat méri.
