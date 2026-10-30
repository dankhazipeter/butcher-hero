# Közvetlen 463 HP és azonnali Island 4-átló

## Biztos +4 fejlődés — `20260829-020635-play`

A 358. esemény közelében a bot befejezett egy passzív tábori célpontot; ezt a 48
másodperces közeli újratermelődési kör közvetlenül igazolja. Később ugyanebben a helyi
harcszakaszban:

- a 373. esemény 450 pillanatnyi HP-t mutatott sérülten;
- a 375. eseményen a pillanatnyi HP 459-re regenerált;
- a `frame-00376.png` közvetlen zöld `+4` szívfeliratot és teljes 463 HP-t mutat.

Ez biztos `459→463` maximális HP-fejlődés, nem a regeneráció téves maximumnak olvasása.
A `docs/bot-state.json` értéke 463, és az új `021337-play` első friss OCR-je szintén
`463 / 100%` volt.

## Új elakadási anomália

A régi Island 4-szabály először mindig tisztán jobbra mozgott. A `020635-play`
137–198. és 245–315. eseménye között ez sokszor ugyanabba a kiugró sziklaékbe futott,
majd csak hat statikus döntés és egy hosszú faljárás után próbálta a működő átlót.
Közben talált és befejezett farmcélokat, tehát nem teljes befagyás történt, de az út
feleslegesen hosszú és ismétlődő volt.

## Javítás és regresszió

A látható Island 4-felirat + balra mutató minimapállapot navigációs szándéka most már
az első swipe-tól a korábban élőben bizonyított `(0,48; 0,88)` jobbra-le átló. A statikus
falőr továbbra is megmarad tartaléknak, de nem kell előtte hat biztosan rossz tiszta
jobbra próbát elvesztegetni.

- `20260829-021246-replay`: régi bináris ugyanazon a `frame-00306.png` képen `(1,00; 0,00)`.
- `20260829-021323-replay`: javított bináris ugyanott `(0,48; 0,88)`.
- Build sikeres; friss élő ellenőrzés: `20260829-021337-play`.

## Biztonsági megmaradó szabályok

A változtatás nem írja felül a közeli farmcélt, a frisssebzéses visszavonulást vagy a
bossőrt. Az új élő futás 5. eseményénél a bot egy közeli több ezres veszélyt azonnal
felismert, megszakította a célközelítést, és hathúzásos menekülést kezdett 463/463 HP-n.
