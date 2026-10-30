# A 18.8K-s, 25-ös statikonú páncélos

## Megtalálás

A `20260829-154552-play` a hajóroncs alatti hosszú, hatfázisú kerülés után ismét
követte a nagy térkép piros jelzését. A 227. képen a bal felső sarokban egy nagy,
páncélos vagy sziklás testű ellenfél jelent meg:

- explicit `18.8K` HP;
- `25` értékű, zöldes szívikon;
- narancssziklás Dusty-környezet;
- a játékos ekkor hitelesen 868 teljes HP-n volt.

A 15K-s kontrollált plafon miatt a régi release még eltávolodott. Ez ismét azt
mutatta, hogy a piros minimap felismerése és követése működik; a visszafordulás
konkrét kutatási korlát volt.

## Programdöntés

Az explicit tizedes + K alakú egyszeri kontrollált próba plafonja 20K-ra nőtt.
A pont nélküli K-alak továbbra sem biztonságos. A 18.8K-s cél nem kap statikus
kaktusz-várást: a normál izoláló közelítés, oldalkite és 82% alatti saját-HP
visszavonulás védi a próbát. A halál büntetésmentes, ezért az első tényleges
sebzés- és túlélhetőségi mérés nagyobb érték, mint a puszta HP-arányból való
automatikus menekülés.

Az első 20K-s release a `155228-play` 91. képén még mindig elkerülte a célt. Az
elemzés helyesen 18800 HP-t adott, de a nyers szöveg `18:8K` volt, a külön
nagypróbakapu pedig csak a pontot fogadta el. Javítás: pont, kettőspont és vessző
egyaránt explicit tizedesjel, ha `K` is szerepel; ez megegyezik a központi HP-parser
már bizonyított szabályával.

## Nyitott mérés

A következő eléréskor rögzítendő a cél tényleges sebződése, a játékos HP-mélypontja,
a mozgó/statikus viselkedés, a jutalom és az újratermelődési idő. A 18.8K-s cél
legyőzhetősége még nincs bizonyítva.
