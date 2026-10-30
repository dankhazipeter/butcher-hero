# Háttér-ujjlenyomat és pályaszéli kiszabadulás

## Bizonyított anomália — `235416-play`

A zöld landmark élő ellenőrzése a lila sziklás terület déli előterén indult. A 60. kép
még kis kameramozgást mutatott, de a 80. és 92. mentett kép pixelpontosan ugyanaz maradt,
miközben legalább tizenkét tényleges swipe futott több irányban. A karakter HP-ja stabil
340, a HUD normál; ez fizikai pályaszéli ütközés, nem menü, halál vagy inputkihagyás.

## Miért nem elég a négyzetspirál

A spirál irányt és oldalhosszt vált, de nem ellenőrzi, hogy a kamera valóban mozdult-e.
Összetett sziklasarokban minden kardinális szakasz ütközhet, miközben a program egyre
nagyobb, de eredménytelen négyzetet számol.

## Új mérés

- 11 rögzített, UI-t és a középső karaktert kerülő háttérpont körül 5×5 mintarács;
- pontonként átlagolt, 4 bites RGB, összesen 33 elemű `sceneFingerprint`;
- csak a ténylegesen meghívott stratégiai döntések ujjlenyomatai hasonlítódnak össze;
  a köztes felhasználói aktivitásos képek ezért nem nyelik el a swipe eredményét;
- legfeljebb 12 összesített kvantált eltérés számít statikus háttérnek.

## Kiszabadulási taktika

Hat egymást követő statikus navigációs döntés és legalább 90% HP után hosszú,
0,70 másodperces kiszabadítás indul. Ismert minimap-/sínvektornál az irány arra
merőleges; navigációs vektor nélkül forgó vak átlót használ, legfeljebb négy swipe-pal.
Ismert vektornál legfeljebb tíz falmenti swipe futhat, de a boss-/HP-őr és 180 px-es
közeli farmcél minden képen megszakíthatja. A következő kudarcra oldalt vált. A kameramozgás
megszakítja a statikus számlálást; közeli főképi cél, alacsony HP és bossvédelem
továbbra is elsőbbséges.

## Elfogadási feltételek

1. a 80–92. kép replayén legkésőbb hat döntés után kiszabadulás indul;
2. normál mozgó képsoron nem lép működésbe;
3. élőben a háttér megváltozik, vagy a következő átlós ciklusra vált;
4. kijutás után a piros/zöld minimapnavigáció vagy a spirál normálisan folytatódik.

## Regresszió

A teljes `235416-play` replay a 30. képnél, hat statikus döntés után indította az első
átlós ciklust; a 62. és 86. képnél további változatlan szakaszokat is felismert. Az aktív
ciklus külön eltárolja az irányát. A későbbi `001935-play` vízszintes kerítésénél a két
északi 12-es ciklus 24 döntést vesztett. A vak ciklus ezért négyre rövidült; a későbbi
Deep Mines-kapunál a navigációs vektorra merőleges, tízlépéses falmenti ág elérte a
kapuszélt és a havas területet (`003743-play`), de ez történeti taktika: a
`005645-play` bányatetőjén nyílt terepen is vakon folytatódott. Az átmeneti négyes
változat viszont a `010445-play` hosszú zöld falánál kevés volt. Az aktuális tízes ág
ezért megszakítható; veszély- és közeli-célértékelés minden mozdulat előtt lefut.
