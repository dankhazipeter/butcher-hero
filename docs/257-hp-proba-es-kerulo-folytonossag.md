# HP-megfigyelési lépés és kerülőfolytonosság — 2026-09-19

## Megfigyelés és fejlődés

`182845-8b6cca70-play` 45s: a67HPfa eltűnik, később7h30m kör; a192HPőr
helyén22képen **Steel Splitter25,288→300**,20m0s.26a174HP/10szívfa
516találata,27új3m59s és+10szív; saját6,51K. Fegyver tartalék,
Phantom4/Venom18 marad felszerelve. A22és27jutalomképek vizuálisan is
ellenőrizve: fegyverszám25,288→300; külön+10szívanimáció és6,51K.
Az új futásban a gépi maximum6510-re állt, kerekített kijelzett érték.

11–17és30–36várakozás: időzítő takarja aHP-t, friss numerikus érték nincs.
36képen nincs támadó a játékos mellett, a fegyverőr19m45s köre ül aHUD-on.
Ez nem igazolt sérülés. Az egyetlen0,30s keleti képtisztító lépés kevés volt.

## Feltárt vezérlési hiba és javítás

5képen a navigátor már délre kerüli a kerítést.6képen HP-megfigyelési
oldallépés,7képen ismét A*: az általános `handoffMovement` lenullázta a
falmegkerülést, mert minden nem-V2-inputot harci célváltásnak tekintett.
Így az érzékelés helyreállítása eldobta a már megtalált kerülőirányt.

Új megoldás: az egyetlen engedélyezett megfigyelési lépés a meglévő
falmenti irányt tartja (ennek hiányában kelet), legfeljebb0,50s. Utána
megmarad a cél és a kerülőoldal; nincs akadálytanulás ebből a lépésből.
Valódi harci/gyógyulási átadás továbbra törli a régi útvonalat.
A próbabüdzsé nem változik: két friss magasHP-kép szükséges újraélesítéshez,
legalább8s a próbák között; nincs korlátlan, vak továbblépés.

Hipotézis: a hosszabb egyszeri lépés gyakrabban tisztázza aHP-t, és a
megőrzött kerülőoldal megszünteti az időzítő okozta falhoz-visszafordulást.
Ez élő ellenőrzést igényel; nem bizonyított minden időzítőhelyzetre.

Release buildPASS, kibővített navigációs tesztPASS (kerülőoldal és cél
megőrzése a megfigyelési lépés után; abból nincs akadálytanulás).
Korábbi HP-takarás replay továbbra pontosan egy próbaPASS; büdzsé-egységtesztPASS.

## A6,5K állapot helyesbítése

Élő183158/0új0,50s próba,1friss6,51K: a takarás megszűnt. Ezen a
meneten próba közben nem volt aktív falmenti kerülés, annak megőrzése csak
egységteszttel igazolt. Utána kerítésmegkerülés és29HPfa aratása,20:+1fejsze.
17–20új várakozás más okból: nincs piros cél, bár van mért pozíció (258).

A korábbi„néhány friss képtől6500lesz”nem igaz: a parser az egy tizedes
K-kijelzésnél±50kerekítési tartományban megtartja a már ismert maximumot.
Ez szándékos pontosságvédelem, nem új maximum bizonyítéka.6,51K két
tizedesjegye már csak±5tartományú. Statpanelből pontos maximum nincs mérve.
