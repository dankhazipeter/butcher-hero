# A boss által félbeszakított kerülő nem sikertelen kerülő

## Reprodukált állapotgéphiba

A `082820-play` 176–190. döntéseinél a 174 HP-s fa megközelítése 284/285 pixelen
stagnált. A 186. döntés balra-le tartós kerülőt indított, majd a 190. képen megjelenő
boss jogosan megszakította. A kerülőoldal jele átfordult jobbra-fel irányra, de a
`failedApproachCycles=1` megmaradt.

A fa következő felismerésekor az újabb stagnálás ezt 2-re emelte, ezért a 259. döntés
az ellenoldali kerülő kipróbálása nélkül közvetlen hosszú kiszakadást indított. A
naplóban tehát a „két kerülő” indok hamis volt: csak egy kerülő kezdődött, és az sem
fejeződött be.

## Javítás

Ha bossészleléskor még aktív a `persistentDetourFrames`, a bossőr:

- változatlanul azonnal menekül;
- törli a félbehagyott mozgásmemóriát;
- eggyel visszalépteti a `failedApproachCycles` számlálót;
- **nem** fordítja vissza a már átállított `nextDetourSign` értéket.

Így a következő azonos stagnálás valóban az ellenkező oldali kerülőt indítja. Csak
két végrehajtott, boss által meg nem szakított kerülő után engedélyezett a hosszú
célterület-elhagyás.

## Ellenőrzési terv

1. A `082820-play` replayben az első bossmegszakítás után a második fa-plató ne adjon
   azonnal „két kerülő” kiszakadást.
2. A következő aktív kerülő iránya a korábbi balra-le helyett jobbra-fel legyen.
3. Boss láthatóságakor a menekülés változatlanul megelőzze a fát.
4. Élőben mérjük, csökken-e a fa távolsága 284 pixel alá a másik oldalon.

## Replay-eredmény

A `083548-replay` az első fa-platón ugyanúgy balra-le kerülőt, majd bossmenekülést
adott. A második 303→284→285 pixeles sorban a javított döntő már nem indított hamis
„két kerülő” hosszú kiszakadást. A ritkított képsor következő képe viszont a régi
élő bináris által már 329 pixelre eltolt állapot, ezért a jobbra-fel mozdulat nem
reprodukálható teljesen ebből a felvételből. A számláló-regresszió sikeres, az irány
élő igazolása még folyamatban.
