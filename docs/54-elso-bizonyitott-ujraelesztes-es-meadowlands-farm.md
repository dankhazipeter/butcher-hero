# Első bizonyított újraéledés és Meadowlands-farm

## Halálhoz vezető eseménysor — `20260829-025524-play`

A 38–68. eseményben a 67,5K boss környékén a karakter 13 HP-s katonák, valamint
1,86K–3,06K HP-s páncélos lovasok közé került.

- `frame-00048`: teljes 475 HP, a veszélycsoport a képszélen közeledik.
- `frame-00054`: a játékoscsík 308, több 13 HP-s katona közvetlenül támad.
- `frame-00058`: friss OCR 426, a 3,06K lovas látható.
- `frame-00068`: 129 HP, közvetlenül az 1,86K lovas mellett.
- `frame-00074`: a játék automatikusan a zöld `Meadowlands – 1` területre helyezte
  vissza a fekvő karaktert.
- 75–89. esemény: a kritikusállapot-őr input nélkül friss numerikus HP-ra várt.
- 90. esemény: biztos 475/475 OCR oldotta fel az újraéledési állapotot.

Ez közvetlenül igazolja a felhasználó korábbi információját: a halál automatikus
újraéledés, és a megszerzett maximum nem veszett el.

## Azonnali kezdőterületi fejlődés

Az újraéledés után a bot alacsony HP-jú szíves célokat farmolt:

| Esemény/kép | Cél | Közvetlen eredmény | Biztos maximum |
|---|---|---|---:|
| 92–95 / `frame-00092→00096` | 10-szíves, 48 HP-s fenyő | zöld `+10` szív | 485 |
| 102–110 / `frame-00108→00110` | 5-szíves, 38→5 HP-s fenyő | zöld `+5` szív | 490 |
| 264–281 | 2-es szintű, 21→2 HP-s cél | stabil `490→492` | 492 |

A +10 és +5 közvetlenül látszik. A +2 jutalomfeliratot a képkockaritkítás nem fogta
meg, de az azonnali, stabil maximumlépcső és a 2-es cél miatt erős következtetés.

## Taktikai következmény

A Meadowlands kezdőterület jelenleg jobb kockázat/hozam régió, mint a narancs
bányatábor: a 38–48 HP-s passzív fák +5/+10 max HP-t adnak, miközben a táborban
többezer HP-s lovasok és sűrű katonaság is megjelenhet. Halál után ezért nem kell
azonnal visszanavigálni a veszélyzónába; a kezdőterületi szíves célok elsőbbséget
kaphatnak.

