# Mérhető futáseredmény és stabil tesztállapot — 2026-09-19

## Új mérési lehetőségek

- A FrameAnalysis most külön `confirmedMaximumDisplayedHP` mezőben naplózza
  a tanult maximumot. Az aktuális, sérült HP-t nem használjuk farmhozamként.
- `bash tests/run-metrics.sh docs/runs/<id>`: időtartam, képszám, swipe-döntések,
  emberi aktivitás miatti várakozás, maximumváltozás és HP/perc. A swipe csak
  döntésszám, nem állítja önmagában, hogy minden input ténylegesen végrehajtódott.
- Régi, maximummező nélküli naplóknál a HP-hozam `null`, nem kitalált nulla.
- `--replay-player-state tests/fixtures/player-4870.json` a felismerő és a
  stratégia kezdő HP-tudását is rögzíti. Így a későbbi valódi játékbeli fejlődés
  nem oldja fel véletlenül a vereségsáv-tesztet. Csak replay mód fogadja el,
  a fixture írásvédett; a regressziós script minden teszthez használja.

## Élő kör és új OCR-hiba

`123241-5a5f5eb3-play`: 5190→5240 maximum, kisebb növények és őrök után.
A későbbi DOC-épület körüli szakasz ismételt kerülőkbe merült, ezért felügyelten
leállítottuk. Ez nem megfelelő hosszú távú farm; valódi kijárati csomópont kell.

A 44. képen a teljes 5,23K K-utótagja kiesett: nyers `5:23`, gépi 5 HP,
majd a következő képen megint 5,23K. Nem valódi halál. Magas előzmény mellett
az egyjegyű egész + két tizedesjegy K nélküli alak most bizonytalan, nem friss
alacsony HP. Nem konvertáljuk találgatva 5230-ra; a pixeles biztonsági őr és a
következő tiszta numerikus kép marad az elsődleges kontroll.

`123640-2eba85e7-replay` a konkrét hibaképen már nem ad 5 HP-t és nem
minősíti friss numerikus mérésnek. Az előző regressziós csomag a rögzített
4870-es fixture-rel teljesen átment; az új csonkolási kép is bekerült a scriptbe.
