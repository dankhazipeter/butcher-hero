# Titan-objektum a bossvonalban és kritikus kiszabadulás

## Élő anomália

A `20260829-132032-play` 29. eseménye helyesen elindította a 4310 HP-s kontrollált
óriásfapróbát. A 30–31. esemény még közvetlenül a boss felé közelített, majd a 32.
képtől a bot 13%-os pixeles HP-t látott és helyben várakozott. Az állapot a 429.
eseményig változatlan maradt, ezért a felügyelet megszakította a hibás példányt.

A `frame-00032.png` és `frame-00169.png` képi auditja szerint:

- a játékos a 200 HP-s, lila Titan-objektum mögött/takarásában áll;
- az óriásfa HP-ja végig `4.31K`, tehát ezúttal nem értük el;
- két lebegő `0` jelzi, hogy az automatikus támadás nem sebzi a köztes objektumot;
- a játékos HP-felirata és valódi csíkja nem látható tisztán;
- a tartós 13% ezért takarásból származó pixeles mérés, nem bizonyított harci HP.

Ez különbözik a 148. fejezet `frame-00228.png` képétől, ahol tényleges `317` saját
HP, két `170` találat és `2.18K`-ra csökkent boss-HP egyszerre látszott.

## Programjavítás

Két egymást kiegészítő változás készült:

1. Ha egy magas objektumkonfidenciájú világstruktúra közelebb van, és ugyanabban
   az iránykúpban áll, mint a kontrollált boss, a bot egyszeri hétlépéses
   oldalkikerülőt indít a közvetlen megközelítés helyett.
2. Aktív bosspróbában a kritikus pixeles HP + hiányzó friss szám többé nem jelent
   helyben várást. A bot a tárolt bossirány ellenirányát egy erős tangenciális
   komponenssel keveri, így egyszerre távolodik és kerül a takaró objektum körül.

Valódi halál vagy átvezető továbbra is inputmentes: ott a HUD eltűnésének külön őre
korábban fut le. A módosítás csak normál HUD-os, aktív bosspróba kritikus/takart
állapotára vonatkozik.

## Regresszió

A `20260829-132412-replay` az élő 29–32. képeken és egy ismételt 32. képen ezt adta:

- 29: 4310-es próbaindítás;
- 30: köztes Titan-objektum egyszeri oldalkikerülése;
- 31: ugyanazon oldalirány megtartása;
- 32–33: 13%-os takart mérés mellett is folyamatos oldalirányú kiszabadulás.

Az új élő folyamat `20260829-132425-play`. A kezdőképen még közeli bossveszély miatt
hatlépéses megelőző eltávolodást végzett, majd friss 778 HP-val folytatta a
felderítést. A következő új 4.31K-találkozásnak már a Titan-objektumot oldalról kell
megkerülnie.

## Nyitott kérdések

- A hét oldallépés elegendő-e a Titan-objektum teljes megkerüléséhez élő kameramozgásban?
- Melyik oldal ad tisztább bossvonalat a zöld sziklafal és az oltár között?
- A `0` érték minden sérthetetlen objektumnál megjelenik-e, vagy csak ennél az oltárnál?
