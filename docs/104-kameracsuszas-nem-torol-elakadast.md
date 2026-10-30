# Kameracsúszás nem törölheti az elakadás bizonyítékát

## Élő anomália

A `docs/runs/20260829-073131-play` futásban a jutalomhiányos területelhagyás a 281.
eseménynél elindult, a 302. eseménynél pedig helyesen átadta a vezérlést a növekvő
szabad felderítésnek. Jutalom azonban nem érkezett: a karakter a bedőlt kék sátor,
a fahíd és a sziklafal közötti zsebben maradt.

A `frame-00302`, `frame-00318`, `frame-00338` és `frame-00346` képek ugyanazt a zsebet
mutatják. A karakter néhány pixeles csúszása és a kamera kis eltolása két háttér-
ujjlenyomat között váltogatott. Emiatt a 318. és 328. eseményen 1→2-re növekvő
kiszabadítási fázisszám a 338. eseményre ismét 1 lett, majd ugyanez megismétlődött.

**Biztos tény:** a nagy háttér-ujjlenyomat-különbség ebben az állapotban sem bizonyít
területelhagyást vagy fejlődést. A HP végig 747, a jutalomszekvencia végig 0 maradt,
a minimap iránya pedig körülbelül `(-0,998; 0,05)` volt.

## Döntés

Ha legalább 150 tényleges döntés óta nincs jutalom és látszik az Island 4 lezárt
HUD-ja, a puszta kamera- vagy háttérmozgás többé nem nullázza a sikertelen statikus
kiszabadítási fázisokat. Ebben a szűk állapotban csak valódi új jutalomszekvencia
törli a bizonyítékot.

A módosítás két korábbi nullázási helyet érint:

- a 44 fölötti kétképes háttérkülönbséget;
- a faljárási szakasz közben látott kameramozgást.

A boss-, sebzés-, közeli biztonságos cél-, láda- és küldetésőrök prioritása nem változik.
Hat összegyűjtött sikertelen fázis után a már bizonyított, HUD-visszacsatolt Unstuck
helyreállítás indul. A döntés tudatosan fejlődésközpontú: büntetésmentes újraéledés
mellett a több száz döntéses, jutalom nélküli kamerahurok rosszabb eredmény, mint a
kontrollált visszatérés a medencéhez.

## Ellenőrzési terv

1. A `073131-play` képsor visszajátszásában a fázisszámláló a két váltakozó
   háttérállapot mellett se csökkenjen.
2. Hat fázis után a döntés a Settings megnyitása legyen.
3. Élő futásban az Unstuck az eltűnt Settings-X/HUD-esés vagy a megmaradó X-es
   aktív időzár alapján igazolja saját kimenetét.
4. Az első új jutalom ismét nullázza a teljes jutalomhiányos/elakadási állapotot.

## Replay-eredmény és új élő build

A teljes, közben 492 mentett képig bővült `073131-play` visszajátszásában a fázisok
a releváns szakaszon 1→2→3→4→5 sorrendben megmaradtak. A `frame-00460` Settings-
nyitást, a `frame-00462` Unstuck-tapot adott. A rögzített élő képsorban a gomb még
időzáras volt, ezért öt megmaradó Settings-X-es döntés után a biztos bezárás következett.
Ez egyszerre igazolja a fázismegőrzést és azt, hogy az Unstuck visszacsatolása nem
gyengült.

Az új kód első élő futása: `docs/runs/20260829-074055-play`. A 0–6. képek ugyanabban
a híd–sátor zsebben indulnak; az első teljes jutalom vagy visszacsatolt Unstuck még
mérés alatt van.
