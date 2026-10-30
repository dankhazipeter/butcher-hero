# HP-mérési eredet és küldetés-oktató állapot

Ez a fejezet a `214936-play` több száz képes regenerációs beragadását és a vele egy
képen megjelenő `0/7` küldetésbuborékot választja szét. A fő tanulság: az állapotérték
mellett a mérés **eredetét és frissességét** is tárolni kell.

## Incidens és képi igazság

- A napló számszerű HP-ja 120-ról 299-ig emelkedett, de a taktikai arány sok képen
  31%, később 79% maradt. Emiatt a 85%-os regenerációs mód nem oldott le.
- A `214936-play/frame-00245.png` valójában teljes zöld csíkot és tiszta `306` HP-t
  mutatott. A képen tehát nem regeneráció, hanem teljesen gyógyult, normál játéknézet volt.
- Ugyanitt megjelent a „Collect all gems to unleash the Titan's power” `0/7` buborék.
  Ez együtt járt a beragadással, de nem okozta: a javított bot első swipe-ja működött,
  és a buborék `215627-play/frame-00005.png`-re külön tap nélkül eltűnt.

## Gyökérokok

1. A játékos-HP parser 300-nál felső korlátot húzott, ezért a valódi 306 nem lehetett
   jelölt, és a 299-es temporális emlék ragadt bent.
2. A teljes csík tanult szélességét egy összeolvadt zöld UI-komponens 58-ról kb. 73 px-re
   növelte. A valós teljes csík ebből csak 79%-nak látszott.
3. A taktikai arány a numerikus és pixelérték minimuma volt. Ez biztonságosnak tűnt, de
   a rossz pixelmérés tartósan felülírta a sok egymást követő tiszta OCR-t.
4. Az egész számhoz tapadt találati szám (`2181`) több jelöltet adott. A minden többes
   jelöltre alkalmazott pixel-előszűrés a helyes 218 helyett 81-et hagyott meg.

## Aktuális mérési hierarchia

1. Ha az aktuális képen van elfogadott numerikus jelölt, az adja a taktikai HP-arányt.
2. Ha a szám hiányzik vagy a nagyugrás-védelem elutasítja, a pixelcsík a tartalék.
3. Ha pixelmérés sincs, az utolsó numerikus memória használható, de eredete
   `ocr-memory`, nem friss mérés.
4. A pixel-nagyságrend csak a bizonyított tizedes csíkszél-hibánál (`188.8→88.8`)
   választ a jelöltek között; sima összeragadt egész számon nem.
5. A parser 999-ig fogad játékos-HP-t, de az aktuális tanult maximum +60 szűrője és a
   legfeljebb +15-ös hiteles maximumlépés megmarad.
6. A fizikailag életszerű teljes játékoscsík felső szélessége a kép 10%-a.
7. Ha legalább 85%-os numerikus memória mellett nincs friss szám, a pixel 20
   százalékpontnál nagyobb esését csak 170 px-en belüli vörös csík támogatásával fogadjuk
   el. Ez az `ocr-memory-no-threat-guard`; timeres OCR-nél külön
   `ocr-memory-timer-guard` forrásnévvel naplózódik.
8. `m`, `s` vagy `h` időegységet tartalmazó OCR-sor nem ad numerikus jelöltet. A
   `222253-play` bizonyította, hogy a 330 HP és 3m56s kör összeragadhat `83m 565`, majd
   `33m 56s` alakra; ezekből a 83/56 hamis kritikus érték volt.

Az `events.jsonl` új diagnosztikai mezői:

- `playerPixelHealthFraction`: a zöld csík önálló becslése;
- `playerHealthFraction`: a stratégiát ténylegesen vezérlő arány;
- `playerHealthSource`: `ocr-current`, `pixel-fallback`, `ocr-memory` vagy `unavailable`.

## Ellenőrzés és új játékismeret

A `215607-replay` a korábbi képeken 126/41%, 143/47%, 209/68%, 256/84%, 271/89%,
284/93%, végül 306/100% értékeket adott. A stratégia 85% fölött ismét felderített.

A `215627-play` első élő szakasza ezután:

- mozgással eltüntette a nem modális `0/7` buborékot;
- legyőzött egy 4-szíves, 43 HP-s humanoidot;
- a teljes HP 306-ról 310-re nőtt;
- 32-es normál találati számot mutatott.

A +4 max-HP jutalom erős következtetés az ikon, a cél eltűnése és a pontos maximumlépés
alapján; közvetlen `+4` lebegő felirat híján még egy ismétlés szükséges a „biztos” címkéhez.
