# Tizedik Bat Cleaver és 500 fegyversebzés

## Utólag megtalált élő eredmény

A `docs/runs/20260829-104751-play` hosszú futásának korábbi elemzése túl korán zárta le
a hordozókísérletet. A teljes napló 861–877. eseményének és képeinek újraellenőrzése
szerint a futás később mégis elérte és legyőzte a 499 HP-s fegyverhordozót.

- `frame-00866`: a teljes `499` cél közvetlenül a játékos mellett áll; az alsó
  Bat Cleaver-kártyán még `9`, a játékos HP-ja 778;
- `frame-00867`: a cél eltűnik, megjelenik a zöld `LEVEL UP` kártya, rajta `10` és
  `Damage 450 > 500`; az alsó fegyversor számlálója már 10;
- ugyanazon a képen vörös `20` sebzés és 769 pillanatnyi HP látszik;
- `frame-00868`: a játékos ismét 778 HP-n van, és egy fehér `24` harci szám is látszik;
- `frame-00871→00877`: a jutalom elhalványul, a 10-es példányszám megmarad.

## Biztos következtetés

A 499 HP-s, zöld fegyverkártya-ikonos humanoid ismét Bat Cleavert adott. A példányszám
`9→10`, a fegyver saját Damage értéke pontosan `450→500`; ez változatlanul példányonként
50-es növekedés. A játékos maximális HP-ja 778 maradt.

A 499-es hordozó eltűnése és a jutalom közvetlen egymásutánja az ölés biztos bizonyítéka.
A képen látható `24` szerepe még nem teljesen biztos: egyetlen szám alapján nem választjuk
szét, hogy a második aktív fegyver találata, más sebzéskomponens vagy ellenféltől kapott
érték. A `500` viszont a jutalomkártya felirata, ezért nem becslés.

## Útvonalpontosítás

A 8–3–8 részpróba valóban elakadt a palánknál, tehát a 131. fejezet geometriai cáfolata
érvényes. A későbbi általános navigáció és újraközelítés azonban 59 pixelre vitte a
hordozót, ahol az automata harc befejezte. Ez bizonyítja, hogy a tábor fizikailag
elérhető, de nem bizonyítja, hogy önmagában a jelenlegi 8–8–8 állapotgép adta a teljes
bejárati utat. A következő élő körben az út minden lábát külön naplózzuk.

