# Respawnkör HP-takarás: 467-ből 7

## Első jel — `20260829-022045-play/frame-00178.png`

Egy 34 másodperces fekete respawnkör részben ráfedett a játékos zöld HP-csíkjára.
A pixeldetektor 61%-ot mért, miközben az előző és a következő friss OCR 467/467 volt,
és a legközelebbi cél több mint 300 px-re állt. A régi 10 százalékpontos pixelkapu
ezt valódi sebzésnek tekintette, ezért a bot egy fölösleges menekülő swipe-ot tett.

## Súlyosabb közös takarás — `frame-00238→00250`

Az ötpereces kör ezután teljesen a játékos fölé került:

- a `frame-00238.png` még tiszta, teljes 467 HP-t mutat;
- a `frame-00240.png` körének fekete teste a zöld csík kb. 85%-át eltakarja;
- a játékos száma a takarásban 467 helyett időnként csak 7/37;
- a 239–278. élő esemény ezért hamis 13% pixelt és 1–8% numerikus HP-t váltogatott;
- a képen nincs sérülési animáció, a karakter áll, az új folyamat pedig rögtön ismét
  több friss 467/467 OCR-t adott.

Ez biztos közös mérési hiba, nem valódi 467→7 sebzés és nem halál/újraéledés.

## Javítás

1. Távoli fenyegetés és közeli támadó nélkül a pixeles nagy esés első képe csak függő
   jelölt. Második, hasonló pixeles kép kell a sebzésemlékhez; közeli támadónál nincs
   késleltetés.
2. A `nearbyRespawnTimer` vagy a játékos OCR-régiójában látható `m/h` timerjel mellett
   a maximális HP 35%-a alatti OCR nem gyűjthet háromképes nagy-esés bizonyítékot.
3. Pixel és OCR nagy esése önmagában nem két független jel: ugyanaz a fekete kör mindkét
   mérést egyszerre takarhatja. A korábbi azonnali pixel+OCR elfogadás megszűnt.
4. Timerrel igazolt nagy pixeles eltérésnél a taktika az utolsó hiteles numerikus
   maximumot használja; friss tiszta OCR, közeli támadó és valódi sebzésőr megmarad.

## Regresszió

- `20260829-022735-replay`, régi bináris: 15%-os kritikus várakozás, majd 37 HP-s
  menekülés.
- `20260829-022924-replay`, köztes javítás: a timeres képek egy része már 467-es memória,
  de az első 15% még kritikus állapotot állít, és a végén 37-et elfogad.
- `20260829-023152-replay`, végleges javítás: az első 15%-os képen sem állít kritikus
  állapotot; a timeres képeken 467-es memóriát használ, a záró takart képen pedig
  függő pixeljel mellett folytatja a navigációt. Nincs hamis 37 HP és nincs menekülés.
- `20260829-023202-replay`: a külön `94.1→94` cél-HP regresszió is változatlanul jó.
- Élő ellenőrzés: `20260829-023210-play`; a következő ismételt overlay külön ellenőrzési pont.
