# Boss-takarás a megtervezett struktúrakerülő közben

## Megfigyelés

A `docs/runs/20260829-135053-play` élő 4.31K-próbájában a második, váltott oldalú
Titan-objektum-kerülő 49. képnél indult. A boss az 52., 55. és 57–63. képen
átmenetileg kicsúszott, miközben a 200-as struktúra továbbra is látszott. A régi
logika ezeken a képeken félbehagyta az oldalirányú kerülőt, és a legutóbbi
bossirányba fordult — éppen vissza az akadály felé.

A háromképes normál célmemória növelése önmagában kevés volt. Nyolcképes memóriával
a 64. képen a 4.31K-s boss ismét megjelent, tehát a boss nem tűnt el és nem halt
meg; a kamera vesztette el az oldalkitérés közben.

## Programdöntés

- Aktív, megtervezett Titan-struktúrakerülő minden hátralévő lépése lefut akkor is,
  ha a boss közben nincs a képen. Az ilyen várható takarás nem fogyasztja a normál
  elveszett-cél számlálót.
- Csak a teljes oldalláb után indul a legutóbbi bossirányú keresés.
- Igazolt struktúrakerülés után a visszakeresési keret három helyett nyolc kép;
  normál bosseltűnésnél továbbra is három.
- A 64. képen visszatalált boss 4310 HP-n maradt: ez navigációs siker, nem harci
  progresszió.

## Regresszió és élő ellenőrzés

A `docs/runs/20260829-135414-replay` 52., 55. és 57. képe már folytatta a rögzített
objektumkerülőt. A teljes láb után a 64. képen újra azonosította a 4.31K-s célt.
Az új fizikai ellenőrző futás: `docs/runs/20260829-135451-play`.
