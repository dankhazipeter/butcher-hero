# 27,7K-s lovag 5610 maximumon; harci HP-felismerés — 2026-09-19

## Valódi kísérlet

`docs/runs/20260919-125457-a8e9024a-play`:

- 6–11: 1,28K növény és két2,49K őr kontaktusa. A 11. képen közvetlen +15,
  két eltűnt őr és időzítők; a maximum5580→5610. A kis őrök nem legyőzhetetlenek.
- 16 / 10:55:17 UTC: 27,7K lovag próbaindítás, saját5,61K, Bat11+Venom13.
- 21 / 10:55:23: ellenfél26,9K, saját képi5,31K, de pixelhiba23%.
- 44 / 10:55:33: ellenfél15,8K, saját képi3,04K; a napló még3,57K-t tartott.
- 60 / 10:55:40: ellenfél8,04K, saját képi1,22K.
- 67: saját733; 76–79: egyértelmű YOU DIED. 106: újraéledve1,87K a medencénél.

Biztos vereség, legalább19,66K kiosztott sebzés. A 27,5K sáv új bizonyított
vesztési maximuma5610; az alap20%-os újrapróbakapu6732. Ez nem győzelmi
küszöb. Taktikai javítás csak külön mért indokkal jogosít korábbi kísérletre.

## Feltárt hibák

1. A kis3,06K őrre írt40képes, takartcsíkos álló támadási kivétel a27,7K lovagra
   is érvényesült. Régi saját HP-ból túl sokáig feltételezett biztonságos harcot.
2. A tág saját-OCR-régióban a szám gyakran olvasható volt, de a 60-nál nagyobb
   eséshez három, egymáshoz25HP-n belüli kép kellett. A320-as találatokkal
   változó több ezres HP ezt nem teljesítette; a memória elöregedett.
3. A zöldcsík első keskeny részletét teljes szélességnek tanulta, így egy
   egyképes replay alacsony HP-n is100%-os pixelértékkel indulhatott.
4. A Titan-feladat távol fent volt, mégis globálisan tiltotta a saját HP OCR-jét.
   A 106. kép tiszta1,87K-ja ellenére733 maradt a memória. Újraéledéskor egy
   100%-os pixelpillanat már északi útvonalat is indított; ez nem megengedett.

## Javítások

- Saját zöldcsík-sor külön, háromszoros nagyított OCR-je; egyetlen tiszta
  numerikus sor esetén az elsődleges. Távoli questbuborék ezt nem tiltja;
  valódi takarás, tört számláló, inventory továbbra tiltott.
- A teljes csíkszélesség legalább a képszélesség9%-a; első részlet nem lesz100%.
- Tiszta lokalizált OCR-nél a nagy esés háromképes konszenzusa a maximum8%-án
  belüli változó értékeket is összekapcsolja, nem csak25HP-t.
- A40képes álló kivétel legfeljebb5K őrre marad. Sebzett nagy humanoid
  három takart kép után megszakítja a vak harcot és hatswipe-os távolodást indít.
  Kritikus takarás nem állíthatja meg ezt a már megkezdett menekülést.
- YOU DIED után külön állapot minden útvonalnál előbb vár friss numerikus90%-ra.

Az élő ellenőrzés és a teljes képsoros regresszió következik; a változtatások
önmagukban még nem bizonyítják, hogy a nagy lovag legyőzhető.

## Ellenőrzés és további pontosítás

`130039-96a63fca-replay` teljes165képes visszajátszás: a nagy boss takarásakor
megszakad a harc; a halál után nincs északi útvonalindítás. A106. kép1870,
a164. kép3440 aktuálisHP; a globális buborék miatti beragadás megszűnt.
`130048-7f1f17a1-observe/1`: élőben friss5,61K teljes sajátHP, biztonságos továbbindulás.

A gyors320-as találatsorhoz a háromképes kompromisszum sem elég. Egyetlen
szigorúan numerikus, tizedes-K alak **a külön nagyított saját zöldcsíksorban**
most közvetlen aktuális mérés. Más OCR továbbra konszenzust kér; maximumfejlődés
továbbra külön ellenőrzött. A nyers lokalizált sor a JSON-ban is megmarad.
`130240-3fd8f5f5-replay`: a44. kép azonnal3040 OCR-current.
`130254-2d574d17-replay`: a106. kép azonnal1870, regenerációs várakozás.
