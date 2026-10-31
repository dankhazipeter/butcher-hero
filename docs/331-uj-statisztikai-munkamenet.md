# Új statisztikai munkamenet előzménytörlés nélkül

2026-10-31. Kérés: az időszakok mellől legyen elérhető egy gomb, amely
újrakezdi a Mostani futás számlálóit, de megőrzi a többi időszak adatait.

## Használat és jelentés

Az időszakgombok melletti **i** ikon infóablakában található az
**Új munkamenet indítása** gomb. Előbb külön megerősítést kér, Igen/Mégse
választással; a Mégse kapja a kezdeti fókuszt. Sikeres szerverválasz után
a felület automatikusan a Mostani futásra vált. A gomb nem indít programot
vagy játékot és nem állítja le a gyűjtést.

A Mostani futás kezdete a legutóbbi `watcher_started` és az új, kézzel
mentett statisztikai kezdőpont közül a későbbi. Más időszak számítása
változatlan: Ma helyi éjféltől, Utolsó óra/24 óra gördülő ablak, Minden a
teljes napló, custom a megadott intervallum. Az előző adatok nem törlődnek.
A mennyiségek, darabszámok, görbék és legutóbbi lista ugyanazt a határt
követik. A munkamenet-váltáskor az animátor új kontextust kap, nem számol
vissza az előző munkamenet összegéről.

Lapfrissítés, nyelvváltás, dashboard-újraindítás és `--resume-run` nem
nulláz újra. Egy későbbi kifejezett új gyűjtőfutás (`--new-run`) új
`watcher_started` határa viszont új kezdet. A határ a dashboard statisztikai
nézetéhez tartozik: a gyűjtő saját runID-ja, eseményfolyama és a külön
kristálynapló nem változik. A natív CLI explicit időszakos statparancsának
nem adunk új kapcsolót ebből a feladatból.

Az átvételeket továbbra a kattintás ideje alapján soroljuk időszakba.
Korábbi kattintás későbbi visszaigazolása nem vihető át az új munkamenetbe.
A már ismert adatbizonytalanság sem oldódik meg a reset révén: a korábbi
unknown/nil sorok a megfelelő történeti időszakban megmaradnak.

## Tárolás és védelem

Új, Gitből kizárt fájl: `data/free-rewards/stat-session.json`. Csak
sémaverziót, azonosítót, előző azonosítót és UTC-kezdőidőt tartalmaz.
Nincs `events.jsonl`-átírás, újrakönyvelés, jutalomérték vagy folyamatvezérlés.
A megjelenített időpontot továbbra a böngésző időzónája formázza.

Explicit `POST /api/statistics/session`: azonos Origin, engedélyezett
loopback Host, Sec-Fetch-Site ellenőrzés és külön, szerverenként generált
`X-Statistics-Session-Token`. A játékindító tokenje nem használható hozzá.
Csak `expectedSessionID` mezős, legfeljebb 256 byte-os JSONtest fogadható el.
Nincs tetszőleges időpont/fájlnév/parancs, nincs GET-reset vagy automatikus
indítás oldalnyitáskor. Az egyéb POST-útvonalak továbbra tiltottak.

A módosítás külön szálzár + fájlzár mellett compare-and-set: régi lap nem
írhat át újabb munkamenetet. Az előző kérés azonos azonosítóval történő
ismétlése ugyanazt a határt adja vissza, nem tolja újra előre. Írás ideiglenes
fájlba, flush/fsync, majd atomi replace; sérült/olvashatatlan metadata és
íráshiba explicit hiba. Nem állítunk sikert, amíg a szerver nem igazolta.

UI-n dupla kattintás ellen in-flight kapu van. Hibánál nincs automatikus
POST-újrapróba: friss GET után ismét megerősítés kell. Elavult kapcsolat vagy
régi, ezt még nem támogató szerver mellett a gomb nem aktív. A reset előtt
elindított, későn visszaérő poll nem írhatja vissza a korábbi számlálókat.
Bezárás/Mégse törli a még el nem küldött megerősítést, de a már elküldött
kérésről nem állítja hamisan, hogy megszakadt. Minden szöveg HU/EN fájlban.

## Ellenőrzés és betöltés

10 új Python teszt: csak run változik; más időszak bitazonos aggregate;
napló változatlan; tartós határ/resume/új watcher; függő régi claim;
több példány duplakérése; stale tab; sérült metadata/íráshiba; explicit
HTTP és idempotencia; Origin/Host/token; szűk body/transport.
6 új Node teszt a valódi app.js-en: megerősítés/Mégse/nyelv/zárás;
egyetlen POST és sikertől függő run-váltás; hiba nem retry; stale/offline;
megerősítéskor rögzített régi sessionID; késői régi poll elutasítása.
Teljes kapu: 193 teszt + 7 JS-szintaxis (72 Swift, 23 dashboard,
7 game-control, 10 session, 3 Git-kapu, 10 supervisor, 19 launcher, 49 Node).

Külön tesztszerveren valódi böngészővel 4 igazolt tételből run=0 lett,
majd Ma=4; a gomb/megerősítés és a magyar modal vizuálisan ellenőrzött.
A tesztprojekten nincs valódi játékvezérlés vagy éles napló. Az éles
dashboardon csak a gomb láthatóságát ellenőriztük, resetet nem küldtünk.
Helyi képproof `.build/stat-session-live.png`, nem commitolt személyes adat.

Szerverkód betöltése rövid saját runnerstop/resume-val, új gyűjtőbuild nélkül:
22:14:22Z runner4117, supervisor4142, worker4143, session8418. A meglévő
kezdet `2026-10-30T16:50:44.381Z`, előtte/utána 1462 igazolt tétel és nincs
éles stat-session.json. Azóta új Cut Defense631 is igazolt, friss képidőkkel.
Az inputbiztonság és a Free/kristály/event automatika nem változott.
