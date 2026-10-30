# Látható gyűjtőállapot a statisztikában — 2026-10-30

## Felhasználói kérés és eredmény

Az oldal mutassa, hogy a program éppen fut-e. Korábban csak apró szöveg
szerepelt a fejlécben az élő adatkapcsolat mellett, ezért könnyen összemosódott
a szerver működése és a gyűjtő működése.

Most a cím alatt külön, színes szegélyű GYŰJTŐPROGRAM ÁLLAPOTA kártya van.
Nagy állapotfelirat, rövid magyarázat és az utolsó sikeres képolvasás ideje.
Nem csak szín jelzi az állapotot; a szöveg és a képernyőolvasó státusz is frissül.

| Állapot | Feltétel |
| --- | --- |
| Fut, zöld | A worker PID-je él, running=true, és a sikeres képidő legfeljebb10srégi. |
| Leállítva, piros | Ismert állapot alapján nincs futó worker. |
| Indul / újraindul, sárga | A folyamat él, de még nincs sikeres képolvasás. |
| Mozgás miatt várakozik, sárga | Friss képfeldolgozás mellett kézi egérgomb/húzás védi a felhasználói inputot. |
| Nincs friss képolvasás, sárga | A folyamat él, de több mint10sóta nincs sikeres képidő; ez megelőzi a mozgásjelzést. |
| Nem ellenőrizhető, szürke | Nincs hiteles állapotadat, kapcsolathiba van, vagy az APIválasz több mint20srégi. Nem állítjuk, hogy a gyűjtő leállt. |

Az utolsó képidő nem a legutóbbi jutalom ideje. Jutalom nélküli időben is
frissül, ha a képfeldolgozás működik. A jelzés mindig a jelenlegi gyűjtőre
vonatkozik, függetlenül a kiválasztott statisztikai időszaktól.

## Megvalósítás

- A read-only backend az állapotfájl mellett ellenőrzi aPIDlétezését.
  Új stateKnown/processAlive mezők; hibásJSON, hiányzófájl, érvénytelenPID
  vagy jogosultsághiány esetén nem adunk hamisFutállapotot.
- A `dashboard/status.js` külön, böngészőben ésNodeunitban használható
  leképezés. A böngésző saját órája a válaszok között is öregíti a képidőt.
- 1másodpercenként frissül a jelzés; a napló APIpollja változatlanul2s,
  háttérlapon10s. HTTPhibánál azonnal megszűnik a zöld státusz, miközben
  a korábbi naplóértékek megmaradnak és az utolsó ismert képidő is látszik.
- Az oldal továbbra csak olvas. Nincs indító/leállító gomb vagy játékinput.

## Teszt és élő ellenőrzés

7Nodeállapotteszteset: friss worker, leállás, elsőképre várás, elavulás,
kézi input, kapcsolathiba és hiányzó/hibás állapot. A folyamat él, de nincs
friss kép eset sem lehet zöld; a hálózat megszakadása nem jelent automatikusanSTOPot.

2újPythonteszt a PID/állapotfájl kezelésére; az existingHTTPteszt a status.js
engedélyezett kiszolgálását is ellenőrzi. A teljes kör:23Swift,15statisztika,
3Gitkapu,9felügyelet,12Node és3JSszintaxisellenőrzésPASS.

A hiba/leállás ágakhoz csak tesztadatokat használtunk, nem állítottuk le
a gyűjtőt. Az éles worker végig66095maradt, folyamatosan friss lastCheckedAt
értékkel. Csak a statisztikaszerver indult újra:32872→77612/session3504.
A meglévő helyi böngészőlapon újratöltés után látható a Fut állapot és a
frissülő képidő;590pxszélességen a státuszkártya jól olvashatóan törik.

QA-kép: `outputs/collector-status.png` (helyi ellenőrzési kép, nem nyers
játéknapló és nem automatikusan új tesztelvárás). A Sites helyi munkafolyamatát
követtük: meglévő helyi szerver, helyi böngészős ellenőrzés; nem hoztunk létre
felhős webhelyet vagy új publikálást.
