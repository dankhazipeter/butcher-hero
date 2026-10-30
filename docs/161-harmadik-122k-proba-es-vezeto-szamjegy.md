# Harmadik 1.22K-próba és a levágott vezető számjegy

## Élő eseménysor

A `144933-play` 161. képe a nagy térkép piros irányának követése után egy tisztán
látható `1.22K` HP-s páncélost talált. A 693 DPS-es build és 802 teljes HP mellett
a kontrollált próba helyesen elindult.

- 161–162: 318→263 pixelre közelítés, az ellenfél még 1.22K.
- 163–165: a felirat a bal/felső képi mozgás közben `.22K`, `:22K`, majd hiányos
  alakra váltott. A régi elemző ezt 220 HP-nak tárolta.
- 166–167: valódi közelharc; a képen két 30-as kapott sebzés, 296 és 130 támadási
  szám, 796 ellenfél-HP és 776 saját HP látszik. Ez 424 kiosztott sebzés mellett
  csak 26 saját HP-vesztés: a harc egyértelműen nyerhető állásban volt.
- A stratégia mégis elveszett célként kezelte a 220-ra tévesen váltott azonosítót,
  majd az általános bossőr eltávolodott. Győzelem és harmadik Fang-jutalom nem
  született.

## Ok

A cél-HP parser a vezető számjegy nélkül felismert `.22K` értéket matematikailag
0,22K = 220-ként bontotta ki. A játék azonban 1000 alatt nem K-rövidítést használ;
ráadásul ugyanazon csík előző képe 1220 volt. A két egymást követő, azonos téves
220 miatt a közös célkövető zajőr is elfogadta az ugrást.

## Javítás

Ha ugyanazon, legfeljebb 85 pixelt mozdult csík előző HP-ja legalább 1000, az új
OCR pedig ponttal vagy kettősponttal kezdődő, 1000 alatti K-alak, az elemző az
előző ezres részt visszateszi:

- `1220 → .22K/:22K → 1220`;
- általánosan például `4310 → :31K → 4310`.

A helyreállítás csak akkor él, ha az eredmény legfeljebb 300 HP-ra van az előző
értéktől. Egy valódi, explicit más ezres érték (például `2.18K`) továbbra is
szabadon mutathat bosssebzést.

## Regresszió

- A `145530-replay` 163–167. elemzése minden levágott alaknál 1220-on tartotta a
  célazonosságot; a 220 eltűnt.
- A kontrollált próbákat is engedélyező `145713-replay` 161–167. döntései a régi
  elveszett-cél keresés helyett folyamatos megközelítést és oldalkite-ot adtak.
  A 167. képen 93% saját HP mellett is folytatta volna a harcot.
- A replay képei az eredeti menekülés eredményei, ezért a 168. képtől fizikailag
  már nincs cél a képen. A tényleges győzelmet csak a következő élő találkozás
  igazolhatja.

## Következtetés

- **Biztos:** a harmadik 1.22K-próba létrehozott harci kontaktust, és a 1220→796
  csökkenés mellett a saját veszteség csak 26 HP volt.
- **Biztos:** a megszakítás oka célazonossági OCR-hiba, nem rossz harci mérleg.
- **Erős következtetés:** ugyanebből az állásból a javított folyamatos kite nagy
  valószínűséggel legyőzi a páncélost, ahogy két korábbi alkalommal már megtette.
- **Nyitott:** a következő élő próba ad-e Savage Fang `3→4`, Damage `24→32`
  jutalmat.
