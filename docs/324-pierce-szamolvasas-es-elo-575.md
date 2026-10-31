# Pierce567/575 számolvasás és élő575igazolás

2026-10-31. Felhasználó a fennmaradt bizonytalanPierce-olvasás javítását
kérte. Nem kell a játékot átállítania; a képfelismerő karakterkészlete hiányos.

## Reprodukció és ok

A korábbi user567kép és537BAD04előképe575 felirattal új, rögzítettelvárású
unitban is nil-t adott. Szegmentálásuk megtalálta a számjegyeket, nem aROI
vagy aK/Mparser hibázott. Az első5-re a legjobb hiba0.15440476,9-re
0.17726935: különbség0.02286459, a megkövetelt0.035alatt. A program ezért
helyesen nem tippelt575-öt vagy975-öt. Az új külső788×1083-as ablak
21pixeles5-öse eltérő rastert adott a korábbi kalibráltaktól.

## Javítás és független ellenőrzés

A meglévő tools/build-reward-digit-templates.swift vizuálisan ellenőrzött
listája egyetlen forrással bővült: external-pierce567-user.png→567.
Ez3új5/6/7változat,14kalibrációs kép/41glyph. A felismerő kód és a
0.30hibaküszöb/0.035margó nem változott; a szám nem a jutalomtípusból vagy
korábbi értékből származik. A teljes régi modell reprodukálhatóan megmaradt.

Két külön képből ellenőrzött575minta NEM kalibrációs forrás:

- pierce575-external-heldout-a.png:537BAD04validatedelőképe,575;
- pierce575-external-heldout-b.png:784BA08Avalidatedelőképe,575.

A fenti PNG-k references/2026-10-31 alatt verziózottak. Az újunit egyszerre
ellenőrzi a szűk számolvasót és a teljesHUD→PierceDamage→összeg útvonalat,
valamint hogy a kalibráló nem tartalmazza a held-outforrás nevét. Három új
fix elvárás a reward-reading-corpus.json-ban, összesen38teljes kép.
Minden korábbi elvárás megmaradt. Az első szándékos regresszióbukás után
a teljes148teszt (69Swift+19stat+7game+3git+10supervisor+40Node),7JSsyntaxPASS.

## Betöltés és élő eredmény

A számadat minden megfigyelésnél újra beolvasódik. A teljesPASSután az
aktív ésstagingresourcebundle digits.json fájlja azonosmappás ideiglenes
fájlból atomilag cserélve; a gyűjtőt ehhez NEM állítottuk le. Nincs új
executable/kattintásiút/állapotgépcsere, nincs történeti reconcile vagy
naplótörlés. A releaseinspect a held-outképen már575-öt adott.

Új **BDF9D157**:

- 20:13:25.321Zreward_detected, piercing_damage,575;
- 20:13:26.963Zclick_sent, amount575;
- 20:13:29.216Zclaim_confirmed_ui, amount575, kétutóképes igazolással.

Ezzel a javítás nem csak mentettmintán, hanem új élő átvételen is igazolt.
A korábbi nil-sorokat nem írtuk át; az új adatok pontossága volt a feladat.

## Futásellenőrzés és külön nyitott ügyek

20:10:46Z53842worker/53735supervisor már nem szerepelt a folyamatlistában,
miközben a régiJSONtrue és utolsóképe20:05:31volt. A kilépés oka ebből
nem állapítható meg. A gyűjtőt --resume-run-nal újraindítottuk:57658worker,
session39912; ugyanaz a logikai statkezdet. Az adatjavítás ellenőrzése és
tesztjei alatt futva maradt. Dashboard session86104újraindítva, mert nem
volt listener8765-ön. Pusztán PID/JSON nem bizonyít sikeres gyűjtést.

E körben külön C2B1DD70képen lila kalapács pajzs nélkül/692látható, de
unknown/nil került naplóba. Ez nincs javítottnak nevezve, és nem írunk
kitaláltSmash692eredményt a statisztikába. A konkrétPiercehiba javult;
nem minden jövőbeli font/méret/ikon vagy a tartós futtatókörnyezet hibája.
