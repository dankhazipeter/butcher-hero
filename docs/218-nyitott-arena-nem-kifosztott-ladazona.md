# A nyitott aréna nem kifosztott ládazóna — 2026-09-19

## Bizonyíték

`125006-0e7f583b-nudge`: 5NW × 0,50 s. `125014-032801cf-observe/1` a fa
híd alatti mozgó pozíciót mutatja. További `125035-92db4ac1-nudge` 4NW × 0,50 s
után `125041-64028846-observe/1`: **szabad, széles narancs aréna**, északon
két 2,49K-s cél, jobb szélen a nagy őr. Tehát a korábbi szélmalomzsebből
északnyugat felé valóban ki lehet jutni. Nem kell Unstuck.

Az observe mindkét helyen mégis „kimerített egyszeri magaslati ládaág” miatt
Settings/Unstuck-ot javasolt. Observe nem küldött inputot. Az ok a 217-ben
leírt hibás keleti makró által mentett `elevatedBossRouteIgnoreUntil` és a
túl tág (narancs + nincs kis farmcél + teljes HP) teleportfeltétel.

## Javítás

Mindkét rövidített ládazónás Unstuck-ág most legalább hat sikertelen
statikus kiszabadítási fázist és 150 fejlődés nélküli döntést kér, az általános
elakadáskezeléshez hasonlóan. Narancs biom vagy tartós flag önmagában nem elég.
Az utolsó hibás makró által írt `811509269.370528` útvonal-lejáratot 0-ra
állítottuk; a valódi harci vereségsávok és minden más navigációs adat megmaradt.

## Következő kísérlet

5580 maximum, Bat11+Venom13 mellett a szabad arénából kontrollált bosspróba.
Az elért sík és a kontaktus külön bizonyítandó; automatikus győzelmet nem állítunk.

Release build és teljes regresszió sikeres. Új `stale-highland-flag.json`
fixture távoli jövőig aktív régi flaggel ellenőrzi, hogy a 125041-es nyitott
arénakép nem eredményez Unstuck-tapot. Ez a teszt is zöld.
