# Célpont nélküli helyi felderítés — 2026-09-19

19:15felülírás:191427/18–22 `frontier-astar` élőben aktiválódott, a
legyőzött174HPfa után új helyi célhoz mozog. Ez az automatikus felderítés
indulásának bizonyítéka, nem globális jó stratégia; végpont sátor/palánk
mellett,500szívfa újraéledése most fontosabb. Részletek264.

## Biztos diagnózis

183158-32a91cee-play/0az új0,50s HP-próba,1képen friss6,51K: a257-es
képtisztítás élő pozitív esete.6–10a sátorkerítés északkeleti végét megkerüli,
17–20a29HPfa után új3m58s és+1fejsze.20képen a déli ösvény, nincs közeli
piros minimappont. A helyi pozíció viszont megvan:21,01/17,60, local-chart.

A17–20várakozás tehát **nem helymeghatározási hiba**, hanem hiányzó cél:
a fa után a kontaktusátadás törölte a régi célt, új világ-/minimapcél nincs.
A navigátor eddig ezen a ponton nem tervezett felderítést.

## Új rövid felderítési cél

Csak érvényes mért pozícióból a nyolc irányban négy rácscellányi jelöltet
vizsgál. A* által elérhető, kevésbé látogatott út kap elsőbbséget; azonos
látogatottságnál a rövidebb út. Ismeretlen terep hipotézis, nem szabadnak
nyilvánított terület. Ugyanaz a mért falél/falkövetés és haladásőr működik.
Rögzített rövid cél marad a megközelítés végéig; friss célpont azonnal előzi.
Pozíció nélkül nincs felderítő input. Harci/HP-biztonsági kapuk változatlanok.

Nem teljes frontier-SLAM: nyolc helyi jelölt, izolált térképrészek, nincs
automatikus globális összeillesztés. A kimerült célhoz visszatérés hosszú távú
költségmodellje még külön fejlesztés; a mostani javítás a cél nélküli várást oldja.

## Teszt és élő korlát

Build és kibővített V2tesztPASS: nincs pozíció→nincs input; helyi térképen
piros pont nélkül rövid cél;20cikluson át megmarad; friss ellenség azonnal
felülírja. Quick-farm és HP-takarás replayPASS.

183501-359d41ee-play: újra láthatóvá vált egy északnyugati piros pont,
ezért **a frontier ág nem futott élőben**. A bot a déli ösvénytől nyugatra,
szikla és tábori kerítés közé fordult;14képen a12-inputos haladásőr39px
nettó mozgás miattSTOP. Ez nem siker, a képi felügyelő nem ismétli vakon.

Képi korrekció:183555-nudge két0,40s kelet.183558-observe/0a játékos az
északi–déli nyílt ösvényen, kerítés/szikla balra;6,51K. Ez felügyelői
beavatkozás, nem önállóV2kijutás. Következő hipotézis: előbb az ösvényen
észak, csak a kerítés felső vége után nyugat. Globális automatikus útnak
ezt mért végpontok és reprodukció nélkül nem importáljuk.

183650-nudge három0,40s észak;183655/0a szabad ösvényen, az őrtorony
még északnyugatra, a karakter annak déli oldalán.6,51K. A torony felső
vége még nincs megkerülve: innen ne indítsuk újra változatlanul az északnyugati
pirosponthajszát. Következő rövid északi szakasz friss képpel, vagy mért
ösvény-köztespont bevezetése szükséges. A frontier mód élő aktivációja nyitott.
