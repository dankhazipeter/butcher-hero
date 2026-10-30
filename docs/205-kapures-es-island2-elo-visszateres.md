# Kapurés és élő Island 2-visszatérés — 2026-09-19

## Biztos mai út, félmásodperces tartásokkal

Kiindulás: `20260919-115940-observe/1`, a Deep Mines zárt kapujának zöld oldala,
a függőleges kerítés KE-i oldalán, sátor és szekér mellett. Ablak 637×882.

| Él | Végpont és képi ellenőrzés |
|---|---|
| 5 dél, 0,50 s | 115958-observe: a függőleges kerítés két része közötti nyílás |
| 5 nyugat, 0,50 s | 120020-observe: a kerítéstől nyugatra, út és sziklás növénycsoport |
| 5 dél, 0,50 s | 120045-observe: kövezett kereszteződés, fa irányjel a játékos felett |
| 6 WNW, 0,50 s | 120109-observe: nyugati út az 1,22K-s őrtábor alatt |
| 6 WNW, 0,50 s | 120139-observe: a tényleges narancs–zöld kapu, játékos a határon |
| 3 nyugat, 0,50 s | 120207-observe: belépés a narancs területre, helyi kaktuszcél |

WNW itt pontosan `dx=-1, dy=-0,25`, normalizálva.
A route belépési feltétele a képi kezdőpont, nem pusztán a Deep Mines felirat.
A kapu teljes szélessége és a kerítés oldala számít; a korábbi 13S az eltérő
kezdőpozícióról nem helyettesíti ezt a sort. A sikeres részélek együtt ma
valóban elérték Island 2-t, hosszú falba futás nélkül.

## Útközbeni fejlődés

A kijelzés 4,46K-ról 4,47K-ra változott a kereszteződés elérésekor. Az útközbeni
humanoidkontaktus időben egybeesik, de a pontos jutalomforrás és a nem kerekített
maximum még nem bizonyított. Tartós állapotot nem írunk át kézi találgatással.

## Következő kísérlet

`120207-observe` után 45 másodperces, minden képet mentő automatikus harci próba
indul Bat11 + Venom12 builddel, 1,5 másodperces emberi inputőr mellett.
Figyelni kell, hogy a koponyaút ne írjon felül már támadható fejlődési célt.
