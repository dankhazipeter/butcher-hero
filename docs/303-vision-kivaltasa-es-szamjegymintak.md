# Apple Vision kiváltása és játékbeli számjegyminták — 2026-10-30

## Miért kellett másik módszer?

A felhasználó többször jogosan jelezte, hogy saját maga gyűjt, a program
pedig vár. A natív képolvasás `TextRecognition.CRImageReaderError1` hibája
újra előjött a CPU-eszközválasztás után is. A folyamat újraindítása csak
átmenetileg segített, a30–45másodperces várakozás alatt jutalmak maradhattak ki.
A302-esCPUhipotézis nem bizonyult végleges megoldásnak.

A tárolt `outputs/reward-push-latest.log` már pontosította a tesztkapu
hibáját is: aCLIreconcile ugyanazzal aCRImageReaderError1-gyel kilépett,
emiatt háromassert bukott. A kaput nem kerültük meg, az akkori push nem történt meg.

## Új aktív felismerési út

1. A meglévőHUDpixelvédelem ellenőrzi, hogy valóban játékfelület látszik.
2. A strukturált zöld badgekereső megadja a tényleges jelzés téglalapját.
   Badgehiányban nincsOCRhívás sem; a zöld fű negatív mintája megmaradt.
3. Csak az izoláltFREEszó megy a Tesseract5.5.1angol motorjának,7-es
   egysoros módban. Fekete betű/fehér háttér maszk, TSVdobozok és biztonság.
   Külön folyamat, OMP_THREAD_LIMIT=1,3másodperces határidő; elakadt hívás
   nem tarthatja életben percekig a gyűjtő várakozását.
4. Az összeget nem aTesseracttal olvassuk. A játék fehér számjegyeinek
   képpontmintái különülnek el a fixHUD-számsorból. Összefüggő komponensek,
   domináns szövegsor és karakterenként24×32normalizált maszk+oldalarány.
   Legjobb hibájú karakter csak0.30alatt és0.035különbséggel fogadható el;
   a hasonlóság nem valószínűség. Pont csak számjegyek között lehet.
5. A nyerskarakterláncot ugyanaz a szigorúRewardAmountparser normalizálja:
   18K=18000,18.3K=18300. Típus továbbra független ikonillesztésből.

Az aktívRewardAutomationCore ezért már nem importálVisiont vagyCoreMLt.
A régi játékbot történeti kódja megmaradt ésPAUSED; nem indítottuk el.
A natív API konkrét gyökérokát nem bizonyítottuk, de az aktív képolvasási
útvonal nem hívja azt a hibázó API-t.

TesseractCLI/TSVelsődleges forrás:
[hivatalos parancssori dokumentáció](https://tesseract-ocr.github.io/tessdoc/Command-Line-Usage.html).
Új klónon `brew install tesseract`; aCIugyanezt telepíti, angol modellel.

## Miért nem olvas mindent aTesseract?

A kísérletben a számoknál5→3és688→68stévesztések jelentkeztek; a tisztán
Tesseractos számolvasás nem ment át a mintákon és nem került élesítésre.
A célzottFREEszó viszont a teljes pozitív készleten helyes lett.
Ezért külön, a játék konkrét számfontjára épülő karakterfelismerés készült.
Nincs mennyiségbecslés a jutalom típusából vagy a korábbi ajánlatból.

## Címkézett glyphadat és tesztek

`tools/build-reward-digit-templates.swift` kizárólag a kódban felsorolt,
vizuálisan ellenőrzött kép→nyersfelirat párokból épít adatot. A szegmentált
karakterszám eltérése hibával megáll, nem címkéz ismeretlen darabokat.
13kalibrációs kép,38glyphváltozat,0–9ésK; a pont külön geometriai szabály.
A kalibráló nem fut automatikusan a tesztkapuban, és nem ír elvárt tesztértéket.

Reprodukció:

```sh
swiftc Sources/RewardAutomationCore/Reward.swift Sources/RewardAutomationCore/RewardNumberReader.swift tools/build-reward-digit-templates.swift -o .build/reward-digit-calibrator
.build/reward-digit-calibrator
```

Adat: `Sources/RewardAutomationCore/Resources/RewardDigits/digits.json`.
29teljes képes regresszió:22pozitív és7negatív.13pozitív kép kalibrációhoz
is szolgált,9további pozitív kép ellenőrző példa; nem állítunk teljesen
független mérési készletet. Továbbra minden8jutalomtípusból több kép van.
TSVfeldolgozási, hiányzóengine- és szándékosan10másodpercig váró próbafolyamatos
teszt is készült: azOCRhatáridő3másodperc után hibát ad, nem marad beragadva.
Teljes csomag az első29-es bővítés előtt:23Swift/13statisztika/3Gitkapu/
9felügyelet/5Node és2JSellenőrzésPASS; az új mintákkal a korpusz újraPASS.

## Élő betöltés és elemzés

66038felügyelő/66095worker tartós91624sessionben indult19:43:25Z-kor.
19:43:30Pierce540,19:44:03és19:44:35Smash688igazolt.
19:52:11ig16igazolt átvétel,0observation_error, egyetlen watcher_resumed
(az indulás), tehát közben nem indult újra.19:52:11kor aktuális képidő.
Ez már éles játék-visszacsatolás, nem csakPIDellenőrzés.

Az első karakterkészlet két további képen bizonytalan volt:19:45:08Regen83
és19:46:13CutDefense593. Nem tippelt rossz számot, hanemnilösszeget naplózott.
Az asszisztens a mentett képeket megnézte: valóban83és593látszik.
Két új rögzített regresszió készült, az elvárásokból nem lettnil.
A jelenlegi font3-asára egy új, vizuálisan címkézett minta került a modellbe;
a másik új kép külön ellenőrző példa maradt. Az elfogadási küszöbök nem lazultak.

A karakteradat minden kártyaolvasáskor betöltődik. A sikeres29képes teszt
után aJSONatomi cserével került a futó és stagingbundle-be: ehhez nem
állítottuk le a gyűjtőt. A következőRegen83már helyesen felismerve.

## Korlátok és folytatás

Új font, eltérőUI vagy még nem látottM/B/Tkarakter új valódi mintát igényel;
a numerikusparser támogatása nem bizonyít képi lefedettséget. Ismeretlen
glyph vagy túl kicsi különbség nem válhat kitalált értékké. A hibatűrő
felügyelő és a kéziSTOPelsőbbsége továbbra megmarad.
Hosszú távú hibátlanságot9perc alapján nem állítunk, az eredményt tovább figyeljük.

## Lezárási ellenőrzés

Az új29képes készlettel is a teljes helyi csomag sikeres:23Swift,
13statisztika,3Gitkapu,9felügyelet,5Node és2JSszintaxisellenőrzés.
19:57:47kor továbbra ugyanaz a66095worker, aktuális sikeres képidő;
25igazolt átvétel az indulás óta,0OCRhiba,0közbensőújraindítás.

Az aktuális futás hat bizonytalan összegét a meglévő
`reconcile --current-run` a mentett eredeti képekből pontosította:
Regen83(3),CutDefense593(2),SmashDefense833(1). Kizárólag
reward_correctedesemények kerültek hozzáadásra; eredeti sor nem változott,
új átvételi igazolás nem keletkezett, korábbi gyűjtési futáshoz nem nyúltunk.
A két új regressziós kép a futás közben látott83/593eset bizonyítéka.
