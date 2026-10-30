# Sziklaív mint hamis HP-csík és a zöld +1 ikon

## Megfigyelés — `20260829-023210-play`

A `frame-00248.png` képen a játékos egy 252 HP-s kaktuszt támadott. A cél fölött `1`
és zöld, szív alakú statikon látható; az egyidejű lebegő találati számok 124 és 44.
A `frame-00250.png` képen a kaktusz eltűnt, megjelent az azonos zöld `+1` effektus,
de a játékos teljes HP-ja továbbra is 475 maradt, és a későbbi képeken sem nőtt.

Biztos következtetés: a zöld szív alakú ikon nem ugyanaz a tartós max-HP jutalom,
mint a piros szív. A cél pontos típusa kaktusz, a jutalom értéke +1; hogy a jutalom
melyik statot vagy erőforrást növeli, még nyitott.

## Felismerési anomália

A cél eltűnése után a vörös sziklaív egy vízszintes, vörös részét a detektor HP-csíknak
nézte. Ehhez az időbeli célmemória hozzákötötte a már lebegő 124-es találati számot.
Az eredmény a 250–260. eseményen nem létező, 124 HP-s közeli cél és hét felesleges
„automata harcot figyelem” döntés volt.

A valódi HP-csíkok fekete UI-kerettel rendelkeznek, a sziklaív nem. Új
`barOutlineConfidence` mérés készült a vörös komponens körüli sötét pixelekből:

- hamis sziklaív, öt egymást követő replay-kép: pontosan 0,000;
- a teljes futás leggyengébb, vizuálisan igazolt valódi célcsíkja: 0,109;
- a közvetlen +4-et adó humanoid csíkja: 0,361.

A célkapu 0,06. A `20260829-024127-replay` ugyanazon `frame-00250.png` képen már
kizárta a sziklaívet, és helyette egy valódi, 226 px-re lévő, 1-es célpontot választott.
A `024134-replay` megtartotta a valódi csíkot és 0,361 keretbizonyítékot naplózott.

## Replay-állapotbiztonság

A vizsgálat közben kiderült, hogy a replay ugyanazt a `bot-state.json` tudást olvasta és
elvileg írhatta, mint az élő bot. Bár az egyszeri 525-ös replay-OCR-t a maximumőr
elutasította, a tesztfuttatásnak semmilyen esetben nem szabad élő tudást módosítania.
Az `Analyzer(readOnlyKnowledge: true)` replay módban most már minden tartós írást
letilt. A regresszió után a biztos maximum változatlanul 475 maradt.

## Élő telepítés

A javított release bináris a `20260829-024202-play` futásban indult újra. Az első
képek stabil 475 HP-t és normál minimap/Island 4 navigációt mutattak.
