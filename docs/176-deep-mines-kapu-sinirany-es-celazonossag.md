# Deep Mines-kapu, sínirány és célazonosság

## A kapu első tiszta teljes képe

A `20260829-185715-play` 143. képe a Deep Mines bejáratát teljesen megmutatta.
A zöld táborból induló türkiz sín egy fehér–türkiz, lila köves kapu közepéhez
vezet. A kapu fölött havas terület, legalább két 1,92K-s, 20-szíves fás cél és
egy 7,15K-s, fegyver-/támadóértékes objektum látszott. Bal oldalt a feladat:
`Find a magic anti-stone potion in Deep Mines 0/1`.

A karakter több északi megközelítéssel a kapu alsó élére, majd képi vetületben
annak tetejére került, de a havas oldalon nem alakult ki támadási kontaktus.
Ez jelenleg erős bizonyíték arra, hogy a 0/1 potion feltétel vagy maga a kapu
fizikailag zár; nem bizonyított harci vereség.

## Miért ingázott a sínkövető

A sín a táborban nagy U-kanyart ír le. A régi detektor a karaktertől távoli
türkiz pixelek súlyozott tömegközéppontját követte. A kanyar mindkét szára
egyszerre látszott, ezért a vektor egymást követő képeken például
`(-0.95, +0.32)`, majd `(+0.43, -0.90)` lett: ugyanazon sín előre- és hátrairánya
váltakozott.

Javítás: a Deep Mines a fix kamerában a havas, északi oldalon van, ezért a
felismert sín tengelyét mindig negatív képi Y irányba tájoljuk. Ettől a kanyart
nem oda-vissza járjuk, hanem következetesen a kapuig haladunk. Ha a kapu ott is
statikus marad, a meglévő kétoldali elérhetetlenségi modell hűti le a célját.

## A 7,15K → 1,92K hamis HP-esés

A 148. döntés 7,15K-s próbát indított a kapu fölötti objektumra. A 158. képen
a cél változatlanul távol, mellette azonban egy 1,92K-s, 20-szíves fa volt.
A régi csökkenő-HP célazonosság az 1,92K-s fát ugyanannak a 7,15K-s célnak
fogadta el, és hamis `7150→1920` haladást jelentett.

Javítás: csökkenő HP csak akkor folytathat próbát, ha a cél jelenlévő és hiányzó
aláírásai is egyeznek. A szív-/fejsze-/fatest-jel hiánya többé nem „bármilyen
cél megfelel”, hanem megköveteli, hogy az új jelöltön se jelenjen meg erős,
ellentétes ikon vagy fatest. Így a 7,15K-s nem-szív cél nem válthat át a közeli,
20-szíves 1,92K-s fára.

## Taktikai következtetés

- A kapu fölötti 1,92K-s, 20-szíves fák 1940 maximummal kiemelt farmcélok,
  amint a járható bejárat vagy a potion megnyílik.
- A 7,15K-s objektum külön cél; hozama valószínűleg támadó-/fegyverérték, nem
  20 szív, ezért más célazonosságot és kockázat/hozam-profilt kap.
- A potion forrását egyelőre a kapu déli oldalán, a zöld tábor és Dusty Gulch
  elérhető helyein kell keresni; a havas célok képi közelsége nem igazol átjárást.
