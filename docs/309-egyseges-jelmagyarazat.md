# Egységes stat- és jelmagyarázat-sorrend — 2026-10-30

A felhasználó a308-as párosítást a közös grafikon jelmagyarázatára is
kiterjesztette. Ez felülírja308 azon döntését, hogy a jelmagyarázat maradjon
eredeti sorrendben. Közös orderedKinds függvény rendezi másolaton a
kártyákat, a jelmagyarázatot, a grafikon vonalait és a rámutatásos listát:

1. Health / Health Regen
2. Pierce Damage / Cut Defense
3. Cut Damage / Smash Defense
4. Smash Damage / Pierce Defense

A legenda széles nézetben is két oszlop, mint a kártyák. A vonalszínek
továbbra típusspecifikus CSS-osztályok. A szaggatási minta most külön
típus→minta Mapből jön, így a rendezett index változása nem cseréli fel
a vonal azonosítását. Az API, napló és statösszesítés nem változik.

A meglévő kirajzolási teszt új, felhasználó által kért elvárása minden
nyolc elemet ellenőriz: kártya-, legenda-, SVG-vonal- és pointermove után
tooltip-sorrend. Mind a nyolc vonalminta egyezik a korábbi típuséval és
a jelmagyarázati vonalmintával. Az eredeti APIlista változatlan marad.
A teszt a valódi app.js-t futtatja, nem csupán egy konstans listát vizsgál.

A Sites készség helyi-only munkamenete szerint nincs felhős publikálás.
Sem a statikus fájlokat kiszolgáló szerver, sem a66095gyűjtő nem áll le.
A meglévő lapon reload kell. A korábban hibás böngészőkapcsolat miatt új
vizuális igazolást nem állítunk; automatizált DOM/SVG és helyi HTTP a kontroll.

Teljes teszt:23Swift+15statisztika+3Gitkapu+9felügyelet+20Node és4JS-
szintaxisellenőrzésPASS. HTTP-n az új közös rendezés kiszolgálása igazolt.

## Közben jelzett külön gyűjtőhiba

A felhasználó kézzel vett át Healthjutalmat; ezt nem könyveljük a botnak.
A66095worker nem állt le:21:32:24Zfriss sikeres képidő, közben21:32:01Z
SmashDefense833click_sent,21:32:03ZUIigazolás. A Health18300nál viszont
21:30:09Z/12Zés21:31:27Zclick_failed történt a kattintás előtti
újraellenőrzésnél, nemclick_sent. Sok újreward_detected sor között nincs
elküldött kattintás. Ez tényleges átvételi hiba, nem puszta folyamatleállás.

A jelenlegi guard egy üzenetbe vonja a megszakítást, ablakazonosságot,
frissfelismerés hiányát és összegfingerprint-eltérést. A meglevő előkép
olvasásából nem állítható biztosan, melyik frissguardág utasított el.
Nem lazítjuk vakon a kattintásvédelmet; a pontos okhoz friss elutasítási
kép és részletes indok kell. Külön javításra a felhasználótól irányt kérünk;
a jelmagyarázat módosítása nem nyúl a gyűjtő kódjához.

## Felhasználói fókuszmegfigyelés és a stabilitási kapu — későbbi diagnózis

A felhasználó szerint egy másik ablak takarta a játékot. A bot próbájára
a játék felvillant, majd eltűnt; később már előtérben volt, mégsem vette
fel a Health-et. A takart ablak kezelésének bővítését most nem kéri,
éjszaka nem dolgozik a gépen. Ez nem a gyűjtés leállításának kérése.

Biztos kódviselkedés: Capture.click aktiválja a játékot,180msután friss
képen újraellenőriz. A defer sikertelen ellenőrzéskor is visszaaktiválja
az előző alkalmazást, ha nincs lenyomott egérgomb. Ez megfelel a leírt
felvillanásnak; nem bizonyítja, hogy egérkattintás is kiment a játékba.

Külön biztos következtetés a naplóból és az állapotgépből: az egymást
követő Health18300reward_detected események új claimID-t kapnak ugyanazzal
a fingerprinttel. Példák UTC21:30:15/18/21/24/27/30és21:31:04/07/10/13.
Közöttük nincs más összegű reward_detected vagy Healthclick_sent, nincs
emberi input miatti input_deferred sem. A forrás szerint ilyenkor egy
köztes reward=nil megfigyelés törli a stableKey-t és stableCountot.
Tehát szakadozott a felismerés, és gyakran nem lett meg a kattintáshoz
szükséges két egymást követő azonos olvasás. Nem tartós duplakattintás-
foglalás akadályozta. UTC21:31:26kor ismét próbálkozott, de a friss
kattintás előtti guard megint elutasította.

A fő ciklusban a reward=nil a HUD/FREEbadge előszűrésből is jöhet;
önmagában a szám vagy típus bizonytalansága még rewardobjektumot adna.
Ez szűkíti az irányt, de a köztes képek és az elutasítás friss képe nélkül
nem állítjuk biztosan, melyik képi ág hibázott, illetve mikor volt a játék
valóban előtérben. Az előtér önmagában nem javítja meg a szakadozó látást.

Ebben a körben kizárólag diagnózis és dokumentálás történt. Nincs lazított
kattintásvédelem, új háttérablak-kezelés vagy gyűjtő-újraindítás.
