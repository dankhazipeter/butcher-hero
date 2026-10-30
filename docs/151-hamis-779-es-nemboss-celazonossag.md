# Hamis 779-es maximum és kis célból képzett hamis bossfolytatás

## Az anomália

Az élő `docs/runs/20260829-132425-play` 334–341. képei két egymást erősítő, de
valójában független felismerési hibát mutattak:

1. A havas fennsíkon álló `1.92K` boss továbbra is teljes HP-val, a zárt átjáró
   túloldalán volt, miközben a játékos közelében egy 1–15 HP-s kis tábori cél
   jelent meg. A régi, laza OCR-utótagos célazonosság ezt a kis célpontot a korábbi
   boss folytatásának tekintette, és hamis `1920→2` bossprogressziót jelentett.
2. A játékos hiteles maximuma 778. A 337. képen az aktuális OCR 778, a 338–340.
   képen a stilizált szám ugyanazon állapotban 779-nek olvasódott, majd a 341.
   képen ismét 778 lett. Jutalom, `+1` effektus és tartós állapotváltozás nem volt.
   A korábbi két-/háromképes kisnövekedés-őr ezt tévesen elmentette.

## Nyers ellenőrzési sor

| Kép | OCR HP | Megjegyzés |
|---:|---:|---|
| 337 | 778 | hiteles teljes HP |
| 338 | 779 | azonos képi állapot, első zajminta |
| 339 | 779 | közeli kis cél látszik |
| 340 | 779 | harmadik zajminta |
| 341 | 778 | visszatérés jutalom nélkül |

Ez nem játékmechanika és nem valódi +1 fejlődés. A `docs/bot-state.json` tartós
maximuma ezért vissza lett állítva 778-ra.

## Programdöntések

- A kontrollált bosspróba OCR-utótagos tartalék azonossága csak olyan aktuális
  célra érvényes, amely maga is bossbizonyítékot hordoz, vagy legalább 800 kijelzett
  HP-jú. Az 1–15 HP-s normál cél többé nem örökölheti a bosspróbát.
- További élő ellenpélda miatt a konkrét, `max(250, kezdő HP / 8)` alatti HP-jelölt
  akkor is kizárt, ha a szomszéd boss ROI-ja átmenetileg hamis bossbizonyítékot és
  OCR-utótagot ad neki. Részletek: `152-deep-mines-kuldetesoverlay-es-hamis-1-hp.md`.
- A `+1`, `+2` vagy `+3` méretű új maximumot öt egymást követő, friss, aktuális
  numerikus OCR-képnek kell igazolnia. Memória, pixelcsík vagy megszakadó sor nem
  számít bele.
- A nagy, közvetlen jutalomlépcsők korábbi elfogadási szabálya változatlan; az új
  szigorítás a tipikus 778/779 karakteralak-zajt célozza.

## Regresszió

A `docs/runs/20260829-133510-replay` ugyanazon 337–342. képsort az öt képes szabállyal
újraelemezte. A három 779 után a 778 megszakította a megerősítést, ezért nem jött
létre új maximumszekvencia. A tartós maximum 778 maradt.

## Következmény a tudásbázisra

- Az `1.92K` boss nem szenvedett bizonyított sebzést ebben a jelenetben.
- A karakter maximális HP-ja továbbra is 778.
- A kis tábori ellenfél pontos típusa és jutalma külön felderítési kérdés; nem
  használható a zárt kapu túloldali boss harci eredményének bizonyítékaként.
