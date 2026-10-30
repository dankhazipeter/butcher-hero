# Házzseb, képszéli HP és rövid ciklus — 2026-09-19

163213-observe/0: északi ház és sziklafal,5860HP; NW keresés ide vezetett.
163628-nudge:4SE,0,50s;163649-observe/0 a nyílt kapunál.
Minimap narancs koordináta21,5/3→28,5/10,5; Venom-rendszerben
17/-62,5→24/-55. A mért kijárat új térbeli célkaranténszabály.
Keleti folytatás hipotézis, nem igazolt teljes út. Autonóm élő teszt szükséges.

A bal oldali322szív rögzített2xReward HUD, **nem ellenfél**.
A felügyelő téves feltételezését163745/0cáfolta:4SW után a panel ugyanott.
Ez nem aratás, nem fejlődés; a bot korábbi HUD-kizárása helyesen működött.

## Javítás

162738-play/52: képszéli1,16K-ból16K keletkezett;163213/0másik csonkolt
OCR116K→116000. A felső65px-ben külön felnagyított csíksor és explicit
tizedesK-előny; pont nélküliK itt bizonytalan, elvetjük. Más régióra nem
vonatkozik, teljes18,8K/67,5K nem kap mesterséges plafont.
K nélküli1:16 ugyanúgy1160mint1.16. Nem kódolunk116K→1160 találgatást.
Következmény: csonkolt cél HP-ja lehet ismeretlen; közelebbi kép szükséges.
163757-replay/0: első csonkolt célHPismeretlen, második1160: célzott javítás igazolt.

Releasebuild sikeres. Célzott és teljes regresszió eredménye lent következik.

## Eredmény és korlát

Célzott quick-farm és karanténtesztPASS. Teljes regresszió **nemPASS**:
133652-play bossoldalkerülő replay18képen hamarabb visszakeresésre vált.
13–17azonos kerülőirány rendben. A kontrollált bossmód továbbra kikapcsolva;
a hibát nem fedjük el tesztelvárás lazításával. Külön javítandó.

163957-play:60s,95kép,88felhasználóaktivitás miatti várakozás,7swipe.
39és53–56az új szabály a kapun átvisz;57kép zöld oldal,5860HP.
Új aratás ebben a körben nincs.92képen a zöld Island1fegyverikon téves
Venompozíciót ad még0,428narancslefedettségnél. Emiatt a látható narancs
koponya elsőbbséges a több helyen azonos zöld fegyverikonnal szemben.
94végképMeadowlands1kapu,5860HP. Ez kijutásigazolás, nemIsland2fejlődés.

Narancskoponya-elsőbbség build+új92képes regresszióPASS; a korábbi hat
quick-farm teszt szinténPASS. A kontrollált bossoldalkerülő hibája nyitott.
