# Képszéli 1-esből 291: célazonosság-javítás

## Incidens — `20260829-041440-play`

A 283–292. eseményben egy ismert, 1-fejszés, 291 HP-s fenyő a kép felső széléről
úszott be. Az első részleges képen a vörös csík fölötti OCR-régió még a macOS
ablakcíméből olvasott `1GZI` / `hew RPG` töredéket, így ideiglenesen 1 HP-s célt
hozott létre. Amikor a következő képeken a nyers cél-OCR már tisztán `291` volt, a
képernyőpozíció-közeli célmemória ugyanannak az entitásnak hitte, és a „cél HP-ja nem
nőhet” őr továbbra is 1-en tartotta. A kék fejsze alakját a statikon 1-eséhez ragasztó
OCR emellett hamis 16-os szintet adott.

A hiba nem okozott veszélyes harcot: a test fának bizonyult, a közelítés kétszer
elakadt, majd a hosszú kiszakadás elindult. Viszont a 291+fa elérhetetlen-cél aláírása
helyett 1+fa került volna hűtésbe, ezért a visszatérő cél felismerése gyengült.

## Javítás

- A célstat csak a közvetlenül bizonyított `1/2/3/4/5/10/20` értékek egyike lehet.
  A 16-os fejsze-összeragadás nem lesz célhozam; a 100+ nyers értékeket a külön
  bossőr továbbra is látja.
- Ha a jelenlegi nyers HP több mint 40-nel nagyobb a célmemóriánál, elsőre továbbra
  is a régi érték marad. Ha ugyanaz a nyers nagyobb HP a következő képen megismétlődik,
  új célazonosságot igazol és feloldja a lefelé ragasztást.

## Regresszió — `20260829-042202-replay`

A ritkított teljes replayben:

- 142. replaykép: részleges képszéli cél, ideiglenes HP 1;
- 143.: első tiszta nyers `291`, még óvatosan HP 1;
- 144.: második tiszta `291`, kijelzett HP már 291;
- 145.: a valódi 1-es statikon is rögzül;
- a következő képeken a 291 HP és 1-es stat stabil marad, majd a normál elérhetetlen-
  cél kiszakadás indul.

Az új élő build `20260829-042252-play` néven fut 727-es tartós maximumállapottal.

