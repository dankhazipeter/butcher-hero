# 364 — Élő mentéspróba: Crystal Jar 360→361 konzisztens hash-szel — SIKER (2026-11-14)

## Kérés és terv

A felhasználó a 362–363 eredményekre alapozva élő próbát kért: az 361-es
Crystal Jar 360→361 módosítás megismétlése **helyes hash-szel** és a
PlayerPrefs bizalmi réteg összehangolásával. A terv:

1. A fájl saját MD5-hash-ének újraszámítása a 362-es recept alapján
   (data + fixstr("5b5496vn7456oodw976d95mo") + optimális salt-int kódolás).
2. A PlayerPrefs `cloud_save_local_hash` beállítása az új hash-re és a
   `cloud_save_local_untrusted` törlése (363).

A próba szkriptje a session ideiglenes mappájában készült
(`jar_experiment.py`, pozíciókövető MessagePack-elemzővel); a Jar-számlálót
**dinamikusan** keresi (`data → player → items[] key="crystal_jar" →
ability_counters["accessory_crystal_jar_ability_1"]`). A megtalált offset
(0x27D5) bájtra egyezik a 361-es dokumentumban rögzítettel. A patchelő logika
offline szimulációban és a repó `scripts/butcher-save-hash.py` eszközével
keresztkontrollálva érvényes fájlt adott, még mielőtt élesben futott volna.

## Végrehajtás (a felhasználó termináljából, Teljes lemezhozzáféréssel)

A szkript előfeltételei: a játék nem fut; a konténer elérhető; az eredeti
mentés hash-e érvényes. Minden teljesült. A biztonsági mentés a
`~/Library/Application Support/Butcher Hero/save-backups/…-jar-361-consistent/`
mappába készült SHA-256 manifesttel (game_data, backup, pre_cloud, plist).

Módosítás a konténerben:
- `game_data.bin`: **1 bájt** (uint16 360→361 alacsony bájtja, 0x68→0x69) + a
  hash-mező 47 karakterének cseréje az új értékre; minden más bájt változatlan.
- `com.multicastgames.butcher.plist`: `cloud_save_local_hash` → új hash,
  `cloud_save_local_untrusted` → 0 (bináris plist, atomi csere).

## Eredmény — a próba sikeres

A felhasználó elindította a játékot: **hibátlan betöltés, nincs „SAVE DATA
ERROR", a Crystal Jar 361-et mutat** (360 helyett). Játszott, majd teljesen
bezárta a játékot. Az utóellenőrzés (`--check`) eredménye:

- A `game_data.bin` a **játék saját újramentése** (144 340 bájt, új salt
  1742030218, új hash `B5-4E-53-BA-…`), és a **hash a 362-es receptje szerint
  érvényes** — a játék tehát a módosított állapotot saját maga mentette újra.
- **Crystal Jar számláló: 361** — a módosítás a játék mentési ciklusán át
  megmaradt.
- `cloud_save_local_hash = 'B5-4E-…'` — a trust-rétezég az aktuális (módosított)
  mentés hash-ét jegyzi meg; ez a Remember hívás nyoma, amely a 363-as elemzés
  szerint a felhői műveletekhez kötődik — **erős jel arra, hogy a módosított
  mentés fel is töltődött a felhőre** (végleges bizonyíték a következő
  frissítés utáni letöltés lesz).
- `cloud_save_local_untrusted = 0` — nincs distrust; a 363-ban vázolt
  felhői-felülírási forgatókönyv nem lépett életbe.
- A `game_data_backup.bin` a normál CreateBackup-ciklusban frissült.

**Következtetés:** a 362-es hash-recept és a 363-as trust-modell együtt
elegendőek a mentés konzisztens, a játék által elfogadott módosításához —
élesben igazolva, a betöltéstől a saját újramentésen át a bizalmi állapotig.

## Következő lépés: játék-frissítés (megfigyelésre nyitva)

A játéknak új verziója érhető el; a felhasználó frissíteni készül. Ez maga a
teljes körű teszt: ha a felhő a módosított mentést tartja, a friss verzió
letöltése után is 361-et kell látni. Kockázatok, amikre számítunk:

- **A felhőnek a régi (360) mentése van**: a szinkron SHA-eltérést lát, és a
  363-as időbélyeg-döntés szerint dönthet letöltésről — ekkor a 361 eltűnik, és
  pontosan látni fogjuk, melyik réteg döntött így.
- **Séma-migráció**: az új verzió a `version` mező (jelenleg 2) alapján
  migrálhat; a Jar egy egyszerű számláló, várhatóan megmarad.
- **A hash-recept változása** az új verzióban: minden 2.1-es mentést ugyanúgy
  érintene (nem csak a miénkat); a visszamenő kompatibilitás a kiadók
  érdeke, de ha mégis változik, a betöltéskori ellenőrzés karanténba teszi a
  mentést — ezt a frissítés után azonnal észrevesszük.

A frissítés utáni megfigyelés új kör (365) lesz: `--check` kimenet, Jar-érték,
és a fájlok állapota alapján zárjuk le a felhői kör kérdését.

## Amit nem csináltunk ebben a körben

- Nem nyúltunk a gyűjtőhöz/supervisorhoz/dashboardhoz (nem is futottak).
- Nem módosítottunk mást a konténerben, mint a fent leírt két fájlrész és a két
  PlayerPrefs-kulcs; a biztonsági mentés a próba előtti állapotot őrzi.
- Nem érintettük a felhői API-t közvetlenül; a felhői állapotra csak a játék
  saját viselkedéséből következtetünk.
