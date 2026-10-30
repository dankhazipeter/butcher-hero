# Timer-OCR és lezárt kerítésből kiszakadás

Ez a lap a `222253-play` két, egymást követő felügyeleti hibáját rögzíti. Mindkettő
látszólag harci probléma volt, de a mentett kép és a teljes eseménysor más okot igazolt.

## 320→330: újabb közvetlen +10 max-HP esemény

- `frame-00100.png`: 10 piros szíves, 174 HP-s fenyő, a játékos 320 HP-n.
- A cél a 104. esemény után eltűnt.
- `frame-00110.png`: teljes `330` HP, zöld `+10` szív és `3m 59s` újratermelődési kör.
- Biztos következtetés: a szíves fenyő ismét pontosan a kijelzett 10-zel növelte a
  maximális HP-t. A tartós érték ezen a ponton 330 lett; a későbbi sikeres kiszakadás
  utáni következő +10 fenyő 340-re emelte.

## A 83/56 HP nem sebzés volt

A 112–113. esemény `83`, majd `56` HP-t és kritikus visszavonulást naplózott. A nyers
OCR azonban `83m 565`, illetve `33m 56s` volt, vörös csík és közeli fenyegetés nélkül.
A `frame-00115.png` teljes zöld csíkot mutat; a következő tiszta olvasatok 301, majd
330. A `3m 56s` kör rátakart a `330` feliratra és a csík egy részére. Nem történt halál,
újraéledés vagy gyógyulás.

Programdöntés:

- bármely `m`, `s` vagy `h` időegységet tartalmazó OCR-sor nem adhat numerikus HP-t;
- ilyen képen a korábbi hiteles HP-memória és a fenyegetéssel ellenőrzött pixelcsík
  vezérel;
- az `m` és legalább két számjegy már respawn-timer bizonyíték, mert a Vision az `s`
  betűt gyakran `5`-nek olvassa;
- a `223438-replay` a mentett timeres képet 330/100%-on tartja, miközben a
  `214936-play` valódi támadásos képei továbbra is 31–38%-on visszavonulnak.

## Lezárt Island 4 célhurok

A 275–645. esemény között a karakter az `UNLOCKS AT ISLAND 4` vízszintes kerítésének
alsó oldalán maradt. A 64 HP-s 5-ös ellenfél, a 923 HP-s fenyő és több 200 HP-s csík a
lezárt oldalról látszott. A háromlépéses merőleges kerülőt a célváltás megszakította;
a bot ismételten 377–457 px közötti célokra fordult vissza, érdemi pályahaladás nélkül.

Az új végrehajtási szabály:

1. négy stagnáló megközelítés után nyolc tényleges swipe-os, célváltástól független
   akadálykövetés indul;
2. ha ugyanebben a megközelítési folyamatban másodszor is stagnál, a bot 18 hosszú
   swipe-pal a cél ellentett irányába kiszakad a lezárt területtől;
3. a kitérőt felhasználói aktivitás miatti várakozás nem fogyasztja;
4. a menekülési/HP-biztonsági logika mindig felülírhatja az akadálymanővert.

A `223438-replay` a régi hurok képein két nyolclépéses kerülőt, majd automatikus hosszú
kiszakadást reprodukált. A `223818-play` első élő próbáján a főképi nyolc lépés valóban
balra vitte a karaktert a kerítés mentén (`frame-00000→00030`), de a régi célmemória,
majd a minimap a `frame-00085` képre visszavezette ugyanahhoz a hordó–őrtorony sarokhoz.
Ez részleges siker, nem lezárt javítás.

Második programdöntés: a minimap külön számolja a teljes, nyolclépéses kerülőciklusokat.
Ha másodszor is ugyanabba a lényegében változatlan irányba vezet, vagy előtte már egy
főképi megközelítés elakadt, a célvektor ellentett irányába ugyanaz a 18 lépéses hosszú
területelhagyás indul. Csak 90 foknál nagyobb tényleges minimap-irányváltás nullázza ezt
a memóriát.

## Második élő ellenőrzés: igazolt kijutás és fejlődés

A `224139-play` a főképi kerülő után ismét visszaért a lezárt kerítéshez, de a megőrzött
elakadási ciklus a 78. eseménynél elindította a 18 lépéses `(-0,60; +0,80)` kiszakadást.
A képi eredmény:

