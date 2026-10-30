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
