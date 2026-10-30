# Képi regressziós korpusz és kötelező tesztkapu — 2026-10-30

## Kérés és rögzített elvárások

A felhasználó minden ismert sikeres olvasási esethez egy, inkább több
mintaképet kér, amelynek előre tudjuk a helyes eredményét. Módosítás után,
commit és push előtt ezek automatikusan ellenőrizzék a felismerőt.

A `tests/reward-reading-corpus.json` **27 valódi teljes képet** sorol fel:
20 jutalomkártyás és7negatív képet. Az asszisztens a képeken látható ikont
és számot ellenőrizte; az elvárás nem a felismerő visszaírt válasza.
Minden sor azonosítót, fájlt, HUD/kártyajelenlétet, típust, normalizált
összeget és az eset jelentőségét tartalmazza. A27sor nem27új átvétel!

| Típus | Minták | Ellenőrzött kijelzések |
| --- | ---: | --- |
| Health | 2 | 18K→18000;18.3K→18300 |
| Health Regen | 2 | 81;83 |
| Pierce Damage | 2 | 516;540 |
| Cut Damage | 3 | 550;555, két külön555kép |
| Smash Damage | 4 | 680;688, három külön688kép |
| Pierce Defense | 2 | 611;616 |
| Cut Defense | 3 | 578előtte és megmaradva;593 |
| Smash Defense | 2 | 802;809 |

A negatívak: zöldfű-hamisjelzés, üresHUD,18Kés18.3Kutáni eltűnt kártya,
valamint a statpanel két görgetési helyzete és a hátizsákpanel. A modalt nem szabad úgy venni,
mintha egy láthatóHUD-ról tűnt volna el a kártya. A lebegő +jutalomszám
nem új ajánlat. A18K/18.3K a játék kerekített kijelzésének normalizálása,
nem a nem látható pontos belső növekmény ígérete.

`RewardCorpusTests` a valódi `RewardVision.observe` láncot futtatja, nem
egy tesztbeli másolatot. Külön validálja a jegyzéket: típusonként legalább
két kép, egyedi ID/útvonal/SHA256tartalom, ismert típus, kötelező címke,
kanonikus pozitív összeg, és negatív/HUD-hiányos lefedettség. A régi
húzásvédelmi, újrapróba-, könyvelési és statisztikatesztek is megmaradtak.

## A teszt valóban talált hibát

Az első futás egyértelműen hibázott a `cut-555-grass-tall` képnél:
elvárt `cutting_damage`, tényleges `unknown`. Az összeg555helyes volt.
A világoskék fejsze pajzs nélkül vizuálisan biztos CutDamage, ezért az
elvárást nem változtattuk meg.

Másik, külön ellenőrzött kép (`corpus-cut555-calibration.png`) szolgált
az új `cutting_damage_current.png` valódiHUDsablon forrásául. Reprodukció:
`swift tools/build-reward-icon-templates.swift --current-cut-only`.
A kivágás kezdete a rögzítettFREEjelzés alja+0.001, az élő algoritmussal
azonos geometria. A hibázó, narancs sziklahátterű555kép nem ez a kalibrációs
kép. Az új sablont a meglévő current-betöltés kezeli; nincs küszöblazítás,
számból kitalált típus vagy megváltozott kattintási szabály. A többi eset
változatlan maradt, és mind27átment. A korpusz részben korábbi kalibrációs
képeket is tartalmaz, ezért nem állítjuk, hogy teljesen független mérési készlet.

## Commit és push előtti automatikus kapu

Egyszeri helyi bekötés: `./scripts/install-git-hooks.sh`.
Beállítás: `core.hooksPath=.githooks`. A telepítő eltérő meglévő beállítást
nem ír felül. Új klónnál újra futtatni kell: Git nem terjeszti ezt a helyi
beállítást. Ez helyi védelem, nem GitHub-szerveroldali ágkorlátozás.

- `pre-commit`: a stage-elt indexből Git-fát készít, azt ideiglenes könyvtárba
  bontja, és azon tesztel. Nem az esetleg eltérő munkafát minősíti jónak.
  Az index futás közbeni változásánál szintén megáll.
