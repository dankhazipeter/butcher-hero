# Ötszázalékos pixelcsík-zaj és sebzéskapu

## Bizonyított anomália — `20260829-010847-play`

A 84. és 107. eseményben a pixeles HP-tartalék kb. 95%-ot adott, miközben a megőrzött
numerikus érték 424 volt. Mindkét esetet közvetlenül friss `424 / 100% [OCR]` kép
követte. Nincs bizonyíték valódi 21 HP sebzésre; a zöld csík széle valószínűleg
animáció, takarás vagy néhány pixelnyi komponensvesztés miatt rövidült.

## Játékmeneti hatás

A korábbi közös 2,5 százalékpontos esési küszöb mindkét 95%-os becslést friss sebzésnek
vette. A bot ezért a 108. eseménynél elfordult a 218 px-re lévő 136 HP-s farmcéltól,
noha a következő friss OCR teljes életerőt igazolt. Ez biztonságos, de mérhetően rontja
a farmolást és hamis menekülési hurkot okozhat.

## Döntés

- Friss numerikus OCR: legalább 2,5 százalékpontos esés továbbra is sebzésemlék.
- Pixel-fallback: csak legalább 10 százalékpontos esés hoz létre sebzésemléket.
- A pixelmérés önálló alacsony-HP védelme megmarad: 55% alatt újraindításkor is
  regenerációs módot aktivál, tehát a zajszűrés nem némítja el a nagy zuhanást.
- Élő ellenőrző futás: `20260829-011133-play`.

## Nyitott rész

A korábban látott 89%→29% pixelugrás még külön komponens-azonosítási hiba lehet. A
mostani kapu ezt menekülésként kezeli, ami biztonságos; később a numerikus HP és a
tartós maximum arányával keresztellenőrizhető, hogy ritkábban adjon téves riasztást.
