# Zöld sátorkerítés: általános négyátlós kiszabadulás

## Élő elakadás — `20260829-031220-play`

A karakter egy Meadowlands-sátor L-alakú fakerítésének belső sarkában állt. A régi
zöld-biomos statikus faljáró csak a blokkolt minimapvektor két merőleges oldalát
váltogatta. A 0–70. esemény során bossmenekülés röviden kijjebb mozdította, de a normál
navigáció újra ugyanabba a sarokba vitte.

## Döntés

A négyfázisú faljárás már nem csak narancssziklán aktív. Bármely ismert blokkolt
iránynál sorra próbálja:

1. balra-hátra;
2. balra-előre;
3. jobbra-előre;
4. jobbra-hátra.

A hosszirányú komponens 0,55. Boss, friss sebzés és 180 pixelen belüli farmcél továbbra
is minden lépés előtt megszakítja a faljárást.

## Regresszió és élő előzmény

A `031220-play` javított teljes replayében a korábbi kétoldalas ismétlés helyén az új
fázis `(-0,92; +0,39)`, majd később `(0,16; -0,99)` irányt adott. A 37. replaydöntésre
129 pixeles cél jelent meg, és a döntő célközelítésre váltott.

A még régi élő build végül csak hosszú célterület-kiszakadással jutott ki, majd elérte
a 20-szíves, 431 HP-s fát. Az általánosítás célja, hogy ugyanezt rövidebb, lokális
négyátlós kereséssel érje el. Az első javított élő folyamat `20260829-031754-play`.

