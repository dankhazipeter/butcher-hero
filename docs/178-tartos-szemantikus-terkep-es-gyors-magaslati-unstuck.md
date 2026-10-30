# Tartós szemantikus térkép és gyors magaslati Unstuck

## Feltárt adatmegőrzési hiba

A `world-map.json` ellenőrzésekor a geometriai térkép elérte a 400 csomópontos
korlátot: 2938 végrehajtott iránypróba, 946 blokkolás és 222 automatikus kerülő
szerepelt benne. A gyorsítótár életkor alapján cserélte a csomópontokat, ezért a
korábban bizonyított `collectedChestDirections` jelölések száma nullára esett.

Ez nem játékmeneti cáfolat volt, hanem architekturális hiba: az egyszeri jutalom
végleges tudását a változó képi helyek gyorsítótárában tároltuk.

## Külön tartós szemantikus réteg

Az egyszeri ládahelyek most a `docs/semantic-map.json` kis, külön állományban is
megmaradnak. A geometriai LRU-térkép:

- nem dobhat ki helyileg vagy szemantikusan ládaként védett csomópontot;
- visszatéréskor a tartós szemantikus irányt akkor is visszatölti egy friss helyi
  csomópontba, ha a geometriai példány korábban eltűnt;
- minden új biztos `TAP TO CLAIM`, `CONTINUE` vagy jutalom után egyszerre frissíti
  a gyors geometriai és a végleges szemantikus állapotot.

A `180420-play` 4. képe megőrizte a második bizonyított különleges láda pontos
33 elemű háttéraláírását és bal-felső, 5. iránybinjét. Ezt hitelesen
visszaállítottuk a szemantikus fájlba. Az új `193049-play` indulása után az
állomány változatlanul, egy begyűjtött ládahellyel megmaradt.

A legelső ládát még a szemantikus naplózás előtt nyitottuk ki, ezért ahhoz nincs
biztos háttéraláírás. A helyét nem becsüljük meg: ha a bot később újra felismeri
a kifosztott csomópontot vagy új ládát talál, bizonyítékból egészíti ki a térképet.

## Gyorsabb magaslati helyreállítás

A `192554-play` a cél nélküli narancssziklás zsebben hat teljes statikus
kiszabadítási fázist futtatott. A 103. döntésben sikeresen végrehajtotta az
Unstuckot, de az első biztos zsákutcajeltől 77 további navigációs döntés telt el.

Narancssziklás magaslaton most három külön statikus fázis elegendő az
Unstuckhoz. Ez továbbra is több eltérő átló és falirány fizikai próbája, nem
egyetlen akadályból levont következtetés. Normál terepen a konzervatív hatfázisos
küszöb változatlan marad.

A `193049-play` 48. döntése már három magaslati fázis után nyitotta meg a
Settingset, de a játék saját Unstuck gombján még visszaszámlálás futott. A bot
ezt az ötödik panelképen felismerte és biztonságosan bezárta. Kiderült, hogy a
tízperces belső újrapróba-tiltás csak folyamatmemóriában volt, így fejlesztési
újraindításkor elveszett. Az `unstuckRetryUntil` most a `navigation-state.json`
része; sikertelen panelnyitás, visszaszámlálós gomb és sikeres teleport után is
abszolút lejárati időt ment. A `193422-play` már ebből a tartós időzárból indult.

## Térképállapotok

- `world-map.json`: sűrű, cserélhető geometriai tapasztalat — sikeres és blokkolt
  irányok, lokális zsákutcák, kerülési pontszámok.
- `semantic-map.json`: kicsi, nem felejthető játéktudás — biztosan begyűjtött
  egyszeri ládahelyek és lezárt visszairányok.
- `navigation-state.json`: időben lejáró helyállapot — Titan- és Deep Mines-hűtés,
  Unstuck-újrapróba, valamint korábbi bossvereség a saját akkori maximum mellett.
- `bot-state.json`: tartós játékoserő — jelenleg 1940 bizonyított maximum-HP.

## Nyitott ellenőrzések

- A visszaállított ládahely tényleges újralátásakor a szemantikus kerülő élőben
  kiválasztja-e a legjobb új irányt.
- Új különleges láda átvétele automatikusan második bejegyzést hoz-e létre.
- A képi aláírás legfeljebb 14-es eltérési küszöbe elég stabil-e eltérő effektek
  és takarás mellett anélkül, hogy más helyet ugyanannak venne.