- `frame-00075.png`: még a hordó–őrtorony sarok és a túloldali célok;
- `frame-00110.png`: más kerítésszakasz, eltérő út és minimap-helyzet;
- `frame-00120.png`: nyílt terület, elérhető 10-szíves, 174 HP-s fenyő;
- 124–129. esemény: megközelítés 129→91→57 px;
- 131–132. esemény: `330→340` és felismert `+10` jutalom.

Ez közvetlenül igazolja, hogy a kiszakadás valódi pályahaladást és mérhető statfejlődést
hozott. Ezen az első rövid szakaszon még nem látszott, kell-e külön célhűtő; a hosszabb
ellenőrzés ezt később megválaszolta.

## Hosszabb ellenőrzés: irányhűtő szükséges

A `224139-play` későbbi 290. és 400. mentett képe ismét ugyanannál a lezárt kerítésnél
mutatta a karaktert. A 294–328. esemény második hosszú kiszakadása elvitte a zöld
medencéhez (`frame-00330`), de a minimap 441–452 között ismét a 200 HP-s, északi
kerítéscélhoz vezette. Tehát a kiszakadás megszünteti az elakadást, de önmagában nem
szünteti meg a rossz cél vonzerejét.

Harmadik programdöntés: minden kiszakadás 120 tényleges döntéses világirány-hűtőt hoz
létre. Ha a főképi vagy minimap-cél vektora legalább 0,45 skalárszorzattal ugyanabba az
irányba mutat, a bot oldalirányban derít fel. Egy kb. 63 foknál nagyobb eltérésű cél
azonnal feloldja a hűtést. Így az első kiszakadás utáni északnyugati fenyő engedélyezett,
az ugyanoda visszavezető északi 200-as cél nem.

## Irányhűtő élő igazolása — `225843-play`

Az újraindítás 35–44. eseményén a túloldali 200-as cél ismét 453→451 px-en stagnált;
a nyolclépéses akadálykövetés után 102–112 között a második megközelítés is 465→451 px-en
állt. A bot ezért 112–146 között végrehajtotta a teljes 18 döntéses `(-0,60; +0,80)`
kiszakadást. Közvetlenül ezután a 148., 150. és 152. valódi döntés már nem fordult vissza
a minimap északi céljához: `(-0,80; -0,60)` oldalirányú, „hűtőlistás lezárt minimap-irány”
swipe futott. A `frame-00150.png` a korábbi vízszintes kerítéssaroktól eltérő, nyitottabb
pályarészt mutat.

Ez biztosan igazolja az irányhűtő bekapcsolását és prioritását. Még mérendő, hogy a 120
döntéses időablak alatt talál-e elérhető farmcélt, illetve visszatér-e később ugyanahhoz
a kerítéshez.

A további felügyelet új korlátot mutatott: `frame-00200.png` és `frame-00245.png` között
a karakter ugyanannál a nyugati szikla–víz falnál maradt, miközben legalább húsz azonos
`(-0,80; -0,60)` hűtőswipe futott. A tiszta merőleges hűtés tehát megszüntette az első
hurkot, de új pályaszéli hurkot hozott létre. A javítás 12 végrehajtott hűtőswipe után
megfordítja a merőleges oldalt; részletes folyamat: `22-iranyhuto-oldalvaltas.md`.

## Bizonyossági címkék

- **Biztos:** 320→330 és a képen látható `+10` szív ugyanazon fenyő befejezéséhez tartozik.
- **Biztos:** a 83/56 sor OCR-szennyezés; a játékos HP-ja nem zuhant le.
- **Biztos:** a régi program több száz döntéses kerítéshurokba került.
- **Biztos:** a 18 lépéses kiszakadás elérhető célhoz és `+10`/340 HP fejlődéshez vitt.
- **Biztos:** hosszabb időtávon irányhűtő nélkül visszatért ugyanabba a lezárt zónába.
- **Biztos:** a `225843-play` első kiszakadása után az irányhűtő élőben felülírta a
  visszavezető minimap-vektort és oldalirányú felderítést indított.
- **Még ellenőrzendő:** az irányhűtő talál-e más elérhető célt fölösleges újabb
  kiszakadási ciklus nélkül, és a hűtés lejárta után tartós marad-e a kijutás.
- **Biztos:** az egyoldalú hűtés a nyugati pályaszélen új, legalább 45 képkockás vizuális
  stagnálást okozott; ezért a 12 swipe-onkénti oldalváltás szükséges.
