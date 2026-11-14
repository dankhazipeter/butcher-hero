# 367 — Tárgyválasztható copies, `make` súgó és a Makefile (2026-11-14)

## Kérés

A `--copies +1` (crystal jar) éles sikere után a felhasználó azt kérte:
(a) a példányszám-szerkesztés **bármelyik tárgyra** választható legyen
kapcsolóval — konkrétan a **gem_ring** copies-át szeretné növelni; (b) a
projekt gyökerébe **Makefile** kerüljön `help` céllal, amely a paraméterektől
függően hívja meg a Python-eszközöket, és amelybe a későbbi eszközök is
beírhatók.

## Tárgyválasztás: `--item KULCS`

A `scripts/butcher-save-edit.py` át lett alakítva: a Save-osztály most
tárgykulcs szerint keres (`item_fields(item_key)`, `find_item_int(item_key,
field)`), a `--item` kapcsoló választja a céltárgyat (alapértelmezés a
`crystal_jar`), és új `--items` mód listázza **az összes tárgyat** (key,
level, copies) — így a kulcsok egyszerűen felderíthetők.

A mentésben ellenőriztük: a `gem_ring` (a felszerelt kiegészítő,
accessory_level 6, 7500 XP) **ugyanazt a sémát használja** — `copies: 0`,
vagyis a fejlesztéshez ott sincs példány. A tesztek két tárgyas szintetikus
mentésre épülnek (crystal_jar + gem_ring): a kiválasztott tárgy módosul, a
**másik érintetlen marad**, és a Jar-számláló is. 16 offline teszt a
kötelező kapuban.

## Makefile súgóval és paraméterezéssel

A projekt gyökerének Makefile-ja (a korábbi `start/stop/status/install-cli/
setup/test/test-vision` célok változatlanul) új elemei:

- **`make help`** — `##`-megjegyzésekből épülő, automatikusan karbantartható
  parancslista. Új eszköz hozzáadásához egy cél + egy `##` sor elegendő.
  **A sima `make` alapértelmezett céle továbbra is a `setup`** (a 326-os
  szabály szerint: sosem rejtett gyűjtőstart) — ezt a repó
  `test_plain_make_still_only_sets_up_hooks_never_starts_collection`
  regressziós tesztje is őrzi, ami az első kísérletben (alapértelmezett cél
  `help`-re állítása) helyesen el is utasította a változtatást; a végső
  Makefile visszatért a `setup` alapértelmezéshez, a help explicit
  `make help` paranccsal érhető el.
- **Mentés-célok**, változókkal paraméterezve:
  - `make save-check [ITEM=…] [SECRET=…]` — állapot: hash, a tárgy adatai, PlayerPrefs
  - `make save-items` — az összes tárgy listája
  - `make save-copies ITEM=gem_ring COUNT=+1` — példányszám (N / +N / −N)
  - `make save-jar COUNT=500` — Jar lelk-számláló
  - `make save-revert` — utolsó biztonsági mentés visszaállítása
- Változók: `PORT` (dashboard), `ITEM` (cél-tárgy, alap crystal_jar),
  `COUNT` (érték, alap `+1`), `SECRET` (hash-kulcs felülírás, ha egy jövőbeli
  verzió más kulcsot használna).

A paraméterátadást `make -n` dry-runokkal ellenőriztük (`--item gem_ring
--copies +1`, `--secret …`, `PORT=8766` stb.), a `make test` a teljes kaput
változatlanul futtatja.

## Éles eredmények e körben

- A 366-os `--copies +1` (crystal jar) **élesben sikerült** a felhasználó
  termináljából: hibátlan betöltés, a fejlesztéshez elérhetővé vált egy
  példány.
- A gem_ring-növelés a felhasználó következő éles lépése:
  `make save-copies ITEM=gem_ring COUNT=+1`.

## Amit nem csináltunk

- Konténer-írás e körben nem történt (eszköz + Makefile + tesztek készültek);
  a gyűjtő/supervisor/dashboard nem futott és nem érintettük.
- A korábbi lezárások (366) érvényben: ~20%-os eltérés és REA MCP szálak
  zárva maradnak.
