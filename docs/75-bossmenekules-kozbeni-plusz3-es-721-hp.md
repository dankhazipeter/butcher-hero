# Bossmenekülés közbeni +3 és 721 HP

## Eseménysor — `20260829-040308-play`

A karakter a zöld sátor–kerítés sarokból a statikus háttérőr két átlós fázisával
kijutott. A 172. eseménynél egy 923 HP-s, bossként osztályozott ellenfél 276 pixelen
belülre került, ezért a bot elindította és öt további tényleges swipe-on át megtartotta
a bizonyított menekülési irányt.

A menekülési útvonal közben egy 3-szíves, 41 HP-s humanoid került a karakter elé:

- `frame-00180.png`: a cél teljes 41 HP-n, a játékos 718 HP-n látszik;
- `frame-00182.png`: automata közelharc, a cél 17 HP-n, a játékos pillanatnyi HP-ja
  714, és egy 10-es kapott sebzés látszik;
- `frame-00184.png`: a cél eltűnt, közvetlen zöld `+3` piros-szív effektus és tiszta
  721 HP látszik;
- `frame-00186.png`: az effektus után is tiszta 721 marad.

A `bot-state.json` az elemi +3 szabály szerint helyesen 721-re frissült.

## Következtetések

- A hiteles aktuális maximum 721.
- Az automata támadás mozgás közben is lezárhat egy keresztezett, nagyon olcsó célt;
  a botnak nem kellett megszakítania a boss utáni menekülési memóriát.
- A 3-szíves, 41 HP-s humanoid ismét közvetlenül +3 maximális HP-t adott.
- A 718→714 átmenet valódi pillanatnyi sebzés volt, nem maximumcsökkenés. A közvetlen
  jutalom után megjelenő 721 a maximális és az aktuális HP-t is helyreállította.
- A hatswipe-os bossmemória ebben a helyzetben biztonságos volt: megtartotta a
  távolodást, miközben az útba eső együtéses farmcél automatikusan elpusztult.

## Stratégiai döntés

Egyetlen ilyen sikeres keresztezés miatt nem gyengítjük a bossmenekülést. A közeli
farmcél megszakítása továbbra is csak a bossmemória lejárta után engedett; az automata
harc útközbeni, kockázatmentes jutalma előny, nem külön üldözési ok. Ha később ismételten
az látszik, hogy a hosszú menekülés már eltűnt boss mellett biztonságos céloktól is
elvisz, ezt külön mérési sor alapján újraértékeljük.
