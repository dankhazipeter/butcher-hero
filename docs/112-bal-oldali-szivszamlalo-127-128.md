# A bal oldali nagy szívszámláló 127→128 változása

## Közvetlen képi eltérés

A `081746-play/frame-00048` bal oldalán egy nagy piros szívikon alatt `127` és egy
zöld részcsík látszik, alatta filmes ikonos `2x Reward!` ajánlattal. Ugyanennek a
futásnak a `frame-00552` képén az érték `128`.

Eközben:

- a játékos hiteles maximális HP-ja végig 768 maradt;
- nem keletkezett `recentRewardSequence`;
- az egyetlen követett 174 HP-s, 10-szíves fa nem halt meg;
- a Titan-küldetés számlálója továbbra is `0/7`.

**Biztos következtetés:** ez a nagy bal oldali szívszám nem azonos a játékos aktuális
vagy maximális HP-jával, és nem azonos a Titan-gem számlálóval. A +1 oka még nem
bizonyított; lehet passzív/területi erőforrás, időzített helyi objektum vagy egy
képkockák között automatikusan felvett jutalom.

## Kezelési szabály

A `127→128` változást egyelőre nem használjuk progress-resetre és nem kötjük
max-HP-jutalomhoz. A `2x Reward!` felület továbbra is reklám/ajánlat jellegű, vak
koppintás tilos. Következő tiszta változásnál közvetlen előtte/utána kell menteni:

- látható célokat és lebegő effektusokat;
- a játékos HP-ját;
- a fegyverkártya-számot;
- a Titan `0/7` állapotát;
- az esetleges időzítőt és helyszínt.
