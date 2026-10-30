# Képszéli farmtiltás és bossészlelés szétválasztása

## Anomália

A `20260829-030113-play/frame-00428` bal szélén egy 1,22K HP-s páncélos 244 pixelre
állt a játékostól. A régi cél-előkészítés a zöld területen is kizárta a bal 25%-ot,
ezért a páncélos nemcsak farmcélként, hanem fenyegetésként is eltűnt. A bot a képen
látható 10-szíves fa felé indult volna.

## Javítás

A fekete keretes vörös csíkból most minden képi `Target` létrejön, a képszéli
helyzettől függetlenül. A bal 25%, illetve narancsszikla-zárfalnál 36% kizárás csak a
`safeTargets` farmjelöltekre vonatkozik. Így:

- részleges képszéli célt továbbra sem üldözünk;
- 800+ HP vagy 500-as statikon esetén ugyanaz a részleges jelölt bossfenyegetés lehet;
- a `nearestThreat` és a bossőr teljesebb látómezőt kap.

## Regresszió

- `20260829-031106-replay`, `frame-00428`: az OCR `1:22K` lett és 122 000-ra bomlott;
  244 pixelen boss, azonnali `(0,97; 0,25)` távolodás. A nagyságrend túlbecslése
  taktikai szempontból konzervatív és helyes.
- `20260829-031133-replay`, `frame-00418`: pontos `1.22K→1220`, de 378 pixelen a
  megelőző 360 pixeles küszöbön kívül marad. Nem farmcél, de még nem indít menekülést.
- A `031220-play` már élőben több, sérülés nélküli bossmenekülést indított ugyanebben
  a zónában.

## Fontos különbség

A 20-szíves, 431 HP-s fa biztonságos cél maradt. A `031220-play/frame-00205` külön
mutatta ezt és a jobb képszélen álló valódi 500/4.31K óriásfát; a döntés az utóbbi
miatt menekült.

