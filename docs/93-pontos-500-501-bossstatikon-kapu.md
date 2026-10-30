# Pontos 500/501 boss-statikon-kapu

## Élő ellenpélda a tartománykapura

A `20260829-055702-play` 95. eseményén egy normál Island 4-csoporttag
`displayedHP=53`, `level=4`, `levelOCRNumbers=[505]` és `ocrStrings=["CALOV"]`
értékeket adott. A 400–699 közötti tartománykapu ezt bossnak minősítette, és
219 pixelen megelőző menekülést indított. Az előző és következő képen ugyanazon
sűrű 253-as csoport látszott, a játékos végig 747/747 HP-n maradt.

Az összes eddigi élő, naplózott tartományérték külön zajmintákat adott: 410 és 419
timer-/feliratátfedésből, 505 értelmetlen OCR-sorból, 594 pedig `5943|253`
összeragadásból származott. Ezzel szemben a bizonyított 4.31K boss regressziós
képén a statikon pontosan 500, OCR-ben 501, a cél HP-OCR-je pedig `500|4.31l`.

## Döntés

Független tartalék boss-statikonnak csak a pontos 500 vagy 501 szám fogadható el,
és továbbra sem egyezhet meg a cél saját HP-számaival. Minden 800+ nyers vagy
simított HP külön bossőr marad, ezért a szűkítés nem érinti az 923, 1.22K és
1,927K típusú közvetlen veszélyeket.

## Regresszió

- `002956/frame-00140`: a 4.31K/501 cél továbbra is bossmenekülés;
- `055702` 95. eseményének 505 értéke többé nem önálló bossjel;
- `032640/frame-00058`: a 923-as boss változatlanul menekülés;
- `033954/frame-00014`: az 1.22K/923 nyers boss változatlanul menekülés.
