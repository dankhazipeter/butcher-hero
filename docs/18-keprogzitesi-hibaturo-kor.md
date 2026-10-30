# Képrögzítési hibatűrés és nem támogatott pixelzuhanás

Ez a lap két olyan felügyeleti hibát rögzít, amely nem játékstratégiai tévedésből, hanem
a visszacsatolási lánc átmeneti bizonytalanságából keletkezett.

## Hamis, közeli támadó nélküli pixelzuhanás

A `221559-play` teljes 320 HP-n 29–31%-os pixelarányt adott, majd a következő mozgás után
ismét 320/100% lett. A töredék csík képeken a játékos OCR-régiójában időzítő volt, és
egyetlen vörös HP-csík sem feküdt 170 px-en belül. A `221123/frame-00090.png` hasonlóan
285 HP-ról hamis 25%-ot adott, közeli célcsík nélkül.

Aktuális bizonyítási szabály:

- legalább 85%-os numerikus memória;
- nincs friss elfogadott numerikus mérés;
- a pixel legalább 20 százalékponttal alacsonyabb;
- nincs 170 px-en belüli vörös célcsík;
- ekkor egy képre a numerikus memória győz, és az eredet őrzött memória.

A `222028-replay` a hamis 25%-os képet 89%-on, normál járőrben tartja. A
`214936/frame-00045.png` valódi sérülésénél közeli vörös csíkok vannak, ezért a 31%-os
pixelmérés továbbra is azonnali visszavonulást indít.

## ScreenCaptureKit 1004 és belső újrapróbálás

A `221559-play` előtti járat egyszeri `CoreGraphicsErrorDomain error 1004` miatt kilépett.
Ez felügyeleti szempontból hibás terminális viselkedés: a játékablak néhány másodperccel
később ismét rögzíthető volt.

Az új `play` ciklus:

1. külön számlálja az egymást követő képrögzítési hibákat;
2. 0,75 másodpercről fokozatosan legfeljebb 5 másodpercig vár;
3. nem lépteti a frame- vagy stratégiai állapotot;
4. ugyanabban a folyamatban korlátlanul újrapróbál;
5. az első sikeres képnél kiírja, hány átmeneti hiba után állt helyre.

A jelenlegi `222253-play` futás 86 400 másodperces technikai kerettel fut. A projekt
küldetése változatlan: ezt is folyamatosan figyelni kell, és csak a felhasználó kifejezett
utasítása állíthatja le végleg.
