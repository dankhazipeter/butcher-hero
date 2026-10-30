# Cooldownos zöld landmark hozamhűtése

## Korábbi szerep

A zöld minimap-landmark fontos felfedezési jel volt: korábban elvezette a botot a
Cursed Girlhöz, majd a 499 HP-s Bat Cleaver-hordozóhoz. Ezért piros cél hiányában
elsőbbséget kapott a vak spirállal szemben.

## Új élő bizonyíték

A `090616-play` első 252 döntésében a karakter a zöld medence, a 200-as Titan-portál,
a lila sziklaperem és a közeli bekerített tábor között mozgott. A képeken:

- több 16–18 órás köridőzítő;
- a Bat Cleaver-hordozó még 15–18 perces újratermelődése;
- nulla új biztonságos HP-csík;
- nulla jutalom és változatlan 778 max-HP / 9 Bat Cleaver-példány.

A zöld landmark iránya gyakran megszakította a növekvő négyzetspirált, majd ugyanabba
a központi, már kiürült farmkörbe vitte vissza. A landmark tehát nem önmagában rossz,
hanem a helyi készlet cooldownja alatt nulla határhozamú.

## Javítás

Ha egyszerre teljesül:

- legalább 150 döntés telt el tartós progressz nélkül;
- nincs piros minimapcél, látható quest-sín, világláda vagy biztonságos cél;
- zöld landmark látható és a játékos legalább 90% HP-n van;

akkor a bot 160 döntéses növekvő szabad felderítést indít, amely figyelmen kívül hagyja
a zöld landmarkot. A közös 360 döntéses drought-cooldown megakadályozza az azonnali
újraindítást.

Valódi cél, quest, láda és bossbiztonság továbbra is megszakítja/felülírja a módot.

## Élő igazolás

A `091457-play` 257. döntése a tartós piros zárút elfordulása után ténylegesen
`A jutalomhiányos zárút után ... növekvő szabad területfelderítés` módra váltott.
A 257–284. döntések négy külön főirányt jártak be, közben:

- a 4,31K-s bosstól biztonságosan eltávolodtak;
- a 200-as Titan-portál 381 pixel fölé került, majd eltűnt;
- a `frame-00285→00290` sorozatban újra láthatóvá vált a már újratermelődött,
  499 HP-s Bat Cleaver-hordozó.

Az elfogadási feltétel teljesült. A landmark hozamhűtése nemcsak elindult, hanem
új, értékes farmcél-területet is feltárt.
