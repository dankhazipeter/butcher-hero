# Első 11,4K-s kaktuszgyőzelem, 1299 HP és K-kijelzés

## Bizonyított győzelem

A `20260829-175358-play` 15. döntése kontrollált próbát indított a 11,4K-s,
300-szíves kaktuszon. A 17. döntésre támadótávban állt, majd a bot nem mozdult el
a takart célcsík miatt. A fegyverek folyamatosan automatikusan támadtak, a saját
HP végig teljes maradt.

A 95. mentett képen a kaktusz helyén `5m49s` újratermelődési kör látszik, a
játékos teljes HP-felirata pedig `1.3K`. Ez bizonyítja, hogy a cél elesett és
cooldownra került. A 300-as szívikon jutalma pontosan illeszkedik:

`999 + 300 = 1299`, amelyet a játék egy tizedesre kerekítve `1.3K`-ként rajzol.

Az új hiteles, tartós maximum ezért **1299 HP**. Ez az első teljesen befejezett
11,4K-s nagy-kaktuszfarm és az eddigi legnagyobb egyedi max-HP jutalom.

## Miért várt még a bot a halott célon

A kaktusz 120 képes takarási memóriája helyesen akadályozta meg a korai
elmozdulást, de a halál után ugyanez túl sokáig tartotta helyben. A `5m49s`
szöveget a széles középső OCR felismerte, míg a régi közeli timerdetektor csak a
szűk játékos-HP régiót nézte. A `nearbyRespawnTimer` ezért hamis maradt.

Javítás:

- a játékos alatti, kis zöld timerkör-ív külön geometriai jel;
- ehhez a középső OCR-ben perces, de órát nem tartalmazó szövegnek kell társulnia;
- a pálya hátterében látható `8h ...` időzítők nem zárhatnak le másik élő harcot;
- a közeli `5m49s` azonnal lezárja az eltűnt, már sebzett fát/kaktuszt.

## A saját HP új `K` formátuma

A játékos-HP parser történetileg legfeljebb háromjegyű számot kezelt. 999 fölött
a játék rövidített formára váltott. Az új parser:

- a `1.3K` alakot közelítő 1300-as kijelzésként érti;
- ha már van jutalommal bizonyított, 60 HP-n belüli pontos maximum, azt tartja meg;
- ezért a jelenlegi `1.3K` a pontos 1299 marad, nem válik hamis 1300-as maximumra;
- K-alak önmagában nem bizonyíthat pontos új maximumot, ehhez továbbra is jutalom
  vagy más független állapotbizonyíték kell.

## Stratégiai következmény

A 18,8K-s páncélos első súlyos próbája 984-es saját maximumnál történt. Az új
1299 több mint 20%-os fejlődés (`1299 / 984 ≈ 1,32`), ezért a tartós vereségmemória
szabály szerint a sáv egyszer újramérhető. Ez nem garantált győzelem: a bot teljes
HP-ról, kontrolláltan közelít, valódi sebzést mér, és szükség esetén kite-ol.

## Mérendő

- A friss timerdetektor a következő nagy kaktusznál az első cooldownképen lezárja-e
  a harcot.
- A `1.3K` HP felismerése stabilan 1299 marad-e időzítőtakarás mellett is.
- A megerősödött karakter milyen saját mélypontot és cél-HP csökkenést ér el a
  következő 18,8K-s kontrollált próbában.

## Közvetlen következő cél: a 4,4K-s erődőr

Az új 1299-es futás első képein a karakter a rózsaszín sziklaépület magas
peremén állt, a 4,4K-s, fegyveres jutalomjelű ellenfél pedig lent-balra látszott.
A képi cél és az éppen kiválasztott minimappont nem egyezett, ezért a régi őr
ismételt távolodást adott.

Javítás: teljes HP-n a legfeljebb 5K-s, 360 pixelen belüli, biztosan olvasható
boss akkor is saját kontrollált próbát kap, ha a több piros minimappont egyike
nem egyezik az irányával. A nagyobb céloknál megmarad a térkép-irányegyezés. Ez
a fal mögötti 4,4K-nál próbát és célhoz kötött akadálykerülést enged, de a 18,8K-s
vagy ismeretlen óriást nem teszi automatikusan közvetlen céllá.
