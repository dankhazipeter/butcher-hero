# Elérhetetlen cél aláírásos hűtése

## Megfigyelt veszteséghurok

Az Island 4-határ környékén ugyanaz a 291 HP-s, kék fejszés, fás cél több külön
megközelítésben is elérhetetlen maradt:

- a `033954-play` 53–81., majd 178–226. eseményében a bot tartós kerülőt és hosszú
  kiszakadást futott miatta;
- ugyanaz a 291 HP-s minta a 410. esemény környékén ismét megjelent;
- az új `034946-play` 58–72. eseménye megint 323→269 pixelen stagnált, tartós kerülőt
  indított, majd egy boss miatt szabályosan megszakadt.

A cél feltehetően a lezárt területrész vagy sziklafal túloldalán áll. Egyetlen kék
fejszés jutalmáért a hosszú útvonalveszteség rosszabb, mint más farmcél keresése.

## Döntés

Két teljes, sikertelen célkerülő után a bot rövid távú elérhetetlenségi aláírást ment:

- HP ±20;
- fa/nem-fa testosztály;
- 360 döntéses lejárat.

Ha azonos aláírású cél újra látható, nem indul új közvetlen üldözés. A bot a cél
világiránya köré meglévő 120 döntéses oldalirányú útvonalhűtést aktiválja, és kifelé
kevert falmenti vektorral új területet keres.

## Biztonsági kivételek

- boss- és sérülésőr továbbra is mindenek előtt fut;
- a legalább 5-szíves kiemelt fa nem hűthető így, még azonos HP esetén sem;
- lényegesen eltérő útirány feloldhatja az útvonalhűtést;
- az aláírás lejár, ezért egy később más oldalról elérhető cél nincs végleg tiltva.

## Várt hozam

Kevesebb idő megy el a 291 HP-s, alacsony hozamú cél ismételt megközelítésére, miközben
a 10-/20-szíves fák, olcsó humanoidok és új területek keresése változatlanul folytatódik.

## Replay-igazolás — `20260829-035550-replay`

A teljes `033954-play` újraelemzésében a 106. képen a második sikertelen kerülő után
indult a hosszú kiszakadás és létrejött a 291 HP + fa aláírás. Ugyanez a cél a 205.,
majd a 217. képen ismét megjelent. Mindkét alkalommal a napló közvetlen üldözés helyett
`Korábban elérhetetlen cél-aláírás; ... oldalirányú felderítés` döntést rögzített,
eltérő kifelé kevert vektorral. A regressziós feltétel teljesült.
