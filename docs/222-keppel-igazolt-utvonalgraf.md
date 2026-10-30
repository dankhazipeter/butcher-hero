# Képpel igazolt útvonalgráf — 2026-09-19

## Mi változott?

A `docs/world-map.json` továbbra a helyi irányok sikerét/blokkolását tárolja.
Az új `docs/route-graph.json` ettől külön, **mért helyeket és járható éleket**
kapcsol össze. A navigátor külön Swift-modul: `VisualRouteNavigator.swift`.
Nem narancs szín vagy boss-HP indítja, hanem a háttér33komponensű aláírásának
szigorú egyezése ismert, képpel hivatkozott kezdőponthoz.

Első részgráf: `roof_pocket → stone_arch_north → south_corridor → corral_north`.
A három déli él6/6/5, egyenként0,50s-os swipe. Kezdő- és végképek a JSON-ban;
a130744/130914/131057 nudge-ok és utólagos observe-k szolgáltatják a bizonyítékot.
Ez nem a teljes világ térképe, és még nem visz önmagában a bossaréna bejáratáig.

## Védelmek

- Legjobb kezdőegyezés összes abszolút eltérése legfeljebb8; a második jelölthöz
  képest legalább6 előny kell. Ismeretlen/kétértelmű hely nem indít útvonalat.
- Élenként legfeljebb12lépés; a konkrét él saját6/6/5 korlátja érvényes.
- Következő él csak a célcsomópont legfeljebb22 eltérésű képi egyezése után.
- Három egymás utáni, legfeljebb12 képi eltérésű lépés megszakítja az élt;
  sikertelen végpont vagy statikusság120döntéses próbastopot ad.
- Sebzés, visszavonulás, kritikus állapot vagy180px-en belüli nagy humanoid
  törli az aktív tervet. A helyi akadálytérkép nem írhatja át titokban az él irányát.
- Felhasználói aktivitáskor a stratégia nem fut, ezért a gráf számlálója sem fogy.

## Tesztek és korlátok

`tests/route-graph-tests.swift`: ismeretlen/kétértelmű kezdőpont, valódi érkezés,
három statikus lépés, korlátkimerülés és hibahűtés tesztje sikeres.
`131805-90268f5a-replay`: az első mért6képes élen mind a6döntés helyes déli0,50s.
A teljes mért lánc visszajátszott háttéraláírásaival mindhárom végpont igazolt
(`tests/fixtures/route-signatures.json`, önálló Swift-teszt, 13:26).
Az automatikus lánc élő ellenőrzése még szükséges.

Második él: `132239-23514a72-replay`6/6helyes déli döntés a pixeljavítás után.
Harmadik él: `131940-ec7843c3-replay`5/5helyes déli döntés.

A33értékű háttéraláírás nem szemantikus térképfelismerő. Szűk toleranciával
szándékosan inkább nem ismer fel egy helyet, mint hogy rossz helyről indítson.
Új élt csak igazolt, képenként mért mozgásból szabad hozzáadni; az irányvágy nem él.
