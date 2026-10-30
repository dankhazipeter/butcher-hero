# Vision-verziók képi regressziója — 2026-10-30

A második távoliCI [41108249493](https://github.com/dankhazipeter/butcher-hero/actions/runs/41108249493)
már lefordította a teljes csomagot. A job124243628722naplója szerint a
régebbiVision két konkrét képen eltért a helyben sikeres felismeréstől:

- `corpus-cutdef593.png`: cutting_defense helyettunknown.
- `free-hp-18k-occluded.png`: hpjó, összegnil; ez a korpuszban és a külön
  történeti regresszióban is hibázott, így háromassert, de két képi eset.

A rögzített képi elvárások helyesek és változatlanok. Nem tekintjük a
korábbi helyiPASS-t minden macOS/Visionverzió igazolásának.

## Javítások és célzott ellenőrzés

Az ikonvágás a FREEfeliratOCRdobozától függ. Kis eltérést most korlátozott
pixeles keresés kezel: vízszintesen−1/0/+1, függőlegesen−2/0/+2pixel.
Képterületen kívüli kivágás nincs; típusonként ugyanazoknak a referenciáknak
a legjobb hibája számít. A0.48maxhiba és0.035típusmargin nem lazult.
Külön teszt a593pajzsos fejszével és±2pixel eltolással.

Ha az eredeti szám-OCRés két szűkebb próbája sem ad összeget, ugyanazon
számsor szűk területéről fehérszöveg/feketeháttér maszk készül, és azt
olvassa újra aVision. Nem sablonból vagy típusból találunk ki számot;
ugyanaz a geometria, magabiztosság és szigorú numerikusparser érvényes.
A maszk csak valóban világos, közel semleges pixeleket tart meg.
Külön direkt teszt kényszeríti ezt az ágat a takart18Kvalódi képen.

Helyi célzott regresszió:27korpuszképPASS, a két új külön tesztPASS.
Hiba esetén a korpuszteszt ezentúl OCRdobozokat és ikonillesztési adatokat
is kiír, hogy a távoli eltérés ne maradjon pusztán egyunknown felirat.
Távoli eredmény még külön igazolandó; a gyűjtő közben külön folyamatban fut.
