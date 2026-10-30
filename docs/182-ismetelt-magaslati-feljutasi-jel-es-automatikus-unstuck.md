# Ismételt magaslati feljutási jel és automatikus Unstuck

## Esemény

A `220802-play` Dusty Gulch- és DOC-kapukeresése után a bot ismét feljutott a
már kifosztott narancssziklás felső rétegre. A `237–255.` képeken nem volt
azonos szintű cél, a narancsszikla-fedettség jellemzően 77–94% volt, és a
karakter a sziklaplató, kaktuszok, háztetők és több órás visszatöltési kör között
mozgott. Az általános minimap- és akadálykerülő ezt járható alsó területnek hitte,
ezért fölöslegesen folytatta az útkeresést.

## Biztos megfigyelés

- A `256.` képen a célzott `nearbyRespawnTimer` detektor igaz értéket adott a
  karakter melletti `3h44m` körre.
- Ugyanez a jel a `214244-play` alsó, járható narancs útján végig hamis maradt,
  még akkor is, amikor a középső szöveg-OCR elszórtan órás találatot adott.
- A kézzel ellenőrzött Settings panelen az Unstuck elérhető volt. A megnyomása
  azonnal a Meadowlands zöld gyógyítómedencéjéhez helyezte a karaktert, teljes
  1940 HP-val.
- Ez nem új ládajutalom és nem harci vereség, hanem visszatérés egy korábban
  kimerített topológiai mellékágra.

## Programdöntés

A tartós `exhaustedOneShotHighlandBranch` állapot mellett most már a következő
két jelkapcsolat bármelyike jogosít azonnali Unstuckra:

1. legalább 75% narancsszikla és a közeli `nearbyRespawnTimer` jel;
2. legalább 75% narancsszikla, középső hosszú timer és friss, biztos OPEN utáni
   `pendingOneShotHighlandExit` állapot.

A második út továbbra is védi az alsó narancs területet a hamis középső
OCR-találatoktól. Az első út a most bizonyított ismételt visszajutást fogja meg
akkor is, ha a platón már nincs új OPEN esemény.

## Taktikai következmény

Az egyszeri magaslati ág teljesen felderített, kifosztott helyszínként kezelendő.
Ha a navigáció újra felvisz, nem szabad ellenségvetületet, visszatöltési kört vagy
minimapjelet üldözni rajta. Azonnal vissza kell térni a zöld járószintre, majd más
kaput, farmcélt vagy az északi, még külön nem igazolt arany ládát kell keresni.

## Nyitott fejlesztés

A tüneti automatikus kijutás már működik, de a térképgráfban még külön élként kell
rögzíteni, mely Dusty/DOC iránysor vezet erre a felső rétegre. A cél hosszú távon
nemcsak a gyors kijutás, hanem magának a fölösleges feljutásnak az elkerülése.
