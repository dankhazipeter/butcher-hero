# Felügyeleti ébresztés és haladásőr — 2026-09-19

## Programon belüli védelem

A `ProgressWatchdog` tizenkét tényleges navigációs mozdulat után 80 képi pixel
alatti nettó elmozdulásnál leállítja a futást és képi újratervezést kér.
Csak azonos, érvényes helyi térképrészen, legalább95% HP-nál, közeli fenyegetés
és UI nélkül mér. Kihagyott input nem számít; térképrészváltás és UI nulláz.
Ez nem bossvereség, és nem bizonyítja, hogy minden hurok felismerhető.

Teszt:12×4px megállít;12×60px nem; input nélküli megfigyelés és chartváltás
nem okoz téves leállást. Releasebuild és teljes regresszió sikeres.
A folyosó-, iránymenti haladás- és megszakítási tesztek is átmentek.
Élő új ellenőrzés: `20260919-154453-23a5b614-play`,0–58. Előbb észak felé
haladt, majd a sziklaudvarban visszatért ugyanoda;43képen nincs támadható cél.
A helyi chartváltások nullázták az őrt, ezért kézzel megszakítottuk.
Javítás: külön13pontos minimapablak,4pixel alatti nettó haladásnál stop;
a két ismert támpont közös koordinátára átszámítva, chartváltás ezt nem törli.
UI/érvénytelen támpont továbbra törli, kihagyott input nem számít.
Új regresszió: minden lépésnél más chart, ugyanazon minimaphely →12után stop.
Az új őr nem állítja, hogy a helyi térkép már globálisan konzisztens.

**Élő javítás igazolva:** `154802-d33bc484-play/12`: tizenkét valóban végrehajtott
mozdulat után automatikus STOP, 4minimappixel alatti nettó haladás miatt.
Saját5860, nincs harc; a visszatérő északnyugati falirány megszakadt.
A következő kísérlet a déli kijárat képi kimérése, nem változatlan újraindítás.
`tests/map-and-shop-regression.sh` kibővítve a haladásőr-, megszakítás- és
folyosótesztekkel; az egész sikeres a javított releasebuild után.

## Tartós, ugyanebben a beszélgetésben futó felügyelet

Aktív percenkénti heartbeat:
`butcher-hero-k-pi-fel-gyelet-s-fejleszt-s`.
Ez időszakos modell-felülvizsgálat, nem minden képkocka valós idejű modellnézése.
Közben a program végzi a képenkénti felismerést; a haladásőr megállíthatja a hurkot.
Minden ébresztés friss PNG-t és naplót értékel; szükség szerint javítás, teszt,
rövid újraindítás és MD-dokumentálás következik. Egyetlen élő képrögzítő futhat.
Változatlan állapotról nem küld ismétlődő üzenetet.

Felhasználói stop: az input azonnal megszakítandó, a heartbeat PAUSED állapotra
állítandó; újraindítás csak új folytatási kérésre. Továbbra idle1.5, nincs pénz-,
gemköltés vagy reklám. Elakadás után tilos változatlan vak újraindítással körözni.

Az OpenAI Docs útmutató alapján a meglévő beszélgetéshez kötött ébresztést
választottuk, így a vizuális fejlesztési kontextus megmarad. Helyi felügyelethez
a számítógépnek és az alkalmazásnak működnie kell.
Forrás: https://learn.chatgpt.com/docs/automations?surface=app

## Legfrissebb igazolt statok

`153751-55d33aee-observe/0`, ismétlés `153854-6daaf180-observe/0`:
**1,39K DPS,5860 HP,68 regeneráció**, Phantom Edge4 + Venom Shard17.
Cut125; piercing111+995+1%. Tartalék:Bat11,Steel22,SavageFang18.
Ez felülírja a237-es1,35K/Venom16 adatot; nem újabb kézi felszereléscsere.
Venom következő16:01:20, DOC16:11:37 körül. A két vesztes boss újrapróbája
nincs feloldva; a teljes automatikus DOC-folyosó reprodukciója még nyitott.
