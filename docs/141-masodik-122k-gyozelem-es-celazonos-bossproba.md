# Második 1.22K győzelem és célazonos bosspróba

## Ismételhető 1.22K-s győzelem

A `20260829-123510-play` 182. eseménye egy új 1.22K-s páncéloson kontrollált próbát
indított. A cél 187-nél 93 pixelre ért, az automata fegyverek oldalkite közben támadtak.
A saját kijelzett HP 778-ról 737-ig esett, majd az ellenfél eltűnt és a helyén húszperces
koponyás cooldown indult.

A mentett `frame-00190.png` közvetlen jutalomképe:

- Savage Fang `2→3`;
- Damage `16→24`;
- a képen a saját HP már 761-re regenerálódott;
- a felszerelt Bat Cleaver 10 + Steel Splitter 14 build változatlan maradt.

Ez a második független győzelem bizonyítja, hogy az 1.22K-s páncélos nem egyszeri
történeti ellenfél: ismételhető Savage Fang-fejlődési forrás. A második mérés nettó
41 HP-s mélypontja továbbra is nagy biztonsági tartalékot mutat 778 HP és 693 DPS mellett.

## Az 1.92K/7.15K csoport hibája

Ugyanebben a futásban a 248. eseménytől az 1.92K-s sáv kontrollált próbája indult.
A képen több 1.92K-s és 7.15K-s csík volt egyszerre. A korábbi aktív próba minden
képkockán a `nearestThreat` értéket vette át, ezért a kijelölt 1.92K helyett időnként
a közelebbi 7.15K-s ellenfél irányába fordult. A saját HP még 778 maradt, így a
felügyelet a veszélyes váltást sebzés előtt állította le.

Az OCR a többszereplős képen ugyanazt az ezres feliratot `1920`, `192000`, `1.92K`,
`31.92K` alakban is adta; a 7.15K pedig `7150`, `715000` és egyszer `615000` lett.
Ezért pusztán a legközelebbi boss vagy a nyers egész szám nem alkalmas célazonosságra.

## Javított kontrollált célazonosság

Az aktív próba most a kezdő cél HP-aláírásához ragaszkodik. Az ezres OCR-t normalizálja,
és a feliratszövegben a stabil három számjegyet (`192`, illetve hiányzó első számjegynél
`92K`) is használja. Más HP-sávú boss csak elkülönítendő veszély: taszító komponenst ad,
de nem válhat a próba új céljává. Ha a kijelölt sáv eltűnik, a bot legfeljebb három
képen a saját utolsó irányával keresi vissza, nem ugrik át a szomszédra.

A `20260829-124320-replay` a 248–280. mentett képsoron végig `1920→1920 HP` próbát
tartott, még azokon a képeken is, ahol a globális legközelebbi veszély a 7.15K volt.

## Stagnáló megközelítés oldalkerülője

A csoport 1.92K-s célja 251–252 pixelen több döntésre megállt, miközben a közvetlen
megközelítés változó irányai nem jutottak közelebb. Az aktív bosspróba ezért külön
stagnálásmérőt kapott. Öt, 3,5 pixelnél kisebb távolságváltozás után hét hosszabb
oldalswipe indul; az irány körönként vált, és a másik HP-sávú bossoktól kifelé is
súlyozódik.

A `124320-replay` 12. döntése pontosan ezt az ágat indította, majd a következő mentett
képeken ugyanazt a 1920 HP-s célazonosságot és oldalkerülő vektort tartotta. Az új
release build ezután azonnal visszaállt élő felügyeletre `20260829-124335-play` néven.

## Következő mérés

Az 1.92K-s cél élő harci eredménye még nyitott. Biztonságos próba csak akkor kezdődhet,
ha friss numerikus 778 HP látszik, a cél HP-aláírása biztos, és a 7.15K-s társ iránya
elkülöníthető. Az első friss képen csak pixeles teljes HP volt, ezért az új élő folyamat
helyesen előbb eltávolodott a csoporttól.
