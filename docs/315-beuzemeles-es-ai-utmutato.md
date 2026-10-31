# Beüzemelés, AI-segítség és No Ads — 2026-10-31

A felhasználó a publikus megosztás előtt teljes beüzemelést és használati
útmutatót kért magába azAGENTS.md-be, automatikusmain-push-sal. Az angol
Discordszöveg bátorítsa az érdeklődőket, hogy AI-val beszéljék át a telepítést
és azt, mire jó a program. A használati útmutató ezért angolul, azAGENTS
elején, a helyiSTOP alatt található; a magyar tudásbázis megmarad.

## Ellenőrzött források és tartalom

Package.swift: macOS14/Swift5.9 cél; az aktuális watch-free argumentumai,
Capture/Accessibility/ScreenCaptureKit ellenőrzései, a start/stop/supervise
és dashboard script, Makefile, tesztkapuk és CI adták a parancsokat.
Az útmutató nem csak hivatkozás: követelmények, függőségek,klónozás, hook,
teszt, releasebuild+resourcebundle, engedélyek, frissHUD, indítás/folytatás/
leállítás, dry-run-korlát, dashboard, napló, összesítés, hibakeresés, update,
AI-prompt és külsőfork/PR munkamenet mind benne van. AREADME közvetlenül
odamutat. Új függőség/parancs/korlát esetén ez a központi rész is frissítendő.

Feltárt korlát: nincs megválasztott projektlicenc; aCountUp harmadikfél-MIT
fájlja nem a sajátkód licence. Nem választottunk tulajdonosi döntés nélkül
licencet, és nem állítunk létező versioned release-t. Külsőklónozó AI-jának
nem ad upstreammain-push jogot a maintainer saját automatikuspush utasítása.

## No Ads pontosítás

Először a közösfigyelő és hiányzó kristály-only kapcsoló miatt figyelmeztetést
terveztünk. A felhasználó pontosította: No Ads nélkül egyáltalán nincsFree-
feladat. Ezért ezen játékviselkedés mellett az ág nem csinál semmit, a
kristálynyitás ugyanazzal a figyelővel működhet. Nincs szükség új kapcsolóra.
Kódtény: csak felismert ténylegeskártyára kattint, nem a vásárlási státuszt
ellenőrzi. Játékszabály forrása a felhasználó, nem megismételt vásárlás/
visszavonás. Nem indítottunk reklámot vagy vásárlást, és nem írtunk új kódot.

## Ellenőrzés és aktuális állapot

Dokumentációs kérés: nem folytatási engedély. A314-es STOP megmarad;
gyűjtőt, játékot, képrögzítőt nem indítunk. A parancsokat statikusan
ellenőrizzük a forrással, és a kötelező commit/push tesztkapu a mentett
képekkel/offline tesztekkel fut. Új gépes tényleges telepítést és a játék
No Ads nélküli állapotát ebben a körben nem teszteltük élesben.
