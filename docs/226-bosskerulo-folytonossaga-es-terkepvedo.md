# Bosskerülő folytonossága és térképvédő — 2026-09-19

## Élő anomália

`133652-d62deb35-play`: a632-es kaktusz megközelítése után a DOC4,4K őre
újra látszik; órás cooldownja lejárt. A7. képtől a bot a déli sziklafalon
át közelített. A12. képen oldalkerülő indult, de13/15/16stb. alatt a takart
boss visszakeresése félbeszakította, visszafordította. A31. döntés feladta,
a33. már ugyanazt a sebzés nélküli próbát újrakezdte. Egyik fél HP-ja nem esett.

## Javítás és hipotézis

A megkezdett általános oldalkerülő is végigfut a legfeljebb hét lépésén, akkor
is, ha a boss átmenetileg kicsúszik a képből. Korábban ezt csak Titan-objektum
kerülésekor engedtük. Sebzés- és HP-védelem továbbra elsőbbséges.
Sebzés nélküli, már kerülőt is próbált elveszett cél120döntéses sávhűtést kap,
nem azonnali új próbakört. Ez útvonalkudarc, nem tartós harci vereség.
Az északi, már bizonyított DOC-bejáratot kell újra elérni (211).

## Kinagyított térkép

`133816-62ee5a19-observe/0`: a nagyító mínuszgombjával megnyitott térkép
elfoglalja a jobb felső félképet, de a régi bot100% HUD-ot és WNW mozgást adna.
Ez hibás: térképen a swipe panorámamozgás vagy félreértelmezett input lehet.

Az új `ExpandedMapDetector.swift` a rögzített mínusz-nagyító gomb24×24-es
szürkeárnyalatos mintáját hasonlítja, nem a változó térképtartalmat. A minta
forrása a fenti eredeti PNG; ezt a referenciát a futásnaplók takarításakor is
meg kell őrizni. Átlagos abszolút eltérés18alatt pozitív. Öt normál/panelkép
76–108eltérést adott; független friss `134014-observe/0` térképkép eltérése0,
tehát az állandó gomb az eltérő képidőben is pontosan felismerhető.

Pozitív térképfelismeréskor inputmentes várás, navigációs számlálók fagyasztása,
HP-tanulás és akadálytanulás tiltása. A térkép bezárását a felügyelő végzi;
ismeretlen UI-elemet nem nyomunk automatikusan. Ez még nem térképolvasó/routing.

Build és teljes regresszió sikeres. `134146-d1b80e5b-replay`12–18képei azonos
irányban befejezik a hétlépéses kerülőt;13/15/16 már nem fordulnak vissza.
`134145-81f1abc2-play`: öt másodperces élő térképellenőrzés,10/10inputmentes
várakozás, mindegyiken pozitív térképfelismerés. Bezárás után `134218-observe`
újra normál játékot mutat. A rövid hűtés külön élő ága még ellenőrzendő.
