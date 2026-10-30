# Bossból átlóval farmba és 467 HP

## Élő ellenőrzés — `20260829-022045-play`

A folyamat a `frame-00000.png` képen valódi veszélyhelyzetből indult: a havas felső
peremen több 1.16K HP-s ellenfél torlódott. A bot hathúzásos bossmenekülést végzett,
majd az Island 4-feliratnál nem a régi tiszta jobbra irányt ismételte, hanem az első
próbától a javított `(0,48; 0,88)` jobbra-le átlót használta.

Az eredmény:

- a 10–42. esemény stabil 463 HP mellett elhagyta a havas bossperemet;
- a `frame-00044.png` már az elérhető narancstábor 253 HP-s, 4-szíves humanoidját
  mutatja közvetlen közelharcban;
- a `frame-00046.png` a humanoid eltűnése utáni találati/jutalomátmenet;
- a `frame-00048.png` közvetlen zöld `+4` szívet és teljes 467 HP-t mutat.

Ez biztos `463→467` maximális HP-fejlődés. Nem OCR-zaj: a jutalomfelirat közvetlenül
látható, és a 467-es teljes HP több egymást követő képen megmaradt. A
`docs/bot-state.json` tartós maximuma 467.

## Stratégiai értékelés

Az azonnali Island 4-átló nem csak kevesebb statikus próbát eredményezett, hanem egy
teljes boss→biztonságos farm→jutalom ciklust zárt le kevesebb mint 50 elemzési
eseményben. A bossőr, a hathúzásos menekülés, a határátló és a +4 humanoidfarm ezért
együtt működő, egymásra épülő stratégiának tekinthető.

A 61. eseménynél egy újabb csoport 407 pillanatnyi HP-ig sebzett, de a 87%-os
frisssebzéses visszavonulás azonnal aktiválódott, és a 63. eseményen már ismét teljes
467 HP látszott. A hozam tehát nő, miközben a védelmi ág továbbra is működik.
