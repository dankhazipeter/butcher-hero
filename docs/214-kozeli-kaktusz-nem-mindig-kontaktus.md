# Közeli kaktusz nem mindig támadási kontaktus — 2026-09-19

`123639-73397ad4-play/76`: 11,4K-s, 300-szíves kaktusz 82,7 px-re, teljes
saját 5,25K. A bot helyben várt, de a kaktusz HP-ja hosszú sorban változatlan
maradt. A fix 100 px-es támadótávolság nem garantál valódi kontaktust minden
közelítési iránynál. A felügyelet megszakította a várakozást.

Javítás: a biztos nagy növény közeli álló harcában hat friss, nem csökkenő
HP-mérés után 0,16 s-os finomító swipe a tényleges célirányba. Valódi sebzés
nullázza a stagnálást. A takart/nem látott cél továbbra is a külön, már működő
csíkmemóriát használja; nem szabad minden takarásnál elhagyni a nyerhető harcot.
Replay és élő ellenőrzés következik ugyaninnen.

Külön biztonsági audit: az akadálytérkép sem írhatja felül a harci visszavonulást.
A visszavonulás/menekülés/tartós vereségsáv döntése a térképréteg saját
függő kerülőjét is törli. Nem elég csak a Strategy kerülőszámlálóját törölni.

`123929-bb81dee2-replay`: a hibás álló sorban a 38. képen 0,16 s-os déli
kontaktusfinomítás jelenik meg, majd újabb stagnálásnál megismétlődik; nincs
végtelen változatlan várakozás. Élő `123929-42ec3969-play`: a folyamat induló
0,38 s-os közelítése már valódi kontaktust adott, a 19. kép új kört és 5,56K-t
mutat. Tehát a kis mozgás szükségessége élőben igazolt, de a pontos 0,16-os
finomítóág ezúttal csak replayben futott, nem szabad élő tesztnek nevezni.
