# Architektúra és döntések — 2026-10-29

## Aktív — 2026-10-30 (282)

296: a típusonként összevont sablonillesztés aktuális HUD-mintákat is
használ, változatlan küszöbökkel. Technikai --resume-run különválasztja
a folyamat újraindítását a gyűjtési időszak kezdetétől. A --current-run
képi típuskorrekció nem módosít igazolást, nem írja át a régi naplósorokat.

295:érték- és darabsorozat külön APIcsatornán. A collectionSeries ismert
típusú, igazolt claimenként1-et számol akkor is, ha az összeg hiányzik.
Az ismeretlen típus unclassifiedClaims, az arányok nevezője az azonosított
darabszám. Ugyanaz a végső kattintási idő/időablak és claimID-deduplikálás.

294:dashboard/format.js közös, szövegalapú K/M/B/T megjelenítési formázó,
az adatréteget nem érinti. dashboard/icons/ különRGBA UI-képek;
a felismerési erőforrások megmaradnak. Ikoncache1óra, API továbbra no-store.

292–293:read-onlyPythonHTTPstatisztika csaklocalhoston, növekményes JSONL-
olvasás, Decimalösszegek, claimID/finalclick szerinti könyvelési egyezés.
Buildmentes böngészőfelület2sfrissítéssel. A gyűjtővision3strukturált
Free-jelzést keres, nem puszta zöld pixelt; teljes nagyságrend/kezdőszámjegy
elsőbbséges.8sblokkolás egyszeri képi diagnózist ment. Régi adatokhoz nem nyúltunk.

286FELÜLÍRÁS:éles módbanRewardClaimVerificationváltja a végleges foglalást.
Kézi gomb/húzásvédelem, elengedés után friss validálás;1s után megmaradt
Freeújrapróbálható. Két HUD-képen hiányzó kártya igazol, külön pixeljelzés
OCRhibánál is jelenlétet tart fenn. Újrapróbák azonosclaimID, egyetlen
könyvelés; statisztika utolsópróba-idő és külön click_attempts.11tesztPASS.
Az alábbi284-es elküldött-input-blokkolás már történeti.

284:szám-OCRsaját számsor/karakterdoboz alapján különül el a háttéridőzítőtől.
Kattintás előtt elutasított input feloldja a foglalást; elküldött input
továbbra blokkol. Aclick_sentírás elkülönül az input előtti hibakezeléstől.

ButcherHeroAutomationkülön futtatja az1sFree-jutalom figyelőt, a régi
játékstratégiától függetlenül. Nyolc címkézett statikon+ellenőrzött valódi
Free-kártyák alapján alak- és színillesztés, külön numerikusOCRtartalékkal.
Kattintás után képi visszaigazolás; JSONLappend-onlynapló, Decimalösszegek,
időintervallumos összesítés. Bizonytalan régi sor offlineképből külön
reward_correctedeseménnyel javítható. Részletek és élő bizonyítékok:282.
A régi heartbeatPAUSED, csak aFreeautomatizáció fut; nincs mozgás vagy harc.
Az alábbi281-esSTOPmár történeti.

281:különButcherHeroAutomationésRewardAutomationCorealap készült,JSONL
jutalomnaplóval. Csakdry-runig tesztelt; a típusfelismerés javítandó,
valódi kattintás nem történt. FelhasználóiSTOP,játék bezárva,nincs futófigyelő.

A korábbi Swift-kód és eszközök megmaradtak; az új rendszer részleteiről még
nem döntöttünk. A21régi felső szintű JSON a visszaállítható archívumban van:
`archive/2026-10-29-before-restart/state/`. Az aktív állapot: `session-state.json`.

Egyetlen `observe --frames 1` készült, input nélkül. A régi elemző7660HP-t
és Island2-mozgást javasolt, miközben a friss képen473Més új UI látható.
Ezért a régi felismerés és stratégia új ellenőrzés nélkül nem dönthet.

A heartbeatPAUSED. Új megfigyelésre felhasználói jelzés kell.
