# Tábori ösvény és képi útmérés — 2026-09-19

## Hipotézis és ellenőrzés

A183501-es zsákutca után nem szabad közvetlenül a nyugati piros pontra
fordulni: a kerítés és a sziklafal közé jutunk. A259-es kísérlet a258-ban
elkezdett korrekció folytatása: az észak–déli nyílt ösvényen előbb a torony
északi oldala fölé kerülünk, utána lehet nyugat felé célt keresni.

183958-observe/0: saját6,51K, a torony északnyugatra.184008-nudge
3×0,45s észak,184013/0még a torony keleti oldalán.184043-nudge újabb
3×0,45s észak;184048/0a torony teljes teteje is a karakter mögött/délre.
Az északi–nyugati nyílt fű most láthatóan szabad. Felügyelői út, nem autonóm siker.

## Új mérőeszköz

`tools/measure-route.swift` a meglévőVisualOdometry-t használó csak olvasó
offline audit. Sorrendben kapottPNG-k között méri a terep eltolódását,
200px-es/érvénytelen képpárnál hibával leáll, nem hidalja át az ismeretlen ugrást.
Nem ír játékállapotot vagy térképet. Fordítás: `swiftc Sources/ButcherHeroBot/VisualOdometry.swift tools/measure-route.swift -o .build/measure-route`.

A fenti két menet minden köztes képe jó: mozgó képpárok43,42,64,59,54,64
konszenzuspont,2,26–2,89maradékhiba. Összesen **x−6,65/y−452,02képpixel**;
az első szakasz y−222,47. A sebességváltozást így nem swipe-számból becsüljük.
A pontok `camp-tower-north-route.json`-ban helyi, kizárólag ehhez a képsorhoz
tartozó koordináták. Automatikus világtérképi import nincs: a kezdőhely
megbízható vizuális visszaazonosítása és az út ismétlése még hiányzik.

184143-play rövid élő ellenőrzés a felső végpontról: a következő cél
megközelítése már a bot feladata. Eredményét külön az alábbiakban rögzítjük.

Élő184143/1–7a déli újraélő29HPfa felé visszafordult,8képen516találat
ésúj7h18m (a kis cél is kimerült).22képen ismét szikla mellett. Ez a
felső kijárat autonóm használatának kudarca, nem bizonyított jó útvonal.
A gyökérokban szerepet játszik, hogy a mért térképrészV2-be nem került át;
konkrét integrációs javítás260-ban, nem több vak északnyugati próba.
