# A bal `2x Reward` panel nem világcél

## Biztos képi bizonyíték

A `093024-play/frame-00718.png` bal oldalán látható a nagy szívszámláló és alatta a
`2x Reward` címke. Az Analyzer ugyanott két HP-csík-jelöltet alkotott:

- `(13...74, 590...596)`: 132 HP, 62 pixeles vörös csík;
- `(13...73, 606...609)`: 2 HP, 61 pixeles vörös csík.

Mindkettő rögzített UI-elem volt `x≈43`, `y≈633/646` becsült „testközéppel”, nem
világban álló lény. A zöld füves háttér miatt a hibás fegyverkártya-bizonyítékuk
`0,19...0,23` lett. A képszéli farmőr megakadályozta a támadást, de a
`nearestThreat` még oldalra torzította a szabad spirált. A 725. eseményben az egyik
OCR-zaj bossbizonyítékot is alkotott; ha ez végrehajtható döntésre esik, hamis
bossmenekülést indíthatott volna.

## Javítás

A képszélesség bal 14%-ában, a képmagasság 67–72%-án lévő vörös csíkokat már a
világcél létrehozása előtt elvetjük. Ez a keskeny téglalap a rögzített jutalompanel
helye. A fő játéktér bal oldala, a felső levél/levélgomb és az alsó fegyversor ettől
független marad.

## Regressziós igazolás

A javított bináris `frame-00713.png` visszajátszása üres `visibleTargets` listát és
normál minimap-felderítést adott; sem 132/2 cél, sem kitérés, sem bossmenekülés nem
maradt. A külön teljes `092709-play` regresszió a valódi 499-es hordozót 233→184
pixelen továbbra is célként választotta. Mindkét elfogadási feltétel teljesült.
