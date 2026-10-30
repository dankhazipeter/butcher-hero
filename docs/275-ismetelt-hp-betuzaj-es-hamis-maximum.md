# Ismételt HP-betűzaj, hamis 7400 maximum — 2026-09-19

## Biztos megfigyelés

212136-028e4724-play/3,7,9,10,17: a képen7,06K, az OCR többek között
`740GKC`, `740GKI`, `-740GK•I`. /17-en a tartós maximum7060→7400 lett,
majd /18–19 újból tiszta7,06K. Ez NEM fejlődés vagy sérülés.
Az ötképes maximumtanuló a hibás olvasatokat összegyűjtötte, a közbeeső
tiszta régi számot pedig nem tekintette cáfolatnak. Nem egyszeri OCR-hiba.

## Javítás és állapotkorrekció

Nagyobb maximum megerősítéséhez a szöveg nem tartalmazhat a K-n kívül
más betűt. A toleráns aktuális HP-parser nem változott. Egy tiszta régi
vagy alacsonyabb számos olvasat törli a még nem igazolt nagyobb maximum
konszenzusát. Hibás köztes olvasat önmagában továbbra nem cáfolat.

`docs/bot-state.json` maximuma a /0–2,/4,/11,/15–16,/18–19 képek alapján
7060-ra visszaállítva; a hamis7400 itt archiválva. Nem győzelemből következtetés.
Új teljes21képes replay-regresszió: `tests/maximum-hp-glyph-regression.sh`.
Build és teszt eredménye alább kerül rögzítésre; eddig nincs új jutalom.

BuildPASS; teljes21képes maximum-hp-glyph-regressionPASS, tartósállapot-hash
változatlan a replay után. Decimal-HP regresszió mindkét részePASS.
212448/0frisskép az időzítő miatt még takart; nem új számosHP-mérés.
Felügyelői3×0,40sSmozdulat indul a képen nyílt déli oldalon, nem autonóm
kijutásként naplózva. Végponti friss kép következik.

## Navigációs eredmény ugyanebben a futásban

/0–11 a nyugati kerítés mentén északra, /11 a zárt havas kaputól délre,
/12–17 a kerítés északi végén át keletre a tábor belső oldalára jutott.
/20 szélmalom/szekér északkeleti oldala, élettakaró4h37m időzítő.
A déli cél felé menet a malom akadályát még kerülni kell. Nem teljes
fejlesztési siker: az499HPőr eddig nem halt meg. Friss kép a folytatás előtt.
