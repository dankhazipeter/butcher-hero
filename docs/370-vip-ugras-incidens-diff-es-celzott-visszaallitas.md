# 370 — VIP-ugrás incidens: játékreakció-törés, diff-figyelés és célzott visszaállítás (2026-11-21)

## Mi történt

A felhasználó a 369-es float-támogatással élőben módosította a
`user.in_apps_bought_value_in_rewarded` mezőt: 3450,0 → **+500 → 3950,0**.
A VIP-pont a játékban jól mutatta az új értéket, de **a hammer/kovács
játékfunkció elromlott**, ami korábban jó volt.

## Elemzés — mi volt rossz és mi nem

- **Az eszköz byte-szinten hibátlanul dolgozott** (a 34 teszt épp ezt őrzi):
  pontosan egy mezőt írt (a float32 kódolást megtartva, helyben), a fájl a
  362-es recept szerint érvényes, minden más bájt érintetlen, a módosítás
  előtt SHA-256 manifestes backup készült.
- **A törést a játék logikája okozta**: a mező a VIP-szint vezérlője, és a
  +500 ugrás olyan határt lépett át, amelytől a hammer/kovács funkció
  megsérült. A korábbi +100 (3350→3450) még rendben volt — a töréshatár a
  3450…3950 tartományban van. **Offline unit-teszt ezt nem jelezheti előre**:
  a játék belső viselkedése dönt, nem a fájl szerkezete.

## Válasz: három rétegű védelem az eszközben

1. **Kockázatos-mező nyilvántartás** (`RISKY_FIELDS` + `risky_note`): a
   `--set-field` a vezérelt mezőknél a mai incidens szövegével figyelmeztet:
   „VIP-szintet vezető mező: nagy ugrás játékfunkciókat törhet
   (2026-11-21: 3450→3950 a hammer/kovács funkciót eltörte)". Az időbélyeg-
   és verziószerű nevek korábbi figyelmeztetése változatlan.
2. **`--diff [MENTÉS]` / `make save-diff [BACKUP=…]`**: mezőszintű
   összehasonlítás a mostani mentés és bármelyik biztonsági mentés között —
   minden változó/új/eltűnő mező útvonallal és régi→új értékkel listázva
   (tömbindexekkel: `player.items[0].copies`). Ez az igazi
   „regresszió-figyelő": szerkesztés után lefuttatva látszik, hogy **pontosan
   az egy mező** változott; a játék session után lefuttatva látszik, **mit
   vezetett le a játék** a módosításból (pl. vip-szint, blacksmith-állapot).
3. **Célzott visszaállítás**: `--revert [MENTÉS]` / `make save-revert
   [BACKUP=…]` — a legutóbbi helyett bármelyik korábbi manifestes mentésből
   (pontos név vagy előtag).

## Javítási recept (a felhasználónak)

1. `make save-revert` — vissza a +500 előtti állapotba (20261121-074105,
   VIP 3450, ahol a funkció még jó volt).
2. Indítás, **rövid játék, hogy a játék maga mentsen és töltsön fel** (a
   felhőn a törött 3950-ás állapot van; a friss lokális mentés ideje nyer,
   ez írja felül — lásd 365).
3. Zárás, ellenőrzés: `make save-check` és a hammer/kovács funkció a
   játékban. `make save-diff` megmutatja, mit változtatott a játék.
4. Ha 3450-nél még törött maradna (vagyis már a +100 is érintette volna):
   `make save-revert BACKUP=20261120-161004-save-edit` (az eredeti 3350-ás,
   módosítatlan állapot), ugyanaz a play-and-upload menet.

## Nyitott kérdés

A törés pontos mechanizmusa (VIP-szintküszöb? kovács-slot feloldási
állapotgépe? szerver-ütközés?) nem ismert — a felhasználó diagnosztikai
adataiból (mi pontosan romlott el; `make save-section SECTION=blacksmith`
és `SECTION=vip` kimenete a javítás után) egy későbbi kör zárhatja. A
VIP-pontok jövőbeni növelésére a biztonságos zóna jelenleg ≤3450; ennél
többhez a VIP-küszöbtábla binárisból való kinyerése kellene (362-es
módszertan, külön kör).

## JAVÍTÁS (2026-11-21, a teljes napló alapján): a fenti diagnózis TÉVES VOLT

A felhasználó a teljes napi naplót megosztotta, és kiderült: **egetlen
játékfunkció sem törött el**. A valós eseménysor:

1. A `+500` VIP-módosítás **sikerült és persistálódott** — a felhasználó
   `make save-diff` kimenetében a `user.in_apps_bought_value_in_rewarded`
   nem szerepel a változott mezők közt (a játék saját újramentése után is
   3950,0 maradt), a 10 változás mind normális játékmenet (cashback,
   daily procok, fegyverszámlálók, órák). A játék egészséges.
2. A „hammeres elromlott" valójában azt jelentette: a
   `make save-copies ITEM=mythic_hammer COUNT=+2` **elbukott** — a 369-es
   float-újítás regressziója miatt (a `resolve_value` minden értéket
   lebegőpontosított, a `patch_int` az int mezőn elutasította). A
   korábban működő int-szerkesztés (crystal_jar, gem_ring, soul_essence
   copies) élőben tönkrement. **A hiba a mi eszközünkben volt, nem a játékban.**
3. A visszavezetett „VIP-töréshatár 3450…3950 között" elmélet tehát
   alaptalan; a mező bizonyítottan rendben működik 3950-ig, és a felhasználó
   szerint a következő VIP-ugrás a játékban **5000-nél** van — a +500 azt
   el sem érte.

A javítás, a regresszió-teszt (élő út, típusellenőrzéssel) és a korrigált
kockázatos-mező szöveg a **371-es** dokumentumban. Az itt bevezetett
save-diff / célzott revert / kockázatos-mező figyelmeztetés eszközök
változatlanul hasznosak — csak az őket indokoló diagnózis volt hibás.

## Amit nem csináltunk (eredeti zárszó, a javítás előttről)

- Konténer-írás e körben nem történt (eszköz + tesztek + doksi); a
  javító lépéseket a felhasználó futtatja saját termináljából.
- A gyűjtő/supervisor/dashboard nem futott és nem érintettük.
