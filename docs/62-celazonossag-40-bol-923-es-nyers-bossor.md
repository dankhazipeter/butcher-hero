# Célazonosság-csere: 40-ből 923 és nyers bossőr

## Élő anomália — `20260829-032640-play`

A `frame-00058→00064` képeken egy 4-fejszés fa fölött az OCR hét egymást követő
eseményben helyesen `923` HP-t olvasott. A strukturált `Target.displayedHP` mégis 40
maradt, a `bossEvidence` pedig hamis volt. A bot ezért a 923-as fát normál célként
követte 180 pixelre.

## Ok

Az időbeli célmemória képi x/y közelséggel párosít. Kameramozgáskor egy korábbi 40 HP-s
cél és az új 923 HP-s fa 85 pixelen belüli képernyőpozícióba került. A „cél HP-ja nem
ugorhat 40-nél többet” simítás helyesen védi a harc alatti OCR-zajtól, de célcsere
esetén ráörökítette a régi 40-et az új testre.

## Javítás

A `bossEvidence` most a simított `displayedHP` mellett a tizedes-helyreállítás utáni
aktuális `detectedHP` értékét is vizsgálja. Így a friss 923 azonnal boss, akkor is, ha
a célazonossági simítás még 40-et tart. A korábbi `94.1→941` normálcél-védelem nem
romlik: az azonos, rövidülő csíkot a kód előbb 94-re állítja vissza, és csak ezután
alkalmazza a nyers bossőrt.

## Regressziós feltételek

- a `032640-play/frame-00064` azonnali 923-as bossmenekülést adjon;
- a `021337-play/frame-00034` 94.1 HP-s kaktusz ne legyen boss;
- az 1.22K és 67.5K korábbi bossképek továbbra is menekülést adjanak;
- a 923-as cél ne kerülhessen a `safeTargets` listába akkor sem, ha a naplózott,
  simított HP átmenetileg 40.

## Regresszió eredménye

A `033019/033032-replay` eredménye: a 923-as kép azonnal menekül, a 94.1-es teljes
idősor `136→115→94→78` normál cél marad, az 1.22K és 67.5K minták továbbra is
bossmenekülést adnak. Az egyképes, előzmény nélküli 94.1 minta konzervatívan bossnak
látszik; az élő idősor helyreállítása a bizonyított működési út.
