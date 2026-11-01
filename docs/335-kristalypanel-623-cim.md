# 623×863 kristálypanel: pontos címolvasás és folytatás

2026-11-01, Europe/Budapest. A felhasználó újraindította a játékot és kérte
a program indítását, majd kifejezetten jóváhagyta a panel felismerési hibájának
javítását: ha az x1 aktív, folytassuk; ha nincs mit nyitni, a saját piros X.

## Reprodukált hiba

A feloldott gépen az egyszeri snapshot sikeres; nincs aktuális TCC-hiba.
Ez nem bizonyítja a korábbi éjszakai TCC-hiba pontos okát. A normál HUD-ról
indult új saját D2BE46D1 tranzakció 09:44:38.598Z-kor megnyitotta az inventoryt,
de az eredeti 623×863 képen az olvasó `unknown`-t adott: title `; A EEE`,
grid `A AL`. 09:46:09.170Z-kor transaction_timeout. Nem történik vak x1-input.

Eredeti kép: `references/2026-10-31/crystals/inventory-ready-623-live.png`.
A dátumos könyvtár a már meglévő közös korpusz helye; e kép november1-i.
A képen arany X1 Open, saját felső pink X, CRYSTAL STATS és CRYSTALS látszik.
Az új teszt a javítás előtt öt ellenőrzésen elbukott. A 73pixel széles pink
komponensből számolt panelméret miatti titlecrop levágja a betűk tetejét.

## Szűk javítás

Az eredeti titlecrop az első. Csak sikertelen pontos cím esetén próbálunk
egyetlen felső, tágabb kivágást: x.38/y.337/w.25/h.041, a meglévő inventory-X
koordinátarendszerében. Ez `CRYSTAL’ STATS`-t ad, a korábbi írásjel-szűrés
után pontos CRYSTALSTATS. Az első .345-ös kísérlet `CRYSTAE’STATS`-ot adott:
ezt nem engedtük át és nem tettünk be fuzzy szóegyezést.

A grid továbbra pontos CRYSTALS a meglévő három szűk kivágás valamelyikén.
Arany komponens és pontos X1 kell, nem más gomb vagy Sell All. Nincs változás
a piros pöttyön, az inputvédelmen, a 16ütés/3lépés/90s kereten vagy az
operátori helyreállítás 600másodperces saját-napló ellenőrzésén.

## Regressziós védelem

Négy új unit teszt négy új eredeti képpel. A valódi képen inventoryReady,
az Open célpont a látható arany gombban, a bezárás a saját felső X-ben.
A title vagy grid kitakarásával unknown: sem Open, sem X nem engedett.
Az x1 helyének kitakarásával inventoryUnavailable: saját folyamat két
stabil képe után csak X; kézi egérgomb alatt vár, HUD-visszatérés nem jutalom.
A saját operátori recovery megőrzi a korábbi Open-próbákat, harmadik után
nem kap új keretet. A régi képi és kézipanel-védelmi tesztek megmaradnak.

További képek: `inventory-ready-623-validation` a betöltés utáni új preclick
(nem a crop kiválasztásához használt kép), `result-623-live` és a szürke,
inaktív Open gombos `inventory-no-open-623-live`. Az utóbbi konzervatívan
inventoryUnavailable, nem számként igazolt 0/9; ez a saját folyamat számára
bezárható, de nyitásra sosem jogosít. A valódi képek külön tesztelik, hogy
csak a saját lépés engedett: Open / Continue / X.

## Betöltés és élő eredmény

A kód+első három új teszt teljes offline kapuja sikeres:202teszt+7JS-check.
Külön staging release sikeres. Saját stop után, nem futó executable-re
atomikus `.next`→rename csere. Leállítás kérése09:53:47Z, új worker09:54:03Z;
a képrögzítés ebben a fejlesztési szünetben nem folyt párhuzamosan.

A saját D2BE tranzakció még600másodpercen belüli volt: operátori recovery
09:54:03.363Z, az eredeti09:44:38.176Z kezdettől565.187másodperc. Nem
hosszabbítottuk meg a guardot, nem vettük át a tegnapi lejárt2DEtranzakciót.
Eredeti elküldött próbák megmaradtak. A frissképes élő lépések:

- 09:54:06.488Z x1 Open;
- ellenőrzött geodeütések, majd piros40 / Pierce Damage +89K eredménykép;
- 09:54:19.420Z saját Continue;
- 09:54:21.361Z saját, már nem nyitható inventory;
- 09:54:22.607Z saját felső X;
- 09:54:23.681Z két HUD után `crystal_completed_ui`;
- 09:54:56.064Z 34BD8C4B új Health18200 Free `claim_confirmed_ui`.

Ez most javítás utáni operátori helyreállítással befejezett kör, nem egy
teljesen megszakításmentes új notification-kör bizonyítéka. A kristály
eredménye nem kerül a Free-statisztikába; történeti naplóátírás/reset nincs.
Az új független élő képekkel bővített végső kapu203teszt+7JS-check.
Friss runtime: `data/local-app/state.json`, `data/free-rewards/state.json`,
`supervisor.json`; a worker6390/runner6381/session4985 itt csak történeti.
A gyűjtő a további offline tesztek és Git-kapuk alatt futva marad.
