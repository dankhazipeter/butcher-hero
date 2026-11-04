# „?” összeg a Naplóban: 633 és 591 lila padlón

2026-11-04 este, natív app. A felhasználó képernyőképén a Naplóban a
22:52:11-es Pierce Defense átvételnél „?” állt a mennyiség helyén.

## Tények

- `BB7D4070` (21:52:11Z): a kártyán 633, utóképen „+633” pajzs-nyíl ikonnal.
  Olvasó: 6 jó, a középső 3 = 0.128 a 9 = 0.149 ellen, különbség 0.021 < 0.035,
  ezért helyesen nem tippelt.
- `F4E69593` (21:53:19Z, közben jött): kártyán 591, utóképen „+591” nyíllal
  (Pierce Damage). Az első 5 = 0.134 a 9 = 0.167 ellen, 0.033 < 0.035.
- Mindkettő 637×882 ablak, 16 px-es számjegyek, lila dungeonpadló háttér.
- Az app összes többi, összeg nélküli átvétele (82 db, nov. 3–4. éjjel) a
  jelenlegi kóddal már helyesen olvasódik; azokat korábbi javítások fedik.

## Javítás

Küszöb, crop, szegmentálás nem változott. A `tools/build-reward-digit-templates.swift`
három új, vizuálisan ellenőrzött glyphet kap, a korábbi 60 bájtra azonos:

- 633-ból csak a hibázó középső 3 (`piercedef633-calibration.png`);
- 591-ből csak az 5 (`pierce591-calibration.png`);
- egy 598-as Cut Defense claimből (`cutdef598-nine-calibration.png`, utókép
  „+598”) a 9. Az első próbában a 633 két 3-asa miatt a 598 9-ese 0.030-ra
  szorult, és három korábban jól olvasott 598 kép nil lett. Ezt a teljes
  visszajátszás fogta meg; csak a középső 3 sem volt elég, ezért kell a 9.

## Ellenőrzés

- Új teszt (`testPurpleFloorAmountsWithThreeFiveAndNine`): régi digits.json
  mellett piros (633/591 nil), újjal zöld. Ellenőrző képek: két másik 598 claim,
  valamint a 633 és 591 claim második képe. Ez utóbbiak ugyanannak a claimnek
  másik frame-jei, nem független held-out minták.
- Visszajátszás minden mentett, ismert összegű validált képen (6174, app +
  régi data mappa): 6172 egyezik a naplóval, 0 nil (régi mintákkal 15 nil:
  551/552/554, most ezek is jók). A 2 eltérés régi, ismert naplóhiba
  (817 = a 346-ban már korrigált tétel, és egy 8→525), mindkét mintakészlettel
  ugyanaz, tehát nem új regresszió.
- A két mostani „?” tétel naplóját NEM írtuk át; `reward_corrected`
  csak külön felhasználói engedéllyel kerülhet be.
