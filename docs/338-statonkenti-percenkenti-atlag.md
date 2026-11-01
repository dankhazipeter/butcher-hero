# Átlagos statnövekedés percenként

2026-11-01. A felhasználó a Növekedés, statonként rész nagy statösszegei
mellé átlagos egység/perc kijelzést kért. A teljes kiválasztott időablakkal
kell osztani, a bot leállásait is beleértve; nem kizárólag az aktív idővel.

## Számítás és megjelenítés

Minden kártyán a változatlan animált nagy összeg mellett kisebb Átlag:
érték/perc felirat. Keskeny kártyán külön sorba törhet. A magyarázó tooltip
és a stat nevét tartalmazó aria-label is HU/EN fájlból jön. A Health és
egyéb játékbeli statnevek továbbra angolok.

Képlet: `row.total × 60000 / (Date.parse(range.to) - Date.parse(range.from))`.
Az eredeti, ismert és visszaigazolt naplóértékek összegét használjuk, nem
a már K/M-re rövidített képernyőfeliratot és nem az átvételek darabszámát.
Az alkalmazott API-időablak dönt, nem a szűrőmező-piszkozat, az első/utolsó
jutalom ideje vagy a worker futásideje. Így24órás nézetben1440perc az osztó,
akkor is, ha ebből12órát nem futott a bot. Run a logikai session saját
teljes hossza; All/Today/custom ugyanilyen elven a saját határain oszt.
Utc-pillanatok különbsége miatt DST-váltás sem módosítja hibásan a hosszt.

A decimális sztringet egész BigInt számláló/nevező kezeli, nem nagy
lebegőpontos Number. Megjelenítéskor két tizedesig csonkolunk,1000felett
a meglévő játékos K/M/B/T formázó dolgozik. Pozitív0,01alatti átlag <0,01,
nem nulla. Ismert nulla összeg pozitív időablakon0. Nulla hosszúságú új
session, hibás időablak, ismeretlen/hibás összeg esetén —, nem kitalált0
vagy Infinity. Ez kijelzett naplóalapú átlag, nem független karakterstat-
mérés vagy garantált jövőbeli hozam.

Új poll új jutalom nélkül is csökkentheti az átlagot a hosszabb időablak
miatt. Nyelvváltás újraformatál, nem kér új adatot és nem resetel. A nagy
összeg animációja, a darabszámok és grafikonok változatlanok. Nincs új
backendmező/futtatási függőség, naplóírás vagy gyűjtő-újraindítás.

## Regressziós ellenőrzés

5új Node-teszt:3tiszta számítási/formázási unit és2valódi app.js DOM-teszt.
24órás és12órás azonos1,44M összeg →1K/perc és2K/perc;819K/160perc →5,1K;
83/160perc →0,51. Decimális és nagyon nagy sztringek, egységhatárok,
<0,01 pozitív átlag, valódi0, hiányzó/negatív/hibás adatok, DST-időtartam.
Kártyán az átlag az összeg melletti közös konténerben, nem darabszám/percek;
poll, változatlan összeg, nulla időablak és HU→EN váltás is ellenőrzött.

Az első új DOM-fixture-ből a kötelező API `series` mező kimaradt, ezért a
grafikonhívásnál elbukott. A fixture-t egészítettük ki `series:{}`-vel,
nem a production szerződést lazítottuk és nem az elvárt átlagot írtuk át.
Teljes kapu221teszt+7JS-szintaxis sikeres; a kötelező Git-kapuk is ezt futtatják.

## Élő ellenőrzés

Rejtett, saját IAB-lapon a run és a24órás nézetet ellenőriztük. A day
nézetben Health+2,3M mellett Átlag1,6K/perc, Regen+4,9K mellett3,41/perc
látszott. A teszt kizárólag GET és időszakszűrő-kattintás volt, session-POST
nélkül. Az élő session kezdőpontjának közben történt változását nem ez a
fejlesztés kezdeményezte; mindig az API aktuális határaival számolunk.
Helyi, eredeti böngészős képkivágás `.build/ui-proof/338-rates-day.png`,
nem Gitadat; a saját tesztlap bezárva. Meglévő userlapon egyszeri reload kell.

12:44:15Z aktuális runtime: worker26239 friss game-bundle/PID26421/window1134,
captureStatus=ok, screenState=hud, event/kristály idle. Ez a felületmódosítás
nem indított vagy állított le gyűjtőt. A korábbi337 CI41307061939 success.
