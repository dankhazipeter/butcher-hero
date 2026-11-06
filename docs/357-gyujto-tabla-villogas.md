# Gyűjtő tábla: „Dolgozik” ↔ „Fut” villogás kristálynyitáskor

2026-11-06. Felhasználói jelzés: az oldalsáv GYŰJTŐ tábláján a „Dolgozik” és a
„Fut” felirat folyamatosan váltakozik.

## Ok (kódból és a kristálynaplóból)

A tábla állapotát minden képkockánál újra kiszámoltuk. „Dolgozik” csak akkor
volt, ha az adott kép felismert kristály- vagy eseményképernyő volt
(`screenState` crystal/event). Kristálynyitáskor (nagyjából 52 percenként,
kb. 15 s; ma 12 kör, mind completed_ui) két ütés között a geode-animációt a
kristályfelismerő `unknown`-nak látja. Ha a HUD is látszik, a képernyő `hud`, így
a felirat másodpercenként visszaugrott „Fut”-ra; HUD nélkül átmenetileg
„Ismeretlen képernyő” is lehetett. Eseményablak ma nem volt (0 sor).
A gyűjtés és a kristálynyitás helyesen működött, csak a kijelzés villogott.

## Javítás (csak kijelzés)

`AppModel.collectorState`: a folyamat fázisa dönt, nem az egyes kép. Ha
`crystalPhase` vagy `eventEndPhase` nem `idle`, a tábla végig „Dolgozik” a
körön belül, a záró két HUD-képig. Az elakadás (`blocked`), a kézi panel és a
„Rád vár” előrébb van, és változatlan. A gyűjtő kódja, a felismerés és a napló
nem változott.

## Ellenőrzés

Fordítás és teljes tesztkapu. Élőben nem figyeltük meg, mert a felhasználó a
gyűjtést és a játékot közben leállította; a következő kristálynyitásnál látszik.
