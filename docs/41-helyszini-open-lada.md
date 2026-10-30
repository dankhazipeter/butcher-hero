# Helyszíni `OPEN` láda

## Felfedezés — `20260829-012951-play/frame-00068.png`

A kifelé kevert bosskerülő egy új, nyílt zöld részre vitte a karaktert. Közvetlenül
alatta fénylő fehér-arany láda és nagy sárga `OPEN` gomb jelent meg; jobb oldalt egy
192 HP-s humanoid állt. Ez helyszíni interakció, nem a jobb oldali inventoryláda.

## Felismerés

A Vision a stilizált `OPEN` feliratot `NEdU`-nak vagy hasonló alaknak olvasta. Az első
változat tévesen rögzített középső régióhoz kötötte a gombot, miközben az a ládával
együtt mozog. A javított biztos állapothoz egyszerre kell:

- a játéktérben egy 55–150 px széles, lapos narancssárga gombkomponens;
- a jelölt saját régiójának `OPEN` vagy a megtanult `NEDU` OCR-normalizálása.

Szöveg vagy narancssárga terep önmagában nem ad koppintást.

## Interakciós szabály

- Az első biztos képen egy tap megy a felismert gombkomponens tényleges közepére.
- Ha a gomb marad, a bot vár; nincs folyamatos tap-spam.
- Csak a tizedik további látható döntésnél engedett egyetlen késleltetett újrapróbálás.
- A megnyitás utáni ismeretlen modalon nincs vak input. A pontos `CONTINUE` továbbra is
  a már megtanult jutalomállapot; reklám és vásárlás nem aktiválható.

## Regresszió és eredmény

A `20260829-014451-replay` a jobbra került gombon `(411, 467)`, a
`20260829-014458-replay` középső változatán `(296, 436)` koppintást adott. Az élő
`20260829-013448-play` 544. eseménye megnyitotta a ládát. Tartalma `+10` szív,
`+2` kék fejsze és `+1%` szív; részletesen lásd a 42. tudáslapot.
