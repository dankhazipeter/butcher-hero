# A fehér szám kettévágta a HP-csíkot — 2026-09-19

## Bizonyított ok

`130809-105eeb6b-observe/1`: vizuálisan teljes5,65K zöld csík. A régi detektor
csak a jobb x335…348, y396…404 darabot tartotta meg. A hasonló bal oldali
13×9 darab képaránya1,44, ezért az1,5-ös általános feltétel kidobta.
A teljes csík helyett14pixelből téves23–24% sajátHP lett. A szöveg szétdarabolja
a színes komponenst; ez nem sebzés.

## Javítás

Csak a saját HP szűk, középső helyén (x44–56%, y45,5% körül±2,5%) a kisebb
zöld darabokat is megtartjuk. A már meglévő vízszintes összeillesztés így mindkét
oldalt látja. A normál távoli komponensek szűrése változatlan.

`132128-12a560fd-replay`: azonos képen egyesített x288…348, y396…404,
238zöldpixel, teljes csík. `132239-23514a72-replay`: a második6lépéses gráfélt
végig déli0,50s döntések adják, a korábbi téves kritikus megállás nélkül.
Release és teljes regressziós sor sikeres, beleértve a valódi3,04K/1,87K alacsonyHP-t.

Kapcsolódó OCR-védelem: ezres maximum mellett egy szűk kivágásból kapott puszta
`65` nem írhatja felül a tágabb sajátOCR-t. A lokalizált felülíráshoz K kell;
a tiszta tizedes-K közvetlen aktuális mérése megmarad. Ez megelőzi a5,65K→65 hibát.
