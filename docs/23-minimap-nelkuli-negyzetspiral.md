# Minimap nélküli növekvő négyzetspirál

Ez a kutatási folyamat a `20260828-230435-play` medence–lila sziklafal zónájából indult.
A minimap képe látható volt, de a detektor több képen át nem talált használható
játékosjel–piros pont vektort, főképi biztonságos cél pedig nem jelent meg.

## A zárt út bizonyítéka

A régi tartalék járőr 16 tényleges döntéses periódusa:

1. négy swipe lefelé;
2. négy swipe jobbra;
3. négy swipe felfelé;
4. négy swipe balra.

Sík, átjárható terepen e négy vektor összege pontosan nulla. A `frame-00150.png` és
`frame-00180.png` gyakorlatilag ugyanazt a zöld medencét, kőszórást, lila sziklafalat és
játékospozíciót mutatja. A 178–208. esemény újabb teljes le–jobb–fel–bal kört kezdett,
tehát nem egyszeri képi véletlenről volt szó.

## Programdöntés

A tartalék út négyzetspirál lett:

- 4 lefelé, 4 jobbra;
- 8 felfelé, 8 balra;
- 12 lefelé, 12 jobbra;
- majd minden két oldal után további 4-gyel nő, legfeljebb 48-ig.

Az egymásra merőleges irányváltás megmarad, ezért egy pályaszéli fal nem köt le
korlátlanul. Az oldalhossz növekedése miatt azonban az út minden teljes forduló után
eltolódik és nagyobb területet fed le, nem ugyanazt a 4×4-es négyzetet ismétli.

Csak tényleges stratégiai döntés fogyaszt spirállépést. Főképi cél elfogadásakor a spirál
visszaáll az első 4 lépéses oldalra; így egy későbbi, harc utáni elszigetelt helyzet nem
örököl indokolatlanul hosszú régi járőrszakaszt. A minimap nem nulláz, mert annak rövid
villogása képenként újrakezdte volna az első oldalt.

## Regresszió

A `20260828-230853-replay` a mentett, minden ötödik képet tartalmazó soron is reprodukálja
a döntési mintát: négy lefelé, négy jobbra, majd legalább nyolc felfelé mutató döntés.
Ez igazolja, hogy az első 16 döntés vektorösszege már nem nulla.

## Első élő eredmény és minimap-hiszterézis

A `20260828-230949-play` növekvő oldalai ténylegesen más tereprészekre vitték a
karaktert; `frame-00050.png` már a bal oldali útnál, `frame-00110.png` a lila sziklánál
mutatta. A 150. eseménynél új `(-0,41; -0,91)` minimap-vektor jelent meg, tehát a spirál
megtalálta a navigációs jelet.

Ezután a detektor a vektort minden második tényleges képen elvesztette. A program
felváltva adott felfelé-balra minimap-swipe-ot és lefelé mutató, újrakezdett spirállépést;
a két irány részben kioltotta egymást. Új szabály:

- az utolsó minimap-vektor három hiányzó végrehajtási döntésig érvényes;
- a minimapút nem nullázza a spirált, csak a főképi cél;
- a memória kifutása után a spirál ott folytatódik, ahol valóban abbahagyta.

A `20260828-231329-replay` ritkított képein a 150-es friss vektort a 155/160/165. hiányzó
képek is megtartják; csak 170-nél vált spirálra. A későbbi új vektor ismét azonnal átveszi
a vezérlést.

## Élő elfogadási feltételek

- a karakter eltávolodik a `frame-00150/00180` medence–sziklafal helyszíntől;
- új minimap-vektor vagy főképi biztonságos cél jelenik meg;
- a bot nem tér vissza ismétlődően ugyanarra a vizuális pontra azonos 16 lépéses mintával;
- a növekvő oldalak pályaszéli holtidejét a rendszeres fordulók elfogadhatóan korlátozzák.
