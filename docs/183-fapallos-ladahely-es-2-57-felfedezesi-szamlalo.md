# Fapallós ládahely és a 2/57 felfedezési számláló

## Biztos esemény

A `222821-play` déli falvégi mozgása a 47. képre egy zöld oldali, magasban lévő
fapallós platformhoz jutott. A 82–83. képen a karakter egy fehér szegélyű
ládahelyhez ért, és a játék explicit üzenetet mutatott:

`You found 2/57 chests`

Az üzenet a 96. és 105. képen is látszott, miközben a karakter már távolodott.
Külön `OPEN`, `CLAIM` vagy kattintható gomb nem jelent meg. A `2/57` ezért maga a
biztos, tartós felfedezési eredmény; ezt a ládát nem kell újra felkeresni.

## Helyszín és út

- Kiindulás: a zöld–narancs függőleges határfal zöld oldala.
- A nagy térkép sárga átjárójele délnyugatra látszott.
- A tiszta déli faljárás a kék ponyvás/fapallós platformhoz vezetett.
- A nyugati szakasz a platformon és a fehér ládahely mellett haladt el.
- A hely zöld képi fedettségű, de topológiailag magas, korlátozott mellékág.

## Következtetés

A játék legalább 57 világ-ládahelyet tart számon, és a felfedezés automatikus
közelségi esemény lehet. Az OPEN/CLAIM alapú egyszeri ládamemória ezért nem fedi
le az összes ládatípust: a `You found N/57 chests` számláló növekedése önálló,
erős progressziójel és helyszínlezárási bizonyíték.

## Kijutás

A láda után az általános statikussági őr Settings→Unstuck láncot indított, amely
a karaktert teljes 1940 HP-val visszatette a Meadowlands zöld medencéjéhez. Mivel
a ládaszámláló már 2/57-re nőtt és a felhasználói szabály szerint az ilyen helyre
nem kell visszatérni, ez a teleport taktikai szempontból helyes mellékáglezárás
volt. A napló szövege viszont pontatlanul „három magaslati fázist” mondott egy
hatfázisos zöld platformon; ezt külön diagnosztikai megfogalmazásként javítani kell.

## Programkövetelmény

1. A középső `You found N/57 chests` szöveget külön OCR-rel kell felismerni.
2. A számláló növekedése progresszió és egyszeri helyszín-begyűjtés.
3. A már beszámított számlálóért ugyanarra a platformra nem szabad visszatérni.
4. A konkrét nagy térképi útvonal teljes futását az általános statikussági őr nem
   szakíthatja félbe; ez a javítás elkészült, release-ellenőrzés következik.

## Tartós lezárás

A `bot-state.json` `discoveredChestCount: 2` mezővel őrzi a biztos számlálót. Az
elemző a karakterközeli szövegrégióból a `/57` alakot ismeri fel, csak növekvő
értéket fogad el, és az új maximumot atomikusan visszaírja. Ha a tartósan
kifosztott magaslati ág és legalább 2/57 együtt ismert, a zöldről északnyugatra
mutató régi piros minimapág időzár nélkül lezárt; a bot másik célterületet választ.