- `pre-push`: Git bemenetéből a tényleges feltöltendő commito(ka)t teszteli,
  szintén külön másolatban. Ugyanazt a commitot egy pushon belül egyszer;
  ref-törléshez nincs új kód, ott nincs teszt. Több feltöltendő ref esetén
  minden külön commitvégpontot ellenőriz.
- Mindkettő a verziózott `scripts/check-rewards.sh` futtatót használja.
  Swift képi/parser/állapotgép/CLItesztek, Python statisztika és Git-kapu
  integrációs tesztek, Nodeformázás/ikonellenőrzés és JSszintaxisellenőrzés.
- Bármely hiányzó fájl/program vagy teszthiba nemnulla kilépés, commit/push
  tiltása. Nincs automatikus elvárás-újraírás, kihagyás vagy bypasskapcsoló.
  A két ellenőrzés külön lefut, nincs elavulható „előbb már átment” cache.

Az elkülönített futás nem használ élő képernyőt/inputot, nem nyit játékot,
nem ír éles naplóba. Az integrációs tesztek a saját ideiglenes adataikat
használják. A futó jutalomgyűjtő és a statisztikaszerver ettől külön folyamat.

A három `test_git_test_gate.py` integrációs teszt egy eldobható Gitrepóban
valódi hookokat használ gyors, szándékosan jó/rossz próbafuttatóval:
jó stage-elt fa rossz munkafa mellett átmegy; hibás stage-elt fa commitja
nem jön létre; jó feltöltendő commit rossz munkafa mellett átmegy; hibás
commit push-ellenőrzése blokkol; hiányzó futtató és hibás bemenet is blokkol.
Ezek a vezérlést tesztelik; a valódiOCRtesztek külön, ugyanebben a kapuban futnak.

## Bővítési szabály

Minden kattintási próbához és igazoláshoz továbbra megmarad a helyi eredeti
bizonyítékkép és időbélyeg a `data/free-rewards/` alatt. Nem mentünk be Gitbe
minden másodperc azonos kártyájáról másolatot. Új típusváltozat, méret,
háttér, kerekítési vagy takarási hiba esetén:

1. Valódi eredeti kép kiválasztása és vizuális ellenőrzés.
2. Kicsi, tartós PNG/JPEGreferencia a `docs/references/` alatt.
3. Új sor a jegyzékben: képből megállapított, változatlan elvárás.
4. Hibánál először reprodukáló piros teszt, utána felismerőjavítás.
5. Sablonkalibrálás mellett másik külön képen is ellenőrzés; negatívak megőrzése.
6. Teljes kapu, dokumentálás, commit, push. Címkehiba csak képi indoklással
   javítható, soha pusztán az aktuális programválaszhoz igazítva.

## Ellenőrzési eredmény és korlát

Munkapéldányon:17Swift+13statisztikaiPython+3Gitkapu+5NodePASS;
27képes regresszió és két JSszintaxisellenőrzés sikeres. A mintakorpusz
futtatása meleg indulásnál körülbelül1.5s; a teljes csomag a külön VisionCLI-
integráció indítása miatt itt35–40s plusz build. Izolált hideg build tovább tarthat.

Ez a megőrzött esetek visszaromlását akadályozza, nem bizonyít minden jövőbeli
képernyőre hibátlan felismerést. Valódi M/B/T-sFREEkártyához még nincs kép;
a számos egységteszt és a megjelenítési teszt ettől külön lefedettség.
Történeti naplókat nem változtatunk, új igazolást nem gyártunk.

Az új sablont tartalmazó release build után kizárólag az előző29305figyelőt
állítottuk le, majd `--resume-run` módban37802/session48218indult. Az eredeti
gyűjtési időszak megmarad. A leállításkori utóképen a felhasználó inventory-
panelje nyitva van; a korábbi18300függő tétel emiatt nem igazolt, utólag sem
könyveljük. A panelhez nem nyúltunk, és negatív tesztképként elmentettük.
