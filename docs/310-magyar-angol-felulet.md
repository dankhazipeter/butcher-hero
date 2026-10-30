# Magyar–angol felület — 2026-10-30

## Kérés és eredmény

A fejléc tetején Magyar / English nyelvválasztó jelenik meg. Alapértelmezés
a magyar; a választást a böngésző helyi tárolója megjegyzi. Váltáshoz nem
kell újratölteni az oldalt. Az új funkció betöltéséhez a korábban nyitott
lapot egyszer újra kell tölteni.

Külön nyelvi fájlok: `dashboard/locales/hu.js` és `en.js`. Az i18n.js csak
kulcsot keres, helyőrzőt cserél és statikus DOM-szöveget fordít. A katalógus
tartalmazza a nyelv saját nevét és Intl-locale értékét is. A selector ezekből
épül, nincs második kézzel karbantartott nyelvlista.

Új nyelv felvételének részletes menete: `dashboard/locales/README.md`.
Egy új fájl és egy helyi scriptbetöltés kell; a fordítások kulcs-/helyőrző-
azonosságát és betöltését a teljes tesztkapu automatikusan ellenőrzi.
Nincs fordítási szolgáltatás, CDN, új csomagfüggőség vagy külső adatküldés.

## Lefedettség és adatvédelem

Fordulnak a fejlécek, gombok, súgók, figyelmeztetések, üres állapotok,
táblázat, grafikonok, statnevek, tooltipek és akadálymentes címkék.
Az állapotgép kimenetét fordítófüggvény teszi emberi szöveggé; a döntése
változatlan. Dátumok és számjelek locale-függők: HU18,3K / EN18.3K,
pontos tooltipben HU18 300 / EN18,300. A K/M-skálaszabály nem változik.

A nyelv csak UI-beállítás. Nem fordítjuk át a mentett jutalomnaplót,
nem változik a játék nyelve, az API és a belső jutalomtípusok. Az eredeti
gyűjtő-/rendszerhiba üzenetét szó szerint idézzük lokalizált keretszöveggel.
Pénzösszeg vagy naplóérték nem kerül lebegőpontos konverzióval könyvelésre.

Nyelvváltáskor a meglévő kártyák megmaradnak, a számok új nyelvi
végformátumra váltanak animált „új bevétel” nélkül. Az időszak és saját
dátummezők, valamint elrejtett görbék megmaradnak. Régi/hibás kapcsolat
nem válhat tévesen élővé pusztán a nyelvváltástól. Helyi tárolási hiba és
ismeretlen tárolt nyelv nem állíthatja le a felületet; magyar a fallback.

## Ellenőrzés és működés

A nyelvi fájlok kulcsait, helyőrzőit, nem üres fordításait, HTML/JS-kulcsait
és betöltési sorrendjét Node-teszt ellenőrzi. A böngészős global-regisztráció
vm-ben is lefut. További tesztek: tárolás/fallback, dokumentumnyelv/cím/ARIA,
mindkét számformátum, az összes gyűjtőállapot, tényleges élő app-kirajzolás,
meglévő kártya/szűrő/elrejtés megőrzése, kapcsolatvesztés utáni váltás.
A Python HTTP-teszt vizsgálja a két nyelvi fájlt és az útvonalvédelmet.

A Sites készség helyi-only menetét követjük. A read-only szerver új
útvonalakhoz89001-ről2459-re indult újra, tartós session3264. A66095gyűjtő
végig futott,21:47:58Zfriss sikeres képidővel. A309-es Healthpreclickhiba
ettől nem javult meg, továbbra külön nyitott ügy, nem állítunk hibátlan gyűjtést.

A helyi HTTP-n az új JS/nyelvi fájlok elérhetők. A böngészős kapcsolat
korábbi hibája és a natív Codex-felület tiltott automatizálása miatt új
vizuális igazolás nem sikerült; nem próbáltunk kerülő megoldást. A felületet
itt automatizált DOM/SVG-tesztekkel ellenőriztük, nem kézi vizuális PASS-szal.

Végső helyi ellenőrzés:23Swift+15statisztika+3Gitkapu+9felügyelet+31Node,
összesen81teszt és7JS-szintaxisellenőrzésPASS. A korábbi képolvasási
elvárások nem változtak; csak a felhasználó által kért megjelenítési nyelv
miatt frissültek a UI-szövegelvárások. Hiányzó nyelvi fájl404, nincs
tetszőleges fájlolvasás vagy feloldott CSP. A távoli CI külön ellenőrizendő.
