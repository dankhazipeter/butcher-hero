# Piros cél, 4.31K-s óriás és az Unstuck utáni késleltetés

## Élő megfigyelés

A `20260829-145639-play` folyamat 14–26. döntése közvetlenül a nagy, kör alakú
minimap piros ellenféljele felé mozgott. A 137. képen 357 px távolságból biztosan
felismerte a `4.31K` HP-s, `500` szívikonos óriást. Tehát a bot nem hagyta figyelmen
kívül a jelet: odatalált a cél képi környezetébe.

A tényleges támadás még nem kezdődött el. A karakter és az óriás között egy 200 HP-s
lila Titan-oltár, sziklafal és keskeny átjárók voltak. A közvetlen közelítés, az
oltár váltott oldali kerülése és további oldallábak 357→286 px-re javították a
távolságot, de az ellenfél HP-ja végig 4.31K maradt. Ezt útvonalpróbának, nem elvesztett
harcnak kell számítani.

## Az észlelt késleltetés oka

A kerülők után a bot egy másik kerítésnél elakadt, majd a 220–251. döntésben sikeres
Settings/Unstuck helyreállítást végzett. A régi szabály ekkor 120 döntésre olyan
helyi spirált indított, amely szándékosan elnyomta a piros minimapjelet. Ez eredetileg
azt akadályozta meg, hogy a teleport azonnal ugyanabba a zsebbe vigye vissza a botot,
de a mostani élő helyzetben már túl hosszú késleltetés lett.

## Döntés

- Az Unstuck utáni helyi kijutási ablak `120→24` döntésre rövidül.
- A 24 döntés után a piros minimapjel ismét elsőbbséget kap.
- A Dusty Gulch ismert, periodikus bosshurkára adott külön 120 döntéses védelem
  változatlan marad; a két okot nem szabad összemosni.
- A 4.31K-s próbát csak akkor tekintjük harcnak, ha tényleges HP-csökkenés vagy saját
  sebződés látszik. A puszta képi felismerés és közeledés navigációs mérés.

## Következő ellenőrzés

Az új release folyamatban meg kell figyelni, hogy a 24 döntéses kijutás után a bot
visszafordul-e a friss piros jelre, talál-e másik bejáratot az óriáshoz, és létrejön-e
az első valódi 4.31K-s sebzéscsere.
