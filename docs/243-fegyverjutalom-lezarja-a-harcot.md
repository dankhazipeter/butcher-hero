# Friss fegyverjutalom lezárja a harcot — 2026-09-19

## Hipotézis és friss állapot

242:160134/10Venom18jutalom után10–20képen a program a már legyőzött
őrt kereste, felesleges keleti mozdulatokkal. A puszta célhiány nem elég a
győzelemhez, de LEVEL UP és számos Damage-változás erősebb bizonyíték.
160730-df4a7005-observe/0: friss5860HP, DOC déli külső fala, a belső körön
4m6s, ez egyezik a16:11:37körüli visszatéréssel. Nem futott más bot.

## Javítás

`WeaponRewardEvidence`: csak aktív1–5000HP-s próbánál, utolsó távolság≤180,
nincs aktuális cél vagy közeli fenyegetés, és ugyanazon friss elemzésben
LEVEL UP + legalább két számjegyes Damage-sor. Ekkor a kereső/detour/pursuit
állapot törlődik és egy képet vár. Nem növel automatikusan HP-t, nem ment
bossvereséget vagy időzítőt; a jutalom típusa nem általános bossgyőzelem.
Élő ellenségnél, nagy bossnál, távoli célnál, puszta timerre vagy eltűnésre
nem zárja le a harcot. A változatlan biztonsági és modalőrök előbb futnak.

Teszt: pontos160134/10OCRpélda pozitív; timer, egyetlen kulcsszó,18800HP,
250px távolság, megmaradt cél és közeli fenyegetés negatív.
Új teljes replayellenőrzés:160134/10harclezárás,10–20nem visszakeresés.
Az ellenőrzés alatt élő input nem futhat, a tesztszkriptet nem szerkesztjük.

Következő élő kísérlet: DOCújra megjelenése, helyes bejárat és fegyverjutalom
utáni azonnali harclezárás; a Venomőr hosszú hűtése megmarad.

Releasebuild és jutalombizonyíték-egységteszt sikeres. A teljes, izolált
replayregresszió is sikeres: Venom18képen10lezárás,10–20nincs halottőr-keresés,
valamennyi korábbi biztonsági teszt és tartós állapot/fixtureváltozatlanság átment.
A DOCmegközelítéshez a mért kijárat fordított irányát csak szakaszos, friss
végpontképes kísérletként használjuk; visszafelé járhatóság nem automatikus.
