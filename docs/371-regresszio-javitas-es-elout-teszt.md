# 371 — A valódi hiba: a 369-es int→float regresszió és élő-út regresszió-teszt (2026-11-21)

## Kérés és tisztázás

A felhasználó a teljes napi naplóval tisztázta a 370-es kör téves diagnózisát:
**a játék semmit nem sérült**. A `+500` VIP-módosítás (3450,0 → 3950,0)
sikerült, a játék saját újramentése után is persistálódott (a `save-diff`
kimenetében a mező nem változott — a 10 módosult mező mind normális
játékmenet: cashback-statisztikák, daily procok, fegyverszámlálók, órák), a
játék egészséges. A „hammeres elromlott" jelentése: a
`make save-copies ITEM=mythic_hammer COUNT=+2` **hibával elbukott** — azaz a
369-es float-újítás **regressziót** okozott a korábban működő int-szerkesztésben.

## A hiba gyökere

A 369-es `resolve_value` újírás minden értéket `float(body)`-n keresztül
vitt: int mezőnél is lebegőpontos eredmény született (`"+2"` → `2.0`), és a
`patch_int` — helyesen — elutasította (`ValueError: tört érték int mezőn nem
engedélyezett`). A bukó futás a backup után, **a fájlírás ELŐTT** állt le, így
a mentés nem sérült; a biztonsági sorrend megtartotta magát.

**Miért nem fogták el a tesztek?** Kettős vakfolt:
- a patch-tesztek literál int-eket adtak át, megkerülve a `resolve_value`-t;
- a `resolve_value`-tesztek `assertEqual`-t használtak, ami Pythonban
  `8 == 8.0`-ként igaz — **a típuscsere láthatatlan maradt**.

## Javítás

- `resolve_value`: int mezőnél az eredmény **típusra is int** (értékben tört
  eredmény hibát ad; az értékben egész `"+2.0"` elfogadott és int marad);
  tört mezőnél lebegőpontos marad. A negatív-eredmény guard változatlan.
- `RISKY_FIELDS` korrigálva: a téves „funkciótörés" incidens szöveg helyett a
  valós állás — a mező bizonyítottan rendben 3950-ig; a felhasználó szerint a
  következő VIP-ugrás a játékban **5000-nél** van (a +500 azt el sem érte);
  a figyelmeztetés a kis lépéseket, backupot és utána `save-diff`-et kéri.

## A kért regresszió-teszt: `LivePathRegressionTests`

A „legyen olyan teszt, ami nem engedi egy korábbit elromlani" válasza: a
tesztek mostantól **az élő utat** (`resolve_value` → `patch_value` →
`finish_save`) futtatják minden korábbi forgatókönyvre — copies
("+2", "-3", "350", "+1", "+2.0"), Jar-számláló, `--set-field` int útvonal és
tört útvonal — **típusellenőrzéssel** (`assertIsInstance(int/float)`), mert a
puszta `assertEqual` elrejti az int/float cserét. A bukó exact eset
(int mező `copies=0`, `"+2"`) külön teszteset. A 369-es hiba ezzel a
tesztkapuban élőben elbukna, mielőtt bárki élőben futtatná.

Tesztállomány: 34 → **39** (élő-út int/tört, típusok, értékben-tört guard).

## Jelenlegi állás és következő lépések a felhasználónak

- A játék egészséges, VIP 3950, a crystal_jar valódi játékkal level 10-re /
  accessory 11-re fejlődött. A javítandó mentés nincs — a sikertelen
  mythic_hammer-próba nem írt semmit.
- A `mythic_hammer +2` most újrapróbálható: a hiba javítva.
- VIP 5000: a játék **saját tervezett küszöbe** (a felhasználó olvasta a
  játékból) — az eddigiek alapján egyetlen, óvatos kísérletként kipróbálható
  (`COUNT=+1050`), backup + utána `save-diff`, és a telefonon csak a
  feltöltés után játszani (365).

## Amit nem csináltunk

- Konténer-írás e körben nem történt; a gyűjtő/supervisor/dashboard nem
  futott és nem érintettük.
- A 370-es doksiba javítószekció került; a téves diagnózist explicit
  korrigáltuk, nem tüntettük el.
