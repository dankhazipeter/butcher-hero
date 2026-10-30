# Első 4,31K-s szívfa-győzelem és 2470 max-HP

## A győzelem bizonyítéklánca

A `230318-play` a Titan-medence felől újra elérte a 4,31K HP-s, `500` piros
szívjutalmat mutató nagy fát. A kontrollált próba első négy képe:

| Kép | Fa HP | Távolság | Saját állapot |
| --- | ---: | ---: | --- |
| 0 | 4310 | 373 px | teljes |
| 1 | 4310 | 284 px | teljes |
| 2 | 4310 | 222 px | teljes |
| 3 | 4310 | 133 px | rövid pixeles takarás |

A 4. képtől a fa csíkja eltűnt, miközben a 200 HP-s láncos Titan-objektum
megmaradt. Később ugyanazon élő futás képei a saját csík fölött ismételten
`2.47K`-t mutattak, a fa helyének közelében pedig körülbelül 59 perces
újratermelődési kör jelent meg.

Az előző tiszta kijelzés `1.97K` volt. A különbség pontosan `+500`, azonos a fa
előre kiírt szívjutalmával. A fa eltűnése, az újratöltési időzítő és a
`1.97K→2.47K` saját HP három egymástól független jel; ez biztos győzelem, nem
puszta OCR-hipotézis.

## Harci következtetés

A 4,31K ellenfél-HP önmagában valóban nem tette a fát túl erőssé. A jelenlegi
Bat Cleaver 10 + Steel Splitter 14 build és automatikus közelharc néhány
érintkezési képen belül legyőzte. A korábbi sikertelenség oka kizárólag a
Titan-kő és a sziklafal topológiája volt; amint a karakter 133 pixelre, valódi
kontaktusoldalra jutott, nem kellett hosszú kite vagy stratégiai halál.

## HP-felismerési hiba

A bot tartós állapota 1940-et őrzött, miközben a képernyő a győzelem előtt
1.97K-t mutatott. A K-rövidítés közeli értékét a régi parser szándékosan a
megtanult pontos maximumhoz húzta. A győzelem utáni 2.47K-t pedig a `maximum+60`
előszűrő teljesen eldobta, ezért az Agent továbbra is 1940-et naplózott.

A javítás:

- 60–800 közötti nagy maximumugrás külön jelölthalmazba kerül;
- legfeljebb 1,6-szoros növekedés engedhető;
- biztos saját HP-csík és öt, egymáshoz 35 HP-n belüli K-OCR mérés kell;
- a `2147K`/`12.47K` hibás köztes képek legfeljebb tizenkét képig nem törlik a
  már gyűlő, helyes 2.47K konszenzust;
- popup és küldetésbuborék azonnal törli a nagymaximum-jelöltet.

A `230959-replay` írásmentesen igazolta, hogy a javított elemző 2470-re vált és
`confirmedMaximumIncreaseSequence = 1` jelet ad. Az élő `bot-state.json` ennek
alapján 2470-re frissült.

## Stratégiai érték

- A 4,31K-s fa kiemelkedően jó, egyszerre +500 maximális HP-t adó farmcél.
- Az első újratermelődési kijelzés nagyjából egy óra, ezért rövid körben nem
  érdemes visszafordulni hozzá.
- A medence → fa 24 döntéses útját és a valódi kontaktusoldalt tartós gráfként
  kell megőrizni.
- A 2470-es új erőszinten korábban kockázatosnak jelölt ellenfeleket újra kell
  pontozni; a statikus kapuhibát továbbra sem szabad harci vereségnek venni.
