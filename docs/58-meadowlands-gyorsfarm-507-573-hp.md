# Meadowlands gyorsfarm: 507→573 HP

## Egyetlen felügyelt futás eredménye

A `20260829-030113-play` 294–560. eseménye a Meadowlands kezdőterület alacsony HP-jú
szíves céljaival `507→573` tartós maximumot ért el.

| Képsor | Cél/jutalom | Maximum |
|---|---|---:|
| `00294→00298` | 5-szíves, 90 HP-s fa; +5 | 512 |
| `00298→00302` | 5-szíves, 124 HP-s fa; +5 | 517 |
| `00310→00316` | 5-szíves, 38 HP-s fa; +5 | 522 |
| `00324→00328` | 10-szíves, 48 HP-s fa; +10 | 532 |
| `00338→00346` | három 4-szíves, 43 HP-s humanoid; három +4 | 544 |
| `00420→00426` | három 3-szíves, 41 HP-s humanoid; három +3 | 553 |
| `00446→00450` | 10-szíves, 174 HP-s fa; látható +10 | 564 |
| `00540→00546` | két 3-szíves, 41 HP-s humanoid; két +3 | 570 |
| `00556→00560` | egy 3-szíves, 41 HP-s humanoid; +3 | 573 |

## Csoportfarm új kockázati képe

A 252–306 körüli normál találat egy ütéssel ölte a 41/43 HP-s humanoidokat. A
négyes csoportból három ölés közben csak `532→530` pillanatnyi numerikus sebzés
látszott, majd teljes 544. A hármas csoportnál 8–17 HP pillanatnyi esés jelent meg,
de a jutalom és a gyors regeneráció teljesre hozta vissza.

Ezért a korábban általánosan kerülendő sűrű humanoidcsoport a Meadowlands 41–43 HP-s
változatánál már nagy hozamú cél. Ez **nem** vonatkozik a narancstábor 13 HP-s katonái
mellé keveredő 1,86K–3,06K lovasokra.

## Közelharci pixelcsík-összeolvadás

A `frame-00342` és `frame-00422` körül a pixel-fallback 27–29%-ot jelzett, miközben
a vörös célcsíkok ráfedtek a játékos zöld csíkjára. A következő friss OCR 540/550,
majd teljes új maximumot igazolt. A védelmi hátrálás fölösleges volt, de biztonságos;
friss numerikus adat azonnal felülírta.

## +10 felirat, +11 kijelzett lépcső

A `frame-00450` közvetlen `+10` szívet mutat, a kijelzett maximum mégis `553→564`.
Biztos, hogy a végállapot 564 és a +10 effektus valódi. **Nyitott hipotézis:** a
világláda korábbi `+1%` max-HP jutalma a belső alapértékre számolódik, és ennél a
kerekítési határnál egy további kijelzett pont jelent meg. Egyetlen kép alapján nem
zárható ki egy egyidejű, eltakart +1 jutalom sem.

## Aktuális eredmény

A futás végén a `bot-state.json` 573-at tárolt. Ez a hosszú szakasz halál és tartós
veszteség nélkül teljesült.

