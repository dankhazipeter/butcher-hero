# Első jutalomösszesítés — 2026-10-30

Felhasználói kérés: a sima ésK-s értékek megkülönböztetése, eddigi hozam.
Forrás:data/free-rewards/events.jsonl, kattintások08:16:39–08:46:30UTC,
azaz10:16–10:46Europe/Bucharest. A feldolgozás pillanatában35elküldött
kattintásból33UI-visszaigazolt,2még bizonytalan/függő. Csak a33igazolt tétel
szerepel az alábbi összegekben,claimIDnként egyszer, korábbi javításokat figyelembe véve.

| Típus | Darab | Kijelzett jutalomértékek összege |
| --- | ---: | ---: |
| Health | 9 | kb.162000 |
| Health Regen | 4 | 324 |
| Pierce Damage | 9 | 4644 |
| Cut Damage | 0 | 0 |
| Smash Damage | 3 | 2040 |
| Pierce Defense | 2 | 1222 |
| Cut Defense | 4 | 2312 |
| Smash Defense | 2 | 1604 |

A785D7184-F674-493C-AD03-B73828BF81A4claim nyers besorolásaunknown611volt.
Az eredeti előképet az asszisztens most szemrevételezte: világosan nyíl
pajzson, vagyisPierceDefense611. Ezt a jelentés a második ilyen tételként
számolja. A gépi naplót/kódot a csak összesítést kérő körben nem módosítottuk;
a CLI-összesítő ezért egyelőre1besorolatlan611-es tételt mutat, amíg külön
javítóesemény nem kerül bele. Az eltérés dokumentált, nem hallgatólagos adatjavítás.

Az összes9HP-jutalom nyers felirata18K, normalizált értéke18000. Ez a
kijelzett kerekített érték jelentése; a pontos belső jutalom nem ismert.
A sima591/516/81értékeknél nincs ezres szorzó. K=1000,M=1000000,
B=1000000000,T=1000000000000. A statok későbbi teljes növekedése a
karakter szorzói miatt eltérhet a feliratok egyszerű összegétől.

A figyelőt nem állítottuk le és nem változtattuk meg; ez időpillanatos jelentés.
