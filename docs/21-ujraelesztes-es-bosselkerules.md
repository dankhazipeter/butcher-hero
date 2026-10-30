# Újraélesztés, friss HP-megerősítés és bosselkerülés

Ez a fejezet a `20260828-225111-play` első egyértelműen elmentett `YOU DIED` sorozatát
és az abból következő védelmi szabályokat rögzíti. A felismerés, taktika és játékmechanika
azért egy közös kutatási folyamat, mert a hibás újraéledés-feltételezés azonnal újabb
veszélyes célhoz indíthatta a botot.

## Közvetlen képi bizonyíték

- `frame-00075.png`: a közelben egy óriás zöld fa látszik 500-as szívikonnal és
  `4.31K` HP-val. A játékos maximuma ekkor 340.
- `frame-00080.png`: nagy vörös `YOU DIED` felirat és lebegő vörös `170`; a boss csíkja
  kb. `4.23K`. Biztos tény, hogy a játékos meghalt, nem egyszerű OCR-zuhanás történt.
- `frame-00085.png`: a karakter ismét a zöld medencénél, a `0/7` buborék mellett van,
  de megbízható numerikus HP nem olvasható.
- A teljes, nem csak minden ötödik képet tartalmazó eseménynapló 87-nél 45/340,
  89-nél 139/340, majd folyamatos gyógyulást mutat. 115-nél 317/340, később 340/340.

## Biztos és erős következtetések

**Biztos:** a halál után automatikus medencés megjelenés történik, külön újraindító
gomb nélkül. Az átmenet során a HUD és a numerikus HP ideiglenesen hiányozhat.

**Biztos:** az első megbízható HP ebben a sorozatban nem teljes, hanem 45/340 volt.
Ez cáfolja azt az általános programfeltevést, hogy a medencés megjelenés vagy egy magas
pixel-/memóriaérték önmagában teljes HP-s respawnt jelent.

**Erős következtetés:** a karakter az újraélesztés után a medencében gyorsan regenerál.
A képsor nem bizonyítja, hogy pontosan 45 HP-val éled újra; csak azt, hogy a bot addig
nem tekintheti lezártnak a kritikus állapotot, amíg friss számot nem lát.

**Biztos:** a 4.31K HP-s óriásfa a jelenlegi 340 max HP mellett extrém veszélyes. A
`170` pontos jelentése még nem bizonyított egyedi bossütésként, de a teljes találkozás
egy halállal végződött.

## Programdöntések

1. Kritikus HP beállítja a `sawCriticalHealth` állapotot.
2. Az állapotot csak `playerHealthSource == "ocr-current"`, létező számszerű HP és
   legalább 90%-os arány oldhatja fel.
3. Pixelcsík vagy OCR-memória magas értékénél a bot helyben vár; nem indul célhoz és
   nem fogyaszt minimap-/akadálymemóriát.
4. Friss 85–90%-os OCR még nem elég: a visszavonulás folytatódik 90%-ig.
5. Legalább 800 kijelzett HP-jú `nearestThreat` 360 px-en belül boss-veszély. A bot
   törli az üldözési memóriát és 0,68 másodperces swipe-pal közvetlenül távolodik.

## Regresszió

A `20260828-225618-replay` eredménye:

- 75: a boss közelsége megelőző területelhagyást indít;
- 80–105: kritikus állapot után a pixel/memória nem old fel, a bot friss HP-ra vár;
- 110: 291/340 (86%, friss OCR) mellett még visszavonul;
- 115: 317/340 (93%, friss OCR) igazolja a helyreállást;
- 120: 340/340 után ismét engedélyezett a minimap-felderítés.

## Nyitott mérések

- az óriásfa pontos aggrósugara és támadási gyakorisága;
- a vörös `170` találat, összegzett sebzés vagy más halálkijelzés-e;
- az újraélesztés pillanatnyi kezdő HP-ja, illetve a medence passzív gyógyításának üteme;
- a boss jutalma és kapcsolata a Titan/7 gem folyamattal — ezt csak későbbi, felkészített
  kísérletben érdemes mérni.
