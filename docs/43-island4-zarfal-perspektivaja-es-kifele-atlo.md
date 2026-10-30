# Island 4-zárfal perspektívája és kifelé tartó átló

## Anomália — `20260829-014620-play/frame-00220.png`

A karakter a narancsszikla jobb oldalán állt, miközben a bot a túloldali 136/253 HP-s
célokat üldözte. A történeti fix bal 25%-os kizárás kevés: a perspektivikus falnál egy
elérhetetlen csík közepe 25% fölé is benyúlhat. A minimap balra mutató piros pontja ugyanígy
a lezárt célmezőre vezetett, ezért a célkizárás önmagában nem szüntette volna meg a hurkot.

## Területállapot

A bal oldali régió külön OCR-je felismeri az `UNLOCKS AT ISLAND 4` / `ISLAND 4` feliratot.
Ebben az állapotban:

- a képszélesség bal 36%-ában lévő főképi célok elérhetetlenek;
- ha a piros minimapvektor balra mutat, a bot nem követi, hanem a jobb oldali nyílt
  játéktér felé tervezi a határelhagyást;
- boss és friss sebzés továbbra is minden határmozgást megelőz.

A `20260829-015210-replay` ugyanazon képen a régi balra-fel irány helyett tiszta jobbra
swipe-ot adott, külön `Island 4-zárfal` döntési indokkal.

## Kifelé kevert faljárás

A `20260829-015223-play` megmutatta, hogy a szikla kiugró csúcsán a tiszta jobb és a
tiszta függőleges mozgás is statikus lehet. Ezért Island 4-állapotban a falmenti tangenshez
0,55 súlyú jobbra-kifelé komponens adódik.

A `20260829-015352-play/frame-00016→00030` a `(0,48; 0,88)` átlóval ténylegesen lefelé
és jobbra mozdította a kamerát a szikla mellett, stabil 438 HP-val. A korábbi tiszta
függőleges ág ugyanott nem haladt.

## Bossirány és hűtés

A határelhagyás jobbra mutató magas szintű szándéka nem azonos a boss felé vezető
iránnyal. A korábbi boss-hűtő mégis ezt mentette, majd felfelé-balra fordult vissza.
Bossészleléskor a lezárt irány ezért most mindig a boss tényleges képi iránya; láda-,
küldetés- vagy határszándék nem kerülhet bossútvonal-memóriába.

Élő ellenőrzés az összes javítással: `20260829-015654-play`.

## Későbbi javítás: az átló már az első próbától

A `020635-play` újra megmutatta, hogy a tiszta jobbra irány hosszú, ismétlődő
sziklaék-hurkot okoz. A döntő ezért nem csak hat statikus próbálkozás után keveri be a
falmenti komponenst: látható zárfelirat és balra mutató minimap esetén az első mozdulat
is a bizonyított `(0,48; 0,88)` átló. A `021246-replay` régi `(1,00; 0,00)` döntését a
`021323-replay` ugyanazon képen `(0,48; 0,88)` döntésre cserélte.
