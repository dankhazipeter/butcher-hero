# Újabb +20, 747 HP és a hetedik fegyverpéldány

## Közvetlen +20 — `20260829-045414-play`

A javított, folyamatos élő futás elején a bot egy 431 HP-s, piros 20-szívikonú fát
talált. A célkövetés mért távolságai 282→235→222→220→204, majd újrafelvétel után
296→226→172→125 pixel voltak. A türkiz küldetésút rövid időre közbelépett, de a bot
visszavette a kiemelt szívfát és támadási távolságba ért.

- `frame-00026`: a 431 HP-s, 20-szíves fa közvetlenül a 727 HP-s játékos mellett;
- `frame-00028`: a fa eltűnt, helyén 4m 0s újratermelődési kör, továbbá 442-es
  fejsze- és 36-os nyílikonos találati szám;
- `frame-00030`: közvetlen zöld `+20` piros szíveffektus és 747 kijelzett HP;
- `frame-00032`: tiszta 747 OCR, amely a tartós `bot-state.json` maximumát is
  frissítette.

Ez a negyedik dokumentált 431 HP körüli, 20-szíves célminta, és újra közvetlenül
igazolja, hogy a szívikon száma a maximális HP-hoz adódik. A hiteles aktuális maximum
747.

## A megelőző +1 fejsze utóhatása

A `044329-play/frame-00018` és `frame-00022` képein a zöld fegyverkártya számlálója
még 6 volt. A 291 HP-s fa 580-as találat után zöld `+1` kékfejsze-effektust adott.
A következő élő folyamat `045414/frame-00026` képén ugyanez a kártya már 7-et mutat.
Mivel a két kép között más jutalmazott harc nem volt, erős, közvetlen képsorrendi
következtetés, hogy ez a +1 egy újabb fegyverpéldányt adott, és a kártya frissítése
csak az effektus után vált láthatóvá.

A 20-szíves fa ölési képén a 442-es fejszeérték 55-tel nagyobb a korábbi két biztos
387-es normál értéknél. A 36-os nyílikonos szám a korábbi 24 pontos érték 1,5-szerese.
Nyitott, hogy a 442 biztosan normál találat-e, és hogy a 36 külön fegyver kritikus
találata-e. Biztosan csak az állítható, hogy a hetedik kártyapéldány után mindkét
látható érték magasabb mint a korábbi mintában; a pontos sebzésképlet további tiszta
találati képeket igényel.

## Útvonalteszt a fejlődés után

A 107–129. esemény között a karakter a zöld tábor sátor–kerítés sarkánál ugyanazt a
minimapirányt tartotta, és hat tényleges swipe után változatlan maradt a háttér. A
hatfázisú statikus kiszabadítás 129-nél merőleges átlóra váltott. Az első fázis a
sátor mellől a köves úthoz, a második a nyílt, csontokkal jelölt mezőre vitte a
karaktert (`frame-00128→00138→00148`). Ez élőben igazolja, hogy a többfázisú kerülő
nemcsak a korábbi híd–fa zsebben, hanem a sátor–kerítés sarokban is kiszabadít.

