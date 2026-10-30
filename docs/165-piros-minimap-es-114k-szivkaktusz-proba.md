# Piros minimapcél és a 11.4K-s szívkaktusz kontrollált próbája

## Miért nem ment oda a bot?

A `20260829-152922-play` 0–7. döntése bizonyította, hogy a bot követte a nagy
térkép balra-felfelé mutató piros célját. A 7. képen 314 px-re megjelent egy
`300` szívikonos, `11.4K` HP-s kaktusz, de a régi szabály a 8K fölötti célokat
automatikusan veszélynek minősítette és hat swipe-pal elmenekült. Ez volt a
felhasználó által látott visszafordulás oka; nem útvonalhiba és nem hiányzó
minimapfelismerés.

## Első támadási mérés

A program ezután az explicit tizedes + `K` alakú, legfeljebb 15K-s ellenfelet is
egyszeri kontrollált próbatartományba engedte. A pont nélküli `114K` továbbra sem
biztonságos, mert nem különböztethető meg a 11.4K és 114K alak.

A `20260829-153119-play` eredménye:

- a 44. döntés 11400 HP-ról indította el a próbát;
- a 47–48. képen a karakter kb. 72 px-ről automatikusan ütött, miközben 812/812
  saját HP-n maradt;
- az 57. képen ugyanaz a 300-szíves cél 10.4K-t mutatott;
- az 58. képen, egy hosszú eltávolodás után ismét 11.4K látszott.

Az első kb. ezer sebzés tehát veszteség nélkül kiosztható. A két egymást követő,
azonos típusú és helyű képkocka erősen igazolja, hogy a nagy kaktusz harcon kívül
nagyon gyorsan regenerálódik. A régi oldalkite ezért rossz taktika ehhez a statikus
célhoz.

## Folyamatos támadás és képi takarás

A `20260829-153504-play` az új helyben tartó taktikával közvetlenül igazolta a
folyamatos sebzést. Az 5–9. döntés alatt a felismert érték
`11.4K → 11.0K → 10.5K → 10.1K` lett, a játékos végig `822/822` maradt. A 10.
képen a fegyveranimáció letakarta a piros csíkot, noha a külön OCR továbbra is
`10.1K`, majd `9.68K` körüli szöveget látott; az irányos visszakeresés ekkor
fölöslegesen megszakította a támadást.

Programdöntés:

- 8K fölötti, biztosan növényi kontrollált cél 100 px-en belül helyben tartandó;
- legfeljebb tizenkét, teljes HP melletti rövid csíktakarás alatt is várni kell,
  mert az automata fegyverek tovább támadnak;
- valódi saját sebzés, jutalom vagy halál továbbra is korábban megszakítja a módot.

## Közben mért farmfejlődés

A `153119-play/frame-00075.png` közvetlen `+10` szíveffektust és 822-es teljes HP-t
mutatott, tehát az előző 812-ről újabb 10-szíves Dusty-cél emelte a maximumot.
A következő `153504-play` során a hiteles teljes maximum előbb 842-re, majd a
`frame-00087→00088` közvetlen `+10` effektusa után 852-re nőtt. A 822→842 ugrás
közvetlen forrása az összetett, többellenfeles jelenet miatt még nincs típushoz
rendelve; a 842→852 növekedés biztosan újabb +10 szívjutalom.

## Későbbi pontosítás

A következő szakaszban egy 15-szíves kaktusz közvetlen `+15` jutalma 868-as teljes
értéket adott. Az átmenetileg naplózott 898 nem további jutalom, hanem a 868
középső számjegyének OCR-hibája volt. Aktuális tartós maximum: **868**. Részletek:
`166-868-bol-hamis-898-ocr-es-plusz15.md`.
