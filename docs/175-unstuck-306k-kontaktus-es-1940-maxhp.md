# Unstuck, 3,06K-s kontaktus és 1940 max-HP

## Egyszeri láda és ismételhető farmhely nem ugyanaz

A különleges láda egy adott képi helyen és irányban egyszer vehető át. Az
`OPEN` → `TAP TO CLAIM` sor után a hely `collectedChestDirections` állapota
lezárt, ezért jutalomjel nélkül nincs értelme ugyanoda visszamenni. Ettől eltérnek
a kaktuszok és más erőforrások: legyőzésük után visszaszámlálós kör jelenik meg,
tehát ismételhetők, de a hosszú időzár alatt nem szabad őket újra célba venni.

## A magaslati zóna kézi lezárása

A `20260829-182927-play` továbbra sem talált járható bejáratot a DOC-udvarhoz.
A karakter egy magas, szűk párkányon állt; a 4,4K-s őr képen közel volt, de más
járható rétegen. A felügyelő a Settings → Unstuck gombot használta. A karakter
0 HP-s átmenet után a zöld központi gyógyítómedencénél éledt újra 1299 teljes
HP-val. A ládazónába való közvetlen visszatérés helyett innen nyílt terület és
új piros minimapcél következett.

Az új terület zöld csontmező/temető jellegű, majd a `Dusty Gulch – 2` határán a
játék külön megmutatta az ellenfél fegyverét és annak gyengeségét. A Deep Mines
közelében `Find a magic anti-stone potion 0/1` küldetésjel is látható volt. Ezek
nem HP-feliratok, hanem terület- és küldetésinformációk.

## A 3,06K-s őr nyerhető

A `20260829-183754-play` 117–120. képei valódi közelharci kontaktust mutattak:

- az ellenfél 3,06K-ról 2,57K-ra csökkent, tehát körülbelül 490 sebzést kapott;
- a karakter 1299-ről körülbelül 1239-re csökkent, tehát csak 60-at kapott;
- a sebzésarány alapján a harc egyértelműen nyerhető;
- az ellenfél a karakter másik oldalára került, ezért a régi irányazonosság
  tévesen megszakította a próbát.

Javítás: 112 pixelen belül a csökkenő HP, boss-/ikon-aláírás és közelség erősebb
célazonosság, mint a korábbi irány félsíkja. Ha egy közeli cél már legalább 250
HP-t veszített, a teljesen takart csík alatt legfeljebb negyven képen át helyben
marad az automata kombó, amennyiben a numerikus saját HP nem kritikus.

## Második és harmadik nagy szívkaktusz

A `183754-play` 140–204. szakaszában egy újabb 11,4K-s, 300-szíves kaktusz
helyben tartott támadással elfogyott. A 200. képen 699 HP maradt, a 204. képen
pedig megjelent a friss visszatérési kör. A pontos maximum 1299 + 300 = 1599,
amit a következő folyamat `1599 / 100%` értékkel megerősített.

Az ugyanebben a területben később szerzett kisebb jutalmak után a játékos fölött
`1.64K` látszott. A `20260829-185029-play` újabb 11,4K-s kaktusza ezt `1.94K`-ra
növelte; a következő folyamat pontos, teljes `1940 / 100%` értéket olvasott.
Ez összesen legalább két további nagy kaktuszgyőzelem az első dokumentált
999 → 1299 siker után.

## Felismerési és állapotjavítás

- A `1.64K`/`1.94K` két tizedesjegyes játékosfeliratot a parser 1640/1940-ként
  kezeli.
- A gyakori `1164K`/`1194K` OCR-alakban a csík széléből odatapadt első `1`
  eltávolítható, ha aktív, 300-szíves nagy kaktuszpróba igazolja a kontextust.
- A friss közeli respawn-kör vagy a +250…+380 közötti, explicit K-s saját
  növekedés lezárja a kaktuszharcot és rávezeti a +300-at a tartós maximumra.
- A passzív kaktusz csíkátfedési védelme már a jelenlegi cél 135 pixeles
  távolságát használja, így a 18–26%-os hamis pixeles saját csík nem készít
  téves 11,25K-s vereségsávot.
- A téves 11,25K-s tartós vereségbejegyzést töröltük: a 11,4K-s kaktusz
  bizonyított farmcél, nem vesztes boss.

## Következő mérések

- A 3,06K-s őr teljes legyőzése 1940 maximummal és a jutalom pontos típusa.
- A kisebb, 1599 → 1640 közötti összesen +41 fejlődés forrásainak elkülönítése.
- A Dusty Gulch – 2 fegyver/gyengeség jelöléseinek automatikus taktikai használata.
- A Deep Mines 0/1 feladat tárgyának és járható bejáratának felderítése.
