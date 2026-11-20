# 368 — Szekció-nézelődő és általános mezőszerkesztő (2026-11-20)

## Kérés

A felhasználó megkérdezte, hol tárolódnak a **VIP-pontjai** (3350), és hogy
van-e a `make`-ben listázó, amivel a mentés többi értékét meg lehet nézni —
illetve módosító ezekhez. Igaza volt: az eddigi eszköz csak tárgyakat
listázott (`save-items`), és csak `copies`/Jar-számláló szerkesztését tudta.

## Hol vannak a VIP-pontok

A 366-os mezőtérkép szerint a mentés `data`-jában van egy **`vip` szekció**
(két mezővel) — a VIP-pontok szinte biztosan ott élnek (vagy ritkább esetben
a `user` szekcióban). A pontos mezőnév a most elkészült nézelődővel
ellenőrizhető (a mentés a felhasználó gépén, TCC alatt — az eszköz az ő
termináljából fut).

## Új képességek: `--sections`, `--section`, `--set-field`

A `scripts/butcher-save-edit.py` bővült:

- **`--sections`** — a 32 adatszekció listája (név, típus, meződarab).
- **`--section NÉV [--depth 1..4]`** — egy szekció kibontása olvasható
  sorokba (skalárok értékkel, map-ok rekurzívan a megadott mélységig,
  tömbök első elemeivel). Példa: `--section vip` megmutatja a pontok mezőjét.
- **`--set-field ÚTVONAL ÉRTÉK`** — **bármely int-mező** állítása pontozott
  útvonalon (`szekció.mező[.almező…]`, pl. `--set-field vip.points +100`).
  Ugyanazokat a síneket használja, mint a copies/Jar-szerkesztés: játék-nem-fut
  előfeltétel, a jelenlegi mentés hash-érvényességének ellenőrzése, SHA-256
  manifestes backup, minden kódolási átmenet, hash-újraszámolás, PlayerPrefs
  összehangolás, relatív `+N/-N` és abszolút `N` értékek. Időbélyeg- és
  verziószerű nevű útvonalaknál (pl. `*_ts`, `time`, `version`) figyelmeztet,
  mert a 366-os irányelvek szerint ezek szerkesztése kockázatos.

A Makefile új célokkal bővült (a `make help` automatikusan felveszi őket):

```
make save-sections                        # a 32 szekció listája
make save-section SECTION=vip [DEPTH=3]   # szekció kibontása értékekkel
make save-field FIELD=vip.points COUNT=+100   # tetszőleges int-mező
```

Új változók: `FIELD` (útvonal), `SECTION`, `DEPTH`.

## Tesztek

`tests/test_save_edit.py` 16 → **22 teszt**: a szintetikus mentés most
`vip` (points/level), `currency` (geode) és `events.currencies.red`
(háromszintű útvonal) szekciókat is tartalmaz. Lefedve:
`list_sections`, `dump_section`, `find_field_path` minden mélységre, a
guard-esetek (túl rövid útvonal, nincs szekció/mező, int végű útvonalra
lépés), a teljes patch-folyamát (`vip.points 3350→3450`, a többi szekció és
a tárgyak változatlanságával), relatív érték és kódolásváltás
(fixnum→uint16, +2 bájt).

## Amit nem csináltunk

- Konténer-írás e körben nem történt; a felhasználó saját termináljából
  nézi majd meg a `vip` szekciót és szerkeszti a pontokat.
- A gyűjtő/supervisor/dashboard nem futott és nem érintettük.
- A korábbi lezárások (366) érvényben maradnak.
