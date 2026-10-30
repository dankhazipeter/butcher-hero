# Első távoli CI és Swift-fordítókompatibilitás — 2026-10-30

## Bizonyíték, nem hipotézis

A298-as feltöltés után a GitHub valóban elindította a workflowt:
[41106695612futás](https://github.com/dankhazipeter/butcher-hero/actions/runs/41106695612),
commit`e5bc177`, job`124238278204`. A státuszFAIL, a tesztparancs2-es
kilépéssel állt meg. A nyilvános API lépéslistája üres volt, így abból nem
lehetett pontos okot mondani. A jobhoz tartozó csatlakoztatott GitHub-
naplóolvasóval elért tényleges futási napló mutatta meg a hibát.

macOS15.8.2/Swift6.1.2/Python3.13.17/Node24.22.1. A helyi Swift6.4.2.
A kapacitáshiányról is volt NOTICE, de a job elindult, minden setup sikerült,
és a hiba fordítás közben keletkezett, még a képi tesztek futása előtt:

- `main.swift` és `@main` együtt a régi bottargetben top-level belépésütközés.
- A swipe sugárértékének implicit opcionális/numerikus típusfeloldása.
- Az ExpandedMapDetector összetett compactMap/map/zip/reduce kifejezését
  a régebbi fordító nem tudta elfogadható idő alatt típusellenőrizni.

A SwiftPMtesztindítás a régi executabletargetet is fordítja, bár aFree-
tesztek azt nem indítják el. Ezért számít a klónozói fordíthatóság is.

## Szűk javítás

- Az @mainbelépést tartalmazó forrás új neve `BotMain.swift`; a belépés
  tartalma és az executableterméknév változatlan. Nincs unsafecompilerflag.
- A sugár explicitDouble, a CGPointeltolása explicitCGFloat. Az alapképlet
  és az opcionális dragDistanceFraction jelentése változatlan.
- A pixelkülönbség ugyanaz az egész abszolút összeg/elemszám/minimum,
  csak jól típusozható egyszerű ciklusokra bontva.

Nem szedtük ki a régi targetet a buildből, nem hagytunk ki tesztet,
nem engedtünk tovább hibánál, és nem módosítottunk képi elvárást. A régi
játékbotot nem indítottuk el, a javítás nem ad új mozgási engedélyt.

A helyi teljes teszt és a következő valódi GitHubfutás külön bizonyíték;
a korábbi helyiPASSnem volt elegendő a régebbi fordító igazolásához.

A javítás utáni helyi `make test`:17Swift/13statisztika/3Gitkapu/5Node
és két JSszintaxisellenőrzésPASS. A27képes címkézett korpusz változatlan.
