# 369 — Tört (float) mezők támogatása és a VIP-pontok megtalálása (2026-11-20)

## Kérés

A felhasználó a 368-as nézelődővel megtalálta a VIP-pontjait: a
**`user.in_apps_bought_value_in_rewarded`** mezőben élnek (3350,0) — nem a
`vip` szekcióban, ahogy tippeltük (a `vip` szekció más VIP-adatot tart;
valószínűleg cashback/chest állapotot, lásd 361). A módosítása viszont
elbukott: a mező **tört (float64)**, a `--set-field` eddig csak int-mezőt
fogadott, a `+100.0`/`3450.0` alakok pedig a paraméter-ellenőrzésen estek
volna el. (A biztonsági mentés a próbák előtt rendben elkészült, a mentést
nem érte érvénytelen írás.)

## Megoldás — float-támogatás a mezőszerkesztőben

- `resolve_value` mostantól **tört értékeket** is elfogad (`N`, `+N`, `-N`,
  `N.N`, `+N.N`): tört spec int mezőn hibát ad, int spec float mezőn
  lebegőpontossá válik; a negatív-eredmény guard marad.
- Új `patch_float`/`patch_value`: float mező (kód `0xCA` float32 / `0xCB`
  float64) cseréje **az eredeti kódolást megtartva**, helyben (azonos
  bájtszélesség). Float32 mezőnél, ha az érték nem ábrázolható pontosan,
  hibát ad (csendes kerekítés nincs).
- `patch_int` elutasítja a tört értéket int mezőn; a CLI szám-ellenőrzése
  (`is_number_spec`) minden módban elfogadja a tört alakokat.
- A `find_field_path` immár int és float mezőt is visszaad.

Végpont-szimuláció a felhasználó mezőjével: `user.in_apps_bought_value_in_
rewarded` 3350,0 (float64) `+100` → 3450,0; a mentés a 362-es recept szerint
érvényes, a kódolás és a fájlméret változatlan. A valódi módosítás így néz ki:

```
make save-field FIELD=user.in_apps_bought_value_in_rewarded COUNT=+100
```

## Mellékfelismerések a felhasználó dumpjából (személyes azonosító nélkül)

- **A 362-es recept a 2.1.3-as játékverzión is érvényes** — a `--set-field`
  előfutása a friss verzió által írt mentést is bájtra pontosan validálta
  (tárolt == számolt hash).
- A `user` szekció gazdag: játékidők, hirdetési statisztikák és bevételek,
  telepítés időpontja, verzió, vásárlás-jelzők (`no_ads_purchased` stb.) —
  többek között **tört formátumú Unix-időbélyegek** is (pl. `install_time`).
  Ezek szerkesztésére a `--set-field` ts/time-szerű neveknél figyelmeztet
  (366-os irányelvek).
- A mező neve alapján a VIP-pontkészlet a **jutalmazott bolti vételérték**:
  a játék feltehetően ebből származtatja a VIP-szintet. Hogy a bolti/
  szerveroldali vásárlás-követéssel ütközik-e egy kézi módosítás, azt az élő
  próba mutatja meg; az analitikus (adjust_reported_purchases: 0) mezők
  külön élnek.

## Tesztek

`tests/test_save_edit.py` 22 → **27**: float64/float32 mezők keresése és
kódolás-azonossága, relatív törtspecifikációk, int-mező-védelem, float32
precízióguard, teljes patch-folyamát a többi szekció változatlanságával,
valamint a szekciós/int-tesztek a bővült (user szekciós) szintetikus mentésen.

## Amit nem csináltunk

- Konténer-írás e körben nem történt (a felhasználó saját próbája csak
  biztonsági mentést készített, írás nem futott le); a gyűjtő nem futott.
- A felhasználó mentéséből személyes azonosító sem ide, sem a repóba nem
  került.
