# Mért DOC-kijárat és Venom17 — 2026-09-19

## Kimért folyosó a saját térképen

A DOCudvar déli sziklája/kerítése nem járható egyenesben aVenomcél felé.
Északi kijárat, nyugati megkerülés, majd déli haladás a külső oldalon:

| Mérés | Friss végpontkép | Venomhoz viszonyított minimappont |
|---|---|---|
|152840-nudge,5N,0,50s|152848-ffb7b40d-observe/0|(-25;-44,5)|
|152935-nudge,5W,0,50s|152943-189b62da-observe/0|(-44;-45)|
|153017-nudge,8S,0,50s|153030-e1c1dbe7-observe/0|(-44,5;-14,5)|

Az időtartamok mérési jegyzőkönyv, **nem** a vezérlő lépésszámai.
`docs/landmark-corridors.json` menti a köztes pontokat és képi bizonyítékukat.
`LandmarkCorridorPlanner` friss minimappozíció alapján halad a következő pontig,
3,5minimappixeles érkezéssel. Helyi térkép akadálykerülése továbbra működik.
Két támpont közös koordinátára átszámolható, de nincs külön térképrétegek
automatikus összeolvasztása. Indulási régiókorlát,180s próbakeret és ismétlési
hűtés van. A geofence nem tökéletes magassági azonosítás; a következő
automatikus teljes bejárás külön igazolandó.

## Valódi farmgyőzelem

`153101-f2055791-play/0–8`: kilenc friss célirányú mozgás a folyosó végpontjáról.
9:3,06Kőr;12,15:31:21: **Venom17,560→595damage**,29m59s időzítő,
saját5860. A közvetlen megközelítés és jutalom kb20s. A teljes előzetes kijárat-
feltárás fejlesztési ideje nincs ebbe beleszámolva.

A tartós célállapot automatikusan mentette a29m59s hűtést és a jutalomképet.
KövetkezőVenom-ellenőrzés **16:01:20** körül; DOCkövetkező16:11:37körül.
FelszereltPhantom4+Venom17. A legfrissebb biztosDPS még aVenom16melletti1,35K;
a17-es új statpanelje külön ellenőrizendő.

## A nagy kaktusz időzítőjének utóellenőrzése

`123929-42ec3969-play/19` újranézve: a halál helyén, közvetlenül a karakter
alatt **13h20m**, mellette+300szív. Ez nem ugyanaz a távoli háttérkör-hiba,
mint aDOCesetén. `153030-observe/0` ugyanazon villanyoszlopos külső arénában
továbbra10h29m-es köröket mutat, nincs aktív11,4K kaktusz. A216-os hosszú
cooldown-megfigyelést ezért nem vontuk vissza. A napi darabszám és reset
továbbra hipotézis; nem jelenti, hogy minden más cél is napi.
