# 4.31K óriásfa: burst, gyógyulás és visszatérés

## A korábbi élő próba újraértékelése

A `20260829-130403-play/frame-00224.png` és `frame-00228.png` közti képsor nem
egyszerű célvesztés volt. A második képen a közelharc közvetlen adatai láthatók:

- óriásfa: `4.31K → 2.18K`, tehát kb. 2130 HP sebzést vittünk be;
- játékos: `778 → 317`, azaz legalább 461 HP-t vesztett;
- két külön lebegő `170` sebzésszám látható a játékos mellett;
- az óriásfa statikonja továbbra is `500` szív;
- mindez két végrehajtott közelítő swipe időablakában történt.

Biztos tény, hogy a jelenlegi 693 DPS build nagyon gyorsan felezi a 4.31K-s célt,
de a cél is nagy, sorozatos sebzést oszt ki. A pontos 2130/461 csere nem feltétlenül
egyetlen támadási ciklus: a két mentett kép között több automatikus ütés is
megtörténhetett.

## Feltárt állapotkezelési hibák

Az élő bot a 317-es számot ugyan látta, de a nagy egyképes OCR-esést még nem
fogadta el. A zöld csík 33%-ot mutatott, ezt viszont a „távoli, fenyegetés nélküli
pixeles esés” őre késleltette, mert az óriásfa csíkja közelharcban rövid időre
kiesett a célobjektum-detektorból. Emiatt normál felderítő swipe született az
egyértelmű visszavonulás helyett.

További rés volt, hogy a bosspróba a következő képen a régi 778-as HP-memória
alapján túl korán visszafordulhatott volna. Végül a célazonosság sem számolhatott
azzal, hogy ugyanazon ellenfél tényleges HP-felirata 4310-ről 2180-ra csökken.

## Javított taktika

Az új kontrollált nagyellenfél-ciklus:

1. teljes, friss HP-ról rövid közelítés és automatikus sebzésburst;
2. aktív bosspróba alatt minden nagy pixeles HP-esés azonnal valódi sebzésjel,
   akkor is, ha a boss csíkja épp egy képre eltűnik;
3. friss sebzés és 82% alatti HP esetén azonnali hosszú kifelé swipe;
4. az OCR-memória nem oldhatja fel ezt a visszavonulást;
5. új támadási burst csak friss numerikus, legalább 85%-os HP után indulhat;
6. a csökkenő boss-HP ugyanahhoz a célhoz tartozhat, ha a test-/statikon-aláírás,
   az irány és a közeli geometria is egyezik;
7. 45% továbbra is a végső vészkapu, de az új rendszer célja, hogy ezt ne érjük el.

## Regresszió és élő folytatás

A `20260829-132011-replay` eredménye:

- 224: pontos 4310-es próbaindítás;
- 226: további izoláló közelítés;
- 228: 33%-os csík alapján 0,65 másodperces azonnali visszavonulás;
- 230: a memóriából tartott „100%” ellenére ugyanaz a visszavonulási irány marad.

A regresszió tehát lezárja a két közvetlen hibát: nem ignorálja a bosskontaktusban
mért csíkzuhanást, és nem fordul vissza memóriából. A javított élő folyamat
`20260829-132032-play` néven indult, minden képet ment a következő boss-találkozás
részletes kiértékeléséhez.

## Nyitott kérdések

- Hány burst szükséges a maradék 2.18K eltávolításához?
- Az óriásfa regenerálódik-e, amikor a játékos eltávolodik?
- A látható 170 fix találati sebzés, vagy több támadástípus egyike?
- A `500` szív valóban +500 maximális HP-t ad-e, és érvényesül-e rá a +1%-os
  ládabónusz?
- A győzelem után milyen cooldown és újratermelődési idő indul?
