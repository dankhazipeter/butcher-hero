# Helyzetfüggő elérhetetlenség és újabb +1 fejsze

## Kiinduló hurok és első megoldás

A `20260829-043455-play` során a 291 HP-s, 1-fejszés fenyő a kőfal mögött kétszer is
234 pixel körül megállította a közelítést. A hosszú kiszakadás után ugyanaz a piros
minimappont nagyobb körben visszavezette a karaktert. Az első javítás az aktív
HP±20/fa célaláírás teljes 360 döntéses idejére elnémította volna ezt a minimapjelet,
és növekvő négyzetspirált használt volna. A `20260829-044247-replay` igazolta, hogy
a döntő tényleg átáll spirálra és a bossőr továbbra is közbe tud lépni.

## Élő ellenpélda — `20260829-044329-play`

Az új élő folyamat ugyanazt a 291 HP-s, 1-fejszés fenyőt más pályaoldalról érte el:

- 9–20. esemény: 272→226→186→148→119→90 pixel, folyamatos valódi közeledés;
- `frame-00020`: a fenyő közvetlenül a karakter előtt, mögötte egy 1,22K HP-s
  páncélos;
- `frame-00022`: a fenyő eltűnt, fehér fejszeikon mellett 580-as találat, külön
  nyílikon mellett 24, továbbá vizuálisan zöld `+1` kék fejsze jutalom;
- ugyanazon a képen a páncélos 1,22K bossbizonyítéka aktiválta a hatswipe-os
  távolodást; a játékos 727 HP-ja megmaradt.

Biztos következtetés: a 291 HP-s fa nem globálisan elérhetetlen. A járhatóság a
megközelítési oldaltól függ. A korábbi falnézetben üldözni rossz, az új oldalról viszont
gyors +1 támadóstat-hozamelem. A 580 valószínűleg a korábbi 387 normál érték 1,5-szeres,
lefelé kerekített kritikus találata (`387 × 1,5 = 580,5`); ezt további fehér fejszes
számokkal kell igazolni.

## Véglegesített döntés: cél + képi környezet

Az elérhetetlen aláírás most már három részből áll:

1. kijelzett cél-HP ±20;
2. fa/nem-fa testosztály;
3. az elakadáskori 33 elemű háttér-ujjlenyomat.

Az aktív hűtés csak akkor némítja a célhoz tartozó minimapjelet, ha a jelenlegi és az
elakadáskori ujjlenyomat L1-különbsége legfeljebb 44. A fal előtti célképek mért
eltérése 0–22, a kiszakadás első átmenetei legfeljebb 42 voltak. Az élő, járható
megközelítés 45-ös különbséget adott, ezért azon az oldalon a bot újra próbálhatja a
célpontot. A kontextuskaput a `20260829-044610-replay` ellenőrizte:

- a közeli falnézetben spirálfelderítés indul;
- kellően megváltozott háttérnél a minimap újra használható;
- az új oldalról megjelenő 291-es cél közelíthető;
- az 1,22K boss továbbra is azonnal felülírja a farmot.

## Nyitott mérés

A mostani +1 után a következő elkülönített normál fejszes találat várhatóan a korábbi
387-ről ismét kismértékben nő. Mérni kell a normál és kritikus számot, mert az előző
+1 fejsze 385→387, vagyis kijelzetten +2 változást adott, nem +1-et.
