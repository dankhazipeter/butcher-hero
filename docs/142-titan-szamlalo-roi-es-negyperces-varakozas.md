# Titan-számláló ROI és a négyperces téves várakozás

## Élő anomália

A `20260829-124335-play` új folyamatban ismét a lila Titan-oltárhoz ért. A 22–488.
esemény között a bot 35%-os HUD-biztonság miatt passzívan várt, bár a mentett képeken
a teljes játéktér, az oltár és a feladatbuborék végig látható volt.

A 22. esemény OCR-je stabilan ezt tartalmazta:

- `Collect all gemsito unleash the`;
- `Titan's power`;
- a képen vizuálisan látható `0/7`, amelyet az OCR-régió nem adott vissza.

Ez nem átvezető, halál vagy külső felület volt. A feladatbuborék a karakterrel együtt
lejjebb került, ezért a `0/7` sor a Titan számára kijelölt, kép-magasság 23%-os OCR-ROI
alsó szélére vagy azon kívülre esett. A felismerő kizárólag `/7` mellett fogadta el a
Titan-állapotot, így a jól olvasott, egyedi feladatmondat ellenére várakozott. A világ
kb. négy perc után azért tért vissza 100%-os HUD-ra, mert a buborék végül eltűnt; ez
nem a régi szabály helyességét, hanem elvesztegetett játékidőt bizonyít.

## Javítás

A Titan OCR-régió magassága a kép 23%-áról 29%-ára nőtt. A felismerés most két biztos
utat fogad el:

1. `Titan` vagy `power` együtt a `gem` és `collect`/`unleash` utasítással;
2. `/7` számláló együtt legalább egy Titan-/gem-kulcsszóval.

A teljes `Collect all gems to unleash the Titan's power` mondat egyedi játékrendszer-
azonosító, ezért önmagában erősebb bizonyíték, mint a függőlegesen mozgó számláló egy
karaktere. A HP-vétó nem lazult: ha a buborék eltakarja a játékoscsíkot, a bot továbbra
sem fogad kétes numerikus HP-t, csak a HUD-ot tekinti biztonságosnak és kimozog.

## Regresszió és élő folytatás

A `20260829-125030-replay` a korábbi 22–40. esemény tíz mentett képét játszotta vissza.
Mind a tíz 100%-os HUD-biztonságot és normál felderítő swipe-ot adott; egyik sem állt
meg, és egyik sem gyártott hamis HP-t a buborékból.

Release build után a felügyelet `20260829-125042-play` néven azonnal folytatódott.
A folyamat első képe 778 HP-t és normál lila-landmark navigációt mutatott.

## Taktikai következmény

Ismert, egyedi feladatmondatnál a strukturált szöveg fontosabb lehet, mint egyetlen
számláló OCR-je. A botnak ilyenkor folytatnia kell a világmozgást, miközben a takart
harci statot konzervatívan memóriában tartja. A tartós, változatlan HUD-várakozást
mindig képpel kell auditálni; nem szabad automatikusan átvezetőnek nevezni.
