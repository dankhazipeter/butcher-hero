# Húzásvédelem élő igazolása — 2026-10-30

## Helyzet és felhasználói visszajelzés

A felhasználó újraindította a játékot, és az éles működés ellenőrzését kérte.
A már futó83220PIDfigyelő automatikusan visszatalált az ablakhoz:
10:27:48.980Z `capture_recovered`. Nem indítottunk második figyelőt,
nem módosítottunk kódot, nem mozgattunk karaktert.

Felhasználói közlés: mozgott, megjelent a jutalom, nem engedte el a húzást;
amikor megállt, a bot felszedte. Ez egybevág az alábbi naplóval és képekkel.

## Két teljes várakozás → kattintás → igazolás lánc

Az alábbi időpontok Bucharest helyi időben,UTC+02:00; a nyers naplóUTC.

| Jutalom | Kézi input miatti várakozás | Kattintás | Kártya eltűnése igazolva |
| --- | --- | --- | --- |
| Pierce Damage540 | 12:31:05.883 | 12:31:08.334 | 12:31:10.603 |
| Cut Defense593 | 12:31:40.569 | 12:31:46.026 | 12:31:48.291 |

Az első claim: `437D5839-4C10-4450-928B-F30E75A83D49`.
A második: `E70B01F5-6D78-43AE-932A-7AC4BD6B6467`.
Mindkettőben `input_deferred` után ugyanazzal aclaimID-val következett
`click_intent`, `click_sent`, majd `claim_confirmed_ui`.

Bizonyíték: `data/free-rewards/events.jsonl`, és a projektben a
`data/free-rewards/evidence/<claimID>-after.png` képek.
Az asszisztens mindkét utóképet ellenőrizte: aFreekártya hiányzik,
explicit zöld+540nyíl, illetve+593fejszés pajzs jutalomfelirat látszik.
Ez erősebb bizonyíték, mint önmagában a kártya hiánya.

## Könyvelés és aktuális állapot

A `stats --from 2026-10-30T10:31:00Z --to 2026-10-30T10:31:50Z`
lekérdezés eredménye:2kattintási próba,2igazolt claim,0függő,
0besorolatlan és0hibás naplósor; PierceDamage540ésCutDefense593.
Mindkét jutalom egyszer szerepel az összesítésben.

10:32:27.489Zállapot:83220PIDél,1sfigyelés,running=true,
waitingForMouseRelease=false. A286végpontjában látott ablakhiány megszűnt.
A figyelőt futva hagytuk, régi játékbot/heartbeat nem indult.

## Mi igazolt, mi marad nyitott?

**Élőben igazolt:** kézi húzás mellett várakozás; elengedés után automatikus
friss kártyaellenőrzés és átvétel; eltűnés utáni egyszeri naplózás/összesítés.
Ezt felhasználói visszajelzés és két tényleges eseménylánc támasztja alá.

**Még csak automatizált teszttel igazolt:** ténylegesen elküldött, de
hatástalan kattintás utáni1s-os újrapróba. E két élő átvétel elsőre sikerült,
ezért azokat nem nevezzük az újrapróba éles bizonyítékának.
